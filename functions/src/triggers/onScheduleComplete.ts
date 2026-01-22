/**
 * 출석 완료 시 트리거
 * - 출석 관련 인사이트 업데이트
 * - 이탈 위험 점수 재계산
 */

// generateInsights.ts의 onSessionUpdated를 re-export
export { onSessionUpdated as onScheduleComplete } from "../generateInsights";
