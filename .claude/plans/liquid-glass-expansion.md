# Liquid Glass + UI 개선 종합 플랜

## 핵심 원칙 (UI/UX Pro Max 기반)

> **"Glassmorphism은 오버레이/플로팅 요소에만 적용한다"**
> — 모든 곳에 적용하면 시각적 피로 + 성능 저하 + 가독성 저하

### 적용 기준
| 적용 O | 적용 X |
|--------|--------|
| 화면 위에 떠 있는 요소 (overlay) | 일반 콘텐츠 카드 |
| 네비게이션/헤더 (고정 UI) | 리스트 아이템 |
| 모달/다이얼로그/바텀시트 | 텍스트 입력 필드 |
| 스낵바/토스트 (플로팅) | 일반 버튼 |
| FAB 버튼 (플로팅) | 반복되는 위젯 |

### 색상 팔레트 (UI/UX Pro Max 추천)

UI/UX Pro Max "Fitness/Gym App" 추천 기반 + PAL 기존 Toss Blue 유지:

| 용도 | 색상 | Hex | 설명 |
|------|------|-----|------|
| Primary | Toss Blue | `#0064FF` | 기존 유지 - 신뢰/전문성 |
| Secondary | Health Green | `#00C471` | 기존 유지 - 성공/건강 |
| Accent/Energy | Fitness Orange | `#FF6B35` | **신규** - 에너지/동기부여 (CTA 강조용) |
| Background | Soft Gray | `#F4F4F4` | 기존 유지 |
| Dark BG | Deep Black | `#0E0E0E` | 기존 유지 |

> **Fitness Orange(`#FF6B35`)**: 홈 히어로 그라데이션, 운동 관련 강조에만 사용.
> 전체를 바꾸는 게 아니라, 포인트 악센트로 활력감 부여.

---

## Step 0: 하단 네비게이터 가시성 수정 + 위치 조정 (긴급)

**문제:**
1. 현재 `liquid_glass_bottom_bar`의 기본 회색 글래스가 배경과 구분이 안 됨
2. 네비게이터가 콘텐츠에 너무 가까움 (마진 부족)

**파일:**
- `lib/presentation/widgets/common/liquid_glass_nav_bar.dart` (신규)
- `lib/presentation/screens/member/member_shell.dart`
- `lib/presentation/screens/trainer/trainer_shell.dart`
- `pubspec.yaml` (패키지 제거)

**해결: 커스텀 Liquid Glass Nav Bar 구현**

패키지 대신 `GlassContainer` 기반 커스텀 네비게이션 바:

```dart
// lib/presentation/widgets/common/liquid_glass_nav_bar.dart
class LiquidGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LiquidGlassNavItem> items;
}

class LiquidGlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}
```

구현 세부사항:
- `ClipRRect` + `BackdropFilter(blur: 20)` 기반
- **Light: `Colors.white.withOpacity(0.92)`** + border `Colors.white.withOpacity(0.6)` → 가시성 확보
- **Dark: `Colors.black.withOpacity(0.7)`** + border `Colors.white.withOpacity(0.15)` → 가시성 확보
- 활성 탭: `AnimatedContainer` + PAL Blue 배경 pill (opacity 0.12) + 아이콘/라벨 PAL Blue
- 비활성: gray400 아이콘 + gray500 라벨
- **플로팅 마진: `EdgeInsets.fromLTRB(16, 0, 16, 24)`** ← 하단 24px로 충분히 띄움
- `borderRadius: 32` (더 둥글게)
- SafeArea 하단 고려
- Badge: Flutter 기본 `Badge` 위젯 활용

---

## Step 1: FAB 버튼 하단 네비 겹침 수정 (긴급)

**문제:** 기록추가, 일정추가, AI분석 FAB 버튼이 Liquid Glass 네비바와 겹침

**영향 받는 파일 (4개):**

### 1a. member_records_screen.dart - 기록 추가 FAB
**현재:** `Positioned(right: 16, bottom: 16)` → 네비바 뒤에 숨김
**수정:**
```dart
Positioned(
  right: 16,
  bottom: 110,  // 네비바 높이(74) + 마진(24) + 여유(12)
)
```

### 1b. member_calendar_screen.dart - 일정 추가 FAB
**현재:** `floatingActionButton: FloatingActionButton(...)` → Scaffold 기본 위치
**수정:** `floatingActionButtonLocation: FloatingActionButtonLocation.endFloat` 유지하되 padding 추가
```dart
floatingActionButton: Padding(
  padding: const EdgeInsets.only(bottom: 90),  // 네비바 공간 확보
  child: FloatingActionButton(...)
)
```

