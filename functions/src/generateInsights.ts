/**
 * AI 인사이트 생성 Cloud Function
 * 트레이너의 회원 데이터를 분석하여 관리 인사이트 생성
 *
 * @module generateInsights
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {GoogleGenerativeAI} from "@google/generative-ai";

// Firestore 인스턴스
const db = admin.firestore();

// 인사이트 타입 정의
type InsightType =
  | "attendanceAlert"
  | "ptExpiry"
  | "performance"
  | "recommendation"
  | "weightProgress"
  | "workoutVolume";

type InsightPriority = "high" | "medium" | "low";

interface InsightData {
  trainerId: string;
  memberId?: string;
  memberName?: string;
  type: InsightType;
  priority: InsightPriority;
  title: string;
  message: string;
  actionSuggestion?: string;
  data?: Record<string, unknown>;
  isRead: boolean;
  isActionTaken: boolean;
  createdAt: admin.firestore.Timestamp;
  expiresAt?: admin.firestore.Timestamp;
}

interface MemberData {
  id: string;
  name: string;
  trainerId: string;
  startDate?: admin.firestore.Timestamp;
  endDate?: admin.firestore.Timestamp;
  remainingSessions?: number;
  totalSessions?: number;
  goal?: string;
  targetWeight?: number;
}

interface BodyRecordData {
  memberId: string;
  recordDate: admin.firestore.Timestamp;
  weight?: number;
  bodyFat?: number;
  muscleMass?: number;
}

// Google AI 클라이언트 (지연 초기화)
const getGoogleAIClient = (): GoogleGenerativeAI => {
  const apiKey = process.env.GOOGLE_AI_API_KEY || process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error("GOOGLE_AI_API_KEY is not configured");
  }
  return new GoogleGenerativeAI(apiKey);
};

/**
 * 회원의 출석 패턴 분석
 */
function analyzeAttendancePattern(
  memberId: string,
  memberName: string,
  bodyRecords: BodyRecordData[]
): InsightData | null {
  // 최근 4주간 기록 확인
  const fourWeeksAgo = new Date();
  fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

  const recentRecords = bodyRecords.filter((record) => {
    const recordDate = record.recordDate.toDate();
    return record.memberId === memberId && recordDate >= fourWeeksAgo;
  });

  // 주간 기록 횟수 계산
  const weeklyRecords: number[] = [0, 0, 0, 0];
  recentRecords.forEach((record) => {
    const recordDate = record.recordDate.toDate();
    const weeksAgo = Math.floor(
      (Date.now() - recordDate.getTime()) / (7 * 24 * 60 * 60 * 1000)
    );
    if (weeksAgo >= 0 && weeksAgo < 4) {
      weeklyRecords[weeksAgo]++;
    }
  });

  // 최근 2주 vs 이전 2주 비교
  const recentWeeks = weeklyRecords[0] + weeklyRecords[1];
  const previousWeeks = weeklyRecords[2] + weeklyRecords[3];

  // 출석률 50% 이상 하락 시 경고
  if (previousWeeks > 0 && recentWeeks < previousWeeks * 0.5) {
    const dropRate = Math.round((1 - recentWeeks / previousWeeks) * 100);
    return {
      trainerId: "", // 나중에 설정
      memberId,
      memberName,
      type: "attendanceAlert",
      priority: "high",
      title: `${memberName}님 출석률 하락`,
      message: `최근 2주간 출석률이 ${dropRate}% 하락했습니다. 이전 2주 ${previousWeeks}회 → 최근 2주 ${recentWeeks}회`,
      actionSuggestion: "회원에게 연락하여 운동 지속 가능 여부를 확인해보세요.",
      data: {
        dropRate,
        recentCount: recentWeeks,
        previousCount: previousWeeks,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7일 후 만료
      ),
    };
  }

  return null;
}

/**
 * PT 종료 임박 분석
 */
