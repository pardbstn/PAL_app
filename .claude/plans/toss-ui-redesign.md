# PAL 앱 토스 스타일 UI 리디자인 계획서

> **목표**: 기존 기능에 지장 없이, PAL 앱의 전체 UI를 토스(Toss) 디자인 시스템 스타일로 전환
> **범위**: 아이콘, 버튼, 위치, 색상, 방향, 텍스트, 안내메시지 등 디자인 요소만 변경
> **원칙**: 기능 코드(비즈니스 로직, 상태관리, 라우팅) 일체 수정 금지

---

## 1단계: 디자인 토큰 시스템 전면 교체

### 1-1. 색상 시스템 (`app_tokens.dart` > `AppColors`)

| 토큰 | 현재값 | 토스 스타일 변경값 | 용도 |
|------|--------|-------------------|------|
| `primary` | `#2563EB` | `#0064FF` (토스 블루) | 메인 브랜드 색상 |
| `primaryLight` | `#60A5FA` | `#4D9AFF` | 밝은 프라이머리 |
| `primaryDark` | `#1D4ED8` | `#0050CC` | 어두운 프라이머리 |
| `secondary` | `#10B981` | `#00C471` (토스 그린) | 성공/긍정 |
| `secondaryLight` | `#34D399` | `#33D68A` | 밝은 세컨더리 |
| `secondaryDark` | `#059669` | `#009D5A` | 어두운 세컨더리 |
| `tertiary` | `#F59E0B` | `#FF8A00` (토스 오렌지) | 경고/주의 |
| `error` | `#EF4444` | `#F04452` (토스 레드) | 에러/삭제 |
| `gray50` | `#F9FAFB` | `#F4F4F4` | 가장 밝은 회색 |
| `gray100` | `#F3F4F6` | `#EBEBEB` | 밝은 회색 배경 |
| `gray200` | `#E5E7EB` | `#D9D9D9` | 보더/구분선 |
| `gray300` | `#D1D5DB` | `#B0B0B0` | 비활성 보더 |
| `gray400` | `#9CA3AF` | `#8B8B8B` | 비활성 아이콘 |
| `gray500` | `#6B7280` | `#6B6B6B` | 보조 텍스트 |
| `gray600` | `#4B5563` | `#4E4E4E` | 서브 텍스트 |
| `gray700` | `#374151` | `#333333` | 본문 텍스트 |
| `gray800` | `#1F2937` | `#1A1A1A` | 타이틀 텍스트 |
| `gray900` | `#111827` | `#0E0E0E` | 최진한 텍스트 |
| `appBackground` | `#DBE1FE` (연한 파란색) | `#F4F4F4` (밝은 회색) | 앱 배경색 |
| `appBackgroundDark` | `#1A2140` | `#0E0E0E` | 다크모드 배경 |
| `darkSurface` | `#1E2A4A` | `#1A1A1A` | 다크 서피스 |
| `darkBackground` | `#1A2140` | `#0E0E0E` | 다크 배경 |
| `darkBorder` | `#2E3B5E` | `#2A2A2A` | 다크 보더 |
| `navBarBackground` | `#F7F7F7` | `#FFFFFF` | 네비바 배경 |
| `navBarBackgroundDark` | `#1E2A4A` | `#1A1A1A` | 다크 네비바 |
| `navBarSelected` | `#93C5FD` | `#0064FF` (토스 블루) | 선택된 네비 |
| `navBarSelectedDark` | `#60A5FA` | `#4D9AFF` | 다크 선택 네비 |
| `iconBackgroundLight` | `#EFF6FF` | `#F4F4F4` | 아이콘 배경 |
| `iconBackgroundDark` | `#1E3A5F` | `#2A2A2A` | 다크 아이콘 배경 |

**핵심 변경점**:
- 배경을 연한 파란색(`#DBE1FE`)에서 **순수 라이트 그레이(`#F4F4F4`)**로 변경 (토스의 깔끔한 흰색 기반)
- 다크모드를 남색 계열에서 **순수 블랙 계열**로 변경 (토스 다크모드 방식)
- Primary를 `#0064FF` 토스 블루로 통일

### 1-2. 타이포그래피 (`app_tokens.dart` > `AppTextStyle` + `app_theme.dart`)

