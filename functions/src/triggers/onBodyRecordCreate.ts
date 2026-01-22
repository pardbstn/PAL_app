/**
 * 체중/인바디 기록 시 트리거
 * - 체성분 예측 즉시 업데이트
 * - 관련 인사이트 갱신
 */

// generateInsights.ts의 트리거들을 re-export
export {
  onBodyRecordCreated as onBodyRecordCreate,
  onInbodyRecordCreated
} from "../generateInsights";
