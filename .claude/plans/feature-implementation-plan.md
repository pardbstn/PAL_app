# PAL 앱 4가지 기능 구현 계획

> 생성일: 2026-01-22
> 상태: 계획 완료, 구현 대기

## 개요

| 기능 | 복잡도 | 신규 파일 | 우선순위 |
|------|--------|----------|---------|
| 수업률 80% 알림 | 중 | 12개 | 1순위 |
| 연속 기록 스트릭 | 중 | 11개 | 2순위 |
| 평가 시스템 | 상 | 12개 | 3순위 |
| 셀프 트레이닝 모드 | 상 | 16개 | 4순위 |

**총 작업량**: 신규 51개 + 수정 15개 = 66개 파일

---

## 1. 수업률 80% 알림 (1순위)

### 요구사항
- 수업률 = 완료 횟수 / 등록 횟수 × 100
- 80% 도달 시 회원에게 자동 재등록 안내 알림
- 트레이너는 세일즈 부담 없이 운동 지도에 집중

### 신규 파일

```
Models:
├── lib/data/models/notification_model.dart
└── lib/data/models/reregistration_alert_model.dart

Repositories:
├── lib/data/repositories/notification_repository.dart
└── lib/data/repositories/reregistration_alert_repository.dart

Services:
└── lib/data/services/reregistration_service.dart

Providers:
├── lib/presentation/providers/notification_provider.dart
└── lib/presentation/providers/reregistration_provider.dart

Screens/Widgets:
├── lib/presentation/screens/common/notifications_screen.dart
├── lib/presentation/widgets/notification/notification_card.dart
├── lib/presentation/widgets/notification/notification_badge.dart
├── lib/presentation/widgets/member/reregistration_banner.dart
└── lib/presentation/widgets/trainer/reregistration_alert_card.dart
```

### 수정 파일
- `lib/data/services/fcm_service.dart`: 재등록 알림 템플릿
- `lib/data/repositories/member_repository.dart`: 80% 도달 트리거
- `lib/presentation/screens/member/member_shell.dart`: 알림 아이콘
- `lib/presentation/screens/trainer/trainer_shell.dart`: 알림 아이콘
- `lib/presentation/screens/member/member_home_screen.dart`: 재등록 배너

### Firestore 스키마

```
notifications/{id}
├── userId: string
├── type: 'reregistration' | 'sessionReminder' | ...
├── title: string
├── body: string
├── data: map | null
├── isRead: boolean
└── createdAt: timestamp

reregistration_alerts/{id}
├── memberId: string
├── trainerId: string
├── totalSessions: number
├── completedSessions: number
├── progressRate: number
├── alertSentAt: timestamp | null
├── reregistered: boolean
└── createdAt: timestamp
```

---

## 2. 연속 기록 스트릭 (2순위)

### 요구사항
- 대상: 체중 기록(매일), 식단 사진(매 끼니)
- 연속 기록 일수 표시
- 목표 달성 배지 연동
- 현재 70% 구현됨

### 신규 파일

```
Models:
├── lib/data/models/streak_model.dart
└── lib/data/models/badge_model.dart

Repositories:
└── lib/data/repositories/streak_repository.dart

Services:
└── lib/data/services/streak_service.dart

Providers:
└── lib/presentation/providers/streak_provider.dart

Screens/Widgets:
├── lib/presentation/widgets/streak/streak_counter_widget.dart
├── lib/presentation/widgets/streak/streak_calendar_widget.dart
├── lib/presentation/widgets/streak/badge_display_widget.dart
├── lib/presentation/widgets/streak/streak_milestone_dialog.dart
└── lib/presentation/screens/member/badges_screen.dart
```

### 수정 파일
- `lib/data/repositories/body_record_repository.dart`: 스트릭 업데이트 트리거
- `lib/data/repositories/diet_record_repository.dart`: 스트릭 업데이트 트리거
- `lib/presentation/screens/member/member_home_screen.dart`: 스트릭 위젯
- `lib/presentation/screens/member/member_records_screen.dart`: 스트릭 표시

### Firestore 스키마

```
streaks/{memberId}
├── memberId: string
├── weightStreak: number
├── dietStreak: number
├── longestWeightStreak: number
├── longestDietStreak: number
├── lastWeightRecordDate: timestamp | null
├── lastDietRecordDate: timestamp | null
├── badges: string[]
└── updatedAt: timestamp

badges/{id} (정적)
├── code: string
├── name: string
├── description: string
├── iconUrl: string
├── requiredStreak: number
└── streakType: 'weight' | 'diet'
```

---

## 3. 평가 시스템 (3순위)

### 요구사항
- 평가 항목: 전문성, 소통력, 시간준수, 변화만족도, 재등록의향 (5점)
- 조건: PT 8회 이상, 종료 후 14일 이내
- 악용 방지: 익명, 5개 누적 시 공개, 이상패턴 감지
- 자동 성과 지표: 재등록률, 목표달성률, 평균체성분변화

### 신규 파일

