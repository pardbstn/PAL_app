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
  | "workoutVolume"
  | "churnRisk"
  | "renewalLikelihood"
  | "plateauDetection"
  | "workoutRecommendation"
  | "noshowPattern"
  | "performanceRanking";

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

interface SessionData {
  memberId: string;
  trainerId: string;
  scheduledAt: admin.firestore.Timestamp;
  status: "scheduled" | "completed" | "cancelled" | "noshow";
  workoutType?: string;
}

interface MessageData {
  memberId: string;
  trainerId: string;
  sentAt: admin.firestore.Timestamp;
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
 * 이탈 위험 예측 분석
 * 출석률 하락, 메시지 부재, 체중 정체 등을 종합하여 이탈 위험도 계산
 */
function analyzeChurnRisk(
  member: MemberData,
  bodyRecords: BodyRecordData[],
  sessions: SessionData[],
  messages: MessageData[],
  trainerId: string
): InsightData | null {
  const now = new Date();
  const fourWeeksAgo = new Date(now.getTime() - 28 * 24 * 60 * 60 * 1000);
  const twoWeeksAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);

  // 1. 출석률 하락 분석 (최근 2주 vs 이전 2주)
  const memberSessions = sessions.filter((s) => s.memberId === member.id);
  const recentSessions = memberSessions.filter(
    (s) => s.scheduledAt.toDate() >= twoWeeksAgo && s.status === "completed"
  );
  const previousSessions = memberSessions.filter(
    (s) =>
      s.scheduledAt.toDate() >= fourWeeksAgo &&
      s.scheduledAt.toDate() < twoWeeksAgo &&
      s.status === "completed"
  );

  let attendanceDropScore = 0;
  if (previousSessions.length > 0) {
    const dropRate = 1 - recentSessions.length / previousSessions.length;
    if (dropRate > 0.4) {
      attendanceDropScore = Math.min(dropRate * 100, 40); // 최대 40점
    }
  }

  // 2. 메시지 부재 분석 (2주간 메시지 없음)
  const memberMessages = messages.filter((m) => m.memberId === member.id);
  const recentMessages = memberMessages.filter(
    (m) => m.sentAt.toDate() >= twoWeeksAgo
  );
  const noMessageScore = recentMessages.length === 0 ? 30 : 0; // 30점

  // 3. 체중 정체 분석 (4주 이상 0.5kg 미만 변화)
  const memberRecords = bodyRecords
    .filter((r) => r.memberId === member.id && r.weight !== undefined)
    .sort((a, b) => a.recordDate.toDate().getTime() - b.recordDate.toDate().getTime());

  let plateauScore = 0;
  if (memberRecords.length >= 2) {
    const fourWeeksRecords = memberRecords.filter(
      (r) => r.recordDate.toDate() >= fourWeeksAgo
    );
    if (fourWeeksRecords.length >= 2) {
      const firstWeight = fourWeeksRecords[0].weight!;
      const lastWeight = fourWeeksRecords[fourWeeksRecords.length - 1].weight!;
      if (Math.abs(lastWeight - firstWeight) < 0.5) {
        plateauScore = 30; // 30점
      }
    }
  }

  // 이탈 위험도 계산
  const churnRisk = attendanceDropScore + noMessageScore + plateauScore;

  if (churnRisk < 40) return null;

  const priority: InsightPriority = churnRisk > 70 ? "high" : "medium";
  const riskFactors: string[] = [];
  if (attendanceDropScore > 0) riskFactors.push(`출석률 ${Math.round(attendanceDropScore)}% 하락`);
  if (noMessageScore > 0) riskFactors.push("2주간 메시지 없음");
  if (plateauScore > 0) riskFactors.push("4주간 체중 정체");

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "churnRisk",
    priority,
    title: `${member.name} 회원 이탈 위험`,
    message: `${member.name} 회원 이탈 위험도 ${churnRisk}% - ${riskFactors.join(", ")}`,
    actionSuggestion: "개인 연락으로 동기 부여 필요",
    data: {
      churnRisk,
      attendanceDropScore,
      noMessageScore,
      plateauScore,
      riskFactors,
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    ),
  };
}

/**
 * 재등록 가능성 분석
 * 목표 달성률, 출석률, 잔여 세션 등을 종합하여 재등록 가능성 예측
 */