### 1c. member_diet_screen.dart - AI 분석 FAB
**현재:** `floatingActionButton: FloatingActionButton.extended(...)` → 네비바와 겹침
**수정:** 동일 패턴으로 bottom padding 90px 추가

### 1d. member_inbody_screen.dart - InBody 스캔 FAB
**현재:** `floatingActionButton: FloatingActionButton.extended(...)`
**수정:** 동일 패턴

### 1e. workout_log_screen.dart - 운동 추가 FAB
**현재:** `floatingActionButton: FloatingActionButton.extended(...)`
**수정:** 동일 패턴

**공통 토큰 추가 (app_tokens.dart):**
```dart
abstract class AppNavGlass {
  // ... 기존 토큰 ...

  /// FAB 하단 패딩 (네비바 겹침 방지)
  static const double fabBottomPadding = 90.0;
}
```

---

## Step 2: "내 기록" 헤더 폰트 + 탭 계층 구분 개선

**문제:**
1. "내 기록" 제목이 `titleLarge` + `bold` → 너무 크고 올드한 느낌
2. 상위 탭(체성분/운동기록/서명기록)과 하위 필터(체중/골격근량/체지방률/전체)가 동일한 스타일
   - 둘 다 `surfaceContainerHighest.withOpacity(0.5)` 배경
   - 둘 다 `primary` 색상 인디케이터
   - 둘 다 `borderRadius: 10`
   - 크기만 살짝 차이 → 사용자 혼란

**파일:** `lib/presentation/screens/member/member_records_screen.dart`

### 2a. 헤더 폰트 모던화
```dart
// Before
style: theme.textTheme.titleLarge?.copyWith(
  fontWeight: FontWeight.bold,
  color: colorScheme.onSurface,
),

// After - Toss 스타일 (더 가벼운 웨이트 + 적절한 크기)
style: TextStyle(
  fontSize: 22,  // titleLarge(26)보다 작게
  fontWeight: FontWeight.w700,
  letterSpacing: -0.3,  // 약간 좁은 자간 = 모던
  color: colorScheme.onSurface,
),
```

### 2b. 상위 탭 (체성분/운동기록/서명기록) - 명확한 탭 바 스타일
```dart
// Before: 둥근 pill 형태 (하위 필터와 동일)
color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
borderRadius: AppRadius.mdBorderRadius,
indicator: BoxDecoration(color: colorScheme.primary, borderRadius: 10)

// After: 밑줄 형태로 변경 → 탭 바 역할 명확화
// Container 배경 제거, 대신 하단 밑줄 인디케이터
TabBar(
  indicator: UnderlineTabIndicator(
    borderSide: BorderSide(color: AppColors.primary, width: 3),
    borderRadius: BorderRadius.circular(2),
  ),
  labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
  labelColor: AppColors.primary,
  unselectedLabelColor: AppColors.gray400,
  dividerColor: Colors.transparent,
)
```

### 2c. 하위 필터 (체중/골격근량/체지방률/전체) - 작은 칩 스타일 유지
```dart
// 현재 SegmentedButton - 스타일은 유지하되 크기 축소 + 색상 차별화
SegmentedButton<String>(
  style: SegmentedButton.styleFrom(
    backgroundColor: Colors.transparent,
    selectedBackgroundColor: AppColors.primary.withOpacity(0.1),  // 연한 파란 배경 (기존: 불투명 파란)
    selectedForegroundColor: AppColors.primary,  // 파란 텍스트 (기존: 흰색)
    foregroundColor: AppColors.gray400,
    side: BorderSide.none,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),  // 더 작은 글꼴
    minimumSize: Size(0, 36),  // 높이 축소
  ),
)
```

**시각적 계층 결과:**
| 요소 | 스타일 | 크기 | 색상 |
|------|--------|------|------|
| 상위 탭 | 밑줄 인디케이터 | 16px, w700 | Primary Blue 밑줄 |
| 하위 필터 | pill/칩 배경 | 13px, w500 | 연한 Blue 배경 + Blue 텍스트 |

→ **명확한 계층 구분**: 탭(네비게이션) vs 필터(데이터 뷰)

---

## Step 3: AppDialog 글래스 업그레이드

**파일:** `lib/presentation/widgets/common/app_dialog.dart`

