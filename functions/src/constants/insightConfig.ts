/**
 * AI 인사이트 설정
 * 회원과 트레이너의 인사이트 우선순위, 필터, 메시지 스타일 정의
 */

// ===== 공통 설정 =====
export const INSIGHT_CONFIG = {
  // 메시지 길이 제한
  MAX_TITLE_LENGTH: 25,
  MAX_MESSAGE_LENGTH: 50,

  // 표시할 최대 인사이트 수
  MAX_INSIGHTS_DISPLAY: 5,

  // 인사이트 만료 기간 (일)
  DEFAULT_EXPIRY_DAYS: 7,
};

// ===== 회원용 인사이트 설정 =====
export const MEMBER_INSIGHT_CONFIG = {
  // 우선순위 가중치 (높을수록 먼저 표시)
  PRIORITY_WEIGHTS: {
    goal_progress: 100,        // 목표 달성률 - 가장 중요
    workout_achievement: 90,   // 운동 성과
    body_change_report: 85,    // 체성분 변화
    body_prediction: 80,       // 체성분 예측
    attendance_habit: 70,      // 출석 습관
    nutrition_balance: 60,     // 영양 밸런스
    condition_pattern: 40,     // 컨디션 패턴
    benchmarking: 30,          // 벤치마킹 (선택적)
  } as Record<string, number>,

  // 필수 표시 타입 (항상 포함)
  REQUIRED_TYPES: [
    "goal_progress",
    "body_change_report",
  ],

  // 제외할 타입 (데이터 부족시)
  EXCLUDE_IF_LOW_DATA: [
    "benchmarking",
    "condition_pattern",
  ],

  // 메시지 스타일: 동기부여, 격려 중심
  MESSAGE_STYLE: "motivational",
};

// ===== 트레이너용 인사이트 설정 =====
export const TRAINER_INSIGHT_CONFIG = {
  // 우선순위 가중치 (높을수록 먼저 표시)
  PRIORITY_WEIGHTS: {
    churnRisk: 100,            // 이탈 위험 - 가장 중요
    attendanceAlert: 95,       // 출석 경고
    ptExpiry: 90,              // PT 만료 임박
    noshowPattern: 85,         // 노쇼 패턴
    weightProgress: 70,        // 체중 변화
    performance: 60,           // 성과
    plateauDetection: 55,      // 정체기 감지
    renewalLikelihood: 50,     // 재등록 가능성
    workoutRecommendation: 40, // 운동 추천
    performanceRanking: 30,    // 성과 랭킹
    workoutVolume: 25,         // 운동량
    recommendation: 20,        // 일반 추천
  } as Record<string, number>,

  // 필수 표시 타입 (항상 포함)
  REQUIRED_TYPES: [
    "churnRisk",
    "attendanceAlert",
    "ptExpiry",
  ],

  // high priority만 표시할 타입
  HIGH_PRIORITY_ONLY: [
    "weightProgress",
    "performance",
  ],

  // 메시지 스타일: 비즈니스, 액션 중심
  MESSAGE_STYLE: "actionable",
};

// ===== 우선순위 레벨별 점수 =====
export const PRIORITY_SCORES: Record<string, number> = {
  high: 30,
  medium: 20,
  low: 10,
};

/**
 * 인사이트 정렬 점수 계산
 */
export function calculateInsightScore(
  type: string,
  priority: "high" | "medium" | "low",
  isTrainer: boolean
): number {
  const config = isTrainer ? TRAINER_INSIGHT_CONFIG : MEMBER_INSIGHT_CONFIG;
  const typeWeight = config.PRIORITY_WEIGHTS[type] || 0;
  const priorityScore = PRIORITY_SCORES[priority] || 0;

  return typeWeight + priorityScore;
}

/**
 * 메시지 길이 제한 적용
 */
export function truncateMessage(message: string, maxLength: number): string {
  if (message.length <= maxLength) return message;
  return message.substring(0, maxLength - 3) + "...";
}

