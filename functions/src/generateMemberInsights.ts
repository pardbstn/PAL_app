/**
 * 회원용 AI 인사이트 생성 Cloud Function
 * 회원의 운동, 체성분, 출석, 영양 데이터를 분석하여 동기부여 인사이트 생성
 *
 * @module generateMemberInsights
 */

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();

// 인사이트 타입 정의
type MemberInsightType =
  | "body_prediction"
  | "workout_achievement"
  | "attendance_habit"
  | "nutrition_balance"
  | "body_change_report"
  | "condition_pattern"
  | "goal_progress";

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
  createdAt?: admin.firestore.Timestamp;
}

interface MemberData {
  id: string;
  name: string;
  goal?: string;
  targetWeight?: number;
  targetBodyFat?: number;
  targetMuscleMass?: number;
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
      const date = (record.measuredAt || record.recordDate || record.createdAt)?.toDate();
      if (date && date >= fourWeeksAgo) {
        weightData.push({weight: record.weight, date});
      }
    }
  });

  inbodyRecords.forEach((record) => {
    if (record.weight) {
      const date = (record.measuredAt || record.createdAt)?.toDate();
      if (date && date >= fourWeeksAgo) {
        weightData.push({weight: record.weight, date});
      }
    }
  });

  if (weightData.length < 2) {
    return null;
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

  // 메시지 생성
  let message: string;
  let priority: InsightPriority = "medium";

  if (targetWeight && Math.abs(predictedWeight - targetWeight) <= 2) {
    message = `현재 속도 유지 시 4주 후 목표 체중 ${targetWeight}kg 도달 예상!`;
    priority = "high";
  } else if (weightChange < -0.5) {
    message = `현재 페이스대로면 4주 후 ${predictedWeight.toFixed(1)}kg 예상! ` +
      `${Math.abs(weightChange).toFixed(1)}kg 감량 중이에요.`;
  } else if (weightChange > 0.5) {
    message = `4주 후 ${predictedWeight.toFixed(1)}kg 예상. ` +
      "체중이 조금씩 증가하고 있어요.";
  } else {
    message = `체중이 ${currentWeight.toFixed(1)}kg으로 안정적으로 유지되고 있어요!`;
    priority = "low";
  }

  return {
    type: "body_prediction",
    priority,
    title: "체성분 예측",
    message,
    graphData,
    graphType: "line",
    data: {
      currentWeight,
      predictedWeight: parseFloat(predictedWeight.toFixed(1)),
      weightChange: parseFloat(weightChange.toFixed(1)),
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
  if (workoutRecords.length < 2) {
    return null;
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

    const date = record.createdAt?.toDate();
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
      title: "운동 성과",
      message: `${bestExercise} 최고 기록: ${latestRM.toFixed(0)}kg! 꾸준히 운동하고 있어요.`,
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

  return {
    type: "workout_achievement",
    priority: "high",
    title: "운동 성과",
    message: `${bestExercise} 1RM이 4주 전보다 ${bestImprovement.toFixed(0)}kg 증가! ` +
      `이 속도면 다음 달 ${nextTarget}kg 도전 가능`,
    graphData,
    graphType: "line",
    data: {
      exercise: bestExercise,
      previousRM: parseFloat(oldestRM.toFixed(1)),
      currentRM: parseFloat(latestRM.toFixed(1)),
      improvement: parseFloat(bestImprovement.toFixed(1)),
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
    const date = (s.date || s.scheduledAt)?.toDate();
    return date && date >= fourWeeksAgo;
  });

  if (recentSchedules.length === 0) {
    return null;
  }

  // 완료된 세션 수
  const completed = recentSchedules.filter(
    (s) => s.status === "completed" || s.status === "attended"
  ).length;
  const total = recentSchedules.length;
  const attendanceRate = Math.round((completed / total) * 100);

  // 주간 출석 데이터 계산
  const weeklyData: number[] = [0, 0, 0, 0];
  recentSchedules.forEach((s) => {
    const date = (s.date || s.scheduledAt)?.toDate();
    if (!date) return;

    const weeksAgo = Math.floor(
      (Date.now() - date.getTime()) / (7 * 24 * 60 * 60 * 1000)
    );
    if (weeksAgo >= 0 && weeksAgo < 4 &&
        (s.status === "completed" || s.status === "attended")) {
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

  // 메시지 생성
  let message: string;
  let priority: InsightPriority;

  if (attendanceRate >= 80) {
    message = `출석률 ${attendanceRate}%로 상위 ${percentile}%! 꾸준함이 최고의 무기예요`;
    priority = "medium";
  } else if (attendanceRate >= 60) {
    message = `출석률 ${attendanceRate}%! 조금만 더 힘내면 목표 달성이 눈앞이에요`;
    priority = "medium";
  } else {
    message = `최근 출석률이 ${attendanceRate}%예요. 다시 시작해볼까요?`;
    priority = "high";
  }

  return {
    type: "attendance_habit",
    priority,
    title: "출석 습관",
    message,
    graphData,
    graphType: "bar",
    data: {
      attendanceRate,
      percentile,
      completedSessions: completed,
      totalSessions: total,
      weeklyData,
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
    const date = d.createdAt?.toDate();
    return date && date >= oneWeekAgo;
  });

  if (recentDiets.length < 3) {
    return null;
  }

  // 일평균 섭취량 계산
  const totalDays = 7;
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

  // 메시지 생성
  let message: string;
  let priority: InsightPriority;

  if (mostDeficient.percent < 70) {
    message = `이번 주 ${mostDeficient.name} 섭취 목표 대비 ` +
      `${100 - mostDeficient.percent}% 부족 - ${mostDeficient.suggestion} 추가 권장`;
    priority = "high";
  } else if (mostDeficient.percent < 90) {
    message = `${mostDeficient.name} 섭취가 조금 부족해요. ` +
      `${mostDeficient.suggestion} 추가하면 완벽!`;
    priority = "medium";
  } else {
    message = "이번 주 영양 밸런스가 매우 좋아요! 이대로 유지하세요";
    priority = "low";
  }

  return {
    type: "nutrition_balance",
    priority,
    title: "영양 밸런스",
    message,
    graphData,
    graphType: "donut",
    data: {
      avgProtein: parseFloat(avgProtein.toFixed(1)),
      avgCarbs: parseFloat(avgCarbs.toFixed(1)),
      avgFat: parseFloat(avgFat.toFixed(1)),
      proteinPercent,
      carbsPercent,
      fatPercent,
    },
  };
}

/**
 * 5. 체성분 변화 리포트 (body_change_report)
 * 3개월간 체지방/골격근 변화
 */
function generateBodyChangeReport(
  inbodyRecords: InbodyRecord[]
): MemberInsight | null {
  if (inbodyRecords.length < 2) {
    return null;
  }

  // 날짜순 정렬
  const sortedRecords = [...inbodyRecords].sort((a, b) => {
    const dateA = (a.measuredAt || a.createdAt)?.toDate()?.getTime() || 0;
    const dateB = (b.measuredAt || b.createdAt)?.toDate()?.getTime() || 0;
    return dateA - dateB;
  });

  // 3개월 전 데이터와 최근 데이터 비교
  const threeMonthsAgo = new Date();
  threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);

  const oldRecords = sortedRecords.filter((r) => {
    const date = (r.measuredAt || r.createdAt)?.toDate();
    return date && date <= threeMonthsAgo;
  });

  const latestRecord = sortedRecords[sortedRecords.length - 1];
  const oldestRecord = oldRecords.length > 0 ? oldRecords[0] : sortedRecords[0];

  if (!latestRecord || !oldestRecord) return null;

  // 체지방량, 골격근량 변화
  const beforeFat = oldestRecord.bodyFatMass || 0;
  const afterFat = latestRecord.bodyFatMass || 0;
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

  // 메시지 생성
  let message: string;
  let priority: InsightPriority;

  const fatText = fatChange < 0
    ? `체지방 ${Math.abs(fatChange).toFixed(1)}kg`
    : "";
  const muscleText = muscleChange > 0
    ? `골격근 +${muscleChange.toFixed(1)}kg`
    : "";
  const fatPercentText = beforeFatPercent > 0 && afterFatPercent > 0
    ? `체지방률 ${beforeFatPercent.toFixed(0)}%→${afterFatPercent.toFixed(0)}%`
    : "";

  if (fatChange < 0 && muscleChange > 0) {
    message = `3개월간 ${fatText}, ${muscleText}! ${fatPercentText}`;
    priority = "high";
  } else if (fatChange < 0) {
    message = `3개월간 ${fatText} 감량 성공! ${fatPercentText}`;
    priority = "medium";
  } else if (muscleChange > 0) {
    message = `3개월간 ${muscleText} 증가! 근육이 늘고 있어요`;
    priority = "medium";
  } else {
    message = "체성분이 안정적으로 유지되고 있어요";
    priority = "low";
  }

  return {
    type: "body_change_report",
    priority,
    title: "체성분 변화 리포트",
    message,
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
  if (workoutRecords.length < 5) {
    return null;
  }

  // 요일별 성과 집계
  const dayNames = ["일", "월", "화", "수", "목", "금", "토"];
  const dayStats: Array<{total: number; count: number}> = Array(7)
    .fill(null)
    .map(() => ({total: 0, count: 0}));

  workoutRecords.forEach((record) => {
    const date = record.createdAt?.toDate();
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
  if (activeDays.length < 2) {
    return null;
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
      const dateA = (a.measuredAt || a.createdAt)?.toDate()?.getTime() || 0;
      const dateB = (b.measuredAt || b.createdAt)?.toDate()?.getTime() || 0;
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
      const dateA = (a.measuredAt || a.recordDate || a.createdAt)?.toDate()?.getTime() || 0;
      const dateB = (b.measuredAt || b.recordDate || b.createdAt)?.toDate()?.getTime() || 0;
      return dateB - dateA;
    });
    const latest = sortedBody[0];
    currentWeight = currentWeight || latest.weight;
    currentBodyFat = currentBodyFat || latest.bodyFat;
    currentMuscle = currentMuscle || latest.muscleMass;
  }

  // 목표 설정
  const targetWeight = member.targetWeight;
  const targetBodyFat = member.targetBodyFat;
  const targetMuscle = member.targetMuscleMass;

  // 진행률 계산
  let progressPercent = 0;
  let progressMessage = "";
  let hasTarget = false;

  if (targetWeight && currentWeight) {
    hasTarget = true;
    // 체중 감량 목표인지 증량 목표인지 판단
    const isWeightLoss = member.goal === "diet" || targetWeight < currentWeight;

    if (isWeightLoss) {
      // 시작 체중 추정 (가장 높은 기록)
      const maxWeight = Math.max(
        ...bodyRecords.map((r) => r.weight || 0),
        ...inbodyRecords.map((r) => r.weight || 0),
        currentWeight
      );
      const totalToLose = maxWeight - targetWeight;
      const alreadyLost = maxWeight - currentWeight;

      if (totalToLose > 0) {
        progressPercent = Math.min(100, Math.round((alreadyLost / totalToLose) * 100));
      }
    } else {
      // 체중 증량 목표
      const minWeight = Math.min(
        ...bodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        ...inbodyRecords.filter((r) => r.weight).map((r) => r.weight!),
        currentWeight
      );
      const totalToGain = targetWeight - minWeight;
      const alreadyGained = currentWeight - minWeight;

      if (totalToGain > 0) {
        progressPercent = Math.min(100, Math.round((alreadyGained / totalToGain) * 100));
      }
    }

    progressMessage = `목표 체중 ${targetWeight}kg까지`;
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

  // 메시지 및 우선순위 결정
  let message: string;
  let priority: InsightPriority;

  if (progressPercent >= 90) {
    message = `목표까지 ${progressPercent}% 달성! 조금만 더 힘내세요`;
    priority = "high";
  } else if (progressPercent >= 70) {
    message = `목표까지 ${progressPercent}% 달성! 순조롭게 진행 중이에요`;
    priority = "medium";
  } else if (progressPercent >= 50) {
    message = `목표까지 절반 왔어요! ${progressPercent}% 달성`;
    priority = "medium";
  } else {
    message = `${progressMessage} ${progressPercent}% 진행 중. 꾸준히 해봐요!`;
    priority = "low";
  }

  return {
    type: "goal_progress",
    priority,
    title: "목표 달성률",
    message,
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
      const memberDoc = await db.collection("members").doc(memberId).get();
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

      // 3. 데이터 수집 기간 설정
      const threeMonthsAgo = new Date();
      threeMonthsAgo.setMonth(threeMonthsAgo.getMonth() - 3);
      const threeMonthsAgoTimestamp = admin.firestore.Timestamp.fromDate(threeMonthsAgo);

      // 4. 데이터 병렬 조회
      const [
        bodyRecordsSnapshot,
        inbodyRecordsSnapshot,
        workoutRecordsSnapshot,
        schedulesSnapshot,
        dietRecordsSnapshot,
      ] = await Promise.all([
        // body_records (최근 3개월)
        db.collection("body_records")
          .where("memberId", "==", memberId)
          .orderBy("createdAt", "desc")
          .limit(100)
          .get(),

        // inbody_records (최근 3개월)
        db.collection("inbody_records")
          .where("memberId", "==", memberId)
          .orderBy("measuredAt", "desc")
          .limit(50)
          .get(),

        // workout_records (최근 3개월)
        db.collection("workout_records")
          .where("memberId", "==", memberId)
          .where("createdAt", ">=", threeMonthsAgoTimestamp)
          .orderBy("createdAt", "desc")
          .limit(500)
          .get(),

        // schedules (최근 4주)
        db.collection("schedules")
          .where("memberId", "==", memberId)
          .orderBy("date", "desc")
          .limit(50)
          .get(),

        // diet_records (최근 1주)
        db.collection("diet_records")
          .where("memberId", "==", memberId)
          .orderBy("createdAt", "desc")
          .limit(50)
          .get(),
      ]);

      const bodyRecords: BodyRecord[] = bodyRecordsSnapshot.docs.map(
        (doc) => doc.data() as BodyRecord
      );
      const inbodyRecords: InbodyRecord[] = inbodyRecordsSnapshot.docs.map(
        (doc) => doc.data() as InbodyRecord
      );
      const workoutRecords: WorkoutRecord[] = workoutRecordsSnapshot.docs.map(
        (doc) => doc.data() as WorkoutRecord
      );
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

      functions.logger.info("[generateMemberInsights] 인사이트 생성 완료", {
        totalInsights: insights.length,
        types: insights.map((i) => i.type),
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

      // 새 인사이트 저장
      const savedInsights: Array<MemberInsight & {id: string}> = [];
      for (const insight of insights) {
        const docRef = db.collection("member_insights").doc();
        const insightDoc = {
          memberId,
          type: insight.type,
          priority: insight.priority,
          title: insight.title,
          message: insight.message,
          graphData: insight.graphData || null,
          graphType: insight.graphType || null,
          data: insight.data || null,
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
          type: insight.type,
          priority: insight.priority,
          title: insight.title,
          message: insight.message,
          graphData: insight.graphData,
          graphType: insight.graphType,
          data: insight.data,
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

      const errorMessage = error instanceof Error ? error.message : "알 수 없는 오류";
      throw new functions.https.HttpsError(
        "internal",
        `인사이트 생성 중 오류가 발생했습니다: ${errorMessage}`
      );
    }
  });