function analyzeRenewalLikelihood(
  member: MemberData,
  bodyRecords: BodyRecordData[],
  sessions: SessionData[],
  trainerId: string
): InsightData | null {
  // 종료 7일 이내 회원만 분석
  if (!member.endDate) return null;
  const endDate = member.endDate.toDate();
  const now = new Date();
  const daysUntilExpiry = Math.ceil(
    (endDate.getTime() - now.getTime()) / (24 * 60 * 60 * 1000)
  );

  if (daysUntilExpiry < 0 || daysUntilExpiry > 14) return null;

  // 1. 목표 달성률 계산
  let goalAchievement = 50; // 기본값
  if (member.targetWeight) {
    const memberRecords = bodyRecords
      .filter((r) => r.memberId === member.id && r.weight !== undefined)
      .sort((a, b) => b.recordDate.toDate().getTime() - a.recordDate.toDate().getTime());

    if (memberRecords.length >= 2) {
      const startWeight = memberRecords[memberRecords.length - 1].weight!;
      const currentWeight = memberRecords[0].weight!;
      const targetChange = Math.abs(member.targetWeight - startWeight);
      const actualChange = Math.abs(currentWeight - startWeight);

      if (targetChange > 0) {
        goalAchievement = Math.min(Math.round((actualChange / targetChange) * 100), 100);
      }
    }
  }

  // 2. 출석률 계산
  const memberSessions = sessions.filter((s) => s.memberId === member.id);
  const completedSessions = memberSessions.filter((s) => s.status === "completed").length;
  const totalScheduled = memberSessions.length;
  const attendanceRate = totalScheduled > 0
    ? Math.round((completedSessions / totalScheduled) * 100)
    : 50;

  // 3. 잔여 세션 상태
  const remainingSessions = member.remainingSessions ?? 0;
  const totalSessions = member.totalSessions ?? 1;
  const sessionUtilization = Math.round(
    ((totalSessions - remainingSessions) / totalSessions) * 100
  );

  // 재등록 가능성 계산 (가중 평균)
  const renewalLikelihood = Math.round(
    goalAchievement * 0.4 + attendanceRate * 0.4 + sessionUtilization * 0.2
  );

  // 60% 이상일 때만 인사이트 생성
  if (renewalLikelihood < 60) return null;

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "renewalLikelihood",
    priority: "medium",
    title: `${member.name}님 재등록 가능성 ${renewalLikelihood}%`,
    message: `${member.name} 회원 재등록 가능성 ${renewalLikelihood}% - 목표 ${goalAchievement}% 달성`,
    actionSuggestion: "재등록 혜택 제안 타이밍",
    data: {
      renewalLikelihood,
      goalAchievement,
      attendanceRate,
      sessionUtilization,
      daysUntilExpiry,
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(endDate),
  };
}

/**
 * 정체기 감지 분석
 * 4주 이상 0.5kg 미만 체중 변화 시 정체기로 판단
 */
function analyzePlateauDetection(
  member: MemberData,
  bodyRecords: BodyRecordData[],
  trainerId: string
): InsightData | null {
  const fourWeeksAgo = new Date();
  fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

  const memberRecords = bodyRecords
    .filter(
      (r) =>
        r.memberId === member.id &&
        r.weight !== undefined &&
        r.recordDate.toDate() >= fourWeeksAgo
    )
    .sort((a, b) => a.recordDate.toDate().getTime() - b.recordDate.toDate().getTime());

  if (memberRecords.length < 2) return null;

  const firstWeight = memberRecords[0].weight!;
  const lastWeight = memberRecords[memberRecords.length - 1].weight!;
  const weightChange = Math.abs(lastWeight - firstWeight);

  // 4주간 체중 변화가 0.5kg 미만이면 정체기
  if (weightChange >= 0.5) return null;

  // 정체 주차 계산
  const weeksDiff = Math.ceil(
    (memberRecords[memberRecords.length - 1].recordDate.toDate().getTime() -
      memberRecords[0].recordDate.toDate().getTime()) /
      (7 * 24 * 60 * 60 * 1000)
  );
  const plateauWeeks = Math.max(weeksDiff, 4);

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "plateauDetection",
    priority: "medium",
    title: `${member.name}님 ${plateauWeeks}주째 체중 정체`,
    message: `${member.name} 회원 ${plateauWeeks}주째 체중 정체 - 식단 조절 또는 운동 강도 변경 권장`,
    actionSuggestion: "프로그램 변경 상담 필요",
    data: {
      plateauWeeks,
      firstWeight,
      lastWeight,
      weightChange,
      recordCount: memberRecords.length,
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
    ),
  };
}

/**
 * 최적 운동 추천 분석
 * 운동 유형별 체성분 변화 상관관계 분석
 */