/**
 * 회원용 간결한 메시지 템플릿 (토스 해요체, 동기부여 중심)
 */
export const MEMBER_MESSAGE_TEMPLATES = {
  goal_progress: {
    high: (percent: number, remaining: number) =>
      `목표 ${percent}% 달성! ${remaining}kg만 더 가면 성공이에요 💪`,
    medium: (percent: number, weeks: number) =>
      `목표 ${percent}% 달성 중! 현재 속도면 ${weeks}주 후 목표 달성이에요`,
    low: (percent: number) => `목표 ${percent}% 진행 중 - 꾸준히 가면 돼요`,
  },
  body_prediction: {
    loss: (kg: number, currentSpeed: number) =>
      `현재 속도면 4주 후 ${kg}kg 감량 예상! 주 ${currentSpeed}kg씩 줄고 있어요`,
    gain: (kg: number, currentSpeed: number) =>
      `현재 속도면 4주 후 ${kg}kg 증가 예상! 주 ${currentSpeed}kg씩 늘고 있어요`,
    stable: () => "체중 안정적으로 유지 중이에요",
    goalReach: (weeks: number, targetWeight: number) =>
      `${weeks}주 후 목표 체중 ${targetWeight}kg 도달 예상! 🎯`,
  },
  workout_achievement: {
    improved: (exercise: string, kg: number, weeks: number) =>
      `${exercise} ${weeks}주간 ${kg}kg 향상! 빠르게 성장 중이에요 🔥`,
    best: (exercise: string, kg: number) =>
      `${exercise} 최고기록 ${kg}kg 달성!`,
    milestone: (exercise: string, kg: number, nextTarget: number) =>
      `${exercise} ${kg}kg 달성! 다음 목표는 ${nextTarget}kg이에요`,
  },
  attendance_habit: {
    good: (rate: number, streak: number) =>
      `출석률 ${rate}% - ${streak}주 연속 성실! 상위권이에요 🌟`,
    average: (rate: number) =>
      `출석률 ${rate}% - 평균 수준이에요`,
    low: (rate: number, lastDays: number) =>
      `${lastDays}일째 운동 안했어요 - 오늘 다시 시작해봐요!`,
    improving: (rate: number, increase: number) =>
      `출석률 ${rate}% - 지난 달보다 ${increase}% 늘었어요!`,
  },
  nutrition_balance: {
    deficient: (nutrient: string, amount: number, suggestion: string) =>
      `${nutrient} 하루 ${amount}g 부족해요. ${suggestion} 추가하면 채울 수 있어요`,
    balanced: () => "영양 밸런스 완벽해요! 이대로 유지하세요 👍",
    proteinGood: (amount: number) =>
      `단백질 하루 ${amount}g 섭취 중 - 근육 성장에 이상적이에요!`,
  },
  body_change_report: {
    both: (fat: number, muscle: number, weeks: number) =>
      `${weeks}주간 체지방 ${fat}kg↓ 근육 ${muscle}kg↑ 완벽한 다이어트예요! 💯`,
    fatLoss: (kg: number, weeks: number) =>
      `${weeks}주간 체지방 ${kg}kg 감량! 근육은 유지 중이에요`,
    muscleGain: (kg: number, weeks: number) =>
      `${weeks}주간 골격근 ${kg}kg 증가! 벌크업 성공적이에요`,
    stable: () => "체성분 안정적으로 유지 중이에요",
    fatPercentDrop: (percent: number, weeks: number) =>
      `${weeks}주간 체지방률 ${percent}% 감소! 몸이 확실히 변하고 있어요`,
  },
  rest_needed: {
    consecutive: (days: number) =>
      `${days}일 연속 운동했어요! 오늘은 스트레칭하고 쉬는 게 어때요?`,
    recovery: () => "근육 회복을 위해 오늘은 가볍게 움직이세요",
  },
  weekly_summary: {
    excellent: (sessions: number, progress: string) =>
      `이번 주 ${sessions}회 운동 완료! ${progress} 최고예요 🏆`,
    good: (sessions: number) =>
      `이번 주 ${sessions}회 운동했어요! 목표 달성이에요`,
    needMore: (sessions: number, target: number) =>
      `이번 주 ${sessions}회 운동 - 목표 ${target}회까지 조금 더!`,
  },
};

