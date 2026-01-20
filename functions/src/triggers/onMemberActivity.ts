/**
 * 회원 활동 감지 Firestore 트리거
 * 체성분 기록, 식단 기록 등이 추가될 때 해당 회원의 트레이너에게 인사이트 생성
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// 인사이트 생성 쿨다운 (같은 트레이너에 대해 너무 자주 생성하지 않도록)
const INSIGHT_COOLDOWN_HOURS = 6;

/**
 * 트레이너의 마지막 인사이트 생성 시간 확인
 */
async function shouldGenerateInsight(trainerId: string): Promise<boolean> {
  const cooldownTime = new Date();
  cooldownTime.setHours(cooldownTime.getHours() - INSIGHT_COOLDOWN_HOURS);

  const recentInsights = await db
    .collection("insights")
    .where("trainerId", "==", trainerId)
    .where("createdAt", ">", admin.firestore.Timestamp.fromDate(cooldownTime))
    .limit(1)
    .get();

  return recentInsights.empty;
}

/**
 * 회원 ID로 트레이너 ID 조회
 */
async function getTrainerId(memberId: string): Promise<string | null> {
  const memberDoc = await db.collection("members").doc(memberId).get();
  if (!memberDoc.exists) {
    return null;
  }
  return memberDoc.data()?.trainerId || null;
}

/**
 * 체성분 기록 추가 시 인사이트 생성 트리거
 */
export const onBodyRecordCreated = functions
  .region("asia-northeast3")
  .firestore.document("body_records/{recordId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const memberId = data?.memberId;

    if (!memberId) {
      functions.logger.warn("[onBodyRecordCreated] memberId가 없음", {
        recordId: context.params.recordId,
      });
      return null;
    }

    // 트레이너 ID 조회
    const trainerId = await getTrainerId(memberId);
    if (!trainerId) {
      functions.logger.warn("[onBodyRecordCreated] trainerId를 찾을 수 없음", {
        memberId,
      });
      return null;
    }

    // 쿨다운 체크
    const shouldGenerate = await shouldGenerateInsight(trainerId);
    if (!shouldGenerate) {
      functions.logger.info("[onBodyRecordCreated] 인사이트 쿨다운 중", {
        trainerId,
        memberId,
      });
      return null;
    }

    functions.logger.info("[onBodyRecordCreated] 인사이트 알림 생성", {
      memberId,
      trainerId,
      recordId: context.params.recordId,
    });

    try {
      // 간단한 인사이트 알림 생성 (체성분 기록됨)
      const memberDoc = await db.collection("members").doc(memberId).get();
      const memberName = memberDoc.data()?.name || "회원";

      await db.collection("insights").add({
        trainerId,
        memberId,
        memberName,
        type: "recommendation",
        priority: "low",
        title: `${memberName}님이 체성분을 기록했습니다`,
        message: `${memberName}님이 새로운 체성분 데이터를 기록했습니다. 변화 추이를 확인해보세요.`,
        actionSuggestion: "체성분 변화 그래프를 확인하고 피드백을 제공해주세요.",
        isRead: false,
        isActionTaken: false,
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        ),
      });

      functions.logger.info("[onBodyRecordCreated] 인사이트 생성 완료", {
        memberId,
        trainerId,
      });
      return { success: true, memberId, trainerId };
    } catch (error) {
      functions.logger.error("[onBodyRecordCreated] 인사이트 생성 실패", {
        memberId,
        trainerId,
        error: error instanceof Error ? error.message : error,
      });
      return { success: false, error };
    }
  });

/**
 * 식단 기록 추가 시 인사이트 생성 트리거
 * (하루에 3끼 이상 기록 시에만 생성)
 */
