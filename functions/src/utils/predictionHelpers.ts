/**
 * AI 체중 예측 헬퍼 함수 모듈
 * 선형 회귀, 가중 이동 평균 기반 예측 알고리즘 구현
 *
 * @module predictionHelpers
 */

// ==================== 상수 정의 ====================

/** 최소 필요 데이터 포인트 수 */
export const MIN_DATA_POINTS = 4;

/** 최대 예측 기간 (주) - 1주 예측만 지원 */
export const MAX_WEEKS_AHEAD = 1;

/** 이상치 판단 기준 (kg) */
export const OUTLIER_THRESHOLD = 3;

/** 티어별 월간 예측 한도 */
export const PREDICTION_LIMITS: Record<string, number> = {
  free: 3,
  basic: 20,
  pro: Infinity,
};

// ==================== 인터페이스 정의 ====================

/**
 * 체중 데이터 포인트
 */
export interface WeightDataPoint {
  date: Date;
  weight: number;
}

/**
 * 주간 체중 데이터
 */
export interface WeeklyWeightData {
  weekStart: Date;
  avgWeight: number;
  dataPoints: number;
}

/**
 * 선형 회귀 결과
 */
export interface LinearRegressionResult {
  /** 기울기 (kg/day) */
  slope: number;
  /** y절편 */
  intercept: number;
  /** 결정계수 (0~1) */
  rSquared: number;
}

/**
 * 예측 포인트
 */
export interface PredictedPoint {
  date: string;
  weight: number;
  upperBound: number;
  lowerBound: number;
}

/**
 * 예측 요청 인터페이스
 */
export interface PredictWeightRequest {
  memberId: string;
  weeksAhead?: number;
}

/**
 * 예측 응답 인터페이스
 */
export interface PredictWeightResponse {
  success: boolean;
  prediction?: {
    id: string;
    memberId: string;
    trainerId: string;
    currentWeight: number;
    targetWeight: number | null;
    predictedWeights: PredictedPoint[];
    weeklyTrend: number;
    estimatedWeeksToTarget: number | null;
    confidence: number;
    dataPointsUsed: number;
    analysisMessage: string;
  };
  error?: {
    code: string;
    message: string;
  };
}

// ==================== 헬퍼 함수 ====================

/**
 * 선형 회귀 계산 (최소제곱법)
 *
 * @param data - 체중 데이터 포인트 배열
 * @returns 회귀 결과 (기울기, 절편, R²)
 *
 * @example
 * const data = [{date: new Date('2024-01-01'), weight: 80}, ...];
 * const result = calculateLinearRegression(data);
 * console.log(result.slope); // kg/day
 */
export function calculateLinearRegression(
  data: WeightDataPoint[]
): LinearRegressionResult {
  const n = data.length;
  if (n < 2) {
    return {slope: 0, intercept: data[0]?.weight || 0, rSquared: 0};
  }

  // x를 일수로 변환 (첫 날짜 기준)
  const baseDate = data[0].date.getTime();
  const points = data.map((d) => ({
    x: (d.date.getTime() - baseDate) / (1000 * 60 * 60 * 24),
    y: d.weight,
  }));

  // 평균 계산
  const sumX = points.reduce((acc, p) => acc + p.x, 0);
  const sumY = points.reduce((acc, p) => acc + p.y, 0);
  const meanX = sumX / n;
  const meanY = sumY / n;

  // 기울기와 절편 계산
  let numerator = 0;
  let denominator = 0;
  for (const p of points) {
    numerator += (p.x - meanX) * (p.y - meanY);
    denominator += (p.x - meanX) ** 2;
  }

  const slope = denominator !== 0 ? numerator / denominator : 0;
  const intercept = meanY - slope * meanX;

  // R² (결정계수) 계산
  let ssRes = 0;
  let ssTot = 0;
  for (const p of points) {
    const predicted = slope * p.x + intercept;
    ssRes += (p.y - predicted) ** 2;
    ssTot += (p.y - meanY) ** 2;
  }
  const rSquared = ssTot !== 0 ? 1 - ssRes / ssTot : 0;

  return {slope, intercept, rSquared};
}