/**
 * 트레이너용 간결한 메시지 템플릿 (토스 해요체, 액션 중심)
 */
export const TRAINER_MESSAGE_TEMPLATES = {
  churnRisk: {
    critical: (name: string, dropRate: number, factors: string) =>
      `${name}님 이탈 위험 매우 높아요! 출석률 ${dropRate}% 하락, ${factors}`,
    high: (name: string, factors: string) =>
      `${name}님 이탈 주의! ${factors} - 이번 주 연락 권장해요`,
    medium: (name: string, issue: string) =>
      `${name}님 ${issue} - 동기부여 필요해요`,
  },
  attendanceAlert: {
    drop: (name: string, rate: number, recent: number, previous: number) =>
      `${name}님 출석률 ${rate}%↓ (최근 ${recent}회 → 이전 ${previous}회)`,
    consecutive: (name: string, weeks: number) =>
      `${name}님 ${weeks}주 연속 결석 중 - 즉시 연락 필요해요`,
  },
  ptExpiry: {
    urgent: (name: string, days: number, sessions: number) =>
      `${name}님 PT ${days}일 후 종료! 잔여 ${sessions}회 - 일정 조율 필요해요`,
    soon: (name: string, days: number, achievement: number) =>
      `${name}님 PT ${days}일 남음 - 목표 ${achievement}% 달성`,
    renewal: (name: string, days: number, progress: string) =>
      `${name}님 PT ${days}일 남음 - ${progress} 재등록 제안 타이밍이에요`,
  },
  noshowPattern: {
    detected: (name: string, count: number, weeks: number) =>
      `${name}님 최근 ${weeks}주간 노쇼 ${count}회 - 패턴 확인 필요해요`,
  },
  weightProgress: {
    gained: (name: string, kg: number, weeks: number, goal: string) =>
      `${name}님 ${weeks}주간 체중 ${kg}kg↑ (목표: ${goal})`,
    lost: (name: string, kg: number, weeks: number, remaining: number) =>
      `${name}님 ${weeks}주간 체중 ${kg}kg↓! 목표까지 ${remaining}kg 남았어요`,
    goal: (name: string, kg: number) =>
      `${name}님 목표 체중 ${kg}kg 달성! 축하 메시지 보내보세요 🎉`,
    plateau: (name: string, weeks: number) =>
      `${name}님 ${weeks}주간 체중 정체 - 프로그램 변경 검토 필요해요`,
    reverseGoal: (name: string, kg: number, goal: string) =>
      `${name}님 체중 ${kg}kg 증가 (목표: ${goal}) - 식단 점검 필요해요`,
  },
  performance: {
    excellent: (name: string, achievement: string) =>
      `${name}님 ${achievement} - 성과 공유하면 동기부여 효과 좋아요!`,
    milestone: (name: string, record: string) =>
      `${name}님 ${record} 달성! 격려 메시지 보내보세요`,
  },
  renewal: {
    highChance: (name: string, percent: number, achievement: number) =>
      `${name}님 재등록 가능성 ${percent}% - 목표 ${achievement}% 달성 중이에요`,
    timing: (name: string, days: number, progress: string) =>
      `${name}님 ${days}일 후 종료 - ${progress} 재등록 제안 타이밍이에요`,
  },
  revenue: {
    monthly: (sessions: number, amount: number, change: number) =>
      `이번 달 ${sessions}회 완료, 예상 수입 ${amount}만원 (${change > 0 ? '+' : ''}${change}%)`,
    weekly: (sessions: number, remaining: number) =>
      `이번 주 ${sessions}회 완료 - ${remaining}회 남았어요`,
  },
};