function analyzePTExpiry(
  member: MemberData,
  trainerId: string
): InsightData | null {
  if (!member.endDate) return null;

  const endDate = member.endDate.toDate();
  const now = new Date();
  const daysUntilExpiry = Math.ceil(
    (endDate.getTime() - now.getTime()) / (24 * 60 * 60 * 1000)
  );

  // 7일 이내 종료 예정
  if (daysUntilExpiry > 0 && daysUntilExpiry <= 7) {
    const remainingSessions = member.remainingSessions ?? 0;
    let priority: InsightPriority = "medium";
    let expiryMessage = `${daysUntilExpiry}일 후 PT 이용권이 종료됩니다.`;

    if (daysUntilExpiry <= 3) {
      priority = "high";
      expiryMessage = `${daysUntilExpiry}일 후 PT 이용권이 종료됩니다!`;
    }

    if (remainingSessions > 0) {
      expiryMessage += ` 잔여 ${remainingSessions}회가 남아있습니다.`;
    }

    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "ptExpiry",
      priority,
      title: `${member.name}님 PT 종료 임박`,
      message: expiryMessage,
      actionSuggestion:
        remainingSessions > 0
          ? "남은 세션 소화 일정을 조율하거나 연장을 권유해보세요."
          : "PT 연장 여부를 확인해보세요.",
      data: {
        daysUntilExpiry,
        remainingSessions,
        endDate: endDate.toISOString(),
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(endDate),
    };
  }

  return null;
}

/**
 * 체중 변화 분석
 */