| 토큰 | 현재값 | 토스 스타일 변경값 | 용도 |
|------|--------|-------------------|------|
| `titleLarge` | 28px | 26px | 페이지 헤딩 (토스: 대형 타이틀 중심) |
| `titleMedium` | 22px | 21px | 섹션 헤딩 |
| `titleSmall` | 18px | 17px | 카드 헤딩 |
| `bodyLarge` | 16px | 16px | 강조 텍스트 (유지) |
| `bodyMedium` | 14px | 15px | 기본 텍스트 (가독성 향상) |
| `bodySmall` | 12px | 13px | 보조 텍스트 (가독성 향상) |
| `caption` | 11px | 11px | 라벨/힌트 (유지) |
| `lineHeightTight` | 1.2 | 1.3 | 타이트 줄 간격 (토스: 1.3em) |
| `lineHeightNormal` | 1.5 | 1.5 | 일반 줄 간격 (유지) |
| `fontFamily` | `Pretendard` | `Pretendard` | **유지** (토스도 Pretendard 계열) |

**핵심 변경점**:
- 폰트 웨이트 체계를 토스 스타일로 조정: **Bold(700) → SemiBold(600)** 기본 사용
- 섹션 헤딩에 `FontWeight.w700` → `FontWeight.w600`
- 본문 텍스트에 `FontWeight.w500` → `FontWeight.w400` (더 가벼운 느낌)
- 제목/값 강조에만 `FontWeight.w700` 사용

### 1-3. 간격 시스템 (`app_tokens.dart` > `AppSpacing`)

| 토큰 | 현재값 | 토스 스타일 변경값 | 설명 |
|------|--------|-------------------|------|
| `xs` | 4px | 4px | 유지 |
| `sm` | 8px | 8px | 유지 |
| `md` | 16px | 16px | 유지 |
| `lg` | 24px | 20px | 섹션간 간격 (토스: 더 타이트) |
| `xl` | 32px | 24px | 대형 간격 |
| `xxl` | 48px | 32px | 최대 간격 |

**추가 토큰**:
- `screenPadding`: 20px (기존 16px → 20px, 토스 스타일의 여유로운 좌우 패딩)
- `sectionGap`: 32px (섹션 간 간격)
- `cardContentPadding`: 20px (카드 내부 패딩)

### 1-4. 모서리 둥글기 (`app_tokens.dart` > `AppRadius`)

| 토큰 | 현재값 | 토스 스타일 변경값 | 용도 |
|------|--------|-------------------|------|
| `sm` | 8px | 8px | 유지 |
| `md` | 12px | 16px | 기본 카드/입력 (토스: 더 둥글게) |
| `lg` | 16px | 20px | 대형 카드 |
| `xl` | 24px | 24px | 유지 |
| `full` | 999px | 999px | 유지 |

### 1-5. 그림자 시스템 (`app_tokens.dart` > `AppShadows`)

토스는 **그림자를 거의 사용하지 않음**. 대신 배경색 차이와 미세한 보더로 구분.

| 토큰 | 현재값 | 토스 스타일 변경값 |
|------|--------|-------------------|
| `sm` | `black 5%, blur 4, offset(0,2)` | `black 2%, blur 2, offset(0,1)` |
| `md` | `black 8%, blur 8, offset(0,4)` | `black 3%, blur 4, offset(0,2)` |
| `lg` | `black 12%, blur 16, offset(0,8)` | `black 5%, blur 8, offset(0,4)` |
| `navBar` | `black 6%, blur 8, offset(0,-2)` | **제거** (borderTop으로 대체) |

---

## 2단계: 테마 설정 전면 교체

### 2-1. `app_theme.dart` 수정

**라이트 테마**:
```
FlexSchemeColor:
  primary: #0064FF (토스 블루)
  primaryContainer: #E8F0FE (연한 파란 배경)
  secondary: #00C471 (토스 그린)
  secondaryContainer: #E5F9EF
  tertiary: #FF8A00 (토스 오렌지)
  tertiaryContainer: #FFF3E0
  error: #F04452 (토스 레드)
  errorContainer: #FFEDEF

SubThemesData 변경:
  blendLevel: 0 → (토스: 색상 블렌딩 없음, 순수 흰색 배경)
  blendOnLevel: 0
  cardRadius: 20 → (토스: 더 둥근 카드)
  dialogRadius: 24 → (토스: 둥근 다이얼로그)
  inputDecoratorRadius: 16 → (토스: 둥근 입력필드)
  inputDecoratorBorderType: underline → (토스: underline 스타일 인풋)
  elevatedButtonRadius: 16 → (토스: 둥근 버튼)
  filledButtonRadius: 16
  outlinedButtonRadius: 16
  textButtonRadius: 16
  bottomNavigationBarElevation: 0 (유지)
  appBarScrolledUnderElevation: 0 → (토스: 앱바 그림자 없음)
```

