/**
 * AI 인사이트 생성 Cloud Function
 * 트레이너의 회원 데이터를 분석하여 관리 인사이트 생성
 *
 * @module generateInsights
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db, safeToDate} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {getOpenAIClient} from "./services/ai-service";
import {
  INSIGHT_CONFIG,
  TRAINER_INSIGHT_CONFIG,
  calculateInsightScore,
  truncateMessage,
  TRAINER_MESSAGE_TEMPLATES,
} from "./constants/insightConfig";

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
  workoutSets?: WorkoutSetData[];
}

interface WorkoutSetData {
  exerciseName: string;
  muscleGroup: "upper" | "lower" | "core" | "cardio";
  sets: number;
  reps: number;
  weight: number; // kg
}

interface MessageData {
  memberId: string; // derived from chat room
  chatRoomId: string;
  senderId: string;
  senderRole: string;
  createdAt: admin.firestore.Timestamp;
}

// OpenAI 클라이언트는 services/ai-service에서 import

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
    const recordDate = safeToDate(record.recordDate);
    return record.memberId === memberId && recordDate && recordDate >= fourWeeksAgo;
  });

  // 주간 기록 횟수 계산
  const weeklyRecords: number[] = [0, 0, 0, 0];
  recentRecords.forEach((record) => {
    const recordDate = safeToDate(record.recordDate);
    if (!recordDate) return;
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

    // 그래프 데이터 추가 (주간 출석 추이)
    const graphData = weeklyRecords.reverse().map((count, idx) => ({
      week: `${idx + 1}주 전`,
      count,
    }));

    return {
      trainerId: "", // 나중에 설정
      memberId,
      memberName,
      type: "attendanceAlert",
      priority: "high",
      title: truncateMessage(`${memberName}님 출석 줄었어요`, INSIGHT_CONFIG.MAX_TITLE_LENGTH),
      message: truncateMessage(
        TRAINER_MESSAGE_TEMPLATES.attendanceAlert.drop(memberName, dropRate, recentWeeks, previousWeeks),
        INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
      ),
      actionSuggestion: "이번 주 중 격려 메시지를 보내보세요. 예: \"요즘 어떠세요? 함께 목표 달성해봐요!\"",
      data: {
        dropRate,
        recentCount: recentWeeks,
        previousCount: previousWeeks,
        graphData,
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

  const endDate = safeToDate(member.endDate);
  if (!endDate) return null;
  const now = new Date();
  const daysUntilExpiry = Math.ceil(
    (endDate.getTime() - now.getTime()) / (24 * 60 * 60 * 1000)
  );

  // 7일 이내 종료 예정
  if (daysUntilExpiry > 0 && daysUntilExpiry <= 7) {
    const remainingSessions = member.remainingSessions ?? 0;
    const totalSessions = member.totalSessions ?? 1;
    const usedSessions = totalSessions - remainingSessions;
    const utilizationRate = Math.round((usedSessions / totalSessions) * 100);

    let priority: InsightPriority = "medium";
    let expiryMessage: string;
    let actionSuggestion: string;

    if (daysUntilExpiry <= 3) {
      priority = "high";
      expiryMessage = TRAINER_MESSAGE_TEMPLATES.ptExpiry.urgent(member.name, daysUntilExpiry, remainingSessions);
      actionSuggestion = remainingSessions > 0
        ? `${remainingSessions}회 빠르게 소진할 수 있도록 일정 제안하세요`
        : "재등록 혜택 제안: '목표 달성까지 함께 가요!' 메시지 추천";
    } else {
      // 세션 이용률 80% 이상이면 재등록 타이밍
      if (utilizationRate >= 80) {
        expiryMessage = TRAINER_MESSAGE_TEMPLATES.ptExpiry.renewal(
          member.name,
          daysUntilExpiry,
          "세션 충실히 이용 중"
        );
        actionSuggestion = "재등록 제안 타이밍: '지금까지 잘 하셨어요. 다음 단계로 가볼까요?'";
      } else {
        expiryMessage = TRAINER_MESSAGE_TEMPLATES.ptExpiry.soon(member.name, daysUntilExpiry, utilizationRate);
        actionSuggestion = remainingSessions > 0 ? "남은 세션 일정 확인" : "연장 의사 확인";
      }
    }

    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "ptExpiry",
      priority,
      title: truncateMessage(`${member.name}님 PT 곧 끝나요`, INSIGHT_CONFIG.MAX_TITLE_LENGTH),
      message: truncateMessage(expiryMessage, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
      actionSuggestion,
      data: {
        daysUntilExpiry,
        remainingSessions,
        totalSessions,
        utilizationRate,
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
    .sort((a, b) => (safeToDate(a.recordDate)?.getTime() || 0) - (safeToDate(b.recordDate)?.getTime() || 0));

  if (memberRecords.length < 1) return null;

  // 데이터가 1개만 있을 경우 기본 인사이트 제공
  if (memberRecords.length === 1) {
    const currentWeight = memberRecords[0].weight!;
    return {
      trainerId,
      memberId,
      memberName,
      type: "weightProgress",
      priority: "low",
      title: `${memberName}님 체중 기록 시작`,
      message: `현재 체중 ${currentWeight.toFixed(1)}kg. 데이터가 쌓이면 더 정확한 분석이 가능합니다.`,
      actionSuggestion: "주기적인 체중 기록을 권장해주세요.",
      data: {
        currentWeight,
        recordCount: 1,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  const latestWeight = memberRecords[memberRecords.length - 1].weight!;
  const previousWeight = memberRecords[memberRecords.length - 2].weight!;
  const weightChange = latestWeight - previousWeight;
  const changePercent = Math.abs((weightChange / previousWeight) * 100);

  // 목표 달성 분석
  if (targetWeight && Math.abs(latestWeight - targetWeight) <= 1) {
    const weeksSinceStart = Math.floor(
      (Date.now() - (safeToDate(memberRecords[0].recordDate)?.getTime() || Date.now())) /
      (7 * 24 * 60 * 60 * 1000)
    );
    const totalChange = Math.abs(latestWeight - memberRecords[0].weight!);

    return {
      trainerId,
      memberId,
      memberName,
      type: "performance",
      priority: "high",
      title: `🎉 ${memberName}님 목표 달성!`,
      message: truncateMessage(
        TRAINER_MESSAGE_TEMPLATES.weightProgress.goal(memberName, targetWeight),
        INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
      ),
      actionSuggestion: `축하 메시지: "${weeksSinceStart}주간 ${totalChange.toFixed(1)}kg 변화! 정말 잘하셨어요 🎉 다음 목표를 함께 정해봐요"`,
      data: {
        currentWeight: latestWeight,
        targetWeight,
        achieved: true,
        weeksTaken: weeksSinceStart,
        totalChange,
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
    const weeksSinceStart = Math.floor(
      (Date.now() - (safeToDate(memberRecords[0].recordDate)?.getTime() || Date.now())) /
      (7 * 24 * 60 * 60 * 1000)
    );
    const weeksCount = Math.max(1, weeksSinceStart);

    return {
      trainerId,
      memberId,
      memberName,
      type: "weightProgress",
      priority: "medium",
      title: `${memberName}님 체중 증가 감지`,
      message: truncateMessage(
        TRAINER_MESSAGE_TEMPLATES.weightProgress.reverseGoal(memberName, weightChange, "다이어트"),
        INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
      ),
      actionSuggestion: "식단 점검 필요: \"최근 식단이 어떤가요? 함께 체크해봐요\" 메시지 추천",
      data: {
        previousWeight,
        currentWeight: latestWeight,
        change: weightChange,
        changePercent,
        weeksCount,
        goal: memberGoal,
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
    const weeksSinceStart = Math.floor(
      (Date.now() - (safeToDate(memberRecords[0].recordDate)?.getTime() || Date.now())) /
      (7 * 24 * 60 * 60 * 1000)
    );
    const weeksCount = Math.max(1, weeksSinceStart);
    const remaining = targetWeight ? Math.abs(targetWeight - latestWeight) : 0;

    return {
      trainerId,
      memberId,
      memberName,
      type: "performance",
      priority: "medium",
      title: `${memberName}님 벌크업 순조로움`,
      message: truncateMessage(
        TRAINER_MESSAGE_TEMPLATES.weightProgress.gained(memberName, weightChange, weeksCount, "벌크업"),
        INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
      ),
      actionSuggestion: remaining > 0
        ? `목표까지 ${remaining.toFixed(1)}kg 남음 - "잘하고 있어요!" 격려 추천`
        : "긍정적 피드백으로 동기부여 유지",
      data: {
        previousWeight,
        currentWeight: latestWeight,
        change: weightChange,
        changePercent,
        weeksCount,
        remainingToTarget: remaining,
        goal: memberGoal,
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
 * 이탈 위험 예측 분석 (고도화 버전)
 * 5개 요소를 가중치 기반으로 종합하여 이탈 위험도 계산
 *
 * 가중치:
 * - 출석률 하락: 30%
 * - 체중 정체: 25%
 * - 메시지 무응답: 20%
 * - 남은 세션: 15%
 * - 목표 달성률: 10%
 *
 * 위험 등급:
 * - CRITICAL: 80점 이상
 * - HIGH: 60점 이상
 * - MEDIUM: 40점 이상
 * - LOW: 40점 미만
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

  // ===== 1. 출석률 하락 분석 (30%) =====
  // 최근 2주 vs 이전 2주 비교
  const memberSessions = sessions.filter((s) => s.memberId === member.id);
  const recentCompleted = memberSessions.filter(
    (s) => {
      const date = safeToDate(s.scheduledAt);
      return date && date >= twoWeeksAgo && s.status === "completed";
    }
  ).length;
  const previousCompleted = memberSessions.filter(
    (s) => {
      const date = safeToDate(s.scheduledAt);
      return date && date >= fourWeeksAgo && date < twoWeeksAgo && s.status === "completed";
    }
  ).length;

  let attendanceDropScore = 0;
  let attendanceDropPercent = 0;
  if (previousCompleted > 0) {
    attendanceDropPercent = Math.round((1 - recentCompleted / previousCompleted) * 100);
    // 30%↓=100점, 20%↓=70점, 10%↓=40점
    if (attendanceDropPercent >= 30) attendanceDropScore = 100;
    else if (attendanceDropPercent >= 20) attendanceDropScore = 70;
    else if (attendanceDropPercent >= 10) attendanceDropScore = 40;
  }
  const weightedAttendance = attendanceDropScore * 0.30;

  // ===== 2. 체중 정체 분석 (25%) =====
  // 4주간 변화, 목표 역행=100점, 2주 정체=60점
  const memberRecords = bodyRecords
    .filter((r) => r.memberId === member.id && r.weight !== undefined)
    .sort((a, b) => (safeToDate(a.recordDate)?.getTime() || 0) - (safeToDate(b.recordDate)?.getTime() || 0));

  let weightPlateauScore = 0;
  let weightPlateauWeeks = 0;
  const memberGoal = member.goal || "diet";

  if (memberRecords.length >= 2) {
    const fourWeeksRecords = memberRecords.filter(
      (r) => {
        const date = safeToDate(r.recordDate);
        return date && date >= fourWeeksAgo;
      }
    );
    if (fourWeeksRecords.length >= 2) {
      const firstWeight = fourWeeksRecords[0].weight!;
      const lastWeight = fourWeeksRecords[fourWeeksRecords.length - 1].weight!;
      const weightChange = lastWeight - firstWeight;

      // 목표 역행 체크
      const isReversingGoal =
        (memberGoal === "diet" && weightChange > 0.5) ||
        (memberGoal === "bulk" && weightChange < -0.5);

      if (isReversingGoal) {
        weightPlateauScore = 100;
        weightPlateauWeeks = 4;
      } else if (Math.abs(weightChange) < 0.5) {
        // 2주 이상 정체 확인
        const twoWeeksRecords = memberRecords.filter(
          (r) => {
            const date = safeToDate(r.recordDate);
            return date && date >= twoWeeksAgo;
          }
        );
        if (twoWeeksRecords.length >= 2) {
          const twoWeeksFirst = twoWeeksRecords[0].weight!;
          const twoWeeksLast = twoWeeksRecords[twoWeeksRecords.length - 1].weight!;
          if (Math.abs(twoWeeksLast - twoWeeksFirst) < 0.3) {
            weightPlateauScore = 60;
            weightPlateauWeeks = 2;
          }
        }
      }
    }
  }
  const weightedPlateau = weightPlateauScore * 0.25;

  // ===== 3. 메시지 무응답 분석 (20%) =====
  // 2주간 응답률: 0%=100점, 30%미만=70점, 50%미만=40점
  const memberMessages = messages.filter((m) => m.memberId === member.id);
  const trainerMessages = memberMessages.filter(
    (m) => m.senderRole === "trainer"
  );
  const memberReplies = memberMessages.filter(
    (m) => m.senderRole === "member"
  );

  let messageNoResponseScore = 0;
  let responseRate = 100;
  if (trainerMessages.length > 0) {
    responseRate = Math.round((memberReplies.length / trainerMessages.length) * 100);
    if (responseRate === 0) messageNoResponseScore = 100;
    else if (responseRate < 30) messageNoResponseScore = 70;
    else if (responseRate < 50) messageNoResponseScore = 40;
  }
  const weightedMessage = messageNoResponseScore * 0.20;

  // ===== 4. 남은 세션 분석 (15%) =====
  // 3회 이하=100점, 5회 이하=60점, 10회 이하=30점
  const remainingSessions = member.remainingSessions ?? 0;
  let remainingSessionsScore = 0;
  if (remainingSessions <= 3) remainingSessionsScore = 100;
  else if (remainingSessions <= 5) remainingSessionsScore = 60;
  else if (remainingSessions <= 10) remainingSessionsScore = 30;
  const weightedRemaining = remainingSessionsScore * 0.15;

  // ===== 5. 목표 달성률 분석 (10%) =====
  // 20%미만=80점, 50%미만=40점
  let goalProgressScore = 0;
  let goalProgress = 50; // 기본값 50%

  if (member.targetWeight && memberRecords.length >= 2) {
    const startWeight = memberRecords[0].weight!;
    const currentWeight = memberRecords[memberRecords.length - 1].weight!;
    const targetChange = Math.abs(member.targetWeight - startWeight);
    const actualChange = Math.abs(currentWeight - startWeight);

    if (targetChange > 0) {
      // 목표 방향으로 변화했는지 확인
      const isCorrectDirection =
        (memberGoal === "diet" && currentWeight < startWeight) ||
        (memberGoal === "bulk" && currentWeight > startWeight);

      goalProgress = isCorrectDirection
        ? Math.min(Math.round((actualChange / targetChange) * 100), 100)
        : 0;
    }
  }

  if (goalProgress < 20) goalProgressScore = 80;
  else if (goalProgress < 50) goalProgressScore = 40;
  const weightedGoal = goalProgressScore * 0.10;

  // ===== 최종 이탈 위험 점수 계산 =====
  const churnScore = Math.round(
    weightedAttendance + weightedPlateau + weightedMessage + weightedRemaining + weightedGoal
  );

  // 위험 등급 결정
  type RiskLevel = "CRITICAL" | "HIGH" | "MEDIUM" | "LOW";
  let riskLevel: RiskLevel;
  if (churnScore >= 80) riskLevel = "CRITICAL";
  else if (churnScore >= 60) riskLevel = "HIGH";
  else if (churnScore >= 40) riskLevel = "MEDIUM";
  else riskLevel = "LOW";

  // LOW는 인사이트 생성 안함
  if (riskLevel === "LOW") return null;

  // 위험 요소 메시지 구성
  const riskFactors: string[] = [];
  if (attendanceDropScore > 0) {
    riskFactors.push(`출석률 ${attendanceDropPercent}% 하락`);
  }
  if (weightPlateauScore > 0) {
    riskFactors.push(
      weightPlateauScore === 100 ? "목표 역행" : `${weightPlateauWeeks}주 체중 정체`
    );
  }
  if (messageNoResponseScore > 0) {
    riskFactors.push(`메시지 응답률 ${responseRate}%`);
  }
  if (remainingSessionsScore > 0) {
    riskFactors.push(`잔여 ${remainingSessions}회`);
  }
  if (goalProgressScore > 0) {
    riskFactors.push(`목표 달성 ${goalProgress}%`);
  }

  const priority: InsightPriority = riskLevel === "CRITICAL" ? "high" : "medium";

  // 간결한 메시지 생성
  let churnMessage: string;
  let actionSuggestion: string;
  const topFactors = riskFactors.slice(0, 2).join(", ");

  if (riskLevel === "CRITICAL") {
    churnMessage = TRAINER_MESSAGE_TEMPLATES.churnRisk.critical(member.name, attendanceDropPercent, topFactors);
    actionSuggestion = `즉시 전화 연락 권장: "안녕하세요! 요즘 어떠세요? 운동 스케줄 함께 조정해봐요" - 이탈 패턴 ${churnScore}점`;
  } else if (riskLevel === "HIGH") {
    churnMessage = TRAINER_MESSAGE_TEMPLATES.churnRisk.high(member.name, topFactors);
    actionSuggestion = `이번 주 중 연락: "${riskFactors[0]} 함께 해결해봐요" - 동기부여 필요`;
  } else {
    const mainIssue = riskFactors[0] || "관심 필요";
    churnMessage = TRAINER_MESSAGE_TEMPLATES.churnRisk.medium(member.name, mainIssue);
    actionSuggestion = "체크인 메시지: \"운동 어떠세요? 궁금한 점 있으면 언제든 연락주세요\"";
  }

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "churnRisk",
    priority,
    title: truncateMessage(`${member.name}님 관리 필요`, INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(churnMessage, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    actionSuggestion,
    data: {
      churnScore,
      riskLevel,
      breakdown: {
        attendanceDrop: {
          score: attendanceDropScore,
          weighted: Math.round(weightedAttendance),
          dropPercent: attendanceDropPercent,
          recentCount: recentCompleted,
          previousCount: previousCompleted,
        },
        weightPlateau: {
          score: weightPlateauScore,
          weighted: Math.round(weightedPlateau),
          weeks: weightPlateauWeeks,
        },
        messageNoResponse: {
          score: messageNoResponseScore,
          weighted: Math.round(weightedMessage),
          responseRate,
        },
        remainingSessions: {
          score: remainingSessionsScore,
          weighted: Math.round(weightedRemaining),
          remaining: remainingSessions,
        },
        goalProgress: {
          score: goalProgressScore,
          weighted: Math.round(weightedGoal),
          progress: goalProgress,
        },
      },
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
 * 수익 분석 (revenue_analysis)
 * 이번 달 완료된 세션 기반 수익 추정 및 전월 대비 변화
 */