function analyzeWeightProgress(
  memberId: string,
  memberName: string,
  memberGoal: string,
  targetWeight: number | undefined,
  bodyRecords: BodyRecordData[],
  trainerId: string
): InsightData | null {
  const memberRecords = bodyRecords
    .filter((r) => r.memberId === memberId && r.weight !== undefined)
    .sort((a, b) => a.recordDate.toDate().getTime() - b.recordDate.toDate().getTime());

  if (memberRecords.length < 2) return null;

  const latestWeight = memberRecords[memberRecords.length - 1].weight!;
  const previousWeight = memberRecords[memberRecords.length - 2].weight!;
  const weightChange = latestWeight - previousWeight;
  const changePercent = Math.abs((weightChange / previousWeight) * 100);

  // 목표 달성 분석
  if (targetWeight && Math.abs(latestWeight - targetWeight) <= 1) {
    return {
      trainerId,
      memberId,
      memberName,
      type: "performance",
      priority: "low",
      title: `🎉 ${memberName}님 목표 체중 달성!`,
      message: `현재 체중 ${latestWeight.toFixed(1)}kg으로 목표 체중 ${targetWeight}kg에 도달했습니다.`,
      actionSuggestion: "회원의 성과를 축하해주고 새로운 목표를 설정해보세요.",
      data: {
        currentWeight: latestWeight,
        targetWeight,
        achieved: true,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  // 다이어트 목표인데 체중 증가 (2% 이상)
  if (memberGoal === "diet" && weightChange > 0 && changePercent >= 2) {
    return {
      trainerId,
      memberId,
      memberName,
      type: "weightProgress",
      priority: "medium",
      title: `${memberName}님 체중 증가 감지`,
      message: `체중이 ${previousWeight.toFixed(1)}kg에서 ${latestWeight.toFixed(1)}kg으로 ${weightChange.toFixed(1)}kg 증가했습니다.`,
      actionSuggestion: "식단 관리 상태를 확인하고 필요시 조언을 제공해보세요.",
      data: {
        previousWeight,
        currentWeight: latestWeight,
        change: weightChange,
        changePercent,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  // 벌크업 목표인데 꾸준한 증가 (긍정적)
  if (memberGoal === "bulk" && weightChange > 0 && changePercent >= 1) {
    return {
      trainerId,
      memberId,
      memberName,
      type: "performance",
      priority: "low",
      title: `${memberName}님 벌크업 진행 중`,
      message: `체중이 ${previousWeight.toFixed(1)}kg에서 ${latestWeight.toFixed(1)}kg으로 ${weightChange.toFixed(1)}kg 증가했습니다. 목표에 맞게 잘 진행되고 있습니다.`,
      data: {
        previousWeight,
        currentWeight: latestWeight,
        change: weightChange,
        changePercent,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  return null;
}

/**
 * AI 기반 종합 추천 생성 (Gemini)
 */
async function generateAIRecommendations(
  trainerId: string,
  members: MemberData[],
  bodyRecords: BodyRecordData[]
): Promise<InsightData[]> {
  const insights: InsightData[] = [];

  try {
    const genAI = getGoogleAIClient();
    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.7,
      },
    });

    // 데이터 요약 생성
    const memberSummaries = members.map((member) => {
      const memberRecords = bodyRecords
        .filter((r) => r.memberId === member.id)
        .sort((a, b) =>
          b.recordDate.toDate().getTime() - a.recordDate.toDate().getTime()
        );

      const latestRecord = memberRecords[0];
      const daysUntilExpiry = member.endDate
        ? Math.ceil(
          (member.endDate.toDate().getTime() - Date.now()) /
              (24 * 60 * 60 * 1000)
        )
        : null;

      return {
        name: member.name,
        goal: member.goal || "fitness",
        remainingSessions: member.remainingSessions ?? 0,
        daysUntilExpiry,
        latestWeight: latestRecord?.weight,
        targetWeight: member.targetWeight,
        recordCount: memberRecords.length,
      };
    });

    const prompt = `당신은 경험 많은 PT 트레이너 매니저입니다.
다음 회원 데이터를 분석하여 트레이너에게 유용한 관리 인사이트를 1-3개 제공해주세요.

[회원 데이터]
${JSON.stringify(memberSummaries, null, 2)}

[요구사항]
1. 가장 관심이 필요한 회원에 대한 구체적인 조언
2. 전체 회원 관리 관점에서의 패턴이나 주의사항
3. 실행 가능한 조치 제안

반드시 아래 JSON 형식으로만 응답하세요:
{
  "recommendations": [
    {
      "title": "인사이트 제목 (20자 이내)",
      "message": "상세 메시지 (100자 이내)",
      "actionSuggestion": "추천 조치 (50자 이내)",
      "priority": "high" | "medium" | "low",
      "relatedMemberName": "관련 회원 이름 (있는 경우)"
    }
  ]
}`;

    const result = await model.generateContent(prompt);
    const text = result.response.text();
    const parsed = JSON.parse(text) as {
      recommendations: Array<{
        title: string;
        message: string;
        actionSuggestion: string;
        priority: InsightPriority;
        relatedMemberName?: string;
      }>;
    };

    if (parsed.recommendations && Array.isArray(parsed.recommendations)) {
      for (const rec of parsed.recommendations) {
        // 관련 회원 찾기
        const relatedMember = rec.relatedMemberName
          ? members.find((m) => m.name === rec.relatedMemberName)
          : undefined;

        insights.push({
          trainerId,
          memberId: relatedMember?.id,
          memberName: relatedMember?.name,
          type: "recommendation",
          priority: rec.priority || "low",
          title: rec.title,
          message: rec.message,
          actionSuggestion: rec.actionSuggestion,
          isRead: false,
          isActionTaken: false,
          createdAt: admin.firestore.Timestamp.now(),
          expiresAt: admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
          ),
        });
      }
    }
  } catch (error) {
    functions.logger.warn("[generateInsights] AI 추천 생성 실패", {
      error: error instanceof Error ? error.message : error,
    });
  }

  return insights;
}

/**
 * 특정 트레이너에 대한 인사이트 생성 (내부 로직)
 * onCall과 scheduled 함수에서 공통으로 사용
 */
async function generateInsightsForTrainer(
  trainerId: string,
  includeAI: boolean
): Promise<{
  success: boolean;
  insights: InsightData[];
  stats: {
    totalMembers: number;
    totalGenerated: number;
    newSaved: number;
    skippedDuplicates: number;
  };
}> {
  const startTime = Date.now();
  functions.logger.info("[generateInsightsForTrainer] 시작", {
    trainerId,
    includeAI,
  });

  // 1. 트레이너의 회원 목록 조회
  const membersSnapshot = await db
    .collection("members")
    .where("trainerId", "==", trainerId)
    .where("status", "==", "active")
    .get();

  const members: MemberData[] = membersSnapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as MemberData[];

  functions.logger.info("[generateInsightsForTrainer] 회원 조회 완료", {
    trainerId,
    memberCount: members.length,
  });

  if (members.length === 0) {
    return {
      success: true,
      insights: [],
      stats: {
        totalMembers: 0,
        totalGenerated: 0,
        newSaved: 0,
        skippedDuplicates: 0,
      },
    };
  }

  // 2. 최근 2개월 체성분 기록 조회
  const twoMonthsAgo = new Date();
  twoMonthsAgo.setMonth(twoMonthsAgo.getMonth() - 2);

  const memberIds = members.map((m) => m.id);
  const bodyRecords: BodyRecordData[] = [];
  const batchSize = 30;

  for (let i = 0; i < memberIds.length; i += batchSize) {
    const batchIds = memberIds.slice(i, i + batchSize);
    const recordsSnapshot = await db
      .collection("body_records")
      .where("memberId", "in", batchIds)
      .where(
        "recordDate",
        ">=",
        admin.firestore.Timestamp.fromDate(twoMonthsAgo)
      )
      .orderBy("recordDate", "desc")
      .get();

    recordsSnapshot.docs.forEach((doc) => {
      bodyRecords.push(doc.data() as BodyRecordData);
    });
  }

  functions.logger.info("[generateInsightsForTrainer] 체성분 기록 조회 완료", {
    recordCount: bodyRecords.length,
  });

  // 3. 인사이트 생성
  const insights: InsightData[] = [];

  for (const member of members) {
    // 3-1. 출석률 분석
    const attendanceInsight = analyzeAttendancePattern(
      member.id,
      member.name,
      bodyRecords
    );
    if (attendanceInsight) {
      attendanceInsight.trainerId = trainerId;
      insights.push(attendanceInsight);
    }

    // 3-2. PT 종료 임박 분석
    const expiryInsight = analyzePTExpiry(member, trainerId);
    if (expiryInsight) {
      insights.push(expiryInsight);
    }

    // 3-3. 체중 변화 분석
    const weightInsight = analyzeWeightProgress(
      member.id,
      member.name,
      member.goal || "fitness",
      member.targetWeight,
      bodyRecords,
      trainerId
    );
    if (weightInsight) {
      insights.push(weightInsight);
    }
  }

  // 3-4. AI 기반 종합 추천 (옵션)
  if (includeAI && members.length > 0) {
    const aiInsights = await generateAIRecommendations(
      trainerId,
      members,
      bodyRecords
    );
    insights.push(...aiInsights);
  }

  functions.logger.info("[generateInsightsForTrainer] 인사이트 생성 완료", {
    totalInsights: insights.length,
    byType: {
      attendanceAlert: insights.filter((i) => i.type === "attendanceAlert")
        .length,
      ptExpiry: insights.filter((i) => i.type === "ptExpiry").length,
      performance: insights.filter((i) => i.type === "performance").length,
      weightProgress: insights.filter((i) => i.type === "weightProgress")
        .length,
      recommendation: insights.filter((i) => i.type === "recommendation")
        .length,
    },
  });

  // 4. 기존 중복 인사이트 제거 (같은 타입, 같은 회원의 24시간 이내 인사이트)
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const existingInsightsSnapshot = await db
    .collection("insights")
    .where("trainerId", "==", trainerId)
    .where(
      "createdAt",
      ">=",
      admin.firestore.Timestamp.fromDate(oneDayAgo)
    )
    .get();

  const existingKeys = new Set<string>();
  existingInsightsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    const key = `${data.type}-${data.memberId || "general"}`;
    existingKeys.add(key);
  });

  const newInsights = insights.filter((insight) => {
    const key = `${insight.type}-${insight.memberId || "general"}`;
    return !existingKeys.has(key);
  });

  // 5. Firestore에 인사이트 저장
  if (newInsights.length > 0) {
    const batch = db.batch();
    newInsights.forEach((insight) => {
      const docRef = db.collection("insights").doc();
      batch.set(docRef, insight);
    });
    await batch.commit();

    functions.logger.info("[generateInsightsForTrainer] 인사이트 저장 완료", {
      savedCount: newInsights.length,
      skippedDuplicates: insights.length - newInsights.length,
    });
  }

  const duration = Date.now() - startTime;
  functions.logger.info("[generateInsightsForTrainer] 완료", {
    trainerId,
    totalGenerated: insights.length,
    newSaved: newInsights.length,
    durationMs: duration,
  });

  return {
    success: true,
    insights: newInsights,
    stats: {
      totalMembers: members.length,
      totalGenerated: insights.length,
      newSaved: newInsights.length,
      skippedDuplicates: insights.length - newInsights.length,
    },
  };
}

/**
 * AI 인사이트 생성 Cloud Function (수동 호출용)
 *
 * @description
 * 트레이너의 회원 데이터를 분석하여 관리에 필요한 인사이트를 생성합니다.
 * 출석률, PT 종료 임박, 체중 변화, AI 추천 등의 인사이트를 제공합니다.
 *
 * @fires https.onCall
 * @region asia-northeast3
 *
 * @param {Object} data - 요청 데이터
 * @param {boolean} [data.includeAI=true] - AI 추천 포함 여부
 *
 * @returns {Promise<Object>} 생성된 인사이트 목록
 *
 * @throws {HttpsError} AUTH_REQUIRED - 로그인 필요
 * @throws {HttpsError} TRAINER_NOT_FOUND - 트레이너 정보 없음
 */
export const generateInsights = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    functions.logger.info("[generateInsights] 함수 시작", {
      callerUid: context.auth?.uid,
      includeAI: data?.includeAI,
    });

    // 1. 인증 확인
    if (!context.auth) {
      functions.logger.warn("[generateInsights] 인증되지 않은 요청");
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const userId = context.auth.uid;
    const includeAI = data?.includeAI !== false; // 기본값 true

    try {
      // 2. 트레이너 정보 확인
      const trainerSnapshot = await db
        .collection("trainers")
        .where("userId", "==", userId)
        .limit(1)
        .get();

      if (trainerSnapshot.empty) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "트레이너 정보를 찾을 수 없습니다."
        );
      }

      const trainerDoc = trainerSnapshot.docs[0];
      const trainerId = trainerDoc.id;

      // 공통 로직 호출
      const result = await generateInsightsForTrainer(trainerId, includeAI);

      return {
        success: result.success,
        insights: result.insights.map((insight) => ({
          type: insight.type,
          priority: insight.priority,
          title: insight.title,
          message: insight.message,
          memberName: insight.memberName,
          actionSuggestion: insight.actionSuggestion,
        })),
        stats: result.stats,
      };
    } catch (error) {
      functions.logger.error("[generateInsights] 오류 발생", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const errorMessage =
        error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `인사이트 생성 중 오류가 발생했습니다. (${errorMessage})`
      );
    }
  });

