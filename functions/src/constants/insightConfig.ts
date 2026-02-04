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
 * 회원용 간결한 메시지 템플릿
 */
export const MEMBER_MESSAGE_TEMPLATES = {
  goal_progress: {
    high: (percent: number) => `목표 ${percent}% 달성! 거의 다 왔어요`,
    medium: (percent: number) => `${percent}% 달성 중, 순조로워요`,
    low: (percent: number) => `${percent}% 진행 중`,
  },
  body_prediction: {
    loss: (kg: number) => `4주 후 ${kg}kg 감량 예상`,
    gain: (kg: number) => `4주 후 ${kg}kg 증가 예상`,
    stable: () => "체중 안정적 유지 중",
  },
  workout_achievement: {
    improved: (exercise: string, kg: number) => `${exercise} ${kg}kg 향상!`,
    best: (exercise: string, kg: number) => `${exercise} 최고기록 ${kg}kg`,
  },
  attendance_habit: {
    good: (rate: number) => `출석률 ${rate}% - 상위권!`,
    average: (rate: number) => `출석률 ${rate}%`,
    low: (rate: number) => `출석률 ${rate}% - 다시 시작해요`,
  },
  nutrition_balance: {
    deficient: (nutrient: string) => `${nutrient} 섭취 부족`,
    balanced: () => "영양 밸런스 좋아요!",
  },
  body_change_report: {
    both: (fat: number, muscle: number) => `체지방 ${fat}kg↓ 근육 ${muscle}kg↑`,
    fatLoss: (kg: number) => `체지방 ${kg}kg 감량!`,
    muscleGain: (kg: number) => `골격근 ${kg}kg 증가!`,
    stable: () => "체성분 안정적 유지",
  },
};

/**
 * 트레이너용 간결한 메시지 템플릿
 */
export const TRAINER_MESSAGE_TEMPLATES = {
  churnRisk: {
    critical: (name: string) => `${name} 이탈 위험 매우 높음`,
    high: (name: string) => `${name} 이탈 위험 높음`,
    medium: (name: string) => `${name} 이탈 주의 필요`,
  },
  attendanceAlert: {
    drop: (name: string, rate: number) => `${name} 출석 ${rate}%↓`,
  },
  ptExpiry: {
    urgent: (name: string, days: number) => `${name} PT ${days}일 후 종료!`,
    soon: (name: string, days: number) => `${name} PT ${days}일 남음`,
  },
  noshowPattern: {
    detected: (name: string, count: number) => `${name} 최근 노쇼 ${count}회`,
  },
  weightProgress: {
    gained: (name: string, kg: number) => `${name} 체중 ${kg}kg↑`,
    lost: (name: string, kg: number) => `${name} 체중 ${kg}kg↓`,
    goal: (name: string) => `${name} 목표 체중 달성!`,
  },
};