/**
 * 가중 추세 계산 (최근 데이터에 높은 가중치)
 *
 * @param data - 주간 체중 데이터 배열
 * @returns 가중 평균 주간 변화량 (kg/week)
 *
 * @example
 * const weeklyData = [{weekStart: new Date(), avgWeight: 80, dataPoints: 3}, ...];
 * const trend = calculateWeightedTrend(weeklyData);
 */
export function calculateWeightedTrend(data: WeeklyWeightData[]): number {
  if (data.length < 2) return 0;

  // 주간 변화량 계산
  const changes: {change: number; weight: number}[] = [];
  for (let i = 1; i < data.length; i++) {
    const weeksDiff = Math.max(
      1,
      (data[i].weekStart.getTime() - data[i - 1].weekStart.getTime()) /
        (1000 * 60 * 60 * 24 * 7)
    );
    const weeklyChange = (data[i].avgWeight - data[i - 1].avgWeight) / weeksDiff;

    // 최근 데이터일수록 높은 가중치
    const recency = data.length - i;
    let weightFactor: number;
    if (recency <= 2) {
      weightFactor = 3; // 최근 2주: 3배
    } else if (recency <= 4) {
      weightFactor = 2; // 최근 3-4주: 2배
    } else {
      weightFactor = 1; // 그 외: 1배
    }

    changes.push({change: weeklyChange, weight: weightFactor});
  }

  // 가중 평균 계산
  const totalWeight = changes.reduce((acc, c) => acc + c.weight, 0);
  const weightedSum = changes.reduce((acc, c) => acc + c.change * c.weight, 0);

  return Math.round((weightedSum / totalWeight) * 100) / 100;
}

/**
 * 표준편차 계산
 *
 * @param values - 숫자 배열
 * @returns 표준편차
 */
export function calculateStandardDeviation(values: number[]): number {
  if (values.length < 2) return 0;

  const mean = values.reduce((a, b) => a + b, 0) / values.length;
  const squaredDiffs = values.map((v) => (v - mean) ** 2);
  const variance = squaredDiffs.reduce((a, b) => a + b, 0) / values.length;

  return Math.sqrt(variance);
}

/**
 * 이상치 제거
 *
 * @param data - 체중 데이터
 * @param maxChange - 허용 최대 변화량 (kg), 기본값: 3
 * @returns 이상치가 제거된 데이터
 */
export function removeOutliers(
  data: WeightDataPoint[],
  maxChange: number = OUTLIER_THRESHOLD
): WeightDataPoint[] {
  if (data.length < 3) return data;

  const result: WeightDataPoint[] = [data[0]];
  for (let i = 1; i < data.length - 1; i++) {
    const prev = data[i - 1].weight;
    const curr = data[i].weight;
    const next = data[i + 1].weight;

    // 전후 데이터와의 차이가 모두 maxChange 이상이면 이상치로 판단
    if (
      Math.abs(curr - prev) < maxChange ||
      Math.abs(curr - next) < maxChange
    ) {
      result.push(data[i]);
    }
  }
  result.push(data[data.length - 1]);
  return result;
}

/**
 * 일별 데이터를 주간 데이터로 집계
 *
 * @param data - 일별 체중 데이터
 * @returns 주간 집계 데이터
 */
export function aggregateToWeekly(data: WeightDataPoint[]): WeeklyWeightData[] {
  if (data.length === 0) return [];

  // 주 시작일(월요일) 기준으로 그룹화
  const weekMap = new Map<string, {weights: number[]; weekStart: Date}>();

  for (const point of data) {
    const d = new Date(point.date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1);
    const monday = new Date(d.setDate(diff));
    monday.setHours(0, 0, 0, 0);
    const key = monday.toISOString().split("T")[0];

    if (!weekMap.has(key)) {
      weekMap.set(key, {weights: [], weekStart: monday});
    }
    weekMap.get(key)!.weights.push(point.weight);
  }

  // 주간 평균 계산
  const result: WeeklyWeightData[] = [];
  for (const [, value] of weekMap) {
    const avgWeight =
      value.weights.reduce((a, b) => a + b, 0) / value.weights.length;
    result.push({
      weekStart: value.weekStart,
      avgWeight: Math.round(avgWeight * 10) / 10,
      dataPoints: value.weights.length,
    });
  }

  // 날짜순 정렬
  result.sort((a, b) => a.weekStart.getTime() - b.weekStart.getTime());
  return result;
}