```
Models:
├── lib/data/models/trainer_review_model.dart
└── lib/data/models/trainer_performance_model.dart

Repositories:
├── lib/data/repositories/trainer_review_repository.dart
└── lib/data/repositories/trainer_performance_repository.dart

Services:
└── lib/data/services/review_validation_service.dart

Providers:
└── lib/presentation/providers/trainer_review_provider.dart

Screens/Widgets:
├── lib/presentation/screens/member/trainer_review_screen.dart
├── lib/presentation/screens/trainer/trainer_reviews_screen.dart
├── lib/presentation/widgets/review/review_form_widget.dart
├── lib/presentation/widgets/review/star_rating_widget.dart
├── lib/presentation/widgets/review/review_card.dart
└── lib/presentation/widgets/trainer/performance_stats_card.dart
```

### 수정 파일
- `lib/data/models/models.dart`: export 추가
- `lib/presentation/screens/member/member_shell.dart`: 평가 버튼
- `lib/presentation/screens/trainer/trainer_settings_screen.dart`: 내 평가 보기
- `lib/core/router/app_router.dart`: 라우트 추가

### Firestore 스키마

```
trainer_reviews/{id}
├── trainerId: string
├── memberId: string
├── professionalism: number (1-5)
├── communication: number (1-5)
├── punctuality: number (1-5)
├── satisfaction: number (1-5)
├── reregistrationIntent: number (1-5)
├── comment: string | null
├── isPublic: boolean
└── createdAt: timestamp

trainer_performance/{trainerId}
├── trainerId: string
├── reregistrationRate: number
├── goalAchievementRate: number
├── avgBodyCompositionChange: number
├── attendanceManagementRate: number
├── totalReviews: number
├── averageRating: number
└── updatedAt: timestamp
```

---

## 4. 셀프 트레이닝 모드 (4순위)

### 요구사항
- 전환 조건: PT 종료 후
- 무료: 체중/운동 기록, 변화 그래프
- 유료(4,900원/월): AI 운동 추천, AI 식단 분석, 월간 리포트, 트레이너 질문권 3회
- 트레이너 연결: 1회 질문(3,000원), 폼체크(5,000원)

### 신규 파일

```
Models:
├── lib/data/models/subscription_model.dart
└── lib/data/models/trainer_request_model.dart

Repositories:
├── lib/data/repositories/subscription_repository.dart
└── lib/data/repositories/trainer_request_repository.dart

Services:
└── lib/data/services/self_training_service.dart

Providers:
├── lib/presentation/providers/subscription_provider.dart
└── lib/presentation/providers/trainer_request_provider.dart

Screens/Widgets:
├── lib/presentation/screens/member/self_training_home_screen.dart
├── lib/presentation/screens/member/subscription_screen.dart
├── lib/presentation/screens/member/trainer_question_screen.dart
├── lib/presentation/screens/member/monthly_report_screen.dart
├── lib/presentation/screens/trainer/trainer_requests_screen.dart
├── lib/presentation/widgets/subscription/premium_feature_gate.dart
├── lib/presentation/widgets/subscription/subscription_card.dart
├── lib/presentation/widgets/trainer_request/request_form_widget.dart
└── lib/presentation/widgets/trainer_request/request_card.dart
```

### 수정 파일
- `lib/data/models/member_model.dart`: ptStatus 필드 추가
- `lib/presentation/screens/member/member_shell.dart`: 셀프 모드 분기
- `lib/presentation/screens/member/member_home_screen.dart`: PT 종료 후 전환 안내
- `lib/core/router/app_router.dart`: 라우트 추가

### Firestore 스키마

```
subscriptions/{id}
├── userId: string
├── plan: 'free' | 'premium'
├── startDate: timestamp
├── endDate: timestamp | null
├── isActive: boolean
├── features: string[]
├── monthlyQuestionCount: number
└── createdAt: timestamp

trainer_requests/{id}
├── memberId: string
├── trainerId: string
├── requestType: 'question' | 'formCheck'
├── content: string
├── attachmentUrls: string[] | null
├── response: string | null
├── status: 'pending' | 'answered' | 'expired'
├── price: number
├── createdAt: timestamp
└── answeredAt: timestamp | null
```

---

## 구현 순서 (의존성 고려)

```
1순위: 수업률 80% 알림
  └── notification 인프라 구축 (다른 기능에서 재사용)

2순위: 연속 기록 스트릭
  └── 기존 body_record/diet_record와 연동

3순위: 평가 시스템
  └── 독립적, PT 완료 조건 필요

4순위: 셀프 트레이닝 모드
  └── 가장 복잡, 구독/결제 연동 필요
```

---

## 공유 컴포넌트

| 컴포넌트 | 사용 기능 |
|---------|----------|
| notification_model.dart | 전체 |
| notification_repository.dart | 전체 |
| notification_badge.dart | Shell 공통 |
| notifications_screen.dart | 공통 알림 센터 |

---

## 검증 체크리스트

각 기능 구현 후:
- [ ] `flutter pub run build_runner build` (freezed 생성)
- [ ] `flutter analyze` 에러 없음
- [ ] Firestore 인덱스 생성 확인
- [ ] UI 반응형 확인 (웹/모바일)
- [ ] 기존 기능 동작 확인
