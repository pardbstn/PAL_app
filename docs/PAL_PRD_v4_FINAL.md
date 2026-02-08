# PAL PRD v4.0 - 최종 제품 요구사항 정의서

**서비스명**: PAL (Progress, Analyze, Level-up)
**슬로건**: "기록하고, 분석하고, 성장하다"
**버전**: 4.0 Final
**최종 수정일**: 2026-02-07
**앱 버전**: 1.0.4+7
**문서 상태**: Production

---

# 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [사용자 정의](#2-사용자-정의)
3. [디자인 시스템](#3-디자인-시스템)
4. [화면 구성 및 라우팅](#4-화면-구성-및-라우팅)
5. [기능 상세 명세](#5-기능-상세-명세)
6. [데이터 모델](#6-데이터-모델)
7. [상태 관리](#7-상태-관리)
8. [백엔드 아키텍처](#8-백엔드-아키텍처)
9. [AI 기능 명세](#9-ai-기능-명세)
10. [기술 스택](#10-기술-스택)
11. [크로스 플랫폼 요구사항](#11-크로스-플랫폼-요구사항)
12. [보안 요구사항](#12-보안-요구사항)
13. [성능 요구사항](#13-성능-요구사항)
14. [에러 처리](#14-에러-처리)
15. [UX 라이팅 가이드](#15-ux-라이팅-가이드)
16. [앱 스토어 배포](#16-앱-스토어-배포)

---

# 1. 프로젝트 개요

## 1.1 서비스 소개

PAL은 **AI 기반 PT(Personal Training) 관리 플랫폼**으로, 트레이너와 회원 간의 효율적인 소통과 운동 관리를 지원하는 B2B2C SaaS 서비스입니다.

### 핵심 가치 제안

| 사용자 | 핵심 가치 | 상세 |
|--------|----------|------|
| **트레이너** | AI 기반 회원 관리 | 커리큘럼 자동 생성, 이탈 예측, 수익 관리, 인사이트 대시보드 |
| **회원** | 데이터 기반 성장 추적 | PT 진행 추적, AI 체성분 예측, 식단 분석, 월간 리포트 |
| **자가 운동** | 독립적 운동/식단 관리 | AI 인사이트, 체형 분석, 운동 기록 |

### 비전

> PT 트레이너의 업무 부담을 AI로 해소하고, 회원에게는 데이터 기반의 과학적 운동 관리 경험을 제공하여, 양측 모두의 성장을 돕는 플랫폼

## 1.2 비즈니스 모델

| 구분 | 내용 |
|------|------|
| **수익 모델** | 트레이너 구독 (Freemium + Premium) |
| **Free 플랜** | 회원 5명, 기본 기능 |
| **Premium 플랜** | 무제한 회원, AI 기능, 웹 대시보드, 고급 분석 |
| **타겟 시장** | 한국 PT 트레이너 (약 10만명 추정) |
| **확장 계획** | 개인 운동 사용자 (B2C), 체육관 단체 (B2B) |

## 1.3 프로젝트 아키텍처

```
lib/
├── core/                    # 핵심 인프라
│   ├── router/              # GoRouter 라우팅
│   ├── theme/               # 디자인 시스템 (토큰, 테마)
│   ├── constants/           # 상수 정의
│   └── utils/               # 유틸리티 (애니메이션 등)
├── data/                    # 데이터 계층
│   ├── models/              # Freezed 데이터 모델 (24개)
│   ├── repositories/        # Firestore CRUD (22개)
│   └── services/            # 외부 서비스 연동 (7개)
├── presentation/            # UI 계층
│   ├── screens/             # 화면 (35+ 스크린)
│   ├── widgets/             # 재사용 위젯 (공통, 상태, 스켈레톤)
│   └── providers/           # Riverpod 상태 관리 (24개)
└── main.dart                # 앱 진입점
```

---

# 2. 사용자 정의

## 2.1 사용자 유형

| 유형 | 코드 | 설명 | 진입 경로 |
|------|------|------|----------|
| **트레이너** | `trainer` | PT 트레이너, 센터 강사 | 소셜 로그인 → 역할 선택 |
| **회원** | `member` | PT 수강 회원 | 소셜 로그인 → 트레이너 코드 연결 |
| **자가 운동** | `self` | 독립 사용자 | 소셜 로그인 → 셀프 모드 선택 |

## 2.2 인증 방식

| 방법 | 구현 | 비고 |
|------|------|------|
| **카카오 로그인** | `kakao_flutter_sdk_user` | 한국 주력 |
| **구글 로그인** | `google_sign_in` + Firebase Auth | 글로벌 |
| **애플 로그인** | `sign_in_with_apple` | iOS 필수 |
| **이메일/비밀번호** | Firebase Auth | 기본 |

## 2.3 온보딩 플로우

```
스플래시 → 온보딩 (3 스텝) → 로그인 → 역할 선택
                                         ├── 트레이너 → 트레이너 홈
                                         ├── 회원 → 트레이너 코드 입력 → 회원 홈
                                         └── 자가 운동 → 셀프 홈
```

---

# 3. 디자인 시스템

## 3.1 디자인 철학

PAL은 **토스(Toss) 디자인 시스템**을 참고하여 설계되었습니다.

| 원칙 | 설명 |
|------|------|
| **미니멀리즘** | 불필요한 장식 제거, 콘텐츠 중심 |
| **빠른 피드백** | 200ms 이하 애니메이션, 즉각적 반응 |
| **일관된 패턴** | 동일한 컴포넌트 재사용, 예측 가능한 UX |
| **접근성** | 충분한 터치 영역(48px+), 명확한 색상 대비 |
| **다크모드** | 완전한 다크모드 지원, 순수 블랙 계열 |

## 3.2 색상 시스템

### 브랜드 색상

| 토큰 | HEX | 용도 |
|------|-----|------|
| `primary` | `#0064FF` | 토스 블루 - 메인 브랜드, CTA 버튼, 활성 상태 |
| `primaryLight` | `#4D9AFF` | 밝은 프라이머리 - 호버, 배경 틴트 |
| `primaryDark` | `#0050CC` | 어두운 프라이머리 - 프레스 상태 |
| `secondary` | `#00C471` | 토스 그린 - 성공, 긍정적 변화, 증가 |
| `tertiary` | `#FF8A00` | 토스 오렌지 - 경고, 주의 |
| `error` | `#F04452` | 토스 레드 - 에러, 삭제, 감소 |

### 그레이 스케일

| 토큰 | HEX | 용도 |
|------|-----|------|
| `gray50` | `#F4F4F4` | 앱 배경색 |
| `gray100` | `#EBEBEB` | 밝은 배경, 구분선 |
| `gray200` | `#D9D9D9` | 보더, 구분선 |
| `gray300` | `#B0B0B0` | 비활성 보더, 플레이스홀더 |
| `gray400` | `#8B8B8B` | 비활성 아이콘 |
| `gray500` | `#6B6B6B` | 보조 텍스트 |
| `gray600` | `#4E4E4E` | 서브 텍스트 |
| `gray700` | `#333333` | 본문 텍스트, 스낵바 배경 |
| `gray800` | `#1A1A1A` | 타이틀 텍스트 |
| `gray900` | `#0E0E0E` | 최진한 텍스트, 다크모드 배경 |

### 다크모드 색상

| 요소 | 라이트 | 다크 |
|------|--------|------|
| 배경 | `#F4F4F4` | `#0E0E0E` |
| 카드/서피스 | `#FFFFFF` | `#1A1A1A` |
| 보더 | `#EBEBEB` | `#2A2A2A` |
| 텍스트 1차 | `#1A1A1A` | `#FFFFFF` |
| 텍스트 2차 | `#6B6B6B` | `#8B8B8B` |
| 텍스트 3차 | `#B0B0B0` | `#6B6B6B` |
| Primary | `#0064FF` | `#4D9AFF` |
| 네비바 | `#FFFFFF` | `#1A1A1A` |

## 3.3 타이포그래피

| 토큰 | 크기 | 굵기 | 용도 |
|------|------|------|------|
| `titleLarge` | 26px | w700 | 페이지 헤딩 |
| `titleMedium` | 21px | w600 | 섹션 헤딩 |
| `titleSmall` | 17px | w600 | 카드 헤딩, 앱바 타이틀 |
| `bodyLarge` | 16px | w500 | 강조 본문 |
| `bodyMedium` | 15px | w400 | 기본 본문 |
| `bodySmall` | 13px | w400 | 보조 텍스트 |
| `caption` | 11px | w400 | 라벨, 힌트, 네비 라벨 |

- **폰트**: Pretendard (Google Fonts)
- **줄 간격**: 타이트 1.3, 일반 1.5
- **원칙**: 제목은 w600-w700, 본문은 w400, 강조는 w500

## 3.4 간격 시스템

| 토큰 | 값 | 용도 |
|------|-----|------|
| `xs` | 4px | 아이콘과 텍스트 사이 |
| `sm` | 8px | 요소 내부 간격 |
| `md` | 16px | 카드 내부 패딩 |
| `lg` | 20px | 화면 좌우 패딩 (screenPadding) |
| `xl` | 24px | 섹션 내부 간격 |
| `xxl` | 32px | 섹션 간 간격 |

## 3.5 모서리 둥글기 (Radius)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `sm` | 8px | 칩, 작은 요소 |
| `md` | 16px | 카드, 입력필드, 버튼 |
| `lg` | 20px | 대형 카드 |
| `xl` | 24px | 다이얼로그, 바텀시트 |
| `full` | 999px | 스낵바, 아바타, 뱃지 |

## 3.6 그림자 (토스 스타일: 최소화)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `sm` | `black 2%, blur 2, offset(0,1)` | 미세한 입체감 |
| `md` | `black 3%, blur 4, offset(0,2)` | 카드 기본 그림자 |
| `lg` | `black 5%, blur 8, offset(0,4)` | 모달, 플로팅 요소 |
| `navBar` | 제거 (border-top으로 대체) | 네비바 |

## 3.7 애니메이션 가이드

| 유형 | 시간 | 이동량 | 설명 |
|------|------|--------|------|
| fadeIn (카드 등장) | 200ms | - | 콘텐츠 페이드 인 |
| slideY (수직 슬라이드) | 200ms | 0.02 | 미세한 아래→위 이동 |
| slideX (수평 슬라이드) | 200ms | 0.02 | 미세한 좌→우 이동 |
| 순차 지연 (stagger) | 50ms | - | 리스트 아이템 간격 |
| 스케일 인 | 200ms | 0.95→1.0 | 요소 확대 등장 |
| 터치 피드백 | 150ms | scale 0.97 | 버튼/카드 터치 |

**원칙**: 토스 스타일 "거의 느끼지 못할 정도"의 빠르고 미세한 애니메이션

## 3.8 공통 컴포넌트

### AppCard
- 흰색 배경, borderRadius 20, 최소 그림자
- 내부 패딩 20px
- 탭 피드백: scale 0.97

### AppButton
- borderRadius 16, 높이 sm=40/md=52/lg=56
- Primary: `#0064FF` 배경 + 흰색 텍스트
- 비활성: `#F4F4F4` 배경 + `#B0B0B0` 텍스트

### AppTextField
- UnderlineBorder 스타일
- 포커스: `#0064FF` 2px 언더라인
- 비포커스: `#D9D9D9` 1px 언더라인
- 에러: `#F04452` 언더라인

### AppDialog
- borderRadius 24, 내부 패딩 28
- 타이틀 좌정렬, w600, 20px
- 하단 버튼: 닫기(outline) + 확인(primary)

### AppBottomSheet
- 상단 borderRadius 24
- 핸들바: 36x4, `#D9D9D9`
- 내부 패딩 20

### AppSnackbar
- Pill shape (borderRadius full)
- `#333333` 배경, 흰색 텍스트
- 좌측 상태 아이콘 (성공=초록, 에러=빨강, 경고=주황, 정보=파랑)

### AppListTile
- 좌우 패딩 20, 상하 패딩 16
- trailing 화살표: `arrow_forward_ios` size 16

### AppSection
- 제목: 17px, w600
- 제목-콘텐츠 간격 12px

## 3.9 아이콘 시스템

| 용도 | 아이콘 | 크기 |
|------|--------|------|
| 뒤로가기 | `arrow_back_ios_new` | 20px |
| 알림 | `notifications_none_rounded` | 24px |
| 설정 | `settings_rounded` | 24px |
| 화살표 (리스트) | `arrow_forward_ios` | 16px |
| 홈 | `home_rounded` | 22px |
| 추가 | `add_rounded` | 24px |
| 닫기 | `close_rounded` | 24px |
| 아이콘 배경 | 40x40 원형, `#F4F4F4` | - |

---

# 4. 화면 구성 및 라우팅

## 4.1 인증/온보딩 플로우

| 화면 | 라우트 | 설명 |
|------|--------|------|
| 스플래시 | `/splash` | 앱 초기화, 자동 로그인 체크 |
| 온보딩 | `/onboarding` | 3단계 앱 소개 슬라이드 |
| 로그인 | `/login` | 소셜 로그인 + 이메일 로그인 |
| 역할 선택 | `/role-selection` | 트레이너/회원/자가 운동 선택 |

## 4.2 회원 화면 (Member Shell)

### 바텀 네비게이션 (4탭)

| 탭 | 화면 | 라우트 | 핵심 기능 |
|----|------|--------|----------|
| 홈 | `MemberHomeScreen` | `/member/home` | PT 진행상황, 체중변화, 다음일정, AI 인사이트 |
| 기록 | `MemberRecordsScreen` | `/member/records` | 체중/체지방/근육량 그래프, 커리큘럼 뷰어 |
| 캘린더 | `MemberCalendarScreen` | `/member/calendar` | PT 일정 캘린더, 일정 추가/수정 |
| 메시지 | `ChatListScreen` | `/member/messages` | 트레이너와 1:1 채팅 |

### 서브 화면

| 화면 | 라우트 | 설명 |
|------|--------|------|
| 식단 기록 | `/member/diet` | AI 식단 분석, 사진 촬영, 영양소 추적 |
| 인바디 | `/member/inbody` | 인바디 데이터 연동/조회 |
| 월간 리포트 | `/member/monthly-report` | 월별 진행 요약, 차트, AI 분석 |
| 설정 | `/member/settings` | 프로필, 목표, 테마, 알림, 로그아웃 |
| 트레이너 평가 | `/member/review-trainer` | 별점 3항목 + 한줄평 |
| 구독 | `/member/subscription` | 프리미엄 구독 관리 |
| 셀프 트레이닝 | `/member/self-training` | 독립 운동 모드 |
| 트레이너 질문 | `/member/trainer-question` | Q&A 게시판 |
| 알림 | `/member/notifications` | 푸시 알림 목록 |

## 4.3 트레이너 화면 (Trainer Shell - 모바일)

### 바텀 네비게이션 (4탭)

| 탭 | 화면 | 라우트 | 핵심 기능 |
|----|------|--------|----------|
| 홈 | `TrainerHomeScreen` | `/trainer/home` | 오늘 일정, 회원 현황, 내 평점, AI 인사이트 |
| 회원 | `TrainerMembersScreen` | `/trainer/members` | 회원 그리드, 추가/삭제, 검색 |
| 캘린더 | `TrainerCalendarScreen` | `/trainer/calendar` | 전체 일정 관리, 일정 생성 |
| 메시지 | `ChatListScreen` | `/trainer/messages` | 회원들과 1:1 채팅 |

### 서브 화면

| 화면 | 라우트 | 설명 |
|------|--------|------|
| 회원 상세 | `/trainer/member-detail/:id` | 회원 정보, PT 기록, 체성분, 커리큘럼 |
| 커리큘럼 관리 | `/trainer/curriculum/:memberId` | 커리큘럼 목록, 생성, 수정 |
| AI 커리큘럼 생성 | `/trainer/ai-curriculum` | AI 자동 커리큘럼 생성기 |
| 커리큘럼 설정 | `/trainer/curriculum-settings` | AI 생성 세부 설정 (부위, 스타일, 제외) |
| 커리큘럼 결과 | `/trainer/curriculum-result` | 생성된 커리큘럼 미리보기/편집 |
| AI 인사이트 | `/trainer/insights` | AI 인사이트 상세 목록 |
| 일정 추가 | `/trainer/add-schedule` | 새 PT 일정 생성 |
| 평점 상세 | `/trainer/rating-detail` | 회원 리뷰 상세 보기 |
| 회원 요청 | `/trainer/requests` | 회원 연결 요청 관리 |
| 서명 기록 | `/trainer/signatures` | PT 세션 서명 이력 |
| 설정 | `/trainer/settings` | 프로필, 구독, 테마, 알림 |

## 4.4 트레이너 웹 대시보드

| 화면 | 라우트 | 설명 |
|------|--------|------|
| 대시보드 | `/trainer/web/dashboard` | 종합 통계, 차트, KPI |
| 회원 관리 | `/trainer/web/members` | PlutoGrid 데이터 테이블 |
| 회원 상세 | `/trainer/web/member-detail/:id` | 상세 분석, 차트 |
| 일정 관리 | `/trainer/web/schedule` | 주간/월간 일정 그리드 |
| 수익 분석 | `/trainer/web/revenue` | 매출, 결제, 수익 차트 |

## 4.5 공통 화면

| 화면 | 라우트 | 설명 |
|------|--------|------|
| 채팅방 | `/chat/:roomId` | 1:1 실시간 채팅 |
| 알림 | `/notifications` | 푸시 알림 목록 |

---

# 5. 기능 상세 명세

## 5.1 트레이너 기능

### 5.1.1 회원 관리
- 회원 등록 (이름, 연락처, 목표, 경력)
- 회원 코드 기반 연결 시스템
- 회원 그리드 뷰 (검색, 필터링)
- PT 진행률 추적 (완료 세션 / 전체 세션)
- 회원 상세 프로필 (체성분 이력, 운동 기록, 식단)

### 5.1.2 AI 커리큘럼 생성
- **입력**: 회원 정보 (목표, 경력, 체성분) + 세부 설정
- **설정 옵션**: 운동 개수, 집중 부위, 운동 스타일, 제외 부위
- **출력**: 세션별 운동 프로그램 (운동명, 세트, 횟수, 무게, 휴식)
- **편집**: 운동 순서 변경, 대체 운동 추천, 세트/횟수 수정
- **템플릿**: 생성된 커리큘럼을 템플릿으로 저장/재사용
- **AI 엔진**: Claude API 기반

### 5.1.3 AI 인사이트 대시보드
- **이탈 위험 예측**: 출석 패턴 분석, 이탈 가능성 경고
- **운동 성과 분석**: 중량 증가율, 운동 강도 트렌드
- **체성분 변화 추적**: 목표 대비 진행률, 예상 달성일
- **생성 주기**: 일간(dailyInsightGenerator) + 주간(weeklyInsightGenerator)
- **알림 연동**: 중요 인사이트 발생 시 푸시 알림

### 5.1.4 일정 관리
- PT 세션 등록/수정/삭제
- 캘린더 뷰 (월간/주간)
- 세션 완료 처리 + 디지털 서명
- 회원별 PT 일정 조회
- PT 리마인더 푸시 알림

### 5.1.5 평점/리뷰 시스템
- 회원의 3항목 평가 수신 (코칭 만족도, 소통, 친절도)
- 평균 평점 대시보드
- 리뷰 상세 보기
- 한줄평 확인

### 5.1.6 웹 대시보드 (Premium)
- **PlutoGrid** 기반 데이터 테이블 (회원 목록, 일정)
- **fl_chart** 기반 수익/성과 차트
- 반응형 사이드바 네비게이션
- 대형 화면 최적화 레이아웃

### 5.1.7 실시간 커뮤니케이션
- 1:1 채팅 (Firestore 실시간)
- 회원 요청(연결 요청) 수신/승인/거절
- 푸시 알림 (FCM)

## 5.2 회원 기능

### 5.2.1 PT 진행 추적
- 잔여 세션 수, 완료율 표시
- 다음 PT 일정 카드
- 트레이너 정보 확인

### 5.2.2 체성분 기록
- **수동 입력**: 체중, 체지방률, 근육량, BMI, BMR
- **인바디 연동**: 인바디 기기 데이터 자동 가져오기 (전화번호 기반)
- **차트 시각화**: 시간대별 변화 그래프 (fl_chart)
- **목표 설정**: 목표 체중, 목표 체지방률

### 5.2.3 AI 식단 분석
- **사진 촬영**: 카메라/갤러리에서 음식 사진 선택
- **AI 인식**: 음식 자동 인식 + 영양소 추정 (칼로리, 단백질, 탄수화물, 지방)
- **수동 검색**: 음식 데이터베이스 검색 + 수동 입력
- **일일 요약**: 식사별(아침/점심/저녁/간식) 영양소 합계
- **피드백**: AI 기반 식단 피드백 및 개선 제안

### 5.2.4 AI 체성분 예측
- **체중 예측**: 현재 추세 기반 미래 체중 예측
- **체성분 예측**: 체지방/근육량 변화 예측
- **시각화**: 예측 그래프 (점선)

### 5.2.5 월간 리포트
- 월별 운동 요약 (세션 수, 운동 시간)
- 체성분 변화 요약
- 식단 분석 요약
- AI 종합 평가

### 5.2.6 트레이너 평가
- 3항목 별점 (각 1-5점): 코칭 만족도, 소통, 친절도
- 한줄평 (선택, 최대 100자)
- 평가 제출 후 트레이너에게 익명 반영

### 5.2.7 구독 관리
- 현재 플랜 확인
- 프리미엄 업그레이드
- 구독 해지
- FAQ

## 5.3 공통 기능

### 5.3.1 실시간 채팅
- Firestore 기반 실시간 메시지
- 텍스트 메시지 전송/수신
- 읽음 상태 표시
- 채팅방 목록 (최신 메시지순)

### 5.3.2 푸시 알림
- PT 일정 리마인더
- AI 인사이트 알림
- 식단 기록 리마인더
- 주간 리포트 알림
- 채팅 메시지 알림

### 5.3.3 다크/라이트 모드
- 시스템 설정 연동
- 수동 전환 가능
- 모든 화면 완전 다크모드 지원

---

# 6. 데이터 모델

## 6.1 사용자 모델

### UserModel
```
uid: String (Firebase Auth UID)
email: String
displayName: String
role: UserRoleType (trainer | member | self)
photoUrl: String?
memberCode: String (6자리 고유 코드)
createdAt: DateTime
```

### TrainerModel
```
id: String
userId: String
gymName: String?
specialization: String?
subscriptionTier: SubscriptionTier (free | premium)
memberIds: List<String>
aiUsageCount: int
aiUsageLimit: int
rating: double?
reviewCount: int
createdAt: DateTime
```

### MemberModel
```
id: String
userId: String
trainerId: String?
name: String
phone: String?
goal: FitnessGoal (weightLoss | muscleGain | maintenance | bodyRecomposition)
experience: ExperienceLevel (beginner | intermediate | advanced)
targetWeight: double?
ptSessionsTotal: int
ptSessionsCompleted: int
startDate: DateTime?
createdAt: DateTime
```

## 6.2 PT 관리 모델

### CurriculumModel
```
id: String
trainerId: String
memberId: String
sessionNumber: int
exercises: List<Exercise>
isAiGenerated: bool
settings: CurriculumSettings?
notes: String?
createdAt: DateTime
```

### Exercise
```
exerciseId: String?
name: String
sets: int
reps: int
weight: double?
restSeconds: int
notes: String?
order: int
```

### ScheduleModel
```
id: String
trainerId: String
memberId: String?
scheduledAt: DateTime
duration: int (분)
scheduleType: ScheduleType (pt | personal | group)
status: ScheduleStatus (scheduled | completed | cancelled | noShow)
notes: String?
signatureUrl: String?
```

## 6.3 건강 데이터 모델

### BodyRecordModel
```
id: String
userId: String
weight: double
bodyFatPercent: double?
muscleMass: double?
bmi: double?
bmr: double?
source: RecordSource (manual | inbody | scale)
recordedAt: DateTime
```

### DietRecordModel
```
id: String
userId: String
mealType: MealType (breakfast | lunch | dinner | snack)
imageUrl: String?
aiAnalysis: AiAnalysis?
totalCalories: double
totalProtein: double
totalCarbs: double
totalFat: double
foods: List<FoodItem>
recordedAt: DateTime
```

### AiAnalysis
```
foodName: String
calories: double
protein: double
carbs: double
fat: double
confidence: double (0.0~1.0)
feedback: String?
```

## 6.4 분석/인사이트 모델

### InsightModel
```
id: String
trainerId: String
memberId: String?
type: InsightType (churnRisk | performance | attendance | bodyComposition | diet | general)
priority: InsightPriority (high | medium | low)
title: String
message: String
graphData: Map<String, dynamic>?
isRead: bool
createdAt: DateTime
```

### TrainerRatingModel
```
id: String
trainerId: String
averageRating: double
coachingSatisfaction: double
communication: double
kindness: double
totalReviews: int
reviews: List<MemberReviewModel>
```

## 6.5 커뮤니케이션 모델

### ChatRoomModel
```
id: String
trainerId: String
memberId: String
lastMessage: String?
lastMessageAt: DateTime?
unreadCount: Map<String, int>
```

### MessageModel
```
id: String
roomId: String
senderId: String
content: String
type: MessageType (text | image | system)
readAt: DateTime?
createdAt: DateTime
```

## 6.6 비즈니스 모델

### PaymentRecordModel
```
id: String
trainerId: String
memberId: String
amount: double
sessionCount: int
startDate: DateTime
endDate: DateTime
status: PaymentStatus
createdAt: DateTime
```

### SessionSignatureModel
```
id: String
scheduleId: String
trainerId: String
memberId: String
signatureUrl: String (Supabase Storage)
signedAt: DateTime
```

---

# 7. 상태 관리

## 7.1 Riverpod 프로바이더 구조

총 **24개 프로바이더**가 앱 상태를 관리합니다.

### 인증/사용자

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `authProvider` | StateNotifier | Firebase Auth 상태, 로그인/로그아웃 |
| `themeProvider` | StateNotifier | 다크/라이트 테마 전환 |
| `onboardingProvider` | StateNotifier | 온보딩 완료 상태 |

### 회원 관리

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `membersProvider` | StateNotifier | 회원 목록 CRUD |
| `bodyRecordsProvider` | StateNotifier | 체성분 기록 관리 |
| `inbodyProvider` | StateNotifier | 인바디 데이터 연동 |

### PT 관리

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `curriculumsProvider` | StateNotifier | 커리큘럼 CRUD |
| `curriculumTemplateProvider` | StateNotifier | 템플릿 관리 |
| `curriculumGeneratorV2Provider` | StateNotifier | AI 커리큘럼 생성 |
| `scheduleProvider` | StateNotifier | 일정 관리 |

### 식단/분석

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `dietAnalysisProvider` | StateNotifier | AI 식단 분석 |
| `foodSearchProvider` | StateNotifier | 음식 데이터베이스 검색 |
| `insightProvider` | StateNotifier | AI 인사이트 관리 |
| `weightPredictionProvider` | StateNotifier | 체중 예측 |
| `bodyCompositionPredictionProvider` | StateNotifier | 체성분 예측 |

### 커뮤니케이션

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `chatProvider` | StreamNotifier | 실시간 채팅 |
| `notificationProvider` | StateNotifier | 푸시 알림 |
| `trainerRequestProvider` | StateNotifier | 회원 연결 요청 |

### 비즈니스

| 프로바이더 | 타입 | 역할 |
|-----------|------|------|
| `paymentProvider` | StateNotifier | 결제 관리 |
| `subscriptionProvider` | StateNotifier | 구독 상태 |
| `trainerStatsProvider` | StateNotifier | 트레이너 통계 |
| `trainerRatingProvider` | StateNotifier | 평점/리뷰 |
| `reregistrationProvider` | StateNotifier | 재등록 알림 |
| `exerciseSearchProvider` | StateNotifier | 운동 DB 검색 |

---

# 8. 백엔드 아키텍처

## 8.1 Firebase 구성

| 서비스 | 용도 |
|--------|------|
| **Firebase Auth** | 인증 (소셜 로그인 + 이메일) |
| **Cloud Firestore** | 메인 데이터베이스 (NoSQL) |
| **Cloud Functions** | 서버리스 백엔드 (37개 함수) |
| **Firebase Messaging** | 푸시 알림 (FCM) |
| **Firebase Analytics** | 사용자 행동 분석 |

## 8.2 Supabase 구성

| 서비스 | 용도 |
|--------|------|
| **Supabase Storage** | 이미지 저장 (식단 사진, 서명, 프로필) |

## 8.3 Cloud Functions 목록

### AI 함수 (9개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `generateCurriculumV2` | HTTP (callable) | Claude API 기반 AI 커리큘럼 생성 |
| `searchExercises` | HTTP | 운동 DB 검색 (AI 보조) |
| `getAlternativeExercises` | HTTP | 대체 운동 추천 |
| `analyzeDiet` | HTTP | 식단 사진 AI 분석 |
| `predictWeight` | HTTP | 체중 예측 알고리즘 |
| `predictBodyComposition` | HTTP | 체성분 변화 예측 |
| `analyzeInbody` | HTTP | 인바디 데이터 분석 |
| `generateInsights` | HTTP | AI 인사이트 생성 |
| `generateMemberInsights` | HTTP | 회원별 인사이트 생성 |

### 스케줄러 (2개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `dailyInsightGenerator` | Scheduled (매일) | 일일 인사이트 자동 생성 |
| `weeklyInsightGenerator` | Scheduled (매주) | 주간 인사이트 자동 생성 |

### 알림 (4개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `sendInsightNotification` | Firestore trigger | 인사이트 생성 시 푸시 |
| `sendWeeklyReport` | Scheduled | 주간 리포트 푸시 |
| `sendDietReminder` | Scheduled | 식단 기록 리마인더 |
| `sendPTReminder` | Scheduled | PT 일정 리마인더 |

### Firestore 트리거 (3개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `onBodyRecordCreate` | Firestore onCreate | 체성분 기록 시 분석 트리거 |
| `onScheduleComplete` | Firestore onUpdate | 세션 완료 시 통계 업데이트 |
| `onMemberActivity` | Firestore onWrite | 회원 활동 시 인사이트 업데이트 |

### 인증/데이터 (3개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `createCustomToken` | HTTP | 커스텀 인증 토큰 생성 |
| `fetchInbodyByPhone` | HTTP | 전화번호로 인바디 조회 |
| `inbodyWebhook` | HTTP | 인바디 웹훅 수신 |

### 통계 (2개)

| 함수 | 트리거 | 설명 |
|------|--------|------|
| `updateTrainerStats` | Firestore trigger | 트레이너 통계 업데이트 |
| `calculateTrainerBadges` | HTTP | 트레이너 뱃지 계산 |

---

# 9. AI 기능 명세

## 9.1 AI 커리큘럼 생성

| 항목 | 내용 |
|------|------|
| **AI 모델** | Claude API (Anthropic) |
| **입력 데이터** | 회원 프로필, 목표, 경력, 체성분, 커리큘럼 설정 |
| **출력** | 세션별 운동 프로그램 (JSON) |
| **커스터마이징** | 운동 개수, 집중 부위, 스타일, 제외 부위, 템플릿 |
| **후처리** | 운동 대체, 순서 변경, 세트/횟수 수정 |

## 9.2 AI 식단 분석

| 항목 | 내용 |
|------|------|
| **AI 모델** | Claude Vision API |
| **입력** | 음식 사진 (카메라/갤러리) |
| **출력** | 음식명, 칼로리, 단백질, 탄수화물, 지방, 신뢰도, 피드백 |
| **정확도** | 신뢰도 0.0~1.0 표시 |
| **보정** | 사용자 수동 수정 가능 |

## 9.3 AI 인사이트

| 유형 | 설명 | 우선순위 |
|------|------|----------|
| 이탈 위험 | 출석률 하락, 장기 미방문 | HIGH |
| 운동 성과 | 중량 증가율, 강도 변화 | MEDIUM |
| 출석 패턴 | 출석 빈도, 시간대 분석 | MEDIUM |
| 체성분 변화 | 목표 대비 진행률 | MEDIUM |
| 식단 분석 | 영양소 균형, 칼로리 추세 | LOW |
| 일반 | 종합 가이드, 팁 | LOW |

## 9.4 AI 체성분 예측

| 항목 | 내용 |
|------|------|
| **알고리즘** | 시계열 회귀분석 + AI 보정 |
| **입력** | 최소 2개 이상의 체성분 기록 |
| **출력** | 2주/4주/8주 후 예상 체중, 체지방률, 근육량 |
| **시각화** | 실선(실제) + 점선(예측) 그래프 |

---

# 10. 기술 스택

## 10.1 프론트엔드

| 분류 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **프레임워크** | Flutter | 3.10+ | 크로스 플랫폼 UI |
| **언어** | Dart | 3.10+ | 타입 안전 개발 |
| **상태관리** | flutter_riverpod | 3.1.0 | 반응형 상태 관리 |
| **라우팅** | go_router | 17.0.1 | 선언적 라우팅 |
| **테마** | flex_color_scheme | 8.4.0 | 고급 테마 시스템 |
| **폰트** | google_fonts | 7.0.2 | Pretendard 폰트 |
| **애니메이션** | flutter_animate | 4.3.0 | 선언적 애니메이션 |
| **차트** | fl_chart | 1.1.1 | 데이터 시각화 |
| **데이터 그리드** | pluto_grid | 8.0.0 | 웹 테이블 (트레이너 대시보드) |
| **스켈레톤** | shimmer | 3.0.0 | 로딩 상태 UI |
| **캘린더** | table_calendar | 3.0.0 | 캘린더 위젯 |
| **서명** | syncfusion_flutter_signaturepad | 24.0.0 | 디지털 서명 |

## 10.2 백엔드

| 분류 | 기술 | 용도 |
|------|------|------|
| **인증** | Firebase Auth | 소셜/이메일 인증 |
| **데이터베이스** | Cloud Firestore | 메인 NoSQL DB |
| **서버리스** | Cloud Functions (TypeScript) | 비즈니스 로직, AI 연동 |
| **스토리지** | Supabase Storage | 이미지/파일 저장 |
| **푸시 알림** | Firebase Cloud Messaging | 앱 알림 |
| **분석** | Firebase Analytics | 사용자 행동 분석 |

## 10.3 AI/ML

| 분류 | 기술 | 용도 |
|------|------|------|
| **LLM** | Claude API (Anthropic) | 커리큘럼 생성, 인사이트 |
| **Vision** | Claude Vision API | 식단 사진 분석 |
| **예측** | 자체 알고리즘 (Cloud Functions) | 체중/체성분 예측 |

## 10.4 소셜 로그인

| 플랫폼 | 패키지 | 버전 |
|--------|--------|------|
| 카카오 | kakao_flutter_sdk_user | 1.9.5 |
| 구글 | google_sign_in | 6.2.0 |
| 애플 | sign_in_with_apple | 6.1.3 |

## 10.5 개발 도구

| 분류 | 기술 | 용도 |
|------|------|------|
| **코드 생성** | freezed + json_serializable | 불변 모델 생성 |
| **HTTP** | dio + retrofit | API 클라이언트 |
| **반응형** | flutter_screenutil | 화면 크기 적응 |

---

# 11. 크로스 플랫폼 요구사항

## 11.1 지원 플랫폼

| 플랫폼 | 지원 | 비고 |
|--------|------|------|
| **iOS** | O | 주력 플랫폼 |
| **Android** | O | 주력 플랫폼 |
| **Web** | O | 트레이너 대시보드 중심 |
| **macOS** | O | 데스크톱 지원 |

## 11.2 반응형 레이아웃

| 화면 크기 | 범위 | 레이아웃 |
|----------|------|----------|
| **모바일** | ~600px | 단일 컬럼, 바텀 네비 |
| **태블릿** | 600~1024px | 2컬럼 (마스터-디테일) |
| **웹/데스크톱** | 1024px~ | 사이드바 네비, 다중 패널 |

## 11.3 플랫폼별 차이

| 기능 | 모바일 | 웹 |
|------|--------|-----|
| 트레이너 대시보드 | 카드 기반 | PlutoGrid 데이터 테이블 |
| 네비게이션 | 바텀 네비 | 사이드바 네비 |
| 카메라 (식단) | 네이티브 카메라 | 파일 업로드 |
| 서명 | 터치 서명 | 마우스 서명 |
| 푸시 알림 | FCM 네이티브 | 웹 알림 |

---

# 12. 보안 요구사항

## 12.1 인증 보안

| 항목 | 구현 |
|------|------|
| 소셜 OAuth 2.0 | Firebase Auth 위임 |
| 커스텀 토큰 | Cloud Functions에서 생성 |
| 세션 관리 | Firebase Auth 자동 갱신 |
| 역할 기반 접근 | Firestore Security Rules |

## 12.2 데이터 보안

| 항목 | 구현 |
|------|------|
| 전송 암호화 | HTTPS (TLS 1.2+) |
| 데이터 격리 | Firestore Rules로 사용자별 데이터 격리 |
| 이미지 보안 | Supabase RLS (Row Level Security) |
| 개인정보 | 한국 개인정보보호법 준수 |

## 12.3 API 보안

| 항목 | 구현 |
|------|------|
| Cloud Functions 인증 | Firebase Auth 토큰 검증 |
| API Rate Limiting | Firebase App Check |
| AI API 키 | 환경 변수로 관리 (서버사이드만) |

---

# 13. 성능 요구사항

| 지표 | 목표 | 현재 |
|------|------|------|
| 앱 시작 시간 (Cold) | < 3초 | 구현 완료 |
| 화면 전환 | < 300ms | 200ms (토스 스타일) |
| Firestore 쿼리 | < 500ms | 캐싱 적용 |
| AI 커리큘럼 생성 | < 15초 | Claude API 의존 |
| AI 식단 분석 | < 10초 | Claude Vision 의존 |
| 이미지 업로드 | < 5초 | 압축 후 Supabase |
| 앱 크기 (iOS) | < 100MB | 빌드 최적화 |
| 앱 크기 (Android) | < 80MB | 빌드 최적화 |
| FPS | 60fps | Flutter 기본 |
| 메모리 사용 | < 200MB | 이미지 캐싱 최적화 |

---

# 14. 에러 처리

## 14.1 에러 상태 분류

| 상태 | UI 표현 | 메시지 예시 |
|------|---------|------------|
| **네트워크 에러** | 에러 상태 위젯 + 재시도 버튼 | "서버에 연결할 수 없어요" |
| **권한 에러** | 안내 메시지 | "접근 권한이 없어요" |
| **데이터 없음** | Empty 상태 위젯 | "아직 기록이 없어요" |
| **서버 에러** | 에러 상태 위젯 | "잠시 문제가 생겼어요" |
| **입력 에러** | 인라인 에러 텍스트 | "올바른 이메일을 입력해주세요" |

## 14.2 비동기 상태 처리

모든 비동기 작업은 3가지 상태를 필수 처리:
1. **로딩**: 스켈레톤 UI (Shimmer)
2. **성공**: 데이터 표시
3. **에러**: 에러 메시지 + 재시도

---

# 15. UX 라이팅 가이드

## 15.1 토스 해요체 원칙

| 원칙 | 예시 (Before) | 예시 (After) |
|------|-------------|-------------|
| **해요체 사용** | "등록되었습니다" | "등록됐어요" |
| **능동태 우선** | "데이터가 로드되었습니다" | "데이터를 불러왔어요" |
| **긍정 표현** | "기록이 없습니다" | "아직 기록이 없어요" |
| **짧은 문장** | "체중 기록이 부족합니다" | "체중을 기록해보세요" |
| **존댓말 간소화** | "삭제하시겠습니까?" | "삭제할까요?" |
| **마침표 최소화** | "로딩 중..." | (스켈레톤만 표시) |

## 15.2 주요 텍스트 변환 예시

| 상황 | 텍스트 |
|------|--------|
| 소셜 로그인 | "카카오로 계속하기", "구글로 계속하기" |
| 삭제 확인 | "삭제할까요?" |
| 성공 | "저장됐어요", "전송됐어요" |
| 에러 | "잠시 문제가 생겼어요. 다시 시도해주세요" |
| 빈 상태 | "아직 데이터가 없어요" |
| 로그아웃 | "로그아웃할까요?" |
| 회원 탈퇴 | "정말 탈퇴할까요?" |

---

# 16. 앱 스토어 배포

## 16.1 앱 정보

| 항목 | 내용 |
|------|------|
| **앱 이름** | PAL - AI PT 관리 |
| **번들 ID (iOS)** | com.palapp.health123 |
| **패키지명 (Android)** | com.palapp.health123 |
| **현재 버전** | 1.0.4+7 |
| **최소 iOS** | 14.0 |
| **최소 Android** | API 24 (Android 7.0) |
| **카테고리** | 건강 및 피트니스 |

## 16.2 필수 권한

| 권한 | 플랫폼 | 용도 |
|------|--------|------|
| 카메라 | iOS, Android | 식단 사진 촬영 |
| 사진 라이브러리 | iOS, Android | 갤러리에서 사진 선택 |
| 알림 | iOS, Android | 푸시 알림 수신 |
| 인터넷 | 전체 | 앱 데이터 동기화 |

## 16.3 릴리즈 체크리스트

- [ ] `flutter analyze` 에러 0개
- [ ] 전체 화면 라이트/다크 모드 검증
- [ ] iOS/Android 실기기 테스트
- [ ] 앱 스토어 스크린샷 준비
- [ ] 개인정보처리방침 URL 등록
- [ ] Firebase Security Rules 검증
- [ ] AI API 키 환경 변수 확인
- [ ] 앱 크기 확인 (iOS < 100MB, Android < 80MB)
- [ ] 크래시 모니터링 설정

---

# 부록

## A. Firestore 컬렉션 구조

```
users/
  {userId}/
trainers/
  {trainerId}/
members/
  {memberId}/
curriculums/
  {curriculumId}/
curriculum_templates/
  {templateId}/
schedules/
  {scheduleId}/
body_records/
  {recordId}/
diet_records/
  {recordId}/
inbody_records/
  {recordId}/
insights/
  {insightId}/
chat_rooms/
  {roomId}/
    messages/
      {messageId}/
notifications/
  {notificationId}/
payments/
  {paymentId}/
trainer_ratings/
  {ratingId}/
    reviews/
      {reviewId}/
trainer_requests/
  {requestId}/
session_signatures/
  {signatureId}/
exercise_db/
  {exerciseId}/
subscriptions/
  {subscriptionId}/
weight_predictions/
  {predictionId}/
reregistration_alerts/
  {alertId}/
```

## B. 환경 설정

| 환경 | Firebase 프로젝트 | 용도 |
|------|-------------------|------|
| **Development** | pal-dev | 개발/테스트 |
| **Production** | pal-prod | 운영 환경 |

## C. 코드 라인 통계

| 영역 | 파일 수 | 설명 |
|------|---------|------|
| 화면 (screens) | 35+ | ~43,000 라인 |
| 위젯 (widgets) | 20+ | 공통 컴포넌트 |
| 모델 (models) | 24 | Freezed 데이터 모델 |
| 프로바이더 (providers) | 24 | Riverpod 상태 관리 |
| 레포지토리 (repositories) | 22 | Firestore CRUD |
| 서비스 (services) | 7 | 외부 연동 |
| Cloud Functions | 37 | TypeScript 백엔드 |
| **총계** | **170+** | **Production-grade SaaS** |

---

*이 문서는 PAL 앱의 최종 제품 요구사항을 정의합니다. 모든 기능은 구현 완료 상태이며, 앱 스토어 배포 준비가 완료되었습니다.*