/**
 * 신뢰도 점수 계산
 *
 * @param dataPoints - 데이터 포인트 수
 * @param variance - 분산
 * @param r2 - R² 결정계수
 * @returns 신뢰도 (0.3 ~ 0.95)
 */
export function calculateConfidence(
  dataPoints: number,
  variance: number,
  r2: number
): number {
  // 데이터 양 점수 (0~0.4): 12주 이상이면 만점
  const dataScore = Math.min(dataPoints / 12, 1) * 0.4;

  // 일관성 점수 (0~0.3): 분산이 낮을수록 높음
  const consistencyScore = Math.max(0, 1 - variance / 5) * 0.3;

  // 추세 적합도 점수 (0~0.3): R² 값 사용
  const fitScore = Math.max(0, r2) * 0.3;

  const confidence = dataScore + consistencyScore + fitScore;
  return Math.round(Math.max(0.3, Math.min(0.95, confidence)) * 100) / 100;
}

/**
 * 목표 도달 예상 주 계산
 *
 * @param currentWeight - 현재 체중
 * @param targetWeight - 목표 체중
 * @param weeklyTrend - 주간 변화량 (kg/week)
 * @returns 예상 주 수 (null: 도달 불가)
 */
export function calculateWeeksToTarget(
  currentWeight: number,
  targetWeight: number | null,
  weeklyTrend: number
): number | null {
  if (targetWeight === null || weeklyTrend === 0) return null;

  const weightDiff = targetWeight - currentWeight;

  // 목표와 추세 방향이 다르면 도달 불가
  if (
    (weightDiff > 0 && weeklyTrend < 0) ||
    (weightDiff < 0 && weeklyTrend > 0)
  ) {
    return null;
  }

  const weeks = Math.ceil(Math.abs(weightDiff / weeklyTrend));

  // 52주(1년) 초과하면 null
  return weeks <= 52 ? weeks : null;
}

/**
 * 분석 메시지 생성
 *
 * @param params - 메시지 생성 파라미터
 * @returns 분석 메시지 (한글)
 */
export function generateAnalysisMessage(params: {
  weeklyTrend: number;
  weeksToTarget: number | null;
  confidence: number;
  goal: string;
  currentWeight: number;
  targetWeight: number | null;
}): string {
  const {
    weeklyTrend,
    weeksToTarget,
    confidence,
    goal,
    currentWeight,
    targetWeight,
  } = params;

  let message = "";

  // 추세 설명
  if (Math.abs(weeklyTrend) < 0.1) {
    message = "체중이 안정적으로 유지되고 있습니다. ";
  } else if (weeklyTrend < -0.5) {
    message = `주당 약 ${Math.abs(weeklyTrend).toFixed(1)}kg씩 빠르게 감량 중입니다. `;
  } else if (weeklyTrend < 0) {
    message = `주당 약 ${Math.abs(weeklyTrend).toFixed(1)}kg씩 꾸준히 감량 중입니다. `;
  } else if (weeklyTrend > 0.5) {
    message = `주당 약 ${weeklyTrend.toFixed(1)}kg씩 빠르게 증량 중입니다. `;
  } else {
    message = `주당 약 ${weeklyTrend.toFixed(1)}kg씩 서서히 증량 중입니다. `;
  }

  // 목표 도달 예상
  if (weeksToTarget && weeksToTarget > 0 && weeksToTarget <= 52) {
    const months = Math.round(weeksToTarget / 4);
    if (weeksToTarget <= 4) {
      message += `현재 속도 유지 시 약 ${weeksToTarget}주 후 목표 체중(${targetWeight}kg)에 도달할 것으로 예상됩니다!`;
    } else {
      message += `현재 속도 유지 시 약 ${months}개월(${weeksToTarget}주) 후 목표 체중(${targetWeight}kg) 도달이 예상됩니다.`;
    }
  } else if (targetWeight) {
    const diff = currentWeight - targetWeight;
    if (goal === "diet" && diff > 0 && weeklyTrend >= 0) {
      message +=
        "목표 달성을 위해 식단 조절이나 운동량 증가가 필요해 보입니다.";
    } else if (goal === "bulk" && diff < 0 && weeklyTrend <= 0) {
      message += "목표 달성을 위해 칼로리 섭취 증가가 필요해 보입니다.";
    }
  }

  // 신뢰도 언급
  if (confidence < 0.5) {
    message += "\n\n데이터가 더 쌓이면 예측 정확도가 높아집니다.";
  } else if (confidence >= 0.8) {
    message += "\n\n충분한 데이터로 신뢰도 높은 예측입니다.";
  }

  return message;
}