export const onDietRecordCreated = functions
  .region("asia-northeast3")
  .firestore.document("diet_records/{recordId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const memberId = data?.memberId;

    if (!memberId) {
      functions.logger.warn("[onDietRecordCreated] memberId가 없음", {
        recordId: context.params.recordId,
      });
      return null;
    }

    // 오늘 식단 기록 수 확인
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    const todayRecords = await db
      .collection("diet_records")
      .where("memberId", "==", memberId)
      .where("recordedAt", ">=", admin.firestore.Timestamp.fromDate(today))
      .where("recordedAt", "<", admin.firestore.Timestamp.fromDate(tomorrow))
      .get();

    // 3끼 이상 기록했을 때만 인사이트 생성
    if (todayRecords.size < 3) {
      functions.logger.info("[onDietRecordCreated] 식단 기록 부족으로 스킵", {
        memberId,
        todayRecords: todayRecords.size,
      });
      return null;
    }

    // 트레이너 ID 조회
    const trainerId = await getTrainerId(memberId);
    if (!trainerId) {
      functions.logger.warn("[onDietRecordCreated] trainerId를 찾을 수 없음", {
        memberId,
      });
      return null;
    }

    // 쿨다운 체크
    const shouldGenerate = await shouldGenerateInsight(trainerId);
    if (!shouldGenerate) {
      functions.logger.info("[onDietRecordCreated] 인사이트 쿨다운 중", {
        trainerId,
        memberId,
      });
      return null;
    }

    functions.logger.info("[onDietRecordCreated] 인사이트 생성 시작", {
      memberId,
      trainerId,
      todayRecords: todayRecords.size,
    });

    try {
      const memberDoc = await db.collection("members").doc(memberId).get();
      const memberName = memberDoc.data()?.name || "회원";

      await db.collection("insights").add({
        trainerId,
        memberId,
        memberName,
        type: "recommendation",
        priority: "low",
        title: `${memberName}님이 오늘 ${todayRecords.size}끼를 기록했습니다`,
        message: `${memberName}님이 오늘 하루 식단을 꾸준히 기록하고 있습니다. 식단 분석 결과를 확인해보세요.`,
        actionSuggestion: "식단 분석 결과를 확인하고 영양 조언을 해주세요.",
        data: {
          mealsToday: todayRecords.size,
        },
        isRead: false,
        isActionTaken: false,
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 3 * 24 * 60 * 60 * 1000)
        ),
      });

      functions.logger.info("[onDietRecordCreated] 인사이트 생성 완료", {
        memberId,
        trainerId,
      });
      return { success: true, memberId, trainerId };
    } catch (error) {
      functions.logger.error("[onDietRecordCreated] 인사이트 생성 실패", {
        memberId,
        trainerId,
        error: error instanceof Error ? error.message : error,
      });
      return { success: false, error };
    }
  });

/**
 * 커리큘럼 완료 시 인사이트 생성 트리거
 */
export const onCurriculumCompleted = functions
  .region("asia-northeast3")
  .firestore.document("curriculums/{curriculumId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // 완료 상태로 변경되었는지 확인
    if (before.isCompleted === true || after.isCompleted !== true) {
      return null;
    }

    const memberId = after.memberId;
    if (!memberId) {
      return null;
    }

    // 트레이너 ID 조회
    const trainerId = await getTrainerId(memberId);
    if (!trainerId) {
      functions.logger.warn("[onCurriculumCompleted] trainerId를 찾을 수 없음", {
        memberId,
      });
      return null;
    }

    // 쿨다운 체크
    const shouldGenerate = await shouldGenerateInsight(trainerId);
    if (!shouldGenerate) {
      functions.logger.info("[onCurriculumCompleted] 인사이트 쿨다운 중", {
        trainerId,
        memberId,
      });
      return null;
    }

    functions.logger.info("[onCurriculumCompleted] 인사이트 생성 시작", {
      memberId,
      trainerId,
      curriculumId: context.params.curriculumId,
    });

    try {
      const memberDoc = await db.collection("members").doc(memberId).get();
      const memberName = memberDoc.data()?.name || "회원";

      await db.collection("insights").add({
        trainerId,
        memberId,
        memberName,
        type: "performance",
        priority: "medium",
        title: `🎉 ${memberName}님이 커리큘럼을 완료했습니다!`,
        message: `${memberName}님이 "${after.title || "PT 커리큘럼"}"을 완료했습니다. 다음 커리큘럼을 준비해주세요.`,
        actionSuggestion: "새로운 커리큘럼을 생성하거나 회원의 목표를 재설정해보세요.",
        data: {
          curriculumId: context.params.curriculumId,
          curriculumTitle: after.title,
          sessionNumber: after.sessionNumber,
        },
        isRead: false,
        isActionTaken: false,
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
        ),
      });

      functions.logger.info("[onCurriculumCompleted] 인사이트 생성 완료", {
        memberId,
        trainerId,
      });
      return { success: true, memberId, trainerId };
    } catch (error) {
      functions.logger.error("[onCurriculumCompleted] 인사이트 생성 실패", {
        memberId,
        trainerId,
        error: error instanceof Error ? error.message : error,
      });
      return { success: false, error };
    }
  });