function analyzeWorkoutRecommendation(
  member: MemberData,
  bodyRecords: BodyRecordData[],
  sessions: SessionData[],
  trainerId: string
): InsightData | null {
  const memberSessions = sessions.filter(
    (s) => s.memberId === member.id && s.status === "completed" && s.workoutType
  );

  if (memberSessions.length < 4) return null;

  const memberRecords = bodyRecords
    .filter((r) => r.memberId === member.id && r.bodyFat !== undefined)
    .sort((a, b) => a.recordDate.toDate().getTime() - b.recordDate.toDate().getTime());

  if (memberRecords.length < 2) return null;

  // 운동 유형별 그룹화
  const workoutTypeGroups: Record<string, SessionData[]> = {};
  memberSessions.forEach((session) => {
    const type = session.workoutType!;
    if (!workoutTypeGroups[type]) {
      workoutTypeGroups[type] = [];
    }
    workoutTypeGroups[type].push(session);
  });

  // 운동 유형별 체지방 감량 효과 분석
  const workoutEffects: Array<{ type: string; effect: number; count: number }> = [];

  for (const [workoutType, typeSessions] of Object.entries(workoutTypeGroups)) {
    if (typeSessions.length < 2) continue;

    // 해당 운동 전후 체지방 변화 계산
    let totalEffect = 0;
    let effectCount = 0;

    typeSessions.forEach((session) => {
      const sessionDate = session.scheduledAt.toDate();
      const beforeRecord = memberRecords.find(
        (r) => r.recordDate.toDate() <= sessionDate
      );
      const afterRecord = memberRecords.find(
        (r) =>
          r.recordDate.toDate() > sessionDate &&
          r.recordDate.toDate().getTime() - sessionDate.getTime() < 7 * 24 * 60 * 60 * 1000
      );

      if (beforeRecord?.bodyFat && afterRecord?.bodyFat) {
        totalEffect += beforeRecord.bodyFat - afterRecord.bodyFat;
        effectCount++;
      }
    });

    if (effectCount > 0) {
      workoutEffects.push({
        type: workoutType,
        effect: totalEffect / effectCount,
        count: typeSessions.length,
      });
    }
  }

  if (workoutEffects.length === 0) return null;

  // 효과순 정렬
  workoutEffects.sort((a, b) => b.effect - a.effect);
  const bestWorkout = workoutEffects[0];

  if (bestWorkout.effect <= 0) return null;

  // 상위 3개 추천 운동
  const recommendedWorkouts = workoutEffects
    .filter((w) => w.effect > 0)
    .slice(0, 3)
    .map((w) => w.type);

  const effectMultiplier = workoutEffects.length > 1 && workoutEffects[1].effect > 0
    ? (bestWorkout.effect / workoutEffects[1].effect).toFixed(1)
    : "1.5";

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "workoutRecommendation",
    priority: "low",
    title: `${member.name}님 최적 운동 분석`,
    message: `${member.name} 회원은 ${bestWorkout.type} 운동 시 체지방 감량 ${effectMultiplier}배 효과`,
    actionSuggestion: `${recommendedWorkouts.join(", ")} 운동 프로그램 권장`,
    data: {
      recommendedWorkouts,
      workoutEffects,
      bestWorkout: bestWorkout.type,
      effectMultiplier: parseFloat(effectMultiplier),
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    ),
  };
}

/**
 * 노쇼 패턴 분석
 * 요일/시간대별 노쇼율 분석
 */