/**
 * 예측 포인트 생성
 *
 * @param params - 예측 파라미터
 * @returns 예측 포인트 배열
 */
export function generatePredictedWeights(params: {
  currentWeight: number;
  lastDate: Date;
  weeklyTrend: number;
  weeksAhead: number;
  standardDeviation: number;
}): PredictedPoint[] {
  const {currentWeight, lastDate, weeklyTrend, weeksAhead, standardDeviation} =
    params;

  const predictedWeights: PredictedPoint[] = [];

  for (let week = 1; week <= weeksAhead; week++) {
    const futureDate = new Date(lastDate);
    futureDate.setDate(futureDate.getDate() + week * 7);

    const predictedWeight = currentWeight + weeklyTrend * week;

    // 신뢰구간: 1.96 * σ * sqrt(week) (95% 신뢰구간)
    const margin = 1.96 * standardDeviation * Math.sqrt(week);

    predictedWeights.push({
      date: futureDate.toISOString(),
      weight: Math.round(predictedWeight * 10) / 10,
      upperBound: Math.round((predictedWeight + margin) * 10) / 10,
      lowerBound: Math.round((predictedWeight - margin) * 10) / 10,
    });
  }

  return predictedWeights;
}

/**
 * 사용량 한도 체크
 *
 * @param tier - 구독 티어
 * @param currentCount - 현재 사용량
 * @returns 한도 초과 여부
 */
export function isQuotaExceeded(tier: string, currentCount: number): boolean {
  const limit = PREDICTION_LIMITS[tier.toLowerCase()] || PREDICTION_LIMITS.free;
  return currentCount >= limit;
}

/**
 * 데이터 요약 인터페이스
 */
export interface DataSummary {
  /** 최근 1주 변화량 (kg) */
  recentWeekChange: number;
  /** 최근 1개월 변화량 (kg) */
  recentMonthChange: number;
  /** 전체 기간 변화량 (kg) */
  totalChange: number;
  /** 최저 체중 (kg) */
  minWeight: number;
  /** 최고 체중 (kg) */
  maxWeight: number;
  /** 평균 체중 (kg) */
  avgWeight: number;
  /** 체중 변동폭 (kg) */
  weightRange: number;
  /** 기록 기간 (일) */
  recordDays: number;
  /** 일관성 점수 (0~100) - 변동이 적을수록 높음 */
  consistencyScore: number;
}

/**
 * 목표 달성 시나리오 인터페이스
 */
export interface GoalScenario {
  /** 시나리오 이름 */
  name: string;
  /** 주당 필요 변화량 (kg) */
  weeklyChange: number;
  /** 예상 소요 주 수 */
  weeksNeeded: number;
  /** 난이도 (easy/moderate/hard/very_hard) */
  difficulty: string;
  /** 설명 */
  description: string;
}

/**
 * 코칭 메시지 인터페이스
 */
export interface CoachingMessage {
  /** 메시지 유형 (success/warning/info/tip) */
  type: string;
  /** 제목 */
  title: string;
  /** 내용 */
  content: string;
}

/**
 * 데이터 요약 생성
 */