function analyzeRevenueProgress(
  sessions: SessionData[],
  trainerId: string
): InsightData | null {
  const now = new Date();
  const thisMonthStart = new Date(now.getFullYear(), now.getMonth(), 1);
  const lastMonthStart = new Date(now.getFullYear(), now.getMonth() - 1, 1);
  const lastMonthEnd = new Date(now.getFullYear(), now.getMonth(), 0, 23, 59, 59);

  // 이번 달 완료된 세션
  const thisMonthSessions = sessions.filter((s) => {
    const date = safeToDate(s.scheduledAt);
    return date && date >= thisMonthStart && s.status === "completed";
  }).length;

  // 지난 달 완료된 세션
  const lastMonthSessions = sessions.filter((s) => {
    const date = safeToDate(s.scheduledAt);
    return date && date >= lastMonthStart && date <= lastMonthEnd && s.status === "completed";
  }).length;

  if (thisMonthSessions === 0 && lastMonthSessions === 0) return null;

  // 세션당 평균 수입 가정 (15만원)
  const avgRevenuePerSession = 15;
  const thisMonthRevenue = thisMonthSessions * avgRevenuePerSession;
  const lastMonthRevenue = lastMonthSessions * avgRevenuePerSession;

  const changePercent = lastMonthRevenue > 0
    ? Math.round(((thisMonthRevenue - lastMonthRevenue) / lastMonthRevenue) * 100)
    : 0;

  // 이번 주 완료 세션
  const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const thisWeekSessions = sessions.filter((s) => {
    const date = safeToDate(s.scheduledAt);
    return date && date >= oneWeekAgo && s.status === "completed";
  }).length;

  // 이번 주 남은 예정 세션
  const weekEnd = new Date(now.getTime() + (7 - now.getDay()) * 24 * 60 * 60 * 1000);
  const remainingThisWeek = sessions.filter((s) => {
    const date = safeToDate(s.scheduledAt);
    return date && date >= now && date <= weekEnd && s.status === "scheduled";
  }).length;

  return {
    trainerId,
    type: "performance",
    priority: "low",
    title: truncateMessage("이번 달 수익", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(
      TRAINER_MESSAGE_TEMPLATES.revenue.monthly(thisMonthSessions, thisMonthRevenue, changePercent),
      INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
    ),
    actionSuggestion: remainingThisWeek > 0
      ? `이번 주 ${remainingThisWeek}회 세션 예정 - 일정 확인하세요`
      : "다음 주 일정을 미리 계획해보세요",
    data: {
      thisMonthSessions,
      thisMonthRevenue,
      lastMonthSessions,
      lastMonthRevenue,
      changePercent,
      thisWeekSessions,
      remainingThisWeek,
      avgRevenuePerSession,
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
  const endDate = safeToDate(member.endDate);
  if (!endDate) return null;
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
      .sort((a, b) => (safeToDate(b.recordDate)?.getTime() || 0) - (safeToDate(a.recordDate)?.getTime() || 0));

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

  // 재등록 제안 메시지 구성
  let progressMessage = "";
  if (goalAchievement >= 80) {
    progressMessage = "목표 거의 달성";
  } else if (goalAchievement >= 50) {
    progressMessage = `목표 ${goalAchievement}% 달성`;
  } else {
    progressMessage = `출석률 ${attendanceRate}% 우수`;
  }

  const actionMessage = renewalLikelihood >= 80
    ? "재등록 확률 높음 - \"목표까지 함께 완주해요! 다음 단계 프로그램 준비했어요\" 제안 추천"
    : `재등록 타이밍 - "지금까지 ${goalAchievement}% 달성! 목표 완성까지 함께 가요" 메시지 추천`;

  return {
    trainerId,
    memberId: member.id,
    memberName: member.name,
    type: "renewalLikelihood",
    priority: renewalLikelihood >= 80 ? "high" : "medium",
    title: truncateMessage(`${member.name}님 재등록 제안해보세요`, INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(
      TRAINER_MESSAGE_TEMPLATES.renewal.highChance(member.name, renewalLikelihood, goalAchievement),
      INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
    ),
    actionSuggestion: actionMessage,
    data: {
      renewalLikelihood,
      goalAchievement,
      attendanceRate,
      sessionUtilization,
      daysUntilExpiry,
      progressMessage,
    },
    isRead: false,
    isActionTaken: false,
    createdAt: admin.firestore.Timestamp.now(),
    expiresAt: admin.firestore.Timestamp.fromDate(endDate),
  };
}

/**
 * 운동 볼륨 분석 (고도화 버전)
 *
 * 주간 총 볼륨 = Σ(세트 × 무게 × 횟수)
 * 트렌드: 이번 주 vs 지난 주 vs 4주 평균
 *
 * 감지 로직:
 * - 오버트레이닝: 3주 연속 20%↑ → 디로드 권장
 * - 언더트레이닝: 2주 연속 20%↓ → 경고
 * - 근육군 밸런스: 상체/하체/코어 비율 분석
 */
function analyzeWorkoutVolume(
  member: MemberData,
  sessions: SessionData[],
  trainerId: string
): InsightData | null {
  const now = new Date();
  const fiveWeeksAgo = new Date(now.getTime() - 35 * 24 * 60 * 60 * 1000);

  // 최근 5주간 세션 필터링 (볼륨 데이터가 있는 것만)
  const memberSessions = sessions.filter(
    (s) => {
      const date = safeToDate(s.scheduledAt);
      return s.memberId === member.id &&
        s.status === "completed" &&
        date && date >= fiveWeeksAgo &&
        s.workoutSets &&
        s.workoutSets.length > 0;
    }
  );

  if (memberSessions.length < 2) return null;

  // 데이터가 2-3개만 있을 경우 기본 인사이트 제공
  if (memberSessions.length < 4) {
    // 기본 볼륨 계산
    let totalVolume = 0;
    const muscleGroups = { upper: 0, lower: 0, core: 0, cardio: 0 };

    memberSessions.forEach((session) => {
      if (session.workoutSets) {
        session.workoutSets.forEach((set) => {
          const volume = set.sets * set.reps * set.weight;
          totalVolume += volume;
          muscleGroups[set.muscleGroup] += volume;
        });
      }
    });

    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutVolume",
      priority: "low",
      title: `${member.name}님 운동량 기록 시작`,
      message: `총 ${memberSessions.length}회 운동, 총 볼륨 ${Math.round(totalVolume / 1000)}톤. 데이터가 쌓이면 더 정확한 분석이 가능합니다.`,
      actionSuggestion: "꾸준한 운동 기록을 통해 트렌드 분석이 가능해집니다.",
      data: {
        volumeTrend: "initializing",
        totalVolume: Math.round(totalVolume),
        sessionCount: memberSessions.length,
        muscleGroupBalance: muscleGroups,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  // 주차별 볼륨 계산 (0: 이번 주, 1: 지난 주, ...)
  const weeklyVolumes: number[] = [0, 0, 0, 0, 0];
  const weeklyMuscleGroups: Array<{
    upper: number;
    lower: number;
    core: number;
    cardio: number;
  }> = Array(5)
    .fill(null)
    .map(() => ({ upper: 0, lower: 0, core: 0, cardio: 0 }));

  memberSessions.forEach((session) => {
    const sessionDate = safeToDate(session.scheduledAt);
    if (!sessionDate) return;
    const weeksAgo = Math.floor(
      (now.getTime() - sessionDate.getTime()) / (7 * 24 * 60 * 60 * 1000)
    );

    if (weeksAgo >= 0 && weeksAgo < 5 && session.workoutSets) {
      session.workoutSets.forEach((set) => {
        const volume = set.sets * set.reps * set.weight;
        weeklyVolumes[weeksAgo] += volume;

        // 근육군별 볼륨
        if (weeklyMuscleGroups[weeksAgo]) {
          weeklyMuscleGroups[weeksAgo][set.muscleGroup] += volume;
        }
      });
    }
  });

  // 볼륨이 0인 주는 제외하고 분석
  const validWeeks = weeklyVolumes.filter((v) => v > 0);
  if (validWeeks.length < 1) return null;

  // 데이터가 1주만 있을 경우 기본 인사이트 제공
  if (validWeeks.length === 1) {
    const thisWeekVol = weeklyVolumes.find((v) => v > 0) || 0;
    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutVolume",
      priority: "low",
      title: `${member.name}님 주간 운동량 기록`,
      message: `이번 주 총 볼륨 ${Math.round(thisWeekVol / 1000)}톤. 데이터가 쌓이면 더 정확한 분석이 가능합니다.`,
      actionSuggestion: "다음 주 운동과 비교 분석이 가능해집니다.",
      data: {
        volumeTrend: "initializing",
        thisWeekVolume: Math.round(thisWeekVol),
        weeklyVolumes: weeklyVolumes.map((v) => Math.round(v)),
        muscleGroupBalance: weeklyMuscleGroups[0],
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  const thisWeekVolume = weeklyVolumes[0];
  const lastWeekVolume = weeklyVolumes[1];
  const fourWeekAverage =
    weeklyVolumes.slice(1, 5).filter((v) => v > 0).reduce((a, b) => a + b, 0) /
    weeklyVolumes.slice(1, 5).filter((v) => v > 0).length;

  // 주간 변화율 계산
  const weeklyChanges: number[] = [];
  for (let i = 0; i < 4; i++) {
    if (weeklyVolumes[i] > 0 && weeklyVolumes[i + 1] > 0) {
      const change =
        ((weeklyVolumes[i] - weeklyVolumes[i + 1]) / weeklyVolumes[i + 1]) * 100;
      weeklyChanges.push(change);
    }
  }

  // ===== 오버트레이닝 감지: 3주 연속 20% 이상 증가 =====
  const consecutiveIncrease = weeklyChanges
    .slice(0, 3)
    .filter((c) => c >= 20).length;

  if (consecutiveIncrease >= 3) {
    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutVolume",
      priority: "high",
      title: `${member.name}님 오버트레이닝 주의`,
      message: `3주 연속 운동량 20% 이상 증가 - 디로드 주간 권장. 이번 주 ${Math.round(thisWeekVolume / 1000)}톤, 4주 평균 ${Math.round(fourWeekAverage / 1000)}톤`,
      actionSuggestion: "부상 방지를 위해 디로드 주간 계획 또는 강도 조절 필요",
      data: {
        volumeTrend: "overtraining",
        thisWeekVolume: Math.round(thisWeekVolume),
        lastWeekVolume: Math.round(lastWeekVolume),
        fourWeekAverage: Math.round(fourWeekAverage),
        weeklyVolumes: weeklyVolumes.map((v) => Math.round(v)),
        weeklyChanges: weeklyChanges.map((c) => Math.round(c)),
        consecutiveIncreaseWeeks: consecutiveIncrease,
        muscleGroupBalance: weeklyMuscleGroups[0],
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  // ===== 언더트레이닝 감지: 2주 연속 20% 이상 감소 =====
  const consecutiveDecrease = weeklyChanges
    .slice(0, 2)
    .filter((c) => c <= -20).length;

  if (consecutiveDecrease >= 2) {
    const dropPercent = Math.round(
      ((fourWeekAverage - thisWeekVolume) / fourWeekAverage) * 100
    );

    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutVolume",
      priority: "medium",
      title: `${member.name}님 운동량 감소`,
      message: `2주 연속 운동량 20% 이상 감소. 이번 주 ${Math.round(thisWeekVolume / 1000)}톤 (4주 평균 대비 ${dropPercent}%↓)`,
      actionSuggestion: "운동 지속 동기 부여 및 프로그램 점검 필요",
      data: {
        volumeTrend: "undertraining",
        thisWeekVolume: Math.round(thisWeekVolume),
        lastWeekVolume: Math.round(lastWeekVolume),
        fourWeekAverage: Math.round(fourWeekAverage),
        weeklyVolumes: weeklyVolumes.map((v) => Math.round(v)),
        weeklyChanges: weeklyChanges.map((c) => Math.round(c)),
        dropPercent,
        muscleGroupBalance: weeklyMuscleGroups[0],
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  // ===== 근육군 밸런스 분석 =====
  const thisWeekBalance = weeklyMuscleGroups[0];
  const totalVolume =
    thisWeekBalance.upper +
    thisWeekBalance.lower +
    thisWeekBalance.core +
    thisWeekBalance.cardio;

  if (totalVolume > 0) {
    const upperRatio = Math.round((thisWeekBalance.upper / totalVolume) * 100);
    const lowerRatio = Math.round((thisWeekBalance.lower / totalVolume) * 100);
    const coreRatio = Math.round((thisWeekBalance.core / totalVolume) * 100);

    // 심한 불균형 감지 (상체:하체 비율이 70:30 또는 30:70 이상)
    const isImbalanced =
      (upperRatio > 70 && lowerRatio < 30) ||
      (lowerRatio > 70 && upperRatio < 30);

    if (isImbalanced) {
      const dominant = upperRatio > lowerRatio ? "상체" : "하체";
      const weak = upperRatio > lowerRatio ? "하체" : "상체";

      return {
        trainerId,
        memberId: member.id,
        memberName: member.name,
        type: "workoutVolume",
        priority: "low",
        title: `${member.name}님 근육군 불균형`,
        message: `${dominant} 위주 운동 (상체 ${upperRatio}% / 하체 ${lowerRatio}% / 코어 ${coreRatio}%). ${weak} 운동 추가 권장`,
        actionSuggestion: `${weak} 운동 비중을 높인 프로그램 조정 권장`,
        data: {
          volumeTrend: "imbalanced",
          thisWeekVolume: Math.round(thisWeekVolume),
          fourWeekAverage: Math.round(fourWeekAverage),
          muscleGroupBalance: {
            upper: upperRatio,
            lower: lowerRatio,
            core: coreRatio,
            cardio: Math.round(
              ((thisWeekBalance.cardio || 0) / totalVolume) * 100
            ),
          },
          imbalanceType: `${dominant} 과다`,
        },
        isRead: false,
        isActionTaken: false,
        createdAt: admin.firestore.Timestamp.now(),
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
        ),
      };
    }
  }

  return null;
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
      (r) => {
        const date = safeToDate(r.recordDate);
        return r.memberId === member.id &&
          r.weight !== undefined &&
          date && date >= fourWeeksAgo;
      }
    )
    .sort((a, b) => (safeToDate(a.recordDate)?.getTime() || 0) - (safeToDate(b.recordDate)?.getTime() || 0));

  if (memberRecords.length < 1) return null;

  // 데이터가 1개만 있을 경우 기본 인사이트 제공
  if (memberRecords.length === 1) {
    const currentWeight = memberRecords[0].weight!;
    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "plateauDetection",
      priority: "low",
      title: `${member.name}님 체중 기록 시작`,
      message: `현재 체중 ${currentWeight.toFixed(1)}kg. 데이터가 쌓이면 정체기 감지가 가능합니다.`,
      actionSuggestion: "주기적인 체중 기록으로 변화 추이를 확인하세요.",
      data: {
        currentWeight,
        recordCount: 1,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 14 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  const firstWeight = memberRecords[0].weight!;
  const lastWeight = memberRecords[memberRecords.length - 1].weight!;
  const weightChange = Math.abs(lastWeight - firstWeight);

  // 4주간 체중 변화가 0.5kg 미만이면 정체기
  if (weightChange >= 0.5) return null;

  // 정체 주차 계산
  const weeksDiff = Math.ceil(
    ((safeToDate(memberRecords[memberRecords.length - 1].recordDate)?.getTime() || 0) -
      (safeToDate(memberRecords[0].recordDate)?.getTime() || 0)) /
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

  if (memberSessions.length < 2) return null;

  // 데이터가 2-3개만 있을 경우 기본 인사이트 제공
  if (memberSessions.length < 4) {
    // 운동 유형별 그룹화
    const workoutTypeCounts: Record<string, number> = {};
    memberSessions.forEach((session) => {
      const type = session.workoutType!;
      workoutTypeCounts[type] = (workoutTypeCounts[type] || 0) + 1;
    });

    const mostFrequent = Object.entries(workoutTypeCounts)
      .sort((a, b) => b[1] - a[1])[0];

    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutRecommendation",
      priority: "low",
      title: `${member.name}님 운동 패턴 분석 중`,
      message: `${memberSessions.length}회 운동 기록. 주로 ${mostFrequent?.[0] || "다양한"} 운동 수행. 데이터가 쌓이면 더 정확한 분석이 가능합니다.`,
      actionSuggestion: "더 많은 운동 기록으로 최적의 운동 추천이 가능해집니다.",
      data: {
        sessionCount: memberSessions.length,
        workoutTypeCounts,
        mostFrequentWorkout: mostFrequent?.[0],
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  const memberRecords = bodyRecords
    .filter((r) => r.memberId === member.id && r.bodyFat !== undefined)
    .sort((a, b) => (safeToDate(a.recordDate)?.getTime() || 0) - (safeToDate(b.recordDate)?.getTime() || 0));

  if (memberRecords.length < 1) return null;

  // 데이터가 1개만 있을 경우 기본 인사이트 제공
  if (memberRecords.length === 1) {
    const currentBodyFat = memberRecords[0].bodyFat!;
    return {
      trainerId,
      memberId: member.id,
      memberName: member.name,
      type: "workoutRecommendation",
      priority: "low",
      title: `${member.name}님 체지방 기록 시작`,
      message: `현재 체지방률 ${currentBodyFat.toFixed(1)}%. 데이터가 쌓이면 운동 효과 분석이 가능합니다.`,
      actionSuggestion: "주기적인 체성분 기록으로 운동 효과를 측정하세요.",
      data: {
        currentBodyFat,
        recordCount: 1,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      ),
    };
  }

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
      const sessionDate = safeToDate(session.scheduledAt);
      if (!sessionDate) return;
      const beforeRecord = memberRecords.find(
        (r) => {
          const rDate = safeToDate(r.recordDate);
          return rDate && rDate <= sessionDate;
        }
      );
      const afterRecord = memberRecords.find(
        (r) => {
          const rDate = safeToDate(r.recordDate);
          return rDate &&
            rDate > sessionDate &&
            rDate.getTime() - sessionDate.getTime() < 7 * 24 * 60 * 60 * 1000;
        }
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

  if (totalSessions.length < 3) return null;

  // 데이터가 3-9개인 경우 기본 인사이트 제공
  if (totalSessions.length < 10) {
    const noshowCount = noshowSessions.length;
    const overallRate = totalSessions.length > 0
      ? Math.round((noshowCount / totalSessions.length) * 100)
      : 0;

    return {
      trainerId,
      type: "noshowPattern",
      priority: "low",
      title: "노쇼 패턴 분석 중",
      message: `총 ${totalSessions.length}회 세션 중 ${noshowCount}회 노쇼 (${overallRate}%). 데이터가 쌓이면 더 정확한 분석이 가능합니다.`,
      actionSuggestion: "더 많은 세션 데이터로 요일/시간대별 패턴 분석이 가능해집니다.",
      data: {
        totalSessions: totalSessions.length,
        noshowCount,
        overallNoshowRate: overallRate,
      },
      isRead: false,
      isActionTaken: false,
      createdAt: admin.firestore.Timestamp.now(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)
      ),
    };
  }

  const overallNoshowRate = noshowSessions.length / totalSessions.length;
  if (overallNoshowRate < 0.1) return null; // 전체 노쇼율 10% 미만이면 스킵

  // 요일별 노쇼율 계산
  const dayNames = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"];
  const dayStats: Record<number, { total: number; noshow: number }> = {};

  for (let i = 0; i < 7; i++) {
    dayStats[i] = {total: 0, noshow: 0};
  }

  totalSessions.forEach((session) => {
    const date = safeToDate(session.scheduledAt);
    if (!date) return;
    const day = date.getDay();
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
    const date = safeToDate(session.scheduledAt);
    if (!date) return;
    const hour = date.getHours();
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
        (r) => {
          const date = safeToDate(r.recordDate);
          return r.memberId === member.id &&
            r.bodyFat !== undefined &&
            date && date >= monthStart;
        }
      )
      .sort((a, b) => (safeToDate(a.recordDate)?.getTime() || 0) - (safeToDate(b.recordDate)?.getTime() || 0));

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

  if (memberChanges.length < 2) return null;

  // 데이터가 2명만 있을 경우 기본 인사이트 제공
  if (memberChanges.length === 2) {
    memberChanges.sort((a, b) => b.bodyFatChange - a.bodyFatChange);
    const top2 = memberChanges.slice(0, 2);
    const rankingMessage = top2
      .map(
        (m, index) =>
          `${index + 1}위 ${m.memberName}(${m.bodyFatChange > 0 ? "-" : "+"}${Math.abs(m.bodyFatChange).toFixed(1)}kg)`
      )
      .join(", ");

    return {
      trainerId,
      type: "performanceRanking",
      priority: "low",
      title: "이번 달 체지방 감량 현황",
      message: `이번 달 체지방 감량: ${rankingMessage}. 데이터가 쌓이면 더 정확한 랭킹 분석이 가능합니다.`,
      data: {
        rankings: top2.map((m, index) => ({
          rank: index + 1,
          memberName: m.memberName,
          memberId: m.memberId,
          change: m.bodyFatChange,
        })),
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
    const openai = getOpenAIClient();

    // 데이터 요약 생성
    const memberSummaries = members.map((member) => {
      const memberRecords = bodyRecords
        .filter((r) => r.memberId === member.id)
        .sort((a, b) =>
          (safeToDate(b.recordDate)?.getTime() || 0) - (safeToDate(a.recordDate)?.getTime() || 0)
        );

      const latestRecord = memberRecords[0];
      const endDateParsed = member.endDate ? safeToDate(member.endDate) : null;
      const daysUntilExpiry = endDateParsed
        ? Math.ceil(
          (endDateParsed.getTime() - Date.now()) /
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

    const result = await openai.chat.completions.create({
      model: "gpt-4o-mini",
      messages: [{role: "user", content: prompt}],
      temperature: 0.7,
      response_format: {type: "json_object"},
    });

    const text = result.choices[0]?.message?.content || "{}";
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
    .collection(Collections.MEMBERS)
    .where("trainerId", "==", trainerId)
    .get();

  // 2. 회원 이름 조회를 위해 users 컬렉션과 조인
  const userIds = membersSnapshot.docs
    .map((doc) => doc.data().userId)
    .filter((id): id is string => !!id);

  // userId로 사용자 정보 배치 조회 (10개씩 나눠서 조회 - Firestore 'in' 제한)
  const usersMap = new Map<string, {name?: string}>();
  for (let i = 0; i < userIds.length; i += 10) {
    const batchIds = userIds.slice(i, i + 10);
    if (batchIds.length > 0) {
      const usersSnapshot = await db
        .collection(Collections.USERS)
        .where(admin.firestore.FieldPath.documentId(), "in", batchIds)
        .get();
      usersSnapshot.docs.forEach((doc) => {
        usersMap.set(doc.id, doc.data() as {name?: string});
      });
    }
  }

  // members 데이터에 이름 매핑
  const members: MemberData[] = membersSnapshot.docs.map((doc) => {
    const data = doc.data();
    const userData = usersMap.get(data.userId);
    return {
      id: doc.id,
      name: userData?.name || "회원",
      ...data,
    };
  }) as MemberData[];

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
      .collection(Collections.BODY_RECORDS)
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
      .collection(Collections.SCHEDULES)
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

  // chat_rooms에서 트레이너의 채팅방 조회 → chatRoomId-memberId 매핑
  const chatRoomsSnapshot = await db
    .collection(Collections.CHAT_ROOMS)
    .where("trainerId", "==", trainerId)
    .get();

  const chatRoomToMember: Record<string, string> = {};
  const chatRoomIds: string[] = [];
  chatRoomsSnapshot.docs.forEach((doc) => {
    const data = doc.data();
    chatRoomToMember[doc.id] = data.memberId;
    chatRoomIds.push(doc.id);
  });

  // chatRoomId로 메시지 조회 (10개씩 배치 - Firestore 'in' 제한)
  for (let i = 0; i < chatRoomIds.length; i += batchSize) {
    const batchIds = chatRoomIds.slice(i, i + batchSize);
    const messagesSnapshot = await db
      .collection(Collections.MESSAGES)
      .where("chatRoomId", "in", batchIds)
      .where(
        "createdAt",
        ">=",
        admin.firestore.Timestamp.fromDate(twoWeeksAgo)
      )
      .get();

    messagesSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      messages.push({
        memberId: chatRoomToMember[data.chatRoomId] || "",
        chatRoomId: data.chatRoomId,
        senderId: data.senderId,
        senderRole: data.senderRole,
        createdAt: data.createdAt,
      });
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

    // 3-6. 운동 볼륨 분석
    const volumeInsight = analyzeWorkoutVolume(member, sessions, trainerId);
    if (volumeInsight) {
      insights.push(volumeInsight);
    }

    // 3-7. 정체기 감지
    const plateauInsight = analyzePlateauDetection(
      member,
      bodyRecords,
      trainerId
    );
    if (plateauInsight) {
      insights.push(plateauInsight);
    }

    // 3-8. 최적 운동 추천
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

  // 3-9. 노쇼 패턴 분석 (트레이너 전체)
  const noshowInsight = analyzeNoshowPattern(sessions, trainerId);
  if (noshowInsight) {
    insights.push(noshowInsight);
  }

  // 3-10. 회원 성과 랭킹 (트레이너 전체)
  const rankingInsight = analyzePerformanceRanking(members, bodyRecords, trainerId);
  if (rankingInsight) {
    insights.push(rankingInsight);
  }

  // 3-11. 수익 분석
  const revenueInsight = analyzeRevenueProgress(sessions, trainerId);
  if (revenueInsight) {
    insights.push(revenueInsight);
  }

  // 3-12. AI 기반 종합 추천 (옵션)
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
      workoutVolume: insights.filter((i) => i.type === "workoutVolume").length,
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

  // 3-12. 우선순위 기반 필터링 및 정렬 (트레이너용)
  // 필수 타입은 항상 포함, 나머지는 점수순으로 상위 N개만
  const requiredInsights = insights.filter((i) =>
    TRAINER_INSIGHT_CONFIG.REQUIRED_TYPES.includes(i.type)
  );
  const optionalInsights = insights.filter((i) =>
    !TRAINER_INSIGHT_CONFIG.REQUIRED_TYPES.includes(i.type)
  );

  const sortedOptional = optionalInsights
    .map((insight) => ({
      ...insight,
      score: calculateInsightScore(insight.type, insight.priority, true),
    }))
    .sort((a, b) => b.score - a.score)
    .slice(0, Math.max(0, INSIGHT_CONFIG.MAX_INSIGHTS_DISPLAY - requiredInsights.length))
    .map(({score: _score, ...insight}) => insight);

  // 필수 인사이트 + 상위 선택 인사이트 합치기
  const filteredInsights = [...requiredInsights, ...sortedOptional]
    .slice(0, INSIGHT_CONFIG.MAX_INSIGHTS_DISPLAY * 2); // 트레이너는 더 많은 인사이트 허용

  functions.logger.info("[generateInsightsForTrainer] 필터링 완료", {
    beforeCount: insights.length,
    afterCount: filteredInsights.length,
    requiredCount: requiredInsights.length,
  });

  // insights를 filteredInsights로 교체
  insights.length = 0;
  insights.push(...filteredInsights);

  // 4. 기존 중복 인사이트 제거 (같은 타입, 같은 회원의 24시간 이내 인사이트)
  const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const existingInsightsSnapshot = await db
    .collection(Collections.INSIGHTS)
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

  // 5. Firestore에 인사이트 저장 (undefined 값 제거)
  if (newInsights.length > 0) {
    const batch = db.batch();
    newInsights.forEach((insight) => {
      const docRef = db.collection(Collections.INSIGHTS).doc();
      const cleanInsight = JSON.parse(JSON.stringify(insight));
      batch.set(docRef, cleanInsight);
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
        .collection(Collections.TRAINERS)
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
  .pubsub.schedule("0 7 * * *") // 매일 오전 7시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const startTime = Date.now();
    functions.logger.info("[generateInsightsScheduled] 스케줄 실행 시작");

    try {
      // 모든 트레이너 조회
      const trainersSnapshot = await db
        .collection(Collections.TRAINERS)
        .get();

      functions.logger.info("[generateInsightsScheduled] 트레이너 조회 완료", {
        trainerCount: trainersSnapshot.size,
      });

      let totalInsights = 0;
      let successCount = 0;
      let errorCount = 0;

      // 각 트레이너에 대해 인사이트 생성 (AI 포함)
      for (const trainerDoc of trainersSnapshot.docs) {
        const trainerId = trainerDoc.id;

        try {
          const result = await generateInsightsForTrainer(trainerId, true);
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

/**
 * 주간 AI 인사이트 생성 스케줄 함수
 *
 * @description
 * 매주 월요일 오전 8시에 모든 활성 트레이너에 대해 AI 추천 인사이트를 생성합니다.
 * 주간 분석이므로 AI 추천을 활성화하여 더 심층적인 분석을 제공합니다.
 *
 * @fires pubsub.schedule
 * @region asia-northeast3
 * @schedule 매주 월요일 오전 7시 (Asia/Seoul)
 */
export const generateInsightsWeekly = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 7 * * 1") // 매주 월요일 오전 7시
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const startTime = Date.now();
    functions.logger.info("[generateInsightsWeekly] 주간 스케줄 실행 시작");

    try {
      // 모든 트레이너 조회
      const trainersSnapshot = await db
        .collection(Collections.TRAINERS)
        .get();

      functions.logger.info("[generateInsightsWeekly] 트레이너 조회 완료", {
        trainerCount: trainersSnapshot.size,
      });

      let totalInsights = 0;
      let successCount = 0;
      let errorCount = 0;

      // 각 트레이너에 대해 AI 인사이트 생성
      for (const trainerDoc of trainersSnapshot.docs) {
        const trainerId = trainerDoc.id;

        try {
          // 주간 분석이므로 AI 추천 활성화 (true)
          const result = await generateInsightsForTrainer(trainerId, true);
          totalInsights += result.stats.newSaved;
          successCount++;

          functions.logger.info("[generateInsightsWeekly] 트레이너 처리 완료", {
            trainerId,
            newInsights: result.stats.newSaved,
          });

          // AI API 레이트 리밋 방지를 위한 지연 (AI 사용 시 더 긴 지연)
          await new Promise((resolve) => setTimeout(resolve, 500));
        } catch (trainerError) {
          errorCount++;
          functions.logger.error("[generateInsightsWeekly] 트레이너 처리 실패", {
            trainerId,
            error: trainerError instanceof Error ? trainerError.message : trainerError,
          });
        }
      }

      const duration = Date.now() - startTime;
      functions.logger.info("[generateInsightsWeekly] 주간 스케줄 실행 완료", {
        totalTrainers: trainersSnapshot.size,
        successCount,
        errorCount,
        totalInsights,
        durationMs: duration,
      });

      return null;
    } catch (error) {
      functions.logger.error("[generateInsightsWeekly] 주간 스케줄 실행 실패", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });

/**
 * 세션 완료 시 트리거되는 인사이트 갱신
 *
 * @description
 * 세션이 완료로 변경될 때 해당 트레이너의 관련 인사이트를 갱신합니다.
 * 출석률, 이탈 위험, 노쇼 패턴 등 세션 관련 인사이트가 갱신됩니다.
 *
 * @fires firestore.document.onUpdate
 * @region asia-northeast3
 */
export const onSessionUpdated = functions
  .region("asia-northeast3")
  .firestore.document("sessions/{sessionId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // status가 completed로 변경되었을 때만 실행
    if (before.status === after.status || after.status !== "completed") {
      return null;
    }

    const trainerId = after.trainerId;
    if (!trainerId) {
      functions.logger.warn("[onSessionUpdated] trainerId 없음", {
        sessionId: context.params.sessionId,
      });
      return null;
    }

    functions.logger.info("[onSessionUpdated] 세션 완료 감지", {
      sessionId: context.params.sessionId,
      trainerId,
      memberId: after.memberId,
    });

    try {
      // 인사이트 갱신 (AI 추천 비활성화로 빠른 처리)
      await generateInsightsForTrainer(trainerId, false);

      functions.logger.info("[onSessionUpdated] 인사이트 갱신 완료", {
        trainerId,
      });

      return null;
    } catch (error) {
      functions.logger.error("[onSessionUpdated] 인사이트 갱신 실패", {
        error: error instanceof Error ? error.message : error,
      });
      return null;
    }
  });

/**
 * 체성분 기록 생성 시 트리거되는 인사이트 갱신
 *
 * @description
 * 새로운 체성분 기록이 추가될 때 관련 인사이트를 갱신합니다.
 * 체중 변화, 정체기 감지, 목표 달성률 등 체성분 관련 인사이트가 갱신됩니다.
 *
 * @fires firestore.document.onCreate
 * @region asia-northeast3
 */
export const onBodyRecordCreated = functions
  .region("asia-northeast3")
  .firestore.document("body_records/{recordId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const memberId = data.memberId;

    if (!memberId) {
      functions.logger.warn("[onBodyRecordCreated] memberId 없음", {
        recordId: context.params.recordId,
      });
      return null;
    }

    functions.logger.info("[onBodyRecordCreated] 체성분 기록 생성 감지", {
      recordId: context.params.recordId,
      memberId,
    });

    try {
      // 회원의 트레이너 찾기
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        return null;
      }

      const trainerId = memberDoc.data()?.trainerId;
      if (!trainerId) {
        return null;
      }

      // 인사이트 갱신
      await generateInsightsForTrainer(trainerId, false);

      functions.logger.info("[onBodyRecordCreated] 인사이트 갱신 완료", {
        trainerId,
        memberId,
      });

      return null;
    } catch (error) {
      functions.logger.error("[onBodyRecordCreated] 인사이트 갱신 실패", {
        error: error instanceof Error ? error.message : error,
      });
      return null;
    }
  });

/**
 * 인바디 기록 생성 시 트리거되는 인사이트 갱신
 *
 * @fires firestore.document.onCreate
 * @region asia-northeast3
 */
export const onInbodyRecordCreated = functions
  .region("asia-northeast3")
  .firestore.document("inbody_records/{recordId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    const memberId = data.memberId;

    if (!memberId) {
      functions.logger.warn("[onInbodyRecordCreated] memberId 없음", {
        recordId: context.params.recordId,
      });
      return null;
    }

    functions.logger.info("[onInbodyRecordCreated] 인바디 기록 생성 감지", {
      recordId: context.params.recordId,
      memberId,
    });

    try {
      // 회원의 트레이너 찾기
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        return null;
      }

      const trainerId = memberDoc.data()?.trainerId;
      if (!trainerId) {
        return null;
      }

      // 인사이트 갱신
      await generateInsightsForTrainer(trainerId, false);

      functions.logger.info("[onInbodyRecordCreated] 인사이트 갱신 완료", {
        trainerId,
        memberId,
      });

      return null;
    } catch (error) {
      functions.logger.error("[onInbodyRecordCreated] 인사이트 갱신 실패", {
        error: error instanceof Error ? error.message : error,
      });
      return null;
    }
  });