function analyzeNoshowPattern(
  sessions: SessionData[],
  trainerId: string
): InsightData | null {
  const noshowSessions = sessions.filter((s) => s.status === "noshow");
  const totalSessions = sessions.filter(
    (s) => s.status === "completed" || s.status === "noshow"
  );

  if (totalSessions.length < 10) return null;

  const overallNoshowRate = noshowSessions.length / totalSessions.length;
  if (overallNoshowRate < 0.1) return null; // 전체 노쇼율 10% 미만이면 스킵

  // 요일별 노쇼율 계산
  const dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
  const dayStats: Record<number, { total: number; noshow: number }> = {};

  for (let i = 0; i < 7; i++) {
    dayStats[i] = {total: 0, noshow: 0};
  }

  totalSessions.forEach((session) => {
    const day = session.scheduledAt.toDate().getDay();
    dayStats[day].total++;
    if (session.status === "noshow") {
      dayStats[day].noshow++;
    }
  });

  // 시간대별 노쇼율 계산 (오전/오후)
  const timeStats: Record<string, { total: number; noshow: number }> = {
    morning: {total: 0, noshow: 0}, // 06-12시
    afternoon: {total: 0, noshow: 0}, // 12-18시
    evening: {total: 0, noshow: 0}, // 18-24시
  };

  totalSessions.forEach((session) => {
    const hour = session.scheduledAt.toDate().getHours();
    let timeSlot: string;
    if (hour >= 6 && hour < 12) timeSlot = "morning";
    else if (hour >= 12 && hour < 18) timeSlot = "afternoon";
    else timeSlot = "evening";

    timeStats[timeSlot].total++;
    if (session.status === "noshow") {
      timeStats[timeSlot].noshow++;
    }
  });

  // 최고 노쇼율 요일 찾기
  let highestNoshowDay = 0;
  let highestNoshowRate = 0;

  for (let day = 0; day < 7; day++) {
    if (dayStats[day].total >= 3) {
      // 최소 3회 이상 세션이 있는 요일만
      const rate = dayStats[day].noshow / dayStats[day].total;
      if (rate > highestNoshowRate) {
        highestNoshowRate = rate;
        highestNoshowDay = day;
      }
    }
  }

  // 최고 노쇼율 시간대 찾기
  let highestNoshowTime = "morning";
  let highestTimeRate = 0;
  const timeLabels: Record<string, string> = {
    morning: "오전",
    afternoon: "오후",
    evening: "저녁",
  };

  for (const [slot, stats] of Object.entries(timeStats)) {
    if (stats.total >= 3) {
      const rate = stats.noshow / stats.total;
      if (rate > highestTimeRate) {
        highestTimeRate = rate;
        highestNoshowTime = slot;
      }
    }
  }

  if (highestNoshowRate < 0.2) return null; // 최고 노쇼율이 20% 미만이면 스킵

  const noshowPercent = Math.round(highestNoshowRate * 100);

  return {
    trainerId,
    type: "noshowPattern",
    priority: noshowPercent > 30 ? "high" : "medium",
    title: `${dayNames[highestNoshowDay]} ${timeLabels[highestNoshowTime]} 노쇼 주의`,
    message: `${dayNames[highestNoshowDay]} ${timeLabels[highestNoshowTime]} 노쇼율 ${noshowPercent}% - 전날 리마인더 권장`,
    actionSuggestion: "자동 알림 설정 권장",
    data: {
      overallNoshowRate: Math.round(overallNoshowRate * 100),
      highestNoshowDay: dayNames[highestNoshowDay],
      highestNoshowRate: noshowPercent,
      highestNoshowTime: timeLabels[highestNoshowTime],
      dayStats: Object.entries(dayStats).map(([day, stats]) => ({
        day: dayNames[parseInt(day)],
        total: stats.total,
        noshow: stats.noshow,
        rate: stats.total > 0 ? Math.round((stats.noshow / stats.total) * 100) : 0,
      })),
      timeStats: Object.entries(timeStats).map(([slot, stats]) => ({
        slot: timeLabels[slot],
        total: stats.total,
        noshow: stats.noshow,
        rate: stats.total > 0 ? Math.round((stats.noshow / stats.total) * 100) : 0,
      })),
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
    ),
  };
}

/**
 * 회원 성과 랭킹 분석
 * 이번 달 체성분 개선 순위 생성
 */