export function generateDataSummary(data: WeightDataPoint[]): DataSummary {
  if (data.length === 0) {
    return {
      recentWeekChange: 0,
      recentMonthChange: 0,
      totalChange: 0,
      minWeight: 0,
      maxWeight: 0,
      avgWeight: 0,
      weightRange: 0,
      recordDays: 0,
      consistencyScore: 0,
    };
  }

  const weights = data.map((d) => d.weight);
  const minWeight = Math.min(...weights);
  const maxWeight = Math.max(...weights);
  const avgWeight = weights.reduce((a, b) => a + b, 0) / weights.length;
  const weightRange = maxWeight - minWeight;

  const firstDate = data[0].date;
  const lastDate = data[data.length - 1].date;
  const recordDays = Math.ceil(
    (lastDate.getTime() - firstDate.getTime()) / (1000 * 60 * 60 * 24)
  );

  const currentWeight = data[data.length - 1].weight;
  const firstWeight = data[0].weight;
  const totalChange = currentWeight - firstWeight;

  // 최근 1주 변화
  const oneWeekAgo = new Date(lastDate);
  oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);
  const weekAgoData = data.filter((d) => d.date >= oneWeekAgo);
  const recentWeekChange =
    weekAgoData.length >= 2
      ? currentWeight - weekAgoData[0].weight
      : 0;

  // 최근 1개월 변화
  const oneMonthAgo = new Date(lastDate);
  oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);
  const monthAgoData = data.filter((d) => d.date >= oneMonthAgo);
  const recentMonthChange =
    monthAgoData.length >= 2
      ? currentWeight - monthAgoData[0].weight
      : totalChange;

  // 일관성 점수 (변동계수 기반, 낮을수록 일관적)
  const stdDev = calculateStandardDeviation(weights);
  const cv = avgWeight > 0 ? (stdDev / avgWeight) * 100 : 0;
  const consistencyScore = Math.round(Math.max(0, Math.min(100, 100 - cv * 10)));

  return {
    recentWeekChange: Math.round(recentWeekChange * 10) / 10,
    recentMonthChange: Math.round(recentMonthChange * 10) / 10,
    totalChange: Math.round(totalChange * 10) / 10,
    minWeight: Math.round(minWeight * 10) / 10,
    maxWeight: Math.round(maxWeight * 10) / 10,
    avgWeight: Math.round(avgWeight * 10) / 10,
    weightRange: Math.round(weightRange * 10) / 10,
    recordDays,
    consistencyScore,
  };
}

/**
 * 목표 달성 시나리오 생성
 */
export function generateGoalScenarios(
  currentWeight: number,
  targetWeight: number | null,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  goal: string
): GoalScenario[] {
  if (!targetWeight) return [];

  const diff = targetWeight - currentWeight;
  const isLosing = diff < 0;
  const absDiff = Math.abs(diff);

  if (absDiff < 0.5) {
    return [
      {
        name: "목표 달성!",
        weeklyChange: 0,
        weeksNeeded: 0,
        difficulty: "achieved",
        description: "축하합니다! 목표 체중에 거의 도달했습니다.",
      },
    ];
  }

  const scenarios: GoalScenario[] = [];

  // 천천히 (건강한 속도)
  const slowPace = isLosing ? -0.3 : 0.3;
  const slowWeeks = Math.ceil(absDiff / Math.abs(slowPace));
  scenarios.push({
    name: "천천히 & 건강하게",
    weeklyChange: slowPace,
    weeksNeeded: slowWeeks,
    difficulty: "easy",
    description: isLosing
      ? `주 ${Math.abs(slowPace)}kg 감량으로 약 ${slowWeeks}주(${Math.round(slowWeeks / 4)}개월) 소요. 요요 위험 최소화.`
      : `주 ${slowPace}kg 증량으로 약 ${slowWeeks}주(${Math.round(slowWeeks / 4)}개월) 소요. 근육 위주 증량 가능.`,
  });

  // 보통 속도
  const moderatePace = isLosing ? -0.5 : 0.5;
  const moderateWeeks = Math.ceil(absDiff / Math.abs(moderatePace));
  scenarios.push({
    name: "균형잡힌 페이스",
    weeklyChange: moderatePace,
    weeksNeeded: moderateWeeks,
    difficulty: "moderate",
    description: isLosing
      ? `주 ${Math.abs(moderatePace)}kg 감량으로 약 ${moderateWeeks}주(${Math.round(moderateWeeks / 4)}개월) 소요. 권장 속도.`
      : `주 ${moderatePace}kg 증량으로 약 ${moderateWeeks}주(${Math.round(moderateWeeks / 4)}개월) 소요.`,
  });

  // 빠른 속도 (다이어트만)
  if (isLosing && absDiff > 3) {
    const fastPace = -0.8;
    const fastWeeks = Math.ceil(absDiff / Math.abs(fastPace));
    scenarios.push({
      name: "집중 다이어트",
      weeklyChange: fastPace,
      weeksNeeded: fastWeeks,
      difficulty: "hard",
      description: `주 ${Math.abs(fastPace)}kg 감량으로 약 ${fastWeeks}주 소요. 철저한 식단 관리 필요.`,
    });
  }

  return scenarios;
}

/**
 * AI 코칭 메시지 생성
 */
