import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

/**
 * 매주 월요일 오전 9시 주간 리포트 푸시
 * Cloud Scheduler로 실행
 * 트레이너에게 담당 회원들의 주간 요약 알림
 * 회원에게 지난주 활동 요약 알림
 */
export const sendWeeklyReport = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 9 * * 1") // 매주 월요일 오전 9시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    try {
      // 지난주 날짜 범위 계산
      const now = new Date();
      const lastWeekStart = new Date(now);
      lastWeekStart.setDate(lastWeekStart.getDate() - 7);
      lastWeekStart.setHours(0, 0, 0, 0);

      const lastWeekEnd = new Date(now);
      lastWeekEnd.setDate(lastWeekEnd.getDate() - 1);
      lastWeekEnd.setHours(23, 59, 59, 999);

      // 트레이너들에게 주간 리포트 전송
      await sendTrainerWeeklyReports(lastWeekStart, lastWeekEnd);

      // 회원들에게 주간 리포트 전송
      await sendMemberWeeklyReports(lastWeekStart, lastWeekEnd);

      console.log("주간 리포트 스케줄 완료");
      return null;
    } catch (error) {
      console.error("주간 리포트 스케줄 실패:", error);
      return null;
    }
  });

/**
 * 트레이너들에게 주간 리포트 전송
 */
async function sendTrainerWeeklyReports(
  startDate: Date,
  endDate: Date
): Promise<void> {
  // 모든 트레이너 조회
  const trainersSnapshot = await db.collection("users")
    .where("role", "==", "trainer")
    .get();

  for (const trainerDoc of trainersSnapshot.docs) {
    const trainer = trainerDoc.data();
    const trainerId = trainerDoc.id;
    const fcmToken = trainer.fcmToken;

    if (!fcmToken) continue;

    // 담당 회원 수 조회
    const membersSnapshot = await db.collection("members")
      .where("trainerId", "==", trainerId)
      .where("endDate", ">=", new Date())
      .get();

    const totalMembers = membersSnapshot.size;
    if (totalMembers === 0) continue;

    // 지난주 PT 세션 수 조회
    const schedulesSnapshot = await db.collection("schedules")
      .where("trainerId", "==", trainerId)
      .where("startTime", ">=", startDate)
      .where("startTime", "<=", endDate)
      .where("status", "==", "completed")
      .get();

    const completedSessions = schedulesSnapshot.size;

    // 지난주 식단 기록 수 조회
    const startDateStr = startDate.toISOString().split("T")[0];
    const endDateStr = endDate.toISOString().split("T")[0];

    let dietRecords = 0;
    for (const memberDoc of membersSnapshot.docs) {
      const dietsSnapshot = await db.collection("diets")
        .where("memberId", "==", memberDoc.id)
        .where("date", ">=", startDateStr)
        .where("date", "<=", endDateStr)
        .get();
      dietRecords += dietsSnapshot.size;
    }

    // 알림 메시지 구성
    const title = "📊 주간 리포트가 도착했어요!";
    const body = `지난주: ${totalMembers}명 담당, ${completedSessions}회 PT 완료, ${dietRecords}개 식단 기록`;

    const notificationMessage: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: "weekly_report",
        targetScreen: "/trainer/insights",
        targetId: "weekly",
        reportType: "trainer",
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    try {
      await admin.messaging().send(notificationMessage);
      console.log("트레이너 주간 리포트 전송:", trainerId);
    } catch (sendError) {
      console.error("트레이너 주간 리포트 전송 실패:", trainerId, sendError);
    }
  }
}

/**
 * 회원들에게 주간 리포트 전송
 */
async function sendMemberWeeklyReports(
  startDate: Date,
  endDate: Date
): Promise<void> {
  // 활성 회원 조회
  const membersSnapshot = await db.collection("members")
    .where("endDate", ">=", new Date())
    .get();

  const startDateStr = startDate.toISOString().split("T")[0];
  const endDateStr = endDate.toISOString().split("T")[0];

  for (const memberDoc of membersSnapshot.docs) {
    const member = memberDoc.data();
    const memberId = member.userId;

    if (!memberId) continue;

    // 회원의 FCM 토큰 가져오기
    const userDoc = await db.collection("users").doc(memberId).get();
    if (!userDoc.exists) continue;

    const userData = userDoc.data()!;
    const fcmToken = userData.fcmToken;

    if (!fcmToken) continue;

    // 지난주 PT 세션 수 조회
    const schedulesSnapshot = await db.collection("schedules")
      .where("memberId", "==", memberDoc.id)
      .where("startTime", ">=", startDate)
      .where("startTime", "<=", endDate)
      .where("status", "==", "completed")
      .get();

    const completedSessions = schedulesSnapshot.size;

    // 지난주 식단 기록 수 조회
    const dietsSnapshot = await db.collection("diets")
      .where("memberId", "==", memberDoc.id)
      .where("date", ">=", startDateStr)
      .where("date", "<=", endDateStr)
      .get();

    const dietRecords = dietsSnapshot.size;

    // 알림 메시지 구성
    const title = "📊 지난주 활동 리포트";
    let body: string;

    if (completedSessions > 0 && dietRecords > 0) {
      body = `지난주 ${completedSessions}회 PT를 완료하고 ${dietRecords}개의 식단을 기록했어요! 꾸준히 잘하고 계세요 💪`;
    } else if (completedSessions > 0) {
      body = `지난주 ${completedSessions}회 PT를 완료했어요! 식단 기록도 함께하면 더 좋은 결과를 얻을 수 있어요.`;
    } else if (dietRecords > 0) {
      body = `지난주 ${dietRecords}개의 식단을 기록했어요! 이번 주도 꾸준히 기록해보세요.`;
    } else {
      body = "지난주 활동이 없었어요. 이번 주는 함께 시작해볼까요? 🔥";
    }

    const notificationMessage: admin.messaging.Message = {
      token: fcmToken,
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: "weekly_report",
        targetScreen: "/member/home",
        targetId: "weekly",
        reportType: "member",
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          priority: "high",
          sound: "default",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title: title,
              body: body,
            },
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    try {
      await admin.messaging().send(notificationMessage);
      console.log("회원 주간 리포트 전송:", memberId);
    } catch (sendError) {
      console.error("회원 주간 리포트 전송 실패:", memberId, sendError);
    }
  }
}