function analyzePerformanceRanking(
  members: MemberData[],
  bodyRecords: BodyRecordData[],
  trainerId: string
): InsightData | null {
  const now = new Date();
  const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

  // 각 회원별 이번 달 체지방 변화 계산
  const memberChanges: Array<{
    memberId: string;
    memberName: string;
    bodyFatChange: number;
    startBodyFat: number;
    endBodyFat: number;
  }> = [];

  for (const member of members) {
    const memberRecords = bodyRecords
      .filter(
        (r) =>
          r.memberId === member.id &&
          r.bodyFat !== undefined &&
          r.recordDate.toDate() >= monthStart
      )
      .sort((a, b) => a.recordDate.toDate().getTime() - b.recordDate.toDate().getTime());

    if (memberRecords.length < 2) continue;

    const startBodyFat = memberRecords[0].bodyFat!;
    const endBodyFat = memberRecords[memberRecords.length - 1].bodyFat!;
    const bodyFatChange = startBodyFat - endBodyFat; // 양수면 감량

    memberChanges.push({
      memberId: member.id,
      memberName: member.name,
      bodyFatChange,
      startBodyFat,
      endBodyFat,
    });
  }

  if (memberChanges.length < 3) return null;

  // 체지방 감량순 정렬
  memberChanges.sort((a, b) => b.bodyFatChange - a.bodyFatChange);

  const top3 = memberChanges.slice(0, 3);
  const rankings = top3.map((m, index) => ({
    rank: index + 1,
    memberName: m.memberName,
    memberId: m.memberId,
    change: m.bodyFatChange,
  }));

  const rankingMessage = top3
    .map(
      (m, index) =>
        `${index + 1}위 ${m.memberName}(${m.bodyFatChange > 0 ? "-" : "+"}${Math.abs(m.bodyFatChange).toFixed(1)}kg)`
    )
    .join(", ");

  return {
    trainerId,
    type: "performanceRanking",
    priority: "low",
    title: "이번 달 체지방 감량 TOP3",
    message: `이번 달 체지방 감량 TOP3: ${rankingMessage}`,
    data: {
      rankings,
      month: `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`,
      totalMembers: memberChanges.length,
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    ),
  };
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

  // 2-2. 최근 2개월 세션 기록 조회
  const sessions: SessionData[] = [];
  for (let i = 0; i < memberIds.length; i += batchSize) {
    const batchIds = memberIds.slice(i, i + batchSize);
    const sessionsSnapshot = await db
      .collection("sessions")
      .where("memberId", "in", batchIds)
      .where("trainerId", "==", trainerId)
      .where(
        "scheduledAt",
        ">=",
        admin.firestore.Timestamp.fromDate(twoMonthsAgo)
      )
      .get();

    sessionsSnapshot.docs.forEach((doc) => {
      sessions.push(doc.data() as SessionData);
    });
  }

  functions.logger.info("[generateInsightsForTrainer] 세션 기록 조회 완료", {
    sessionCount: sessions.length,
  });

  // 2-3. 최근 2주 메시지 기록 조회
  const twoWeeksAgo = new Date();
  twoWeeksAgo.setDate(twoWeeksAgo.getDate() - 14);
  const messages: MessageData[] = [];
  for (let i = 0; i < memberIds.length; i += batchSize) {
    const batchIds = memberIds.slice(i, i + batchSize);
    const messagesSnapshot = await db
      .collection("messages")
      .where("memberId", "in", batchIds)
      .where("trainerId", "==", trainerId)
      .where(
        "sentAt",
        ">=",
        admin.firestore.Timestamp.fromDate(twoWeeksAgo)
      )
      .get();

    messagesSnapshot.docs.forEach((doc) => {
      messages.push(doc.data() as MessageData);
    });
  }

  functions.logger.info("[generateInsightsForTrainer] 메시지 기록 조회 완료", {
    messageCount: messages.length,
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

    // 3-4. 이탈 위험 예측
    const churnRiskInsight = analyzeChurnRisk(
      member,
      bodyRecords,
      sessions,
      messages,
      trainerId
    );
    if (churnRiskInsight) {
      insights.push(churnRiskInsight);
    }

    // 3-5. 재등록 가능성 분석
    const renewalInsight = analyzeRenewalLikelihood(
      member,
      bodyRecords,
      sessions,
      trainerId
    );
    if (renewalInsight) {
      insights.push(renewalInsight);
    }

    // 3-6. 정체기 감지
    const plateauInsight = analyzePlateauDetection(
      member,
      bodyRecords,
      trainerId
    );
    if (plateauInsight) {
      insights.push(plateauInsight);
    }

    // 3-7. 최적 운동 추천
    const workoutRecInsight = analyzeWorkoutRecommendation(
      member,
      bodyRecords,
      sessions,
      trainerId
    );
    if (workoutRecInsight) {
      insights.push(workoutRecInsight);
    }
  }

  // 3-8. 노쇼 패턴 분석 (트레이너 전체)
  const noshowInsight = analyzeNoshowPattern(sessions, trainerId);
  if (noshowInsight) {
    insights.push(noshowInsight);
  }

  // 3-9. 회원 성과 랭킹 (트레이너 전체)
  const rankingInsight = analyzePerformanceRanking(members, bodyRecords, trainerId);
  if (rankingInsight) {
    insights.push(rankingInsight);
  }

  // 3-10. AI 기반 종합 추천 (옵션)
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
      churnRisk: insights.filter((i) => i.type === "churnRisk").length,
      renewalLikelihood: insights.filter((i) => i.type === "renewalLikelihood")
        .length,
      plateauDetection: insights.filter((i) => i.type === "plateauDetection")
        .length,
      workoutRecommendation: insights.filter(
        (i) => i.type === "workoutRecommendation"
      ).length,
      noshowPattern: insights.filter((i) => i.type === "noshowPattern").length,
      performanceRanking: insights.filter(
        (i) => i.type === "performanceRanking"
      ).length,
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