**다크 테마**:
```
FlexSchemeColor:
  primary: #4D9AFF (밝은 토스 블루)
  primaryContainer: #1A3A6B
  secondary: #33D68A (밝은 그린)
  secondaryContainer: #0A3D25
  tertiary: #FFB74D
  tertiaryContainer: #5C3300
  error: #FF6B6B
  errorContainer: #4D1515

blendLevel: 0 (순수 다크)
```

---

## 3단계: 공통 위젯 리디자인

### 3-1. `AppCard` 위젯 (`app_card.dart`)

**현재**: 흰색 배경 + 그레이 보더 1px + 쉐도우
**토스 스타일**: 흰색 배경 + 보더 없음 or 매우 연한 보더 + 최소 쉐도우

변경사항:
- `_borderRadius`: 16 → 20
- `_defaultPadding`: `EdgeInsets.all(16)` → `EdgeInsets.all(20)`
- Standard 카드: 보더 제거, 쉐도우 최소화 (`black 2%, blur 2`)
- 배경색: `Colors.white` 유지 (토스: 순수 흰색 카드 on 그레이 배경)
- Elevated 카드: 쉐도우 약간 강화 (`black 4%, blur 6`)
- Accent 카드: primary 보더 유지하되 `1.5px`로 줄임
- GradientBorder 카드: 제거 → standard로 대체 (토스는 그라데이션 미사용)
- 탭 피드백: `scale 0.98` → `scale 0.97` + 배경색 미세 변화 (토스 스타일 터치 피드백)

### 3-2. `AppButton` 위젯 (`app_button.dart`)

**현재**: borderRadius 12, 다양한 변형
**토스 스타일**: borderRadius 16, BottomCTA 패턴

변경사항:
- borderRadius: 12 → 16 (전체적으로 더 둥글게)
- Primary 버튼 높이: `sm=40, md=52, lg=56` (토스: 넉넉한 터치 영역)
- 수직 패딩: `sm=10, md=16, lg=18`
- 수평 패딩: `sm=20, md=24, lg=28`
- Primary 색상: `#0064FF` → 흰색 텍스트
- FontWeight: `w600` (토스: 세미볼드)
- 비활성 상태: `opacity 0.5` → `backgroundColor: #F4F4F4, textColor: #B0B0B0` (토스 방식)
- **BottomCTA 패턴 추가**: 하단 고정 버튼용 variant 추가
  - 화면 하단 SafeArea 내에 좌우 20px 패딩
  - 토스 "다음", "확인", "계속하기" 버튼 패턴

### 3-3. `AppListTile` 위젯 (`app_list_tile.dart`)

**현재**: Material Design 스타일 리스트 타일
**토스 스타일**: ListRow 컴포넌트

변경사항:
- 기본 패딩: `horizontal: 16, vertical: 16` → `horizontal: 20, vertical: 16`
- 타이틀 스타일: `FontWeight.w500` → `FontWeight.w400` (토스: 가벼운 느낌)
- 서브타이틀 색상: `gray500` → `gray400` (토스: 더 연한 보조 텍스트)
- trailing 화살표: `chevron_right_rounded` → 더 가는 아이콘 (사이즈 18px)
- 구분선: full width 대신 leading 이후부터 시작하는 partial divider
- Card variant: 보더 제거, 배경색만으로 구분

### 3-4. `AppSection` 위젯 (`app_section.dart`)

