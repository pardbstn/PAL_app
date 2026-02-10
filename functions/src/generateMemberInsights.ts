/**
 * 회원용 AI 인사이트 생성 Cloud Function
 * 회원의 운동, 체성분, 출석, 영양 데이터를 분석하여 동기부여 인사이트 생성
 *
 * @module generateMemberInsights
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import {db, safeToDate} from "./utils/firestore";
import {Collections} from "./constants/collections";
import {
  INSIGHT_CONFIG,
  calculateInsightScore,
  truncateMessage,
  MEMBER_MESSAGE_TEMPLATES,
} from "./constants/insightConfig";

// 인사이트 타입 정의
type MemberInsightType =
  | "body_prediction"
  | "workout_achievement"
  | "attendance_habit"
  | "nutrition_balance"
  | "body_change_report"
  | "condition_pattern"
  | "goal_progress"
  | "benchmarking";

type InsightPriority = "high" | "medium" | "low";

interface MemberInsight {
  type: MemberInsightType;
  priority: InsightPriority;
  title: string;
  message: string;
  graphData?: unknown[];
  graphType?: string;
  data?: Record<string, unknown>;
}

interface BodyRecord {
  memberId: string;
  weight?: number;
  bodyFat?: number;
  muscleMass?: number;
  measuredAt?: admin.firestore.Timestamp;
  recordDate?: admin.firestore.Timestamp;
  createdAt?: admin.firestore.Timestamp;
}

interface InbodyRecord {
  memberId: string;
  weight?: number;
  bodyFatMass?: number;
  bodyFatPercent?: number;
  skeletalMuscleMass?: number;
  measuredAt?: admin.firestore.Timestamp;
  createdAt?: admin.firestore.Timestamp;
}

interface WorkoutRecord {
  memberId: string;
  exerciseName: string;
  weight?: number;
  reps?: number;
  sets?: number;
  oneRM?: number;
  createdAt?: admin.firestore.Timestamp;
}

interface ScheduleRecord {
  memberId: string;
  status: string;
  date?: admin.firestore.Timestamp;
  scheduledAt?: admin.firestore.Timestamp;
}

interface DietRecord {
  memberId: string;
  calories?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
  analyzedAt?: admin.firestore.Timestamp;
}

interface MemberData {
  id: string;
  name: string;
  goal?: string;
  targetWeight?: number;
  targetBodyFat?: number;
  targetMuscleMass?: number;
  gender?: "male" | "female";
  birthDate?: admin.firestore.Timestamp;
  height?: number;
  startWeight?: number;
  startBodyFat?: number;
}

// 연령대 계산 헬퍼
function getAgeGroup(birthDate?: unknown): string {
  if (!birthDate) return "unknown";
  const birth = safeToDate(birthDate);
  if (!birth) return "unknown";
  const today = new Date();
  const age = today.getFullYear() - birth.getFullYear();
  if (age < 30) return "20s";
  if (age < 40) return "30s";
  if (age < 50) return "40s";
  return "50s+";
}

// BMI 범위 계산 헬퍼
function getBmiRange(weight?: number, height?: number): string {
  if (!weight || !height) return "unknown";
  const heightM = height / 100;
  const bmi = weight / (heightM * heightM);
  if (bmi < 18.5) return "underweight";
  if (bmi < 23) return "normal";
  if (bmi < 25) return "overweight";
  return "obese";
}

/**
 * 1. 체성분 예측 (body_prediction)
 * 최근 4주간 체중 트렌드를 분석하여 4주 후 예측
 */