export function generateCoachingMessages(params: {
  weeklyTrend: number;
  recentWeekChange: number;
  goal: string;
  currentWeight: number;
  targetWeight: number | null;
  consistencyScore: number;
  dataPointsUsed: number;
}): CoachingMessage[] {
  const {
    weeklyTrend,
    recentWeekChange,
    goal,
    currentWeight,
    targetWeight,
    consistencyScore,
    dataPointsUsed,
  } = params;

  const messages: CoachingMessage[] = [];
  const isDiet = goal === "diet";
  const diff = targetWeight ? currentWeight - targetWeight : 0;

  // 1. 최근 진행 상황 피드백
  if (Math.abs(recentWeekChange) >= 0.3) {
    if ((isDiet && recentWeekChange < 0) || (!isDiet && recentWeekChange > 0)) {
      messages.push({
        type: "success",
        title: "좋은 진행 중!",
        content: `최근 1주간 ${Math.abs(recentWeekChange).toFixed(1)}kg ${recentWeekChange < 0 ? "감량" : "증량"} 성공! 이 페이스를 유지하세요.`,
      });
    } else {
      messages.push({
        type: "warning",
        title: "방향 점검 필요",
        content: `최근 1주간 ${Math.abs(recentWeekChange).toFixed(1)}kg ${recentWeekChange < 0 ? "감소" : "증가"}했습니다. 목표와 반대 방향이에요.`,
      });
    }
  }

  // 2. 목표까지 남은 거리
  if (targetWeight && Math.abs(diff) >= 1) {
    const weeksNeeded = Math.abs(weeklyTrend) > 0.1
      ? Math.ceil(Math.abs(diff) / Math.abs(weeklyTrend))
      : null;

    if (weeksNeeded && weeksNeeded <= 52) {
      messages.push({
        type: "info",
        title: "목표까지",
        content: `${Math.abs(diff).toFixed(1)}kg ${isDiet ? "감량" : "증량"} 필요. 현재 속도면 약 ${weeksNeeded}주 후 달성 예상.`,
      });
    } else {
      const requiredPace = diff / 12; // 12주 기준
      messages.push({
        type: "info",
        title: "목표 달성 전략",
        content: `12주 내 달성하려면 주당 ${Math.abs(requiredPace).toFixed(1)}kg ${isDiet ? "감량" : "증량"}이 필요합니다.`,
      });
    }
  }

  // 3. 일관성 피드백
  if (consistencyScore < 50) {
    messages.push({
      type: "tip",
      title: "체중 변동이 큽니다",
      content: "같은 시간대에 측정하고, 수분/식사량 영향을 줄여보세요. 일관된 측정이 정확한 추세 파악에 도움됩니다.",
    });
  } else if (consistencyScore >= 80) {
    messages.push({
      type: "success",
      title: "일관된 기록",
      content: "체중 기록이 안정적입니다. 신뢰할 수 있는 데이터입니다.",
    });
  }

  // 4. 데이터 양 피드백
  if (dataPointsUsed < 8) {
    messages.push({
      type: "tip",
      title: "더 많은 기록 필요",
      content: `현재 ${dataPointsUsed}개의 기록이 있습니다. 최소 2주 이상 기록하면 더 정확한 분석이 가능합니다.`,
    });
  }

  // 5. 정체기 감지
  if (Math.abs(weeklyTrend) < 0.1 && targetWeight && Math.abs(diff) > 2) {
    messages.push({
      type: "warning",
      title: "정체기 감지",
      content: isDiet
        ? "체중 변화가 없습니다. 운동 루틴 변경이나 칼로리 재조정을 고려해보세요."
        : "체중 변화가 없습니다. 단백질 섭취량 증가나 훈련 강도 조절을 고려해보세요.",
    });
  }

  return messages;
}

// ==================== Gemini AI 분석 (Pro 전용) ====================

import {GoogleGenerativeAI} from "@google/generative-ai";

/**
 * Gemini AI 심층 분석 인터페이스
 */
export interface GeminiAnalysisResult {
  /** AI 생성 심층 분석 메시지 */
  aiInsight: string;
  /** AI 추천 액션 아이템 */
  actionItems: string[];
  /** AI 생성 동기부여 메시지 */
  motivationalMessage: string;
  /** 분석 생성 성공 여부 */
  success: boolean;
}

