/**
 * 트리거 모듈 통합 export
 */

// 회원 활동 트리거 (onMemberActivity.ts)
export {
  onBodyRecordCreated,
  onDietRecordCreated,
  onCurriculumCompleted,
} from "./onMemberActivity";

// 체중/인바디 기록 트리거 (generateInsights.ts 기반)
export {
  onBodyRecordCreate,
  onInbodyRecordCreated,
} from "./onBodyRecordCreate";

// 출석 완료 트리거 (generateInsights.ts 기반)
export { onScheduleComplete } from "./onScheduleComplete";