function generateBodyPrediction(
  bodyRecords: BodyRecord[],
  inbodyRecords: InbodyRecord[],
  member: MemberData
): MemberInsight | null {
  // 최근 4주 데이터 필터링
  const fourWeeksAgo = new Date();
  fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

  // body_records와 inbody_records 통합
  const weightData: Array<{weight: number; date: Date}> = [];

  bodyRecords.forEach((record) => {
    if (record.weight) {
      const date = safeToDate(record.measuredAt || record.recordDate || record.createdAt);
      if (date && date >= fourWeeksAgo) {
        weightData.push({weight: record.weight, date});
      }
    }
  });

  inbodyRecords.forEach((record) => {
    if (record.weight) {
      const date = safeToDate(record.measuredAt || record.createdAt);
      if (date && date >= fourWeeksAgo) {
        weightData.push({weight: record.weight, date});
      }
    }
  });

  if (weightData.length === 0) {
    return null;
  }

  // 데이터가 1개인 경우 fallback 인사이트 반환
  if (weightData.length === 1) {
    const currentWeight = weightData[0].weight;
    return {
      type: "body_prediction",
      priority: "low",
      title: "체성분 예측",
      message: `현재 체중 ${currentWeight.toFixed(1)}kg - 1회 더 기록하면 예측 가능!`,
      graphData: [{
        x: 0,
        y: currentWeight,
        date: weightData[0].date.toISOString().split("T")[0],
        isPrediction: false,
      }],
      graphType: "line",
      data: {
        currentWeight,
        needsMoreData: true,
      },
    };
  }

  // 날짜순 정렬
  weightData.sort((a, b) => a.date.getTime() - b.date.getTime());

  // 선형 회귀로 트렌드 계산
  const n = weightData.length;
  const xValues = weightData.map((d, i) => i);
  const yValues = weightData.map((d) => d.weight);

  const sumX = xValues.reduce((a, b) => a + b, 0);
  const sumY = yValues.reduce((a, b) => a + b, 0);
  const sumXY = xValues.reduce((total, x, i) => total + x * yValues[i], 0);
  const sumXX = xValues.reduce((total, x) => total + x * x, 0);

  const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
  const intercept = (sumY - slope * sumX) / n;

  // 4주 후 예측
  const weeksAhead = 4;
  const pointsPerWeek = Math.max(1, n / 4);
  const futureIndex = n + (weeksAhead * pointsPerWeek);
  const predictedWeight = intercept + slope * futureIndex;

  const currentWeight = weightData[weightData.length - 1].weight;
  const weightChange = predictedWeight - currentWeight;
  const targetWeight = member.targetWeight;

  // 그래프 데이터 생성 (과거 + 예측)
  const graphData = weightData.map((d, i) => ({
    x: i,
    y: d.weight,
    date: d.date.toISOString().split("T")[0],
    isPrediction: false,
  }));

  // 예측 포인트 추가
  for (let week = 1; week <= 4; week++) {
    const idx = n + (week * pointsPerWeek);
    graphData.push({
      x: idx,
      y: parseFloat((intercept + slope * idx).toFixed(1)),
      date: new Date(Date.now() + week * 7 * 24 * 60 * 60 * 1000)
        .toISOString().split("T")[0],
      isPrediction: true,
    });
  }

  // 메시지 생성 (간결하게)
  let message: string;
  let priority: InsightPriority = "medium";

  // 주간 변화율 계산
  const weeklyChange = Math.abs(weightChange / 4);

  if (targetWeight && Math.abs(predictedWeight - targetWeight) <= 2) {
    // 목표 도달 예정
    const weeksToGoal = Math.ceil(Math.abs(targetWeight - currentWeight) / weeklyChange);
    message = MEMBER_MESSAGE_TEMPLATES.body_prediction.goalReach(weeksToGoal, targetWeight);
    priority = "high";
  } else if (weightChange < -0.5) {
    message = MEMBER_MESSAGE_TEMPLATES.body_prediction.loss(
      parseFloat(Math.abs(weightChange).toFixed(1)),
      parseFloat(weeklyChange.toFixed(1))
    );
    priority = "medium";
  } else if (weightChange > 0.5) {
    message = MEMBER_MESSAGE_TEMPLATES.body_prediction.gain(
      parseFloat(weightChange.toFixed(1)),
      parseFloat(weeklyChange.toFixed(1))
    );
    priority = "medium";
  } else {
    message = MEMBER_MESSAGE_TEMPLATES.body_prediction.stable();
    priority = "low";
  }

  return {
    type: "body_prediction",
    priority,
    title: truncateMessage("체성분 예측", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(message, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    graphData,
    graphType: "line",
    data: {
      currentWeight,
      predictedWeight: parseFloat(predictedWeight.toFixed(1)),
      weightChange: parseFloat(weightChange.toFixed(1)),
      weeklyChange: parseFloat(weeklyChange.toFixed(2)),
      targetWeight,
    },
  };
}

/**
 * 2. 운동 성과 (workout_achievement)
 * 1RM 변화가 가장 큰 운동 찾기
 */
function generateWorkoutAchievement(
  workoutRecords: WorkoutRecord[]
): MemberInsight | null {
  if (workoutRecords.length === 0) {
    return null;
  }

  // 데이터가 1개인 경우 fallback 인사이트 반환
  if (workoutRecords.length === 1) {
    const record = workoutRecords[0];
    const exerciseName = record.exerciseName || "운동";
    return {
      type: "workout_achievement",
      priority: "low",
      title: "운동 성과",
      message: `첫 운동 기록! ${exerciseName} - 계속 기록하면 성장 추이를 볼 수 있어요`,
      graphData: [],
      graphType: "text",
      data: {
        exercise: exerciseName,
        needsMoreData: true,
      },
    };
  }

  // 운동별로 그룹화
  const exerciseGroups: Map<string, Array<{oneRM: number; date: Date}>> = new Map();

  workoutRecords.forEach((record) => {
    if (!record.exerciseName) return;

    // 1RM 계산 (Brzycki 공식: weight * (36 / (37 - reps)))
    let oneRM = record.oneRM;
    if (!oneRM && record.weight && record.reps && record.reps > 0 && record.reps < 37) {
      oneRM = record.weight * (36 / (37 - record.reps));
    }
    if (!oneRM) return;

    const date = safeToDate(record.createdAt);
    if (!date) return;

    const existing = exerciseGroups.get(record.exerciseName) || [];
    existing.push({oneRM, date});
    exerciseGroups.set(record.exerciseName, existing);
  });

  // 각 운동의 1RM 변화 계산
  let bestExercise = "";
  let bestImprovement = 0;
  let latestRM = 0;
  let oldestRM = 0;

  exerciseGroups.forEach((records, exerciseName) => {
    if (records.length < 2) return;

    // 날짜순 정렬
    records.sort((a, b) => a.date.getTime() - b.date.getTime());

    // 4주 전 데이터와 비교
    const fourWeeksAgo = new Date();
    fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

    const oldRecords = records.filter((r) => r.date < fourWeeksAgo);
    const recentRecords = records.filter((r) => r.date >= fourWeeksAgo);

    if (oldRecords.length > 0 && recentRecords.length > 0) {
      const oldAvg = oldRecords.reduce((sum, r) => sum + r.oneRM, 0) / oldRecords.length;
      const recentMax = Math.max(...recentRecords.map((r) => r.oneRM));
      const improvement = recentMax - oldAvg;

      if (improvement > bestImprovement) {
        bestImprovement = improvement;
        bestExercise = exerciseName;
        latestRM = recentMax;
        oldestRM = oldAvg;
      }
    }
  });

  if (!bestExercise || bestImprovement <= 0) {
    // 최근 운동 중 최고 성과 찾기 (개선 없더라도)
    exerciseGroups.forEach((records, exerciseName) => {
      const maxRM = Math.max(...records.map((r) => r.oneRM));
      if (maxRM > latestRM) {
        latestRM = maxRM;
        bestExercise = exerciseName;
      }
    });

    if (!bestExercise) return null;

    return {
      type: "workout_achievement",
      priority: "low",
      title: truncateMessage("운동 성과", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
      message: truncateMessage(
        MEMBER_MESSAGE_TEMPLATES.workout_achievement.best(bestExercise, parseFloat(latestRM.toFixed(0))),
        INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
      ),
      graphData: exerciseGroups.get(bestExercise)?.map((r) => ({
        x: r.date.toISOString().split("T")[0],
        y: parseFloat(r.oneRM.toFixed(1)),
      })) || [],
      graphType: "line",
      data: {
        exercise: bestExercise,
        currentRM: latestRM,
      },
    };
  }

  // 그래프 데이터 생성
  const exerciseData = exerciseGroups.get(bestExercise) || [];
  const graphData = exerciseData.map((r) => ({
    x: r.date.toISOString().split("T")[0],
    y: parseFloat(r.oneRM.toFixed(1)),
  }));

  // 다음 목표 계산 (10kg 단위)
  const nextTarget = Math.ceil(latestRM / 10) * 10;

  // 개선 기간 계산
  const firstDate = exerciseData.find((r) => r.oneRM === oldestRM)?.date;
  const lastDate = exerciseData[exerciseData.length - 1].date;
  const weeksBetween = firstDate && lastDate
    ? Math.max(1, Math.floor((lastDate.getTime() - firstDate.getTime()) / (7 * 24 * 60 * 60 * 1000)))
    : 4;

  return {
    type: "workout_achievement",
    priority: "high",
    title: truncateMessage("운동 성과", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(
      MEMBER_MESSAGE_TEMPLATES.workout_achievement.improved(
        bestExercise,
        parseFloat(bestImprovement.toFixed(0)),
        weeksBetween
      ),
      INSIGHT_CONFIG.MAX_MESSAGE_LENGTH
    ),
    graphData,
    graphType: "line",
    data: {
      exercise: bestExercise,
      previousRM: parseFloat(oldestRM.toFixed(1)),
      currentRM: parseFloat(latestRM.toFixed(1)),
      improvement: parseFloat(bestImprovement.toFixed(1)),
      weeksBetween,
      nextTarget,
    },
  };
}

/**
 * 3. 출석 습관 (attendance_habit)
 * 출석률 계산 및 퍼센타일 분석
 */
async function generateAttendanceHabit(
  schedules: ScheduleRecord[],
  _memberId: string
): Promise<MemberInsight | null> {
  const fourWeeksAgo = new Date();
  fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

  // 최근 4주 출석 데이터
  const recentSchedules = schedules.filter((s) => {
    const date = safeToDate(s.date || s.scheduledAt);
    return date && date >= fourWeeksAgo;
  });

  if (recentSchedules.length === 0) {
    return null;
  }

  // 완료된 세션 수 (개인모드: 과거 예정 일정도 출석으로 간주)
  const now = new Date();
  const completed = recentSchedules.filter((s) => {
    if (s.status === "completed" || s.status === "attended") return true;
    // 과거 날짜의 "scheduled" 상태는 출석으로 간주 (취소/노쇼 아닌 경우)
    if (s.status === "scheduled" || !s.status) {
      const date = safeToDate(s.date || s.scheduledAt);
      if (date && date < now) return true;
    }
    return false;
  }).length;
  const total = recentSchedules.filter((s) =>
    s.status !== "cancelled"
  ).length;
  const attendanceRate = total > 0 ? Math.round((completed / total) * 100) : 0;

  // 주간 출석 데이터 계산
  const weeklyData: number[] = [0, 0, 0, 0];
  recentSchedules.forEach((s) => {
    const date = safeToDate(s.date || s.scheduledAt);
    if (!date) return;

    const weeksAgo = Math.floor(
      (Date.now() - date.getTime()) / (7 * 24 * 60 * 60 * 1000)
    );
    // 완료 또는 과거 예정 일정(취소/노쇼 아닌 것) 모두 출석으로 간주
    const isAttended =
      s.status === "completed" || s.status === "attended" ||
      ((s.status === "scheduled" || !s.status) && date < now);
    if (weeksAgo >= 0 && weeksAgo < 4 && isAttended && s.status !== "cancelled") {
      weeklyData[3 - weeksAgo]++; // 오래된 주부터 최근 순으로
    }
  });

  // 전체 회원 중 퍼센타일 계산 (간소화: 고정 기준 사용)
  let percentile: number;
  if (attendanceRate >= 90) percentile = 10;
  else if (attendanceRate >= 80) percentile = 20;
  else if (attendanceRate >= 70) percentile = 30;
  else if (attendanceRate >= 60) percentile = 50;
  else percentile = 70;

  // 그래프 데이터
  const graphData = weeklyData.map((count, i) => ({
    week: `${4 - i}주 전`,
    value: count,
  }));

  // 연속 출석 계산
  let currentStreak = 0;
  for (let i = 0; i < weeklyData.length; i++) {
    if (weeklyData[weeklyData.length - 1 - i] > 0) {
      currentStreak++;
    } else {
      break;
    }
  }

  // 메시지 생성 (간결하게)
  let message: string;
  let priority: InsightPriority;

  if (attendanceRate >= 80) {
    message = MEMBER_MESSAGE_TEMPLATES.attendance_habit.good(attendanceRate, currentStreak);
    priority = "medium";
  } else if (attendanceRate >= 60) {
    message = MEMBER_MESSAGE_TEMPLATES.attendance_habit.average(attendanceRate);
    priority = "medium";
  } else {
    // 마지막 운동한 날 계산
    const lastSession = recentSchedules
      .filter((s) => s.status === "completed" || s.status === "attended")
      .sort((a, b) => {
        const dateA = safeToDate(a.date || a.scheduledAt)?.getTime() || 0;
        const dateB = safeToDate(b.date || b.scheduledAt)?.getTime() || 0;
        return dateB - dateA;
      })[0];

    const lastSessionDate = lastSession ? safeToDate(lastSession.date || lastSession.scheduledAt) : null;
    const daysSinceLastSession = lastSessionDate
      ? Math.floor((Date.now() - lastSessionDate.getTime()) / (24 * 60 * 60 * 1000))
      : 14;

    message = MEMBER_MESSAGE_TEMPLATES.attendance_habit.low(attendanceRate, daysSinceLastSession);
    priority = "high";
  }

  return {
    type: "attendance_habit",
    priority,
    title: truncateMessage("출석 습관", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(message, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    graphData,
    graphType: "bar",
    data: {
      attendanceRate,
      percentile,
      completedSessions: completed,
      totalSessions: total,
      weeklyData,
      currentStreak,
    },
  };
}

/**
 * 4. 영양 밸런스 (nutrition_balance)
 * 매크로 섭취량 분석
 */
function generateNutritionBalance(
  dietRecords: DietRecord[],
  _member: MemberData
): MemberInsight | null {
  // 최근 1주일 데이터
  const oneWeekAgo = new Date();
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

  const recentDiets = dietRecords.filter((d) => {
    const date = safeToDate(d.analyzedAt);
    return date && date >= oneWeekAgo;
  });

  if (recentDiets.length === 0) {
    return null;
  }

  // 데이터가 1-2개인 경우 fallback 인사이트 반환 (일부 데이터로 분석)
  if (recentDiets.length < 3) {
    const totalProtein = recentDiets.reduce((sum, d) => sum + (d.protein || 0), 0);
    const totalCarbs = recentDiets.reduce((sum, d) => sum + (d.carbs || 0), 0);
    const totalFat = recentDiets.reduce((sum, d) => sum + (d.fat || 0), 0);
    // 일수 기반 평균 (끼니 수가 아닌 실제 기록 날수로 나눔)
    const fallbackDays = new Set(
      recentDiets.map((d) => {
        const date = safeToDate(d.analyzedAt);
        return date ? date.toISOString().split("T")[0] : "";
      }).filter((d) => d !== "")
    );
    const fallbackDayCount = Math.max(1, fallbackDays.size);
    const avgProtein = totalProtein / fallbackDayCount;
    const avgCarbs = totalCarbs / fallbackDayCount;
    const avgFat = totalFat / fallbackDayCount;

    // 간단한 그래프 데이터
    const graphData = [
      {name: "단백질", value: Math.round(avgProtein), target: 120},
      {name: "탄수화물", value: Math.round(avgCarbs), target: 250},
      {name: "지방", value: Math.round(avgFat), target: 60},
    ];

    return {
      type: "nutrition_balance",
      priority: "low",
      title: "영양 밸런스",
      message: `${recentDiets.length}개 기록 분석 완료 - 더 기록하면 정확한 분석 가능`,
      graphData,
      graphType: "donut",
      data: {
        avgProtein: parseFloat(avgProtein.toFixed(1)),
        avgCarbs: parseFloat(avgCarbs.toFixed(1)),
        avgFat: parseFloat(avgFat.toFixed(1)),
        needsMoreData: true,
        recordCount: recentDiets.length,
      },
    };
  }

  // 일평균 섭취량 계산 (실제 기록이 있는 날수로 나눔)
  const uniqueDays = new Set(
    recentDiets.map((d) => {
      const date = safeToDate(d.analyzedAt);
      return date ? date.toISOString().split("T")[0] : "";
    }).filter((d) => d !== "")
  );
  const totalDays = Math.max(1, uniqueDays.size);
  const totalProtein = recentDiets.reduce((sum, d) => sum + (d.protein || 0), 0);
  const totalCarbs = recentDiets.reduce((sum, d) => sum + (d.carbs || 0), 0);
  const totalFat = recentDiets.reduce((sum, d) => sum + (d.fat || 0), 0);

  const avgProtein = totalProtein / totalDays;
  const avgCarbs = totalCarbs / totalDays;
  const avgFat = totalFat / totalDays;

  // 목표 대비 비율 (기본 목표: 단백질 120g, 탄수화물 250g, 지방 60g)
  const targetProtein = 120;
  const targetCarbs = 250;
  const targetFat = 60;

  const proteinPercent = Math.round((avgProtein / targetProtein) * 100);
  const carbsPercent = Math.round((avgCarbs / targetCarbs) * 100);
  const fatPercent = Math.round((avgFat / targetFat) * 100);

  // 그래프 데이터
  const graphData = [
    {name: "단백질", value: proteinPercent, target: 100},
    {name: "탄수화물", value: carbsPercent, target: 100},
    {name: "지방", value: fatPercent, target: 100},
  ];

  // 가장 부족한 영양소 찾기
  const deficits = [
    {name: "단백질", percent: proteinPercent, suggestion: "닭가슴살 100g"},
    {name: "탄수화물", percent: carbsPercent, suggestion: "현미밥 한 공기"},
    {name: "지방", percent: fatPercent, suggestion: "아보카도 반 개"},
  ];

  const mostDeficient = deficits.reduce((min, d) =>
    d.percent < min.percent ? d : min
  );

  // 메시지 생성 (간결하게)
  let message: string;
  let priority: InsightPriority;

  if (mostDeficient.percent < 70) {
    const deficitAmount = Math.round(
      mostDeficient.name === "단백질" ? targetProtein - avgProtein :
        mostDeficient.name === "탄수화물" ? targetCarbs - avgCarbs :
          targetFat - avgFat
    );
    message = MEMBER_MESSAGE_TEMPLATES.nutrition_balance.deficient(
      mostDeficient.name,
      deficitAmount,
      mostDeficient.suggestion
    );
    priority = "high";
  } else if (mostDeficient.percent < 90) {
    const deficitAmount = Math.round(
      mostDeficient.name === "단백질" ? targetProtein - avgProtein :
        mostDeficient.name === "탄수화물" ? targetCarbs - avgCarbs :
          targetFat - avgFat
    );
    message = MEMBER_MESSAGE_TEMPLATES.nutrition_balance.deficient(
      mostDeficient.name,
      deficitAmount,
      mostDeficient.suggestion
    );
    priority = "medium";
  } else {
    // 단백질이 충분하면 특별 메시지
    if (proteinPercent >= 90) {
      message = MEMBER_MESSAGE_TEMPLATES.nutrition_balance.proteinGood(Math.round(avgProtein));
      priority = "medium";
    } else {
      message = MEMBER_MESSAGE_TEMPLATES.nutrition_balance.balanced();
      priority = "low";
    }
  }

  return {
    type: "nutrition_balance",
    priority,
    title: truncateMessage("영양 밸런스", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(message, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    graphData,
    graphType: "donut",
    data: {
      avgProtein: parseFloat(avgProtein.toFixed(1)),
      avgCarbs: parseFloat(avgCarbs.toFixed(1)),
      avgFat: parseFloat(avgFat.toFixed(1)),
      proteinPercent,
      carbsPercent,
      fatPercent,
      targetProtein,
      targetCarbs,
      targetFat,
    },
  };
}

/**
 * 인바디 기록에서 체지방량 계산 (bodyFatMass가 없으면 bodyFatPercent * weight / 100)
 */
function getBodyFatMass(record: InbodyRecord): number {
  if (record.bodyFatMass) return record.bodyFatMass;
  if (record.bodyFatPercent && record.weight) {
    return (record.bodyFatPercent * record.weight) / 100;
  }
  return 0;
}

/**
 * 5. 체성분 변화 리포트 (body_change_report)
 * 3개월간 체지방/골격근 변화
 */
function generateBodyChangeReport(
  inbodyRecords: InbodyRecord[]
): MemberInsight | null {
  if (inbodyRecords.length === 0) {
    return null;
  }

  // 데이터가 1개인 경우 fallback 인사이트 반환
  if (inbodyRecords.length === 1) {
    const record = inbodyRecords[0];
    const currentFat = getBodyFatMass(record);
    const currentMuscle = record.skeletalMuscleMass || 0;
    const currentFatPercent = record.bodyFatPercent || 0;

    // 유효한 데이터가 있는 경우에만 반환
    if (currentFat === 0 && currentMuscle === 0 && currentFatPercent === 0) {
      return null;
    }

    const graphData = [
      {
        label: "체지방",
        before: null,
        after: parseFloat(currentFat.toFixed(1)),
      },
      {
        label: "골격근",
        before: null,
        after: parseFloat(currentMuscle.toFixed(1)),
      },
    ];

    return {
      type: "body_change_report",
      priority: "low",
      title: "체성분 변화 리포트",
      message: `현재 체지방 ${currentFat.toFixed(1)}kg, 골격근 ${currentMuscle.toFixed(1)}kg - 인바디 1회 더 측정하면 변화 분석 가능!`,
      graphData,
      graphType: "bar",
      data: {
        afterFat: currentFat,
        afterMuscle: currentMuscle,
        afterFatPercent: currentFatPercent,
        needsMoreData: true,
      },
    };
  }

  // 날짜순 정렬
  const sortedRecords = [...inbodyRecords].sort((a, b) => {
    const dateA = safeToDate(a.measuredAt || a.createdAt)?.getTime() || 0;
    const dateB = safeToDate(b.measuredAt || b.createdAt)?.getTime() || 0;
    return dateA - dateB;
  });

  // 3개월 전 데이터와 최근 데이터 비교
  const threeMonthsAgo = new Date();
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);

  const oldRecords = sortedRecords.filter((r) => {
    const date = safeToDate(r.measuredAt || r.createdAt);
    return date && date <= threeMonthsAgo;
  });

  const latestRecord = sortedRecords[sortedRecords.length - 1];
  const oldestRecord = oldRecords.length > 0 ? oldRecords[0] : sortedRecords[0];

  if (!latestRecord || !oldestRecord) return null;

  // 체지방량, 골격근량 변화
  const beforeFat = getBodyFatMass(oldestRecord);
  const afterFat = getBodyFatMass(latestRecord);
  const fatChange = afterFat - beforeFat;

  const beforeMuscle = oldestRecord.skeletalMuscleMass || 0;
  const afterMuscle = latestRecord.skeletalMuscleMass || 0;
  const muscleChange = afterMuscle - beforeMuscle;

  const beforeFatPercent = oldestRecord.bodyFatPercent || 0;
  const afterFatPercent = latestRecord.bodyFatPercent || 0;

  // 데이터가 유효하지 않으면 건너뛰기
  if (beforeFat === 0 && afterFat === 0 && beforeMuscle === 0 && afterMuscle === 0) {
    return null;
  }

  // 그래프 데이터
  const graphData = [
    {
      label: "체지방",
      before: parseFloat(beforeFat.toFixed(1)),
      after: parseFloat(afterFat.toFixed(1)),
    },
    {
      label: "골격근",
      before: parseFloat(beforeMuscle.toFixed(1)),
      after: parseFloat(afterMuscle.toFixed(1)),
    },
  ];

  // 기간 계산
  const oldestDate = safeToDate(oldestRecord.measuredAt || oldestRecord.createdAt);
  const latestDate = safeToDate(latestRecord.measuredAt || latestRecord.createdAt);
  const weeksBetween = oldestDate && latestDate
    ? Math.max(1, Math.floor((latestDate.getTime() - oldestDate.getTime()) / (7 * 24 * 60 * 60 * 1000)))
    : 4;

  // 체지방률 변화
  const fatPercentChange = afterFatPercent - beforeFatPercent;

  // 메시지 생성 (간결하게)
  let message: string;
  let priority: InsightPriority;

  if (fatChange < -0.5 && muscleChange > 0.3) {
    message = MEMBER_MESSAGE_TEMPLATES.body_change_report.both(
      parseFloat(Math.abs(fatChange).toFixed(1)),
      parseFloat(muscleChange.toFixed(1)),
      weeksBetween
    );
    priority = "high";
  } else if (fatChange < -0.5) {
    message = MEMBER_MESSAGE_TEMPLATES.body_change_report.fatLoss(
      parseFloat(Math.abs(fatChange).toFixed(1)),
      weeksBetween
    );
    priority = "medium";
  } else if (muscleChange > 0.3) {
    message = MEMBER_MESSAGE_TEMPLATES.body_change_report.muscleGain(
      parseFloat(muscleChange.toFixed(1)),
      weeksBetween
    );
    priority = "medium";
  } else if (fatPercentChange < -1) {
    // 체지방률이 눈에 띄게 감소
    message = MEMBER_MESSAGE_TEMPLATES.body_change_report.fatPercentDrop(
      parseFloat(Math.abs(fatPercentChange).toFixed(1)),
      weeksBetween
    );
    priority = "medium";
  } else {
    message = MEMBER_MESSAGE_TEMPLATES.body_change_report.stable();
    priority = "low";
  }

  return {
    type: "body_change_report",
    priority,
    title: truncateMessage("내 몸이 변하고 있어요", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(message, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    graphData,
    graphType: "bar",
    data: {
      beforeFat,
      afterFat,
      fatChange: parseFloat(fatChange.toFixed(1)),
      beforeMuscle,
      afterMuscle,
      muscleChange: parseFloat(muscleChange.toFixed(1)),
      beforeFatPercent,
      afterFatPercent,
      fatPercentChange: parseFloat(fatPercentChange.toFixed(1)),
      weeksBetween,
    },
  };
}

/**
 * 6. 컨디션 패턴 (condition_pattern)
 * 요일별 운동 성과 분석
 */
function generateConditionPattern(
  workoutRecords: WorkoutRecord[]
): MemberInsight | null {
  if (workoutRecords.length < 2) {
    // 데이터가 1개인 경우 fallback 인사이트 반환
    if (workoutRecords.length === 1) {
      const record = workoutRecords[0];
      const date = safeToDate(record.createdAt);
      const dayNames = ["일", "월", "화", "수", "목", "금", "토"];
      const dayName = date ? dayNames[date.getDay()] : "알 수 없음";

      return {
        type: "condition_pattern",
        priority: "low",
        title: "컨디션 패턴",
        message: `${dayName}요일에 운동 기록이 있어요 - 더 기록하면 최적의 운동 요일을 분석해드려요`,
        graphData: [],
        graphType: "text",
        data: {
          needsMoreData: true,
          recordCount: 1,
        },
      };
    }
    return null;
  }

  // 요일별 성과 집계
  const dayNames = ["일", "월", "화", "수", "목", "금", "토"];
  const dayStats: Array<{total: number; count: number}> = Array(7)
    .fill(null)
    .map(() => ({total: 0, count: 0}));

  workoutRecords.forEach((record) => {
    const date = safeToDate(record.createdAt);
    if (!date) return;

    const dayIndex = date.getDay();

    // 운동 볼륨 계산 (무게 x 횟수 x 세트)
    const volume = (record.weight || 0) * (record.reps || 0) * (record.sets || 1);
    if (volume > 0) {
      dayStats[dayIndex].total += volume;
      dayStats[dayIndex].count++;
    }
  });

  // 요일별 평균 성과
  const dayScores = dayStats.map((stat, i) => ({
    day: dayNames[i],
    dayIndex: i,
    score: stat.count > 0 ? Math.round(stat.total / stat.count) : 0,
    count: stat.count,
  }));

  // 활동이 있는 요일만 필터링
  const activeDays = dayScores.filter((d) => d.count > 0);
  if (activeDays.length === 0) {
    return null;
  }

  // 활동이 1개 요일에만 있는 경우 fallback 인사이트 반환
  if (activeDays.length === 1) {
    const onlyDay = activeDays[0];
    return {
      type: "condition_pattern",
      priority: "low",
      title: "컨디션 패턴",
      message: `${onlyDay.day}요일에 ${onlyDay.count}회 운동 기록! 다른 요일에도 운동하면 패턴 분석 가능해요`,
      graphData: dayScores.map((d) => ({
        day: d.day,
        score: d.count > 0 ? 100 : 0,
      })),
      graphType: "bar",
      data: {
        activeDays: 1,
        recordCount: onlyDay.count,
        needsMoreData: true,
      },
    };
  }

  // 최고 성과 요일 찾기
  const bestDay = activeDays.reduce((max, d) => (d.score > max.score ? d : max));

  // 점수 정규화 (0-100)
  const maxScore = Math.max(...activeDays.map((d) => d.score));
  const normalizedScores = dayScores.map((d) => ({
    day: d.day,
    score: maxScore > 0 ? Math.round((d.score / maxScore) * 100) : 0,
  }));

  // 그래프 데이터
  const graphData = normalizedScores;

  // 메시지 생성 (요일에 따른 설명)
  let reason: string;
  if (bestDay.dayIndex === 1) {
    reason = "주말 휴식 효과!";
  } else if (bestDay.dayIndex === 0 || bestDay.dayIndex === 6) {
    reason = "여유로운 주말의 힘!";
  } else if (bestDay.dayIndex === 5) {
    reason = "한 주의 마무리 에너지!";
  } else {
    reason = "최적의 컨디션!";
  }

  return {
    type: "condition_pattern",
    priority: "low",
    title: "컨디션 패턴",
    message: `${bestDay.day}요일 운동 성과가 가장 좋아요 - ${reason}`,
    graphData,
    graphType: "bar",
    data: {
      bestDay: bestDay.day,
      bestDayIndex: bestDay.dayIndex,
      dayScores: normalizedScores,
    },
  };
}

/**
 * 7. 목표 달성률 (goal_progress)
 * 현재 vs 목표 값 비교
 */
function generateGoalProgress(
  bodyRecords: BodyRecord[],
  inbodyRecords: InbodyRecord[],
  member: MemberData
): MemberInsight | null {
  // 최신 체성분 데이터 가져오기
  let currentWeight: number | undefined;
  let currentBodyFat: number | undefined;
  let currentMuscle: number | undefined;

  // inbody_records에서 최신 데이터
  if (inbodyRecords.length > 0) {
    const sortedInbody = [...inbodyRecords].sort((a, b) => {
      const dateA = safeToDate(a.measuredAt || a.createdAt)?.getTime() || 0;
      const dateB = safeToDate(b.measuredAt || b.createdAt)?.getTime() || 0;
      return dateB - dateA;
    });
    const latest = sortedInbody[0];
    currentWeight = latest.weight;
    currentBodyFat = latest.bodyFatPercent;
    currentMuscle = latest.skeletalMuscleMass;
  }

  // body_records에서 보완
  if (bodyRecords.length > 0 && !currentWeight) {
    const sortedBody = [...bodyRecords].sort((a, b) => {
      const dateA = safeToDate(a.measuredAt || a.recordDate || a.createdAt)?.getTime() || 0;
      const dateB = safeToDate(b.measuredAt || b.recordDate || b.createdAt)?.getTime() || 0;
      return dateB - dateA;
    });
    const latest = sortedBody[0];
    currentWeight = currentWeight || latest.weight;
    currentBodyFat = currentBodyFat || latest.bodyFat;
    currentMuscle = currentMuscle || latest.muscleMass;
  }

  // startWeight로 currentWeight 보완
  if (!currentWeight && member.startWeight) {
    currentWeight = member.startWeight;
  }

  // 목표 설정
  const targetWeight = member.targetWeight;
  const targetBodyFat = member.targetBodyFat;
  const targetMuscle = member.targetMuscleMass;

  // 진행률 계산
  let progressPercent = 0;
  let hasTarget = false;

  if (targetWeight && currentWeight) {
    hasTarget = true;
    // 체중 감량 목표인지 증량 목표인지 판단
    const isWeightLoss = member.goal === "diet" || targetWeight < currentWeight;

    if (isWeightLoss) {
      // startWeight가 있으면 사용, 없으면 가장 높은 기록 사용
      const startWeight = member.startWeight || Math.max(
        ...bodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        ...inbodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        currentWeight
      );
      const totalToLose = startWeight - targetWeight;
      const alreadyLost = startWeight - currentWeight;

      if (totalToLose > 0) {
        progressPercent = Math.min(100, Math.round((alreadyLost / totalToLose) * 100));
      }
    } else {
      // startWeight가 있으면 사용, 없으면 가장 낮은 기록 사용
      const weightValues = [
        ...bodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        ...inbodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        currentWeight,
      ];
      const startWeight = member.startWeight || Math.min(...weightValues);
      const totalToGain = targetWeight - startWeight;
      const alreadyGained = currentWeight - startWeight;

      if (totalToGain > 0) {
        progressPercent = Math.min(100, Math.round((alreadyGained / totalToGain) * 100));
      }
    }
  }

  if (!hasTarget) {
    // 목표가 없으면 기본 동기부여 메시지
    return {
      type: "goal_progress",
      priority: "low",
      title: "목표 달성률",
      message: "목표를 설정하면 더 정확한 진행률을 확인할 수 있어요!",
      graphData: [{value: 0, max: 100}],
      graphType: "progress",
      data: {
        hasTarget: false,
      },
    };
  }

  // 메시지 및 우선순위 결정 (간결하게)
  let message: string;
  let priority: InsightPriority;

  // 남은 양 계산
  const remaining = targetWeight ? Math.abs(targetWeight - (currentWeight || 0)) : 0;

  // 예상 소요 주차 계산
  const allWeights = [
    ...bodyRecords.filter((r) => r.weight).map((r) => ({weight: r.weight!, date: safeToDate(r.recordDate)})),
    ...inbodyRecords.filter((r) => r.weight).map((r) => ({weight: r.weight!, date: safeToDate(r.measuredAt)})),
  ].filter((w) => w.date).sort((a, b) => a.date!.getTime() - b.date!.getTime());

  let weeklyRate = 0.5; // 기본값
  if (allWeights.length >= 2) {
    const firstWeight = allWeights[0].weight;
    const lastWeight = allWeights[allWeights.length - 1].weight;
    const weeksBetween = Math.max(1,
      Math.floor((allWeights[allWeights.length - 1].date!.getTime() - allWeights[0].date!.getTime()) /
      (7 * 24 * 60 * 60 * 1000))
    );
    weeklyRate = Math.abs(lastWeight - firstWeight) / weeksBetween;
  }

  const weeksToGoal = weeklyRate > 0 ? Math.ceil(remaining / weeklyRate) : 0;

  if (progressPercent >= 90) {
    message = MEMBER_MESSAGE_TEMPLATES.goal_progress.high(progressPercent, remaining);
    priority = "high";
  } else if (progressPercent >= 50) {
    message = MEMBER_MESSAGE_TEMPLATES.goal_progress.medium(progressPercent, weeksToGoal);
    priority = "medium";
  } else {
    message = MEMBER_MESSAGE_TEMPLATES.goal_progress.low(progressPercent);
    priority = "low";
  }

  return {
    type: "goal_progress",
    priority,
    title: truncateMessage("목표 달성률", INSIGHT_CONFIG.MAX_TITLE_LENGTH),
    message: truncateMessage(message, INSIGHT_CONFIG.MAX_MESSAGE_LENGTH),
    graphData: [{value: progressPercent, max: 100}],
    graphType: "progress",
    data: {
      progressPercent,
      currentWeight,
      targetWeight,
      currentBodyFat,
      targetBodyFat,
      currentMuscle,
      targetMuscle,
      remaining,
      weeksToGoal,
      weeklyRate: parseFloat(weeklyRate.toFixed(2)),
    },
  };
}

/**
 * 9. 주간 요약 (weekly_summary)
 * 이번 주 운동 횟수와 성과 요약
 */
function generateWeeklySummary(
  schedules: ScheduleRecord[],
  bodyRecords: BodyRecord[],
  inbodyRecords: InbodyRecord[],
  member: MemberData
): MemberInsight | null {
  const oneWeekAgo = new Date();
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

  // 이번 주 완료된 세션 수
  const weekSessions = schedules.filter((s) => {
    const date = safeToDate(s.date || s.scheduledAt);
    return date &&
      date >= oneWeekAgo &&
      (s.status === "completed" || s.status === "attended");
  }).length;

  if (weekSessions === 0) return null;

  // 이번 주 체중 변화
  const weekWeightData = [
    ...bodyRecords.filter((r) => {
      const date = safeToDate(r.recordDate);
      return date && date >= oneWeekAgo && r.weight;
    }).map((r) => ({weight: r.weight!, date: safeToDate(r.recordDate)!})),
    ...inbodyRecords.filter((r) => {
      const date = safeToDate(r.measuredAt);
      return date && date >= oneWeekAgo && r.weight;
    }).map((r) => ({weight: r.weight!, date: safeToDate(r.measuredAt)!})),
  ].sort((a, b) => a.date.getTime() - b.date.getTime());

  let progressMessage = "";
  let priority: InsightPriority = "medium";

  if (weekWeightData.length >= 2) {
    const weekChange = weekWeightData[weekWeightData.length - 1].weight - weekWeightData[0].weight;
    const goal = member.goal || "diet";

    if (goal === "diet" && weekChange < -0.5) {
      progressMessage = `체중 ${Math.abs(weekChange).toFixed(1)}kg 감량`;
      priority = "high";
    } else if (goal === "bulk" && weekChange > 0.5) {
      progressMessage = `체중 ${weekChange.toFixed(1)}kg 증가`;
      priority = "high";
    } else {
      progressMessage = "꾸준히 운동 중";
    }
  } else {
    progressMessage = "꾸준히 운동 중";
  }

  // 목표 횟수 (주 3회 기준)
  const targetSessions = 3;
  let message: string;

  if (weekSessions >= targetSessions) {
    message = MEMBER_MESSAGE_TEMPLATES.weekly_summary.excellent(weekSessions, progressMessage);
  } else if (weekSessions >= 2) {
    message = MEMBER_MESSAGE_TEMPLATES.weekly_summary.good(weekSessions);
  } else {
    message = MEMBER_MESSAGE_TEMPLATES.weekly_summary.needMore(weekSessions, targetSessions);
    priority = "low";
  }

  return {
    type: "attendance_habit", // 출석 관련이므로 기존 타입 재사용
    priority,
    title: "이번 주 요약",
    message,
    graphData: [{sessions: weekSessions, target: targetSessions}],
    graphType: "text",
    data: {
      weekSessions,
      targetSessions,
      progressMessage,
    },
  };
}

/**
 * 10. 휴식 권장 (rest_recommendation)
 * 연속 운동일 감지 및 휴식 제안
 */
function generateRestRecommendation(
  schedules: ScheduleRecord[]
): MemberInsight | null {
  const now = new Date();
  const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  // 최근 7일간 완료된 세션을 날짜별로 그룹화
  const completedDates = new Set<string>();
  schedules.forEach((s) => {
    const date = safeToDate(s.date || s.scheduledAt);
    if (date &&
        date >= sevenDaysAgo &&
        (s.status === "completed" || s.status === "attended")) {
      completedDates.add(date.toISOString().split("T")[0]);
    }
  });

  // 연속 운동일 계산
  let consecutiveDays = 0;
  for (let i = 0; i < 7; i++) {
    const checkDate = new Date(now);
    checkDate.setDate(checkDate.getDate() - i);
    const dateStr = checkDate.toISOString().split("T")[0];

    if (completedDates.has(dateStr)) {
      consecutiveDays++;
    } else {
      break;
    }
  }

  // 5일 이상 연속 운동했으면 휴식 권장
  if (consecutiveDays >= 5) {
    return {
      type: "attendance_habit",
      priority: "medium",
      title: "휴식이 필요해요",
      message: MEMBER_MESSAGE_TEMPLATES.rest_needed.consecutive(consecutiveDays),
      graphData: [],
      graphType: "text",
      data: {
        consecutiveDays,
        recommendation: "rest",
      },
    };
  }

  return null;
}

/**
 * 8. 벤치마킹 비교 (benchmarking)
 *
 * 동일 목표/체형 그룹 대비 나의 위치 분석
 * - 같은 목표 회원 대비 체지방률 감량 속도 비교
 * - 전체 회원 중 출석률 순위
 * - 유사 체형 회원 대비 근육량 비교
 *
 * 퍼센타일 계산 방식:
 * - 상위 10% → "상위 10%에 속해요!"
 * - 상위 25% → "평균 이상이에요"
 * - 중간 50% → "평균 수준이에요"
 * - 하위 25% → "조금 더 분발해봐요"
 */
async function generateBenchmarking(
  member: MemberData,
  bodyRecords: BodyRecord[],
  inbodyRecords: InbodyRecord[],
  schedules: ScheduleRecord[]
): Promise<MemberInsight | null> {
  // 현재 회원의 데이터
  let currentWeight: number | undefined;
  let currentBodyFat: number | undefined;
  let currentMuscle: number | undefined;

  // 최신 체성분 데이터
  if (inbodyRecords.length > 0) {
    const sortedInbody = [...inbodyRecords].sort((a, b) => {
      const dateA = safeToDate(a.measuredAt || a.createdAt)?.getTime() || 0;
      const dateB = safeToDate(b.measuredAt || b.createdAt)?.getTime() || 0;
      return dateB - dateA;
    });
    const latest = sortedInbody[0];
    currentWeight = latest.weight;
    currentBodyFat = latest.bodyFatPercent;
    currentMuscle = latest.skeletalMuscleMass;
  }

  if (bodyRecords.length > 0 && !currentWeight) {
    const sortedBody = [...bodyRecords].sort((a, b) => {
      const dateA = safeToDate(a.measuredAt || a.recordDate || a.createdAt)?.getTime() || 0;
      const dateB = safeToDate(b.measuredAt || b.recordDate || b.createdAt)?.getTime() || 0;
      return dateB - dateA;
    });
    const latest = sortedBody[0];
    currentWeight = currentWeight || latest.weight;
    currentBodyFat = currentBodyFat || latest.bodyFat;
    currentMuscle = currentMuscle || latest.muscleMass;
  }

  // 출석률 계산
  const fourWeeksAgo = new Date();
  fourWeeksAgo.setDate(fourWeeksAgo.getDate() - 28);

  const recentSchedules = schedules.filter((s) => {
    const date = safeToDate(s.date || s.scheduledAt);
    return date && date >= fourWeeksAgo;
  });

  const completed = recentSchedules.filter(
    (s) => s.status === "completed" || s.status === "attended"
  ).length;
  const total = recentSchedules.length;
  const attendanceRate = total > 0 ? Math.round((completed / total) * 100) : 0;

  // ===== VALIDATION: Minimum data check =====
  // Personal mode users with no activity shouldn't get benchmark insights
  if (recentSchedules.length === 0 && bodyRecords.length === 0 && inbodyRecords.length === 0) {
    return null; // No data at all - don't show benchmark
  }

  // 체지방률 4주 변화 계산
  let bodyFatChange = 0;
  if (inbodyRecords.length >= 2) {
    const sortedInbody = [...inbodyRecords].sort((a, b) => {
      const dateA = safeToDate(a.measuredAt || a.createdAt)?.getTime() || 0;
      const dateB = safeToDate(b.measuredAt || b.createdAt)?.getTime() || 0;
      return dateA - dateB;
    });

    const fourWeeksRecords = sortedInbody.filter((r) => {
      const date = safeToDate(r.measuredAt || r.createdAt);
      return date && date >= fourWeeksAgo && r.bodyFatPercent !== undefined;
    });

    if (fourWeeksRecords.length >= 2) {
      const firstFat = fourWeeksRecords[0].bodyFatPercent || 0;
      const lastFat = fourWeeksRecords[fourWeeksRecords.length - 1].bodyFatPercent || 0;
      bodyFatChange = lastFat - firstFat;
    }
  }

  // ===== VALIDATION: Zero activity case =====
  // If user has no attendance and no body composition change, benchmark is meaningless
  if (attendanceRate === 0 && bodyFatChange === 0) {
    return null; // User hasn't done anything yet
  }

  // ===== 동일 그룹 회원 대비 벤치마킹 (성별, 연령대, 목표, BMI 기반) =====
  const ageGroup = getAgeGroup(member.birthDate);
  const bmiRange = getBmiRange(member.startWeight, member.height);
  const memberGender = member.gender || "unknown";
  const memberGoal = member.goal || "fitness";

  // Firestore에서 동일 그룹 회원 조회
  let similarMembersQuery = db.collection(Collections.MEMBERS).where("goal", "==", memberGoal);

  // 성별 필터 (알 수 있는 경우)
  if (memberGender !== "unknown") {
    similarMembersQuery = similarMembersQuery.where("gender", "==", memberGender);
  }

  const similarMembersSnapshot = await similarMembersQuery.limit(500).get();

  // 동일 그룹 회원들의 데이터 수집
  const groupMetrics: {
    memberId: string;
    attendanceRate: number;
    bodyFatChange: number;
    muscleChange: number;
  }[] = [];

  for (const doc of similarMembersSnapshot.docs) {
    if (doc.id === member.id) continue; // 본인 제외

    const memberData = doc.data();

    // 연령대 필터 (birthDate가 있는 경우)
    if (memberData.birthDate && ageGroup !== "unknown") {
      const otherAgeGroup = getAgeGroup(memberData.birthDate);
      if (otherAgeGroup !== ageGroup) continue;
    }

    // BMI 범위 필터 (height, startWeight가 있는 경우)
    if (memberData.height && memberData.startWeight && bmiRange !== "unknown") {
      const otherBmiRange = getBmiRange(memberData.startWeight, memberData.height);
      if (otherBmiRange !== bmiRange) continue;
    }

    // 해당 회원의 출석률 계산
    const memberSchedules = await db
      .collection(Collections.SCHEDULES)
      .where("memberId", "==", doc.id)
      .where("scheduledAt", ">=", fourWeeksAgo)
      .get();

    const memberCompleted = memberSchedules.docs.filter(
      (s) => s.data().status === "completed" || s.data().status === "attended"
    ).length;
    const memberTotal = memberSchedules.docs.length;
    const memberAttendanceRate = memberTotal > 0 ? (memberCompleted / memberTotal) * 100 : 0;

    // 해당 회원의 체지방 변화 계산
    const memberInbody = await db
      .collection(Collections.INBODY_RECORDS)
      .where("memberId", "==", doc.id)
      .orderBy("measuredAt", "desc")
      .limit(5)
      .get();

    let memberBodyFatChange = 0;
    let memberMuscleChange = 0;

    if (memberInbody.docs.length >= 2) {
      const first = memberInbody.docs[memberInbody.docs.length - 1].data();
      const last = memberInbody.docs[0].data();
      memberBodyFatChange = (last.bodyFatPercent || 0) - (first.bodyFatPercent || 0);
      memberMuscleChange = (last.skeletalMuscleMass || 0) - (first.skeletalMuscleMass || 0);
    }

    groupMetrics.push({
      memberId: doc.id,
      attendanceRate: memberAttendanceRate,
      bodyFatChange: memberBodyFatChange,
      muscleChange: memberMuscleChange,
    });
  }

  // ===== VALIDATION: Minimum comparison group check =====
  // Need at least 3 comparable members for statistically meaningful benchmark
  if (groupMetrics.length < 3) {
    return null; // Not enough comparison data
  }

  // 백분위 계산: percentile = (내 순위 / 전체) × 100, 상위% = 100 - percentile
  const sampleSize = groupMetrics.length + 1; // 본인 포함

  // 출석률 순위 (높을수록 좋음)
  const attendanceRank = groupMetrics.filter((m) => m.attendanceRate > attendanceRate).length + 1;
  const attendancePercentile = Math.round((attendanceRank / sampleSize) * 100);

  // 체지방 감량 순위 (더 많이 감량할수록 좋음, 음수가 더 좋음)
  let performancePercentile = 50;
  if (memberGoal === "diet") {
    const fatLossRank = groupMetrics.filter((m) => m.bodyFatChange < bodyFatChange).length + 1;
    performancePercentile = Math.round((fatLossRank / sampleSize) * 100);
  } else if (memberGoal === "bulk") {
    // 근육 증가량 순위 계산
    const muscleChange = currentMuscle ? (currentMuscle - (member.startWeight || currentMuscle)) : 0;
    const muscleRank = groupMetrics.filter((m) => m.muscleChange > muscleChange).length + 1;
    performancePercentile = Math.round((muscleRank / sampleSize) * 100);
  }

  // 종합 퍼센타일 (가중 평균)
  const overallPercentile = Math.round(
    attendancePercentile * 0.4 + performancePercentile * 0.6
  );

  // 비교 그룹 정보
  const comparisonGroup = {
    gender: memberGender === "male" ? "남성" : memberGender === "female" ? "여성" : "전체",
    ageGroup: ageGroup === "unknown" ? "전체" : ageGroup,
    goal: memberGoal === "diet" ? "다이어트" : memberGoal === "bulk" ? "벌크업" : "체력향상",
    bmiRange: bmiRange === "unknown" ? "전체" : bmiRange,
    sampleSize,
  };

  // 그래프 데이터 (분포 차트용)
  const topPercent = 100 - overallPercentile;
  const graphData = [
    {
      category: "출석률",
      value: attendanceRate,
      percentile: attendancePercentile,
      topPercent: 100 - attendancePercentile,
      benchmark: 75, // 평균 기준
    },
    {
      category: memberGoal === "diet" ? "체지방 감량" : "근육 증가",
      value: memberGoal === "diet" ? Math.abs(bodyFatChange) : (currentMuscle || 0),
      percentile: performancePercentile,
      topPercent: 100 - performancePercentile,
      benchmark: memberGoal === "diet" ? 1 : 30,
    },
    {
      category: "종합 순위",
      value: topPercent,
      percentile: overallPercentile,
      topPercent,
      benchmark: 50,
    },
  ];

  // 메시지 생성 (더 구체적이고 동기부여)
  let message: string;
  let priority: InsightPriority;
  const topPercentDisplay = 100 - overallPercentile;
  const groupDesc = `${comparisonGroup.gender} ${comparisonGroup.ageGroup} ${comparisonGroup.goal} 회원`;

  if (topPercent >= 80) {
    const attendanceTop = 100 - attendancePercentile;
    message = `${groupDesc} ${sampleSize}명 중 상위 ${topPercentDisplay}%예요! 🏆 ` +
      `출석률도 상위 ${attendanceTop}% - 정말 열심히 하고 있어요`;
    priority = "high";
  } else if (topPercent >= 60) {
    message = `${groupDesc} 중 상위 ${topPercentDisplay}%! 평균 이상이에요. ` +
      `${memberGoal === "diet" ? "체지방 감량" : "근육 증가"} 성과도 좋아요 💪`;
    priority = "medium";
  } else if (topPercent >= 40) {
    message = `${groupDesc} 중 평균 수준이에요. 출석률 ${attendanceRate}%에서 ` +
      "10%만 더 높이면 상위권 진입이에요!";
    priority = "medium";
  } else {
    const needAttendance = Math.max(0, 80 - attendanceRate);
    message = `다른 ${groupDesc}보다 뒤처져 있어요. 출석률 ${needAttendance}% 더 높이면 ` +
      "평균 이상 될 수 있어요 - 함께 해봐요!";
    priority = "low";
  }

  return {
    type: "benchmarking",
    priority,
    title: topPercent >= 80 ? `상위 ${topPercentDisplay}%! 🏆` : "나의 순위",
    message,
    graphData,
    graphType: "distribution",
    data: {
      overallPercentile,
      topPercent,
      topPercentDisplay,
      attendanceRate,
      attendancePercentile,
      bodyFatChange: parseFloat(bodyFatChange.toFixed(1)),
      performancePercentile,
      currentWeight,
      currentBodyFat,
      currentMuscle,
      goal: memberGoal,
      comparisonGroup,
      sampleSize,
    },
  };
}

/**
 * 회원용 인사이트 생성 Cloud Function
 */
export const generateMemberInsights = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 1. 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "로그인이 필요합니다."
      );
    }

    const {memberId} = data;

    if (!memberId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "memberId가 필요합니다."
      );
    }

    try {
      functions.logger.info("[generateMemberInsights] 시작", {memberId});

      // 2. 회원 정보 가져오기
      const memberDoc = await db.collection(Collections.MEMBERS).doc(memberId).get();
      if (!memberDoc.exists) {
        throw new functions.https.HttpsError(
          "not-found",
          "회원 정보를 찾을 수 없습니다."
        );
      }

      const memberData = memberDoc.data()!;
      const member: MemberData = {
        id: memberId,
        name: memberData.name || "회원",
        goal: memberData.goal,
        targetWeight: memberData.targetWeight,
        targetBodyFat: memberData.targetBodyFat,
        targetMuscleMass: memberData.targetMuscleMass,
      };

      // 3. 데이터 병렬 조회
      const [
        bodyRecordsSnapshot,
        inbodyRecordsSnapshot,
        schedulesSnapshot,
        dietRecordsSnapshot,
      ] = await Promise.all([
        // body_records (최근 3개월)
        db.collection(Collections.BODY_RECORDS)
          .where("memberId", "==", memberId)
          .orderBy("recordDate", "desc")
          .limit(100)
          .get(),

        // inbody_records (최근 3개월)
        db.collection(Collections.INBODY_RECORDS)
          .where("memberId", "==", memberId)
          .orderBy("measuredAt", "desc")
          .limit(50)
          .get(),

        // schedules (최근 4주)
        db.collection(Collections.SCHEDULES)
          .where("memberId", "==", memberId)
          .orderBy("scheduledAt", "desc")
          .limit(50)
          .get(),

        // diet_records (최근 1주)
        db.collection(Collections.DIET_RECORDS)
          .where("memberId", "==", memberId)
          .orderBy("analyzedAt", "desc")
          .limit(50)
          .get(),
      ]);

      const bodyRecords: BodyRecord[] = bodyRecordsSnapshot.docs.map(
        (doc) => doc.data() as BodyRecord
      );
      const inbodyRecords: InbodyRecord[] = inbodyRecordsSnapshot.docs.map(
        (doc) => doc.data() as InbodyRecord
      );
      // workout_records 컬렉션 미존재 → 빈 배열 (session_signatures는 출석 확인용)
      const workoutRecords: WorkoutRecord[] = [];
      const schedules: ScheduleRecord[] = schedulesSnapshot.docs.map(
        (doc) => doc.data() as ScheduleRecord
      );
      const dietRecords: DietRecord[] = dietRecordsSnapshot.docs.map(
        (doc) => doc.data() as DietRecord
      );

      functions.logger.info("[generateMemberInsights] 데이터 수집 완료", {
        bodyRecords: bodyRecords.length,
        inbodyRecords: inbodyRecords.length,
        workoutRecords: workoutRecords.length,
        schedules: schedules.length,
        dietRecords: dietRecords.length,
      });

      // 5. 인사이트 생성
      const insights: MemberInsight[] = [];

      // 5-1. 체성분 예측
      const bodyPrediction = generateBodyPrediction(bodyRecords, inbodyRecords, member);
      if (bodyPrediction) insights.push(bodyPrediction);

      // 5-2. 운동 성과
      const workoutAchievement = generateWorkoutAchievement(workoutRecords);
      if (workoutAchievement) insights.push(workoutAchievement);

      // 5-3. 출석 습관
      const attendanceHabit = await generateAttendanceHabit(schedules, memberId);
      if (attendanceHabit) insights.push(attendanceHabit);

      // 5-4. 영양 밸런스
      const nutritionBalance = generateNutritionBalance(dietRecords, member);
      if (nutritionBalance) insights.push(nutritionBalance);

      // 5-5. 체성분 변화 리포트
      const bodyChangeReport = generateBodyChangeReport(inbodyRecords);
      if (bodyChangeReport) insights.push(bodyChangeReport);

      // 5-6. 컨디션 패턴
      const conditionPattern = generateConditionPattern(workoutRecords);
      if (conditionPattern) insights.push(conditionPattern);

      // 5-7. 목표 달성률
      const goalProgress = generateGoalProgress(bodyRecords, inbodyRecords, member);
      if (goalProgress) insights.push(goalProgress);

      // 5-8. 벤치마킹 비교
      const benchmarking = await generateBenchmarking(
        member,
        bodyRecords,
        inbodyRecords,
        schedules
      );
      if (benchmarking) insights.push(benchmarking);

      // 5-9. 주간 요약
      const weeklySummary = generateWeeklySummary(schedules, bodyRecords, inbodyRecords, member);
      if (weeklySummary) insights.push(weeklySummary);

      // 5-10. 휴식 권장
      const restRecommendation = generateRestRecommendation(schedules);
      if (restRecommendation) insights.push(restRecommendation);

      functions.logger.info("[generateMemberInsights] 인사이트 생성 완료", {
        totalInsights: insights.length,
        types: insights.map((i) => i.type),
      });

      // 5-9. 우선순위 기반 필터링 및 정렬
      const sortedInsights = insights
        .map((insight) => ({
          ...insight,
          score: calculateInsightScore(insight.type, insight.priority, false),
        }))
        .sort((a, b) => b.score - a.score)
        .slice(0, INSIGHT_CONFIG.MAX_INSIGHTS_DISPLAY)
        .map(({score: _score, ...insight}) => insight); // score 제거

      functions.logger.info("[generateMemberInsights] 필터링 완료", {
        beforeCount: insights.length,
        afterCount: sortedInsights.length,
        topTypes: sortedInsights.map((i) => i.type),
      });

      // 6. member_insights 컬렉션에 저장
      const now = admin.firestore.Timestamp.now();
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7일 후 만료
      );

      // 기존 인사이트 삭제
      const existingSnapshot = await db
        .collection("member_insights")
        .where("memberId", "==", memberId)
        .get();

      const batch = db.batch();
      existingSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      // 새 인사이트 저장 (필터링된 상위 인사이트만)
      const savedInsights: Array<MemberInsight & {id: string}> = [];
      for (const insight of sortedInsights) {
        const docRef = db.collection("member_insights").doc();
        const insightDoc = {
          memberId,
          type: insight.type,
          priority: insight.priority,
          title: insight.title,
          message: insight.message,
          graphData: insight.graphData || null,
          graphType: insight.graphType || null,
          data: insight.data ? JSON.parse(JSON.stringify(insight.data)) : null,
          createdAt: now,
          expiresAt,
        };
        batch.set(docRef, insightDoc);
        savedInsights.push({...insight, id: docRef.id});
      }

      await batch.commit();

      functions.logger.info("[generateMemberInsights] 저장 완료", {
        savedCount: savedInsights.length,
      });

      // 7. 결과 반환
      return {
        success: true,
        insights: savedInsights.map((insight) => ({
          id: insight.id,
          memberId,
          type: insight.type,
          priority: insight.priority,
          title: insight.title,
          message: insight.message,
          graphData: insight.graphData,
          graphType: insight.graphType,
          data: insight.data,
          isRead: false,
          createdAt: now.toDate().toISOString(),
          expiresAt: expiresAt.toDate().toISOString(),
        })),
        generatedAt: now.toDate().toISOString(),
      };
    } catch (error) {
      functions.logger.error("[generateMemberInsights] 오류 발생", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      const rawMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      functions.logger.error("[generateMemberInsights] raw error:", rawMessage);

      // 사용자 친화적 에러 메시지 반환 (기술적 세부사항 숨김)
      let userMessage = "인사이트 생성 중 문제가 생겼어요. 잠시 후 다시 시도해주세요";
      if (rawMessage.includes("FAILED_PRECONDITION") || rawMessage.includes("requires an index")) {
        userMessage = "서버 설정이 필요해요. 관리자에게 문의해주세요";
      } else if (rawMessage.includes("DEADLINE_EXCEEDED") || rawMessage.includes("timeout")) {
        userMessage = "요청 시간이 초과됐어요. 잠시 후 다시 시도해주세요";
      } else if (rawMessage.includes("UNAVAILABLE")) {
        userMessage = "서버에 연결할 수 없어요. 잠시 후 다시 시도해주세요";
      }

      throw new functions.https.HttpsError("internal", userMessage);
    }
  });

/**
 * 회원 인사이트 자동 생성 스케줄 함수
 *
 * @description
 * 매일 오전 9시에 모든 활성 회원에 대해 자동으로 인사이트를 생성합니다.
 * 트레이너 인사이트보다 1시간 늦게 실행되어 서버 부하 분산
 *
 * @fires pubsub.schedule
 * @region asia-northeast3
 * @schedule 매일 오전 9시 (Asia/Seoul)
 */
export const generateMemberInsightsScheduled = functions
  .region("asia-northeast3")
  .pubsub.schedule("0 8 * * *") // 매일 오전 8시 (트레이너 인사이트 1시간 후)
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const startTime = Date.now();
    functions.logger.info("[generateMemberInsightsScheduled] 스케줄 실행 시작");

    try {
      // 모든 회원 조회
      const membersSnapshot = await db
        .collection(Collections.MEMBERS)
        .get();

      functions.logger.info("[generateMemberInsightsScheduled] 회원 조회 완료", {
        memberCount: membersSnapshot.size,
      });

      let totalInsights = 0;
      let successCount = 0;
      let errorCount = 0;

      // 각 회원에 대해 인사이트 생성
      for (const memberDoc of membersSnapshot.docs) {
        const memberId = memberDoc.id;
        const memberData = memberDoc.data();

        try {
          const member: MemberData = {
            id: memberId,
            name: memberData.name || "회원",
            goal: memberData.goal,
            targetWeight: memberData.targetWeight,
            targetBodyFat: memberData.targetBodyFat,
            targetMuscleMass: memberData.targetMuscleMass,
          };

          // 데이터 병렬 조회
          const [
            bodyRecordsSnapshot,
            inbodyRecordsSnapshot,
            schedulesSnapshot,
            dietRecordsSnapshot,
          ] = await Promise.all([
            db.collection(Collections.BODY_RECORDS)
              .where("memberId", "==", memberId)
              .orderBy("recordDate", "desc")
              .limit(100)
              .get(),
            db.collection(Collections.INBODY_RECORDS)
              .where("memberId", "==", memberId)
              .orderBy("measuredAt", "desc")
              .limit(50)
              .get(),
            db.collection(Collections.SCHEDULES)
              .where("memberId", "==", memberId)
              .orderBy("scheduledAt", "desc")
              .limit(50)
              .get(),
            db.collection(Collections.DIET_RECORDS)
              .where("memberId", "==", memberId)
              .orderBy("analyzedAt", "desc")
              .limit(50)
              .get(),
          ]);

          const bodyRecords: BodyRecord[] = bodyRecordsSnapshot.docs.map(
            (doc) => doc.data() as BodyRecord
          );
          const inbodyRecords: InbodyRecord[] = inbodyRecordsSnapshot.docs.map(
            (doc) => doc.data() as InbodyRecord
          );
          // workout_records 컬렉션 미존재 → 빈 배열
          const workoutRecords: WorkoutRecord[] = [];
          const schedules: ScheduleRecord[] = schedulesSnapshot.docs.map(
            (doc) => doc.data() as ScheduleRecord
          );
          const dietRecords: DietRecord[] = dietRecordsSnapshot.docs.map(
            (doc) => doc.data() as DietRecord
          );

          // 인사이트 생성
          const insights: MemberInsight[] = [];

          const bodyPrediction = generateBodyPrediction(bodyRecords, inbodyRecords, member);
          if (bodyPrediction) insights.push(bodyPrediction);

          const workoutAchievement = generateWorkoutAchievement(workoutRecords);
          if (workoutAchievement) insights.push(workoutAchievement);

          const attendanceHabit = await generateAttendanceHabit(schedules, memberId);
          if (attendanceHabit) insights.push(attendanceHabit);

          const nutritionBalance = generateNutritionBalance(dietRecords, member);
          if (nutritionBalance) insights.push(nutritionBalance);

          const bodyChangeReport = generateBodyChangeReport(inbodyRecords);
          if (bodyChangeReport) insights.push(bodyChangeReport);

          const conditionPattern = generateConditionPattern(workoutRecords);
          if (conditionPattern) insights.push(conditionPattern);

          const goalProgress = generateGoalProgress(bodyRecords, inbodyRecords, member);
          if (goalProgress) insights.push(goalProgress);

          const benchmarking = await generateBenchmarking(
            member,
            bodyRecords,
            inbodyRecords,
            schedules
          );
          if (benchmarking) insights.push(benchmarking);

          const weeklySummary = generateWeeklySummary(schedules, bodyRecords, inbodyRecords, member);
          if (weeklySummary) insights.push(weeklySummary);

          const restRecommendation = generateRestRecommendation(schedules);
          if (restRecommendation) insights.push(restRecommendation);

          // 우선순위 기반 필터링 및 정렬
          const sortedInsights = insights
            .map((insight) => ({
              ...insight,
              score: calculateInsightScore(insight.type, insight.priority, false),
            }))
            .sort((a, b) => b.score - a.score)
            .slice(0, INSIGHT_CONFIG.MAX_INSIGHTS_DISPLAY)
            .map(({score: _score, ...insight}) => insight);

          // 저장
          const now = admin.firestore.Timestamp.now();
          const expiresAt = admin.firestore.Timestamp.fromDate(
            new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
          );

          // 기존 인사이트 삭제
          const existingSnapshot = await db
            .collection("member_insights")
            .where("memberId", "==", memberId)
            .get();

          const batch = db.batch();
          existingSnapshot.docs.forEach((doc) => {
            batch.delete(doc.ref);
          });

          // 새 인사이트 저장 (필터링된 상위 인사이트만)
          for (const insight of sortedInsights) {
            const docRef = db.collection("member_insights").doc();
            batch.set(docRef, {
              memberId,
              type: insight.type,
              priority: insight.priority,
              title: insight.title,
              message: insight.message,
              graphData: insight.graphData || null,
              graphType: insight.graphType || null,
              data: insight.data ? JSON.parse(JSON.stringify(insight.data)) : null,
              createdAt: now,
              expiresAt,
            });
          }

          await batch.commit();

          totalInsights += sortedInsights.length;
          successCount++;

          functions.logger.info("[generateMemberInsightsScheduled] 회원 처리 완료", {
            memberId,
            newInsights: insights.length,
          });

          // API 레이트 리밋 방지를 위한 지연
          await new Promise((resolve) => setTimeout(resolve, 50));
        } catch (memberError) {
          errorCount++;
          functions.logger.error("[generateMemberInsightsScheduled] 회원 처리 실패", {
            memberId,
            error: memberError instanceof Error ? memberError.message : memberError,
          });
        }
      }

      const duration = Date.now() - startTime;
      functions.logger.info("[generateMemberInsightsScheduled] 스케줄 실행 완료", {
        totalMembers: membersSnapshot.size,
        successCount,
        errorCount,
        totalInsights,
        durationMs: duration,
      });

      return null;
    } catch (error) {
      functions.logger.error("[generateMemberInsightsScheduled] 스케줄 실행 실패", {
        error: error instanceof Error ? error.message : error,
        stack: error instanceof Error ? error.stack : undefined,
      });
      return null;
    }
  });