변경사항:
- 제목 스타일: `titleMedium, w700` → `titleSmall(17px), w600` (토스: 적당한 크기의 섹션 헤딩)
- 제목 색상: `gray900` → `gray800` (#1A1A1A)
- 제목-콘텐츠 간격: `md(16)` → `12`
- "더보기" 버튼: 텍스트 → 연한 텍스트 + chevron (크기 줄임)

### 3-5. `AppTextField` (`app_text_field.dart`)

**현재**: Outline 보더 스타일
**토스 스타일**: Underline 보더 + 플로팅 라벨

변경사항:
- 보더 스타일: OutlineBorder → **UnderlineBorder** (토스 인풋 스타일)
- 포커스 시: 블루 언더라인 (`#0064FF`, 2px)
- 비포커스: 그레이 언더라인 (`#D9D9D9`, 1px)
- 에러 시: 레드 언더라인 (`#F04452`) + 에러 라벨 텍스트 빨간색
- 라벨: 입력 시 위로 플로팅, 색상 `#0064FF`
- 힌트 텍스트: `#B0B0B0`
- X 버튼(clear): 입력 시 우측에 표시 (토스 패턴)

### 3-6. `AppDialog` (`app_dialog.dart`)

**현재**: Material 다이얼로그
**토스 스타일**: 둥근 모서리 + 하단 버튼 배치

변경사항:
- borderRadius: 20 → 24
- 내부 패딩: 24 → 28
- 타이틀: 좌정렬, `w600`, 20px
- 본문: 좌정렬, `w400`, 15px, `color: #6B6B6B`
- 버튼 배치: Row (닫기=ghost/outline + 확인=primary)
- 닫기 버튼: outline 스타일, `#F4F4F4` 배경
- 확인 버튼: primary `#0064FF`

### 3-7. `AppBottomSheet` (`app_bottom_sheet.dart`)

변경사항:
- borderRadius: 상단만 24
- 핸들바: width 36, height 4, color `#D9D9D9`, borderRadius full
- 내부 패딩: 20
- 타이틀: 좌정렬, `w600`, 19px
- 바텀시트 내 리스트: 토스의 선택 시트 스타일 (아이템별 16px 수직 패딩)

### 3-8. `AppSnackbar` (`app_snackbar.dart`)

**토스 스타일**: 하단 토스트 메시지 (둥근 pill shape)

변경사항:
- 형태: 하단 중앙 정렬, pill shape (borderRadius: full)
- 배경: `#333333` (다크 배경)
- 텍스트: 흰색, 14px, `w500`
- 아이콘: 좌측에 상태 아이콘 (경고=노란색 원 !, 성공=초록 체크)
- 토스의 "화면 캡처를 감지했어요" 스타일 참고

### 3-9. Empty/Error/Loading 상태 위젯

**현재**: 아이콘 + 텍스트 중앙 배치
**토스 스타일**: 최소한의 일러스트 + 짧은 텍스트

변경사항:
- Empty state: 아이콘 크기 48 → 40, 색상 `#B0B0B0`
- 텍스트: 가운데 정렬, `15px, w400, #6B6B6B`
- 버튼(있을 경우): 텍스트 버튼 스타일, 파란색
- Loading state: CircularProgressIndicator → 토스 스타일 스켈레톤 유지

---

## 4단계: 네비게이션 리디자인

### 4-1. Bottom Navigation Bar (`member_shell.dart`, `trainer_shell.dart`)

**현재**: NavigationBar + navBarSelected 인디케이터 색상
**토스 스타일**: 깔끔한 하단 네비, 선택/비선택 구분 명확

변경사항:
- 배경: 순수 흰색 `#FFFFFF` (다크: `#1A1A1A`)
- 상단 보더: `1px solid #EBEBEB` (쉐도우 대신 보더로 구분)
- 선택된 아이콘: `#0064FF` (토스 블루) + filled 아이콘
- 비선택 아이콘: `#B0B0B0` + outlined 아이콘
- 선택된 라벨: `#0064FF`, `11px, w600`
- 비선택 라벨: `#B0B0B0`, `11px, w400`
- 인디케이터: **제거** (토스는 인디케이터 없이 색상만으로 구분)
- 아이콘 크기: 24px → 22px (토스: 약간 작은 네비 아이콘)

### 4-2. AppBar / Top Navigation

**현재**: SliverAppBar + 타이틀
**토스 스타일**: 미니멀한 상단 바

변경사항:
- 배경: transparent (콘텐츠와 동일)
- elevation: 0 (그림자 완전 제거)
- 뒤로가기: `<` 심볼 (Icons.arrow_back_ios_new, 20px, `#1A1A1A`)
- 타이틀: 좌정렬, `17px, w600` (토스: 심플한 페이지 타이틀)
- 우측 액션: 아이콘 버튼들, 24px, `#1A1A1A`
- 스크롤 시: 하단에 미세한 보더 추가 (`1px solid #EBEBEB`)

---

## 5단계: 화면별 상세 리디자인

### 5-1. 로그인 화면 (`login_screen.dart`)

**현재**: 연한 파란 배경 + 중앙 정렬 + 역할 선택 카드
**토스 스타일**: 순수 흰색 배경 + 좌정렬 + 단계별 진행

변경사항:
- 배경: `#FFFFFF` (순수 흰색)
- 로고: 중앙 → 좌상단 또는 중앙 유지 (심플하게)
- 앱 타이틀 `PAL`: 토스 블루 `#0064FF`, `w700`
- 슬로건: `#6B6B6B`, `15px`
- 역할 선택 카드: 큰 카드 2개 → 심플한 세그먼트 컨트롤 또는 탭
- 입력 필드: outline → underline 스타일
- 소셜 로그인 버튼:
  - "구글로 계속하기": 구글 가이드라인 준수 (흰 배경 + 구글 로고 + 텍스트)
  - "카카오로 계속하기": 카카오 가이드라인 준수 (노란 배경 + 카카오 로고)
- 로그인 버튼: 하단 고정 BottomCTA 스타일, `#0064FF`
- 텍스트: 해요체 적용 ("로그인해 주세요" → "로그인해주세요")

### 5-2. 회원 홈 화면 (`member_home_screen.dart`)

**현재**: 파란 배경 + 카드 기반 레이아웃 + 중앙 인사말
**토스 스타일**: 그레이 배경 + 섹션 기반 레이아웃 + 좌정렬

변경사항:
- 배경: `#F4F4F4`
- 좌우 패딩: 16 → 20
- 인사말 섹션:
  - "안녕하세요, {이름}님" → `26px, w700, #1A1A1A`
  - 아이콘 버튼 (알림/설정): `#1A1A1A`, 24px
- 체중 변화 카드: 흰색 배경 카드, 보더 없음, borderRadius 20
  - 값: 큰 숫자 `24px, w700`
  - 단위: `13px, w400, #6B6B6B`
- 다음 PT 일정 카드: accent 보더 대신 좌측 컬러 바 (4px width)
- 커리큘럼 카드: 심플한 리스트 스타일
- AI 인사이트: 별도 섹션, 카드 내 차트
- 섹션 간격: 32px (넉넉한 여백)

### 5-3. 트레이너 홈 화면 (`trainer_home_screen.dart`)

변경사항 (회원 홈과 동일한 패턴):
- 배경: `#F4F4F4`
- 인사말: 좌정렬, 토스 스타일
- "오늘 일정" 섹션: 카드 리스트, 시간 좌측 강조
- "회원 현황" 섹션: 숫자 강조 카드 (2열 그리드 → 가로 스크롤)
- "AI 인사이트" 섹션: 카드 내 차트
- 섹션 헤더: `17px, w600` + "더보기" 텍스트 버튼

### 5-4. 식단 기록 화면 (`member_diet_screen.dart`)

**현재**: 중앙 정렬 레이아웃
**토스 스타일**: 좌정렬 기반

변경사항:
- 날짜 선택: 상단 가로 스크롤 날짜 칩
- 식사별 섹션 (아침/점심/저녁/간식): 각각 카드
- 음식 항목: ListRow 스타일 (좌: 음식명, 우: 칼로리)
- 사진 보기: 탭 시 전체화면 프리뷰 (토스 스타일 모달)
- 합계 영역: 하단 고정 또는 상단 summary
- 정렬: **좌정렬 기본** (중앙정렬 제거)
- 칼로리 표시: 큰 숫자 `w700` + "kcal" 보조 텍스트

### 5-5. 내 기록 화면 (`member_records_screen.dart`)

변경사항:
- 정렬: **좌정렬 기본**
- 체중/체지방/근육량: 각각 독립 카드 → 하나의 카드 내 탭 또는 세그먼트
- 차트: fl_chart 스타일 유지, 색상만 토스 블루로 변경
- 기록 추가 버튼: 우측 하단 FAB → 하단 CTA 버튼 또는 상단 + 아이콘

### 5-6. 캘린더 화면 (`member_calendar_screen.dart`)

변경사항:
- 캘린더 헤더: 월 이동 화살표 심플하게
- 날짜 셀: 선택 시 `#0064FF` 원형 배경
- 오늘: `#0064FF` 텍스트 (배경 없이)
- 이벤트 도트: 작은 점으로 표시 (4px)
- 일정 리스트: 하단에 선택된 날짜의 일정 ListRow 형태
- **다크모드 텍스트 가시성**: 입력 필드/텍스트 색상 강화

### 5-7. 메시지 화면 (`member_messages_screen.dart`, `trainer_messages_screen.dart`)

변경사항:
- 메시지 리스트: 아바타 + 이름 + 마지막 메시지 + 시간 (ListRow 패턴)
- 읽지 않은 메시지: 우측 빨간 뱃지 (pill shape)
- 채팅방: 말풍선 스타일 유지, 색상만 변경
  - 내 메시지: `#0064FF` 배경 + 흰 텍스트
  - 상대 메시지: `#F4F4F4` 배경 + `#1A1A1A` 텍스트

### 5-8. 트레이너 회원 상세 (`trainer_member_detail_screen.dart`)

변경사항:
- 상단 프로필: 아바타 + 이름 + 상태
- 탭: 기록/커리큘럼/인사이트 (Segment 또는 Tab)
- 뒤로가기 애니메이션: **올바른 방향으로 수정** (좌→우 슬라이드)
- 좌상단 뒤로가기: `<` 아이콘, 자연스러운 pop 애니메이션

### 5-9. 커리큘럼 화면 (`trainer_curriculum_screen.dart`)

변경사항:
- 생성 버튼 아이콘 색상: 현재 잘 안 보이는 문제 → `#0064FF` 또는 `#FFFFFF` on primary 배경
- 커리큘럼 카드: 회차 번호 강조, 운동 목록 서브텍스트
- 설정 적용 UI: 토스 스타일 폼

### 5-10. 알림 화면 (`notifications_screen.dart`)

변경사항:
- 로딩 상태: 스켈레톤 → 토스 스타일 스켈레톤 (더 부드러운 shimmer)
- 알림 항목: ListRow 스타일, 좌측 아이콘 (원형 배경) + 제목 + 시간
- 빈 상태: "알림이 없어요" (토스 해요체)

### 5-11. 설정 화면 (`member_settings_screen.dart`, `trainer_settings_screen.dart`)

변경사항:
- 그룹화된 리스트: AppListTileGroup 사용
- 섹션 간 간격: 32px
- 헤더 텍스트: `13px, w600, #8B8B8B`
- 로그아웃/탈퇴: 별도 섹션, 빨간색 텍스트

---

## 6단계: UX 라이팅 전면 수정

### 6-1. 토스 UX 라이팅 원칙 적용

| 원칙 | 현재 예시 | 토스 스타일 변경 |
|------|----------|-----------------|
| 해요체 | "등록하세요" | "등록해주세요" |
| 능동태 | "데이터가 로드되었습니다" | "데이터를 불러왔어요" |
| 긍정 표현 | "기록이 없습니다" | "아직 기록이 없어요" |
| 짧은 문장 | "체중 기록이 부족합니다" | "체중을 기록해보세요" |
| 존댓말 간소화 | "기록을 추가하시겠습니까?" | "기록을 추가할까요?" |

### 6-2. 화면별 텍스트 수정 목록

| 화면 | 현재 텍스트 | 변경 텍스트 |
|------|----------|-----------|
| 회원 홈 | "체중 기록이 부족합니다" | "체중을 기록해보세요" |
| 회원 홈 | "기록 추가" | "기록하기" |
| 회원 홈 | "첫 회원을 등록하세요" | "회원을 등록해보세요" |
| 로그인 | "구글로 로그인" | "구글로 계속하기" |
| 로그인 | "카카오로 로그인" | "카카오로 계속하기" |
| 로그인 | "이메일로 로그인" | "이메일로 로그인하기" |
| 식단 | "식단 기록" | "오늘 뭐 먹었어요?" |
| 내 기록 | "내 기록" | "내 운동 기록" |
| 커리큘럼 | "커리큘럼 생성" | "커리큘럼 만들기" |
| 알림 | "알림이 없습니다" | "새로운 알림이 없어요" |
| 에러 | "오류가 발생했습니다" | "잠시 문제가 생겼어요" |
| 에러 | "다시 시도해주세요" | "다시 시도해주세요" (유지) |
| 로딩 | "로딩 중..." | (텍스트 제거, 스켈레톤만 표시) |
| 빈 상태 | "데이터가 없습니다" | "아직 데이터가 없어요" |

---

## 7단계: 애니메이션 & 인터랙션 조정

### 7-1. 페이지 전환 애니메이션

**현재 문제**: 뒤로가기 슬라이드가 반대로 작동
**토스 스타일**: iOS 네이티브와 동일한 자연스러운 전환

변경사항:
- Push: 새 페이지가 **오른쪽에서 왼쪽으로** 슬라이드 인
- Pop: 현재 페이지가 **왼쪽에서 오른쪽으로** 슬라이드 아웃
- GoRouter의 `pageBuilder`에서 `CupertinoPage` 사용 권장
- FadeTransition 대신 **SlideTransition** 사용

### 7-2. 카드/리스트 등장 애니메이션

**현재**: fadeIn + slideY 조합
**토스 스타일**: 더 미세하고 빠른 등장

변경사항:
- fadeIn duration: 300ms → 200ms
- slideY begin: 0.02-0.05 → 0.01 (거의 미세한 이동)
- 순차 지연: 100ms → 50ms (더 빠른 연쇄 등장)
- 카드 탭 피드백: scale 0.98 → **opacity 0.7 + scale 0.98** (토스 터치 피드백)

### 7-3. 탭 전환 애니메이션

**현재**: AnimatedSwitcher + FadeTransition
**토스 스타일**: 크로스페이드 (빠른 전환)

변경사항:
- duration: 200ms → 150ms
- curve: easeOut → easeInOut

---

## 8단계: 아이콘 시스템 교체

### 8-1. Material Icons → 라운드/심플 스타일

토스는 자체 아이콘을 사용하지만, Material Icons 중 rounded variant로 대체 가능.

| 현재 아이콘 | 변경 | 용도 |
|------------|------|------|
| `Icons.home_outlined` | `Icons.home_rounded` | 홈 |
| `Icons.fitness_center_outlined` | `Icons.fitness_center_rounded` | 기록 |
| `Icons.calendar_today_outlined` | `Icons.calendar_today_rounded` | 캘린더 |
| `Icons.restaurant_outlined` | `Icons.restaurant_rounded` | 식단 |
| `Icons.message_outlined` | `Icons.chat_bubble_outline_rounded` | 메시지 |
| `Icons.notifications_outlined` | `Icons.notifications_none_rounded` | 알림 |
| `Icons.settings_outlined` | `Icons.settings_rounded` | 설정 |
| `Icons.arrow_back` | `Icons.arrow_back_ios_new` (크기 20) | 뒤로가기 |
| `Icons.chevron_right` | `Icons.chevron_right_rounded` (크기 18) | 화살표 |
| `Icons.add` | `Icons.add_rounded` | 추가 |
| `Icons.close` | `Icons.close_rounded` | 닫기 |

### 8-2. 아이콘 배경 처리

**현재**: `iconBackgroundLight` 색상의 원형/사각 배경
**토스 스타일**: 더 큰 원형 배경 (40x40) + 연한 색상

변경사항:
- 배경 크기: 36x36 → 40x40
- 배경 색상: `#F4F4F4` (라이트), `#2A2A2A` (다크)
- 아이콘 크기: 20 → 20 (유지)
- borderRadius: 12 → full (원형)

---

## 9단계: 다크모드 전면 재검토

### 9-1. 다크모드 색상 체계

| 요소 | 라이트 | 다크 |
|------|--------|------|
| 배경 | `#F4F4F4` | `#0E0E0E` |
| 카드 배경 | `#FFFFFF` | `#1A1A1A` |
| 서피스 | `#FFFFFF` | `#1A1A1A` |
| 보더 | `#EBEBEB` | `#2A2A2A` |
| 텍스트 1차 | `#1A1A1A` | `#FFFFFF` |
| 텍스트 2차 | `#6B6B6B` | `#8B8B8B` |
| 텍스트 3차 | `#B0B0B0` | `#6B6B6B` |
| Primary | `#0064FF` | `#4D9AFF` |
| 구분선 | `#EBEBEB` | `#2A2A2A` |
| 네비바 | `#FFFFFF` | `#1A1A1A` |
| 입력 필드 배경 | `#FFFFFF` | `#1A1A1A` |

### 9-2. 다크모드 특별 주의사항

- **캘린더 텍스트 가시성 문제** 해결: 입력 필드 텍스트를 `#FFFFFF`로 강제 설정
- 카드 구분: 배경 `#1A1A1A` vs 전체 배경 `#0E0E0E`로 명확한 계층
- 차트 색상: 라이트 primary와 별도의 밝은 색상 사용

---

## 실행 순서 (우선순위)

### Phase 1: 파운데이션 (가장 먼저)
1. `app_tokens.dart` 색상/타이포/간격/그림자 토큰 전면 교체
2. `app_theme.dart` FlexColorScheme 설정 변경
3. 결과: **모든 화면에 즉시 반영되는 기본 톤 변경**

### Phase 2: 공통 위젯 (파운데이션 적용 후)
4. `app_card.dart` 리디자인
5. `app_button.dart` 리디자인 + BottomCTA 추가
6. `app_list_tile.dart` 리디자인
7. `app_section.dart` 리디자인
8. `app_text_field.dart` underline 스타일로 변경
9. `app_dialog.dart`, `app_bottom_sheet.dart`, `app_snackbar.dart` 리디자인
10. Empty/Error/Loading 상태 위젯 리디자인

### Phase 3: 네비게이션 & 인터랙션
11. `member_shell.dart`, `trainer_shell.dart` 바텀 네비 리디자인
12. 페이지 전환 애니메이션 수정 (뒤로가기 방향 수정 포함)
13. 등장 애니메이션 토스 스타일로 조정
14. 아이콘 시스템 교체 (rounded 스타일)

### Phase 4: 화면별 세부 조정
15. `login_screen.dart` 리디자인
16. `member_home_screen.dart` 리디자인
17. `trainer_home_screen.dart` 리디자인
18. `member_diet_screen.dart` 좌정렬 + 상세보기
19. `member_records_screen.dart` 좌정렬 + 레이아웃
20. `member_calendar_screen.dart` + 다크모드 수정
21. `notifications_screen.dart` 수정
22. `member_messages_screen.dart`, `trainer_messages_screen.dart` 수정
23. `trainer_member_detail_screen.dart` 수정
24. `trainer_curriculum_screen.dart` 아이콘 색상 수정
25. 설정 화면들 리디자인

### Phase 5: UX 라이팅 & 폴리싱
26. 전체 화면 UX 라이팅 토스 해요체로 수정
27. 다크모드 전면 재검토 및 수정
28. 스켈레톤/로딩 상태 토스 스타일 적용
29. 최종 QA: 모든 화면 라이트/다크 모드 확인

---

## 수정 대상 파일 목록 (총 43개)

### 코어 (3개)
- `lib/core/theme/app_tokens.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/utils/animation_utils.dart`

### 공통 위젯 (14개)
- `lib/presentation/widgets/common/app_card.dart`
- `lib/presentation/widgets/common/app_button.dart`
- `lib/presentation/widgets/common/app_list_tile.dart`
- `lib/presentation/widgets/common/app_section.dart`
- `lib/presentation/widgets/common/app_text_field.dart`
- `lib/presentation/widgets/common/app_dialog.dart`
- `lib/presentation/widgets/common/app_bottom_sheet.dart`
- `lib/presentation/widgets/common/app_snackbar.dart`
- `lib/presentation/widgets/common/app_badge.dart`
- `lib/presentation/widgets/common/app_avatar.dart`
- `lib/presentation/widgets/common/app_stat_card.dart`
- `lib/presentation/widgets/common/app_action_button.dart`
- `lib/presentation/widgets/common/icon_background.dart`
- `lib/presentation/widgets/states/empty_state.dart`

### 스켈레톤 (2개)
- `lib/presentation/widgets/skeleton/skeleton_base.dart`
- `lib/presentation/widgets/skeleton/screen_skeletons.dart`

### 화면 (19개)
- `lib/presentation/screens/auth/login_screen.dart`
- `lib/presentation/screens/member/member_shell.dart`
- `lib/presentation/screens/member/member_home_screen.dart`
- `lib/presentation/screens/member/member_diet_screen.dart`
- `lib/presentation/screens/member/member_records_screen.dart`
- `lib/presentation/screens/member/member_calendar_screen.dart`
- `lib/presentation/screens/member/member_messages_screen.dart`
- `lib/presentation/screens/member/member_settings_screen.dart`
- `lib/presentation/screens/member/monthly_report_screen.dart`
- `lib/presentation/screens/trainer/trainer_shell.dart`
- `lib/presentation/screens/trainer/trainer_home_screen.dart`
- `lib/presentation/screens/trainer/trainer_member_detail_screen.dart`
- `lib/presentation/screens/trainer/trainer_curriculum_screen.dart`
- `lib/presentation/screens/trainer/trainer_messages_screen.dart`
- `lib/presentation/screens/trainer/trainer_settings_screen.dart`
- `lib/presentation/screens/trainer/trainer_calendar_screen.dart`
- `lib/presentation/screens/trainer/ai_curriculum_generator_screen.dart`
- `lib/presentation/screens/common/notifications_screen.dart`
- `lib/presentation/screens/splash/splash_screen.dart`

### 라우터 (1개)
- `lib/main.dart` (페이지 전환 애니메이션 설정)

### 기타 위젯 (4개)
- `lib/presentation/widgets/add_body_record_sheet.dart`
- `lib/presentation/widgets/diet/serving_size_dialog.dart`
- `lib/presentation/widgets/animated/micro_interactions.dart`
- `lib/presentation/widgets/chat/message_input.dart`

---

## 변경하지 않는 것 (명시)

- 모든 Provider/Repository/Service/Model 파일
- Firestore/Supabase 연동 코드
- 비즈니스 로직 (칼로리 계산, 인사이트 분석 등)
- GoRouter 라우트 구조
- 상태관리 구조 (Riverpod)
- 차트 라이브러리 (fl_chart) → 색상만 변경
- 웹 전용 화면 (trainer_web_*) → 별도 처리
