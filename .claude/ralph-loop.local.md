---
active: true
iteration: 2
max_iterations: 50
completion_promise: "전체 수정 완료"
started_at: "2026-01-20T16:50:12Z"
---

PAL 프로젝트 대규모 수정 및 버그 픽스.

## 1. AI 체중 예측 수정
- 현재: 여러 주 예측 → 변경: 1주일 뒤 한 번만 예측
- functions/src/predictWeight.ts 수정: weeksAhead 기본값 1, 최대값 1로 제한
- Flutter UI 수정: 예측 결과 카드에 1주 뒤 예측만 표시
- 그래프에서 예측 점선도 1주치만 표시
- 관련 파일: predictWeight.ts, weight_prediction_provider.dart, 체중 그래프 UI

## 2. AI 인사이트 자동 생성
- 트레이너가 버튼 안 눌러도 자동 생성되게
- functions/src/triggers/onMemberActivity.ts 생성: Firestore 트리거로 회원 활동 감지 시 인사이트 자동 생성
- 또는 Cloud Scheduler로 매일 아침 8시 자동 실행
- 회원 1명이어도 생성 가능하게 NO_MEMBERS 조건 수정 (최소 0명 → 1명 이상이면 실행)
- generateInsights.ts에서 회원 수 체크 로직 수정
- index.ts에 트리거 함수 export 추가

## 3. 회원 앱 캘린더 기능 추가
- lib/presentation/screens/member/member_calendar_screen.dart 생성
- 트레이너 앱의 trainer_calendar_screen.dart 참고해서 동일한 캘린더 기능
- table_calendar 패키지 사용
- PT 일정 표시, 날짜별 운동 기록 표시
- 회원은 조회만 가능 (수정 불가)

## 4. 회원 앱 하단 네비게이터 수정
- lib/presentation/screens/member/member_shell.dart 수정
- 기존 네비게이션 → 새 네비게이션:
  1. 홈 (Icons.home)
  2. 내 기록 (Icons.fitness_center) 
  3. 캘린더 (Icons.calendar_today)
  4. 식단 (Icons.restaurant)
  5. 메시지 (Icons.message)
- 각 탭에 맞는 화면 연결
- 인덱스 및 라우팅 수정

## 5. 식단 기록 오류 수정
- lib/presentation/screens/member/member_diet_screen.dart 오류 수정
- lib/presentation/providers/diet_analysis_provider.dart 확인 및 수정
- lib/data/repositories/diet_analysis_repository.dart 확인 및 수정
- lib/data/models/diet_analysis_model.dart 확인 및 수정
- null 체크 추가
- Provider 초기화 오류 수정
- Firestore 쿼리 오류 수정
- AsyncValue 에러 핸들링 추가
- 모델 필드 매핑 오류 수정

## 6. 인바디 기록 오류 수정
- lib/presentation/screens/member/member_inbody_screen.dart 오류 수정
- lib/presentation/providers/inbody_provider.dart 확인 및 수정
- lib/data/repositories/inbody_repository.dart 확인 및 수정
- lib/data/models/inbody_record_model.dart 확인 및 수정
- null 체크 추가
- Provider 초기화 오류 수정
- Firestore 쿼리 오류 수정
- 차트 데이터 바인딩 오류 수정
- 수동 입력 폼 저장 오류 수정

## 디버깅 체크리스트
- flutter analyze 실행해서 에러 확인
- 각 화면 진입 시 콘솔 에러 확인
- Provider watch/read 올바른지 확인
- Repository 메서드 시그니처 일치하는지 확인
- 모델 fromFirestore/toFirestore 필드 매핑 확인
- Firestore 컬렉션명 오타 확인

## 완료 조건
- flutter build apk --debug 에러 없음
- 회원 앱 하단 네비게이터 5개 탭 정상 동작
- 캘린더 화면 정상 표시
- 식단 기록 화면 오류 없이 표시
- 인바디 기록 화면 오류 없이 표시
- AI 체중 예측 1주만 표시
- AI 인사이트 자동 생성 트리거 배포 준비됨