**현재:** `BackdropFilter(blur: 10)` + 불투명 `colorScheme.surface` 배경
**변경:** 반투명 글래스 배경

### _DialogContainer 변경
```dart
// Before
color: Theme.of(context).colorScheme.surface,

// After
color: isDark
    ? Colors.black.withOpacity(0.78)
    : Colors.white.withOpacity(0.9),
border: Border.all(
  color: isDark
      ? Colors.white.withOpacity(0.1)
      : Colors.white.withOpacity(0.5),
  width: 0.5,
),
```

blur sigma: 10 → 16 으로 증가

### _InputDialogContent 동일 변경

---

## Step 4: AppBottomSheet 글래스 업그레이드

**파일:** `lib/presentation/widgets/common/app_bottom_sheet.dart`

**현재:** `BackdropFilter(blur: 10)` + 불투명 `colorScheme.surface` 배경

### _BottomSheetContent 변경
```dart
// Before
color: backgroundColor,  // colorScheme.surface (불투명)

// After
color: isDark
    ? Colors.black.withOpacity(0.8)
    : Colors.white.withOpacity(0.92),
```

blur sigma: 10 → 20 으로 증가

---

## Step 5: AppSnackbar 글래스 업그레이드

**파일:** `lib/presentation/widgets/common/app_snackbar.dart`

```dart
// Before
backgroundColor: const Color(0xFF333333),

// After
backgroundColor: const Color(0xFF333333).withOpacity(0.88),
```

---

## 적용하지 않는 영역 (명시적 제외)

| 위젯 | 제외 이유 |
|------|----------|
| `AppCard` (standard) | 리스트에 반복 렌더링 → 성능 + 시각적 피로 |
| `AppTextField` | BackdropFilter가 입력 포커스와 충돌 |
| `AppButton` | 탭 어포던스가 중요 → 불투명이 명확 |
| `AppListTile` | 리스트 반복 → 성능 |
| `MemberCard` | Slidable + 리스트 반복 |
| 홈 히어로 섹션 | 검토 후 선택적 적용 (Step 0~5 완료 후 판단) |

---

## 수정 파일 요약

### 필수 수정 (12개 파일)

| Step | 파일 | 변경 내용 |
|------|------|----------|
| 0 | `pubspec.yaml` | `liquid_glass_bottom_bar` 제거 |
| 0 | `lib/core/theme/app_tokens.dart` | `AppNavGlass` 토큰 업데이트 (margin, fabBottomPadding 등) |
| 0 | `lib/presentation/widgets/common/liquid_glass_nav_bar.dart` | **신규** 커스텀 글래스 네비 바 |
| 0 | `lib/presentation/screens/member/member_shell.dart` | 패키지 → 커스텀 네비바 교체 |
| 0 | `lib/presentation/screens/trainer/trainer_shell.dart` | 패키지 → 커스텀 네비바 교체 |
| 1 | `lib/presentation/screens/member/member_records_screen.dart` | FAB 위치 조정 + 헤더 폰트 + 탭 계층 구분 |
| 1 | `lib/presentation/screens/member/member_calendar_screen.dart` | FAB bottom padding |
| 1 | `lib/presentation/screens/member/member_diet_screen.dart` | FAB bottom padding |
| 1 | `lib/presentation/screens/member/member_inbody_screen.dart` | FAB bottom padding |
| 1 | `lib/presentation/screens/member/workout_log_screen.dart` | FAB bottom padding |
| 3 | `lib/presentation/widgets/common/app_dialog.dart` | 글래스 배경 |
| 4 | `lib/presentation/widgets/common/app_bottom_sheet.dart` | 글래스 배경 |
| 5 | `lib/presentation/widgets/common/app_snackbar.dart` | 반투명 배경 |

---

## 기대 효과

1. **네비게이터 가시성 해결** — 흰색 반투명 0.92 + blur 20 → 확실히 보임
2. **네비게이터 위치 개선** — 하단 24px 마진 → 콘텐츠와 충분한 간격
3. **FAB 겹침 해소** — 모든 FAB에 bottom 90px 패딩 → 네비바 위에 표시
4. **탭 계층 명확화** — 상위(밑줄) vs 하위(칩) → 시각적 계층 구분
5. **헤더 모던화** — 작은 폰트 + 좁은 자간 → Toss 스타일
6. **오버레이 글래스 통일** — 다이얼로그/바텀시트/스낵바 글래스 적용
7. **패키지 의존성 제거** — 커스텀 구현으로 완전 제어 가능
