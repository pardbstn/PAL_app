# PAL 리팩토링 분석 보고서

## 프로젝트 현황

### Flutter (lib/)
- **파일 수**: 272개 .dart 파일
- **총 라인 수**: 95,880줄
- **아키텍처**: Clean Architecture (core/data/domain/presentation)
  - `domain/` 레이어는 구조만 존재, 실제 코드 없음
  - 모든 모델과 리포지토리가 `data/`에 위치

### Cloud Functions (functions/src/)
- **파일 수**: 28개 .ts 파일
- **총 라인 수**: 16,631줄
- **구조**: badges, curriculum, notifications, schedulers, triggers, utils

---

## 300줄 초과 파일 (주요)

### Flutter
| 파일 | 라인 수 |
|------|---------|
| trainer_member_detail_screen.dart | 4,172 |
| member_records_screen.dart | 3,094 |
| trainer_calendar_screen.dart | 2,791 |
| member_calendar_screen.dart | 2,681 |
| ai_curriculum_generator_screen.dart | 2,239 |
| trainer_home_screen.dart | 2,035 |
| member_home_screen.dart | 1,767 |
| trainer_member_detail_web_screen.dart | 1,550 |
| trainer_members_web_screen.dart | 1,317 |
| member_inbody_screen.dart | 1,268 |

*총 97개 파일이 300줄 초과*

### Cloud Functions
| 파일 | 라인 수 |
|------|---------|
| generateInsights.ts | 2,411 |
| generateMemberInsights.ts | 1,743 |
| utils/predictionHelpers.ts | 883 |
| predictBodyComposition.ts | 641 |
| index.ts | 559 |
| fetchInbodyByPhone.ts | 499 |
| badges/calculateTrainerBadges.ts | 388 |
| predictWeight.ts | 385 |
| triggers/onMemberActivity.ts | 309 |

---

## 중복 코드 분석

### Flutter
| 카테고리 | 횟수 | 심각도 |
|----------|------|--------|
| Firestore .collection() 직접 호출 | 42회 (10파일) | HIGH |
| 미타입 try/catch 블록 | 116회 (46파일) | MEDIUM |
| dynamic 타입 사용 | 42회 (18파일) | LOW (대부분 generated) |
| TODO/FIXME 주석 | 38회 (20파일) | MEDIUM |
| print() 디버그 코드 | 1회 | LOW |

### Cloud Functions
| 카테고리 | 횟수 | 심각도 |
|----------|------|--------|
| Firestore 직접 접근 | 127회 (19파일) | HIGH |
| 하드코딩 컬렉션명 | 77회 (19파일) | HIGH |
| AI API 중복 초기화 | 38회 (5파일) | HIGH |
| auth 보일러플레이트 | 20회 (11파일) | MEDIUM |
| 응답 포맷 불일치 | 77회 (13파일) | MEDIUM |
| any 타입 사용 | 17회 (5파일) | LOW |
| console.log | 29회 (9파일) | LOW |
| 에러 처리 혼재 (HttpsError vs Error) | 90회 (11파일) | MEDIUM |

---

## 네이밍 컨벤션

### Flutter
- **파일명**: snake_case ✅ (일관성 있음)
- **클래스명**: PascalCase ✅ (일관성 있음)
- **변수명**: camelCase ✅ (일관성 있음)

### Cloud Functions
- **파일명**: camelCase ✅ (일관성 있음)
- **함수명**: camelCase ✅ (일관성 있음)

---

## 기존 core/ 구조

```
lib/core/
├── constants/
│   ├── routes.dart (88줄)
│   └── exercise_constants.dart (103줄)
├── errors/
│   ├── app_exception.dart (460줄) ✅ 이미 존재
│   ├── failure.dart (289줄) ✅ 이미 존재
│   └── error_handler.dart (376줄) ✅ 이미 존재
├── router/
│   └── app_router.dart (508줄)
├── theme/
│   ├── app_theme.dart (103줄)
│   ├── app_tokens.dart (96줄)
│   └── web_theme.dart (238줄)
├── utils/
│   ├── analytics_service.dart (313줄)
│   ├── animation_utils.dart (142줄)
│   ├── logger.dart (290줄)
│   └── responsive_utils.dart (207줄)
├── widgets/ ❌ 없음 (생성 필요)
└── services/ ❌ 없음 (생성 필요)
```

---

## 리팩토링 우선순위

### 1순위 (HIGH Impact)
- Cloud Functions: Firestore 헬퍼 + 컬렉션 상수
- Cloud Functions: AI 서비스 통합
- Cloud Functions: 응답 포맷 통일

### 2순위 (MEDIUM Impact)
- Cloud Functions: Auth 미들웨어
- Cloud Functions: 에러 코드 상수
- Flutter: Firestore 컬렉션 상수
- Flutter: 공통 위젯 추출

### 3순위 (LOW Impact)
- Flutter: Provider 정리
- 사용하지 않는 코드 제거
- any/dynamic 타입 정리