/**
 * Gemini AI를 사용한 심층 체중 분석 생성 (Pro 전용)
 *
 * @param params - 분석 파라미터
 * @returns Gemini 분석 결과
 */
export async function generateGeminiAnalysis(params: {
  currentWeight: number;
  targetWeight: number | null;
  weeklyTrend: number;
  dataSummary: DataSummary;
  goal: string;
  confidence: number;
  dataPointsUsed: number;
  estimatedWeeksToTarget: number | null;
  apiKey: string;
}): Promise<GeminiAnalysisResult> {
  const {
    currentWeight,
    targetWeight,
    weeklyTrend,
    dataSummary,
    goal,
    confidence,
    dataPointsUsed,
    estimatedWeeksToTarget,
    apiKey,
  } = params;

  // 기본 반환값 (실패 시)
  const defaultResult: GeminiAnalysisResult = {
    aiInsight: "",
    actionItems: [],
    motivationalMessage: "",
    success: false,
  };

  if (!apiKey) {
    return defaultResult;
  }

  try {
    const genAI = new GoogleGenerativeAI(apiKey);
    const model = genAI.getGenerativeModel({model: "gemini-1.5-flash"});

    const goalText = goal === "diet" ? "체중 감량" : goal === "bulk" ? "체중 증량" : "체중 유지";
    const trendDirection = weeklyTrend < 0 ? "감소" : weeklyTrend > 0 ? "증가" : "유지";
    const targetInfo = targetWeight
      ? `목표 체중: ${targetWeight}kg (현재와 ${Math.abs(currentWeight - targetWeight).toFixed(1)}kg 차이)`
      : "목표 체중 미설정";

    const prompt = `당신은 전문 PT 트레이너를 위한 AI 체중 관리 어시스턴트입니다.
회원의 체중 데이터를 분석하여 트레이너가 회원에게 전달할 수 있는 실용적인 인사이트를 제공해주세요.

## 회원 데이터
- 현재 체중: ${currentWeight}kg
- ${targetInfo}
- 목표: ${goalText}
- 주간 체중 변화: ${weeklyTrend >= 0 ? "+" : ""}${weeklyTrend.toFixed(2)}kg/주 (${trendDirection} 추세)
- 최근 1주 변화: ${dataSummary.recentWeekChange >= 0 ? "+" : ""}${dataSummary.recentWeekChange.toFixed(1)}kg
- 최근 1개월 변화: ${dataSummary.recentMonthChange >= 0 ? "+" : ""}${dataSummary.recentMonthChange.toFixed(1)}kg
- 전체 기간 변화: ${dataSummary.totalChange >= 0 ? "+" : ""}${dataSummary.totalChange.toFixed(1)}kg
- 체중 범위: ${dataSummary.minWeight}kg ~ ${dataSummary.maxWeight}kg
- 기록 기간: ${dataSummary.recordDays}일
- 기록 횟수: ${dataPointsUsed}회
- 일관성 점수: ${dataSummary.consistencyScore}/100
- 예측 신뢰도: ${Math.round(confidence * 100)}%
${estimatedWeeksToTarget ? `- 목표 도달 예상: ${estimatedWeeksToTarget}주 후` : ""}

## 응답 형식 (JSON)
{
  "insight": "데이터 기반의 전문적인 분석 (3-4문장, 구체적인 수치 포함)",
  "actionItems": ["실천 가능한 구체적 조언 1", "조언 2", "조언 3"],
  "motivation": "회원에게 전달할 동기부여 메시지 (1-2문장)"
}

주의사항:
- 한국어로 작성
- 트레이너가 회원에게 말하듯이 전문적이면서도 따뜻한 톤
- 실제 데이터에 기반한 구체적인 분석
- 막연한 조언 대신 실천 가능한 액션 아이템
- JSON 형식으로만 응답`;

    const result = await model.generateContent(prompt);
    const response = result.response;
    const text = response.text();

    // JSON 파싱 시도
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return defaultResult;
    }

    const parsed = JSON.parse(jsonMatch[0]);

    return {
      aiInsight: parsed.insight || "",
      actionItems: Array.isArray(parsed.actionItems) ? parsed.actionItems : [],
      motivationalMessage: parsed.motivation || "",
      success: true,
    };
  } catch (error) {
    console.error("[Gemini] 분석 생성 실패:", error);
    return defaultResult;
  }
}
