/**
 * 매일 오전 7시 인사이트 자동 생성 스케줄러
 * 모든 활성 트레이너의 모든 회원 대상
 * - 이탈 위험 인사이트
 * - 벤치마킹 인사이트
 */

// generateInsights.ts의 generateInsightsScheduled를 re-export
export { generateInsightsScheduled as dailyInsightGenerator } from "../generateInsights";