/**
 * AI 인사이트 자동 생성 스케줄 함수
 *
 * @description
 * 매일 아침 8시에 모든 활성 트레이너에 대해 자동으로 인사이트를 생성합니다.
 * AI 추천은 API 비용 절감을 위해 비활성화됩니다.
 *
 * @fires pubsub.schedule
 * @region asia-northeast3
 * @schedule 매일 오전 8시 (Asia/Seoul)
 */
export const generateInsightsScheduled = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 8 * * *") // 매일 오전 8시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const startTime = Date.now();
    functions.logger.info("[generateInsightsScheduled] 스케줄 실행 시작");

    try {
      // 모든 활성 트레이너 조회
      const trainersSnapshot = await db
        .collection("trainers")
        .where("status", "==", "active")
        .get();

      functions.logger.info("[generateInsightsScheduled] 트레이너 조회 완료", {
        trainerCount: trainersSnapshot.size,
      });

      let totalInsights = 0;
      let successCount = 0;
      let errorCount = 0;

      // 각 트레이너에 대해 인사이트 생성
      for (const trainerDoc of trainersSnapshot.docs) {
        const trainerId = trainerDoc.id;

        try {
          // AI 추천은 비용 절감을 위해 비활성화 (false)
          const result = await generateInsightsForTrainer(trainerId, false);
          totalInsights += result.stats.newSaved;
          successCount++;

          functions.logger.info("[generateInsightsScheduled] 트레이너 처리 완료", {
            trainerId,
            newInsights: result.stats.newSaved,
          });

          // API 레이트 리밋 방지를 위한 지연
          await new Promise((resolve) => setTimeout(resolve, 100));
        } catch (trainerError) {
          errorCount++;
          functions.logger.error("[generateInsightsScheduled] 트레이너 처리 실패", {
            trainerId,
            error: trainerError instanceof Error ? trainerError.message : trainerError,
          });
        }
      }

      const duration = Date.now() - startTime;
      functions.logger.info("[generateInsightsScheduled] 스케줄 실행 완료", {
        totalTrainers: trainersSnapshot.size,
        successCount,
        errorCount,
        totalInsights,
        durationMs: duration,
      });

      return null;
    } catch (error) {
      functions.logger.error("[generateInsightsScheduled] 스케줄 실행 실패", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });
