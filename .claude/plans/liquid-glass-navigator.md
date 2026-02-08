# iOS 26 Liquid Glass 하단 네비게이터 리디자인 플랜

## 목표
현재 불투명한 `NavigationBar` 기반 하단 네비게이터를 iOS 26 Liquid Glass 스타일의 프로스티드 글래스 네비게이터로 교체

## 현재 상태 분석

### member_shell.dart (5탭)
- 홈, 내 기록, 캘린더, 식단, 메시지
- 불투명 `Container` + `BoxDecoration` (border top)
- 표준 `NavigationBar` 위젯
- 메시지 탭에 `Badge` 위젯 (unread count)
- `AnimatedSwitcher`로 페이지 전환

### trainer_shell.dart (4탭)
- 홈, 회원, 캘린더, 메시지
- 동일한 불투명 구조
- 메시지 탭에 `Consumer` 감싼 `Badge` (리빌드 최적화)

### 공통 문제점
- `Scaffold.extendBody` 미설정 → 바디가 네비 바 뒤로 안 감
- 불투명 배경 → 글래스 효과 불가능

---

## 구현 방식: `liquid_glass_bottom_bar` 패키지 사용

### 패키지 선택 근거

| 방식 | 장점 | 단점 |
|------|------|------|
| **liquid_glass_bottom_bar (v0.0.6)** | Badge 내장, 드롭인 교체, API 심플, 애니메이션 내장 | 패키지 의존성 추가 |
| flutter_liquid_glass_plus | 위젯 종류 풍부 | 네비 바 전용 아님, 복잡 |
| 커스텀 BackdropFilter | 완전 제어 | 구현 복잡, Badge/애니메이션 직접 구현 필요 |

**결론: `liquid_glass_bottom_bar` 사용** — Badge 기본 지원, 드롭인 교체 가능, API가 현재 코드 구조와 1:1 대응

### 패키지 API (v0.0.6)

```dart
LiquidGlassBottomBar(
  items: [LiquidGlassBottomBarItem(icon, activeIcon, label, badge)],
  currentIndex: int,
  onTap: (index) => ...,
  height: 74.0,              // 라벨 있을 때
  margin: EdgeInsets.fromLTRB(12, 0, 12, 12),  // 플로팅 마진
  showLabels: true,
  activeColor: Color,         // 활성 탭 악센트
  barBlurSigma: 16,          // 바 배경 블러
  activeBlurSigma: 24,       // 활성 필(pill) 블러
)
```

---

## 단계별 구현 계획

### Step 1: 패키지 추가 + 디자인 토큰 업데이트

**파일: `pubspec.yaml`**
```yaml
dependencies:
  liquid_glass_bottom_bar: ^0.0.6
```

**파일: `lib/core/theme/app_tokens.dart`**
- 네비게이터 글래스 관련 토큰 추가:
```dart
/// Liquid Glass 네비게이터 토큰
abstract class AppNavGlass {
  static const double barBlurSigma = 16.0;
  static const double activeBlurSigma = 24.0;
  static const double height = 74.0;
  static const EdgeInsets margin = EdgeInsets.fromLTRB(12, 0, 12, 12);

  // 활성 탭 색상 (PAL Primary Blue)
  static const Color activeColor = Color(0xFF0064FF);        // Light
  static const Color activeColorDark = Color(0xFF4D9AFF);    // Dark
}
```

### Step 2: member_shell.dart 리팩터링

**변경 사항:**

1. `import 'package:liquid_glass_bottom_bar/liquid_glass_bottom_bar.dart';` 추가

2. `Scaffold` 설정 변경:
   ```dart
   Scaffold(
     extendBody: true,  // ← 추가 (글래스 효과 핵심)
     body: Container(...),  // 기존 유지
     bottomNavigationBar: LiquidGlassBottomBar(...),  // ← 교체
   )
   ```

3. `bottomNavigationBar` 전체 교체:
   - 기존: `Container` > `NavigationBar` > `NavigationDestination[]`
   - 변경: `LiquidGlassBottomBar` > `LiquidGlassBottomBarItem[]`

4. Badge 처리:
   - 기존: `Badge` 위젯으로 아이콘 감싸기
   - 변경: `LiquidGlassBottomBarItem(badge: unreadCount)` — 패키지 내장 Badge 사용

5. 다크모드 대응:
   ```dart
   activeColor: isDark ? AppNavGlass.activeColorDark : AppNavGlass.activeColor,
   ```

**변경 후 코드 구조:**
```dart
Scaffold(
  extendBody: true,
  body: Container(
    color: isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
    child: AnimatedSwitcher(...),  // 기존 유지
  ),
  bottomNavigationBar: LiquidGlassBottomBar(
    currentIndex: _calculateSelectedIndex(context),
    onTap: (index) => _onItemTapped(index, context),
    height: AppNavGlass.height,
    margin: AppNavGlass.margin,
    barBlurSigma: AppNavGlass.barBlurSigma,
    activeBlurSigma: AppNavGlass.activeBlurSigma,
    activeColor: isDark ? AppNavGlass.activeColorDark : AppNavGlass.activeColor,
    showLabels: true,
    items: [
      const LiquidGlassBottomBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: '홈',
      ),
      const LiquidGlassBottomBarItem(
        icon: Icons.fitness_center_outlined,
        activeIcon: Icons.fitness_center_rounded,
        label: '내 기록',
      ),
      const LiquidGlassBottomBarItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: '캘린더',
      ),
      const LiquidGlassBottomBarItem(
        icon: Icons.restaurant_outlined,
        activeIcon: Icons.restaurant_rounded,
        label: '식단',
      ),
      LiquidGlassBottomBarItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: '메시지',
        badge: unreadCount > 0 ? unreadCount : null,
      ),
    ],
  ),
)
```

**삭제되는 코드:**
- `Container` (decoration + border 감싸기)
- `NavigationBar` 위젯 전체
- `NavigationDestination` 위젯들
- `Badge` 위젯 (패키지 내장 badge로 대체)
- `indicatorColor`, `indicatorShape` 설정

### Step 3: trainer_shell.dart 리팩터링

**동일한 패턴 적용, 차이점만 기술:**

1. 4개 탭: 홈, 회원, 캘린더, 메시지

2. 메시지 Badge 처리:
   - 기존: `Consumer` 위젯으로 감싼 `Badge` (리빌드 최적화)
   - 변경: `ConsumerWidget`이므로 상위에서 `ref.watch` 후 `badge` 파라미터 전달
   - 트레이너 쉘도 `ConsumerWidget`이므로 member_shell과 동일하게 처리 가능

3. Consumer 최적화 유지 검토:
   - 현재 trainer_shell은 메시지 아이콘에만 `Consumer`를 감싸서 다른 탭의 불필요한 리빌드 방지
   - `LiquidGlassBottomBar`는 전체가 하나의 위젯이므로, `ref.watch(totalUnreadCountProvider)` 변경 시 전체 바가 리빌드됨
   - **그러나** 네비 바 리빌드 비용은 매우 낮으므로 허용 가능
   - member_shell과 동일한 패턴으로 통일 (코드 일관성 우선)

**변경 후 코드 구조:**
```dart
Scaffold(
  extendBody: true,
  body: Container(...),
  bottomNavigationBar: LiquidGlassBottomBar(
    currentIndex: _calculateSelectedIndex(context),
    onTap: (index) => _onItemTapped(index, context),
    height: AppNavGlass.height,
    margin: AppNavGlass.margin,
    barBlurSigma: AppNavGlass.barBlurSigma,
    activeBlurSigma: AppNavGlass.activeBlurSigma,
    activeColor: isDark ? AppNavGlass.activeColorDark : AppNavGlass.activeColor,
    showLabels: true,
    items: [
      const LiquidGlassBottomBarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: '홈',
      ),
      const LiquidGlassBottomBarItem(
        icon: Icons.people_outlined,
        activeIcon: Icons.people_rounded,
        label: '회원',
      ),
      const LiquidGlassBottomBarItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: '캘린더',
      ),
      LiquidGlassBottomBarItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: '메시지',
        badge: unreadCount > 0 ? unreadCount : null,
      ),
    ],
  ),
)
```

### Step 4: 테마 연동 (app_theme.dart)

**확인/조정 사항:**
- `NavigationBarThemeData` 가 더 이상 사용되지 않으므로 제거 가능
- 단, 다른 곳에서 표준 `NavigationBar`를 사용하는지 확인 필요 → 사용하지 않으면 제거

### Step 5: 빌드 검증

```bash
flutter pub get
flutter analyze
flutter run  # 시뮬레이터에서 시각적 확인
```

**검증 항목:**
- [ ] 글래스 효과가 콘텐츠 뒤로 비쳐 보이는지
- [ ] 활성 탭 필(pill) 애니메이션 작동하는지
- [ ] 메시지 Badge 표시되는지 (unread > 0일 때)
- [ ] 다크모드에서도 글래스 효과 적절한지
- [ ] 탭 전환 시 라우팅 정상 작동하는지
- [ ] 중복 탭 방지 로직 유지되는지
- [ ] extendBody로 인한 콘텐츠 하단 잘림 없는지
  - 필요시 각 페이지 하단에 `SizedBox(height: AppNavGlass.height + 12)` 추가

---

## 영향 범위

### 수정 파일 (3개)
| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `liquid_glass_bottom_bar: ^0.0.6` 추가 |
| `lib/core/theme/app_tokens.dart` | `AppNavGlass` 토큰 클래스 추가 |
| `lib/presentation/screens/member/member_shell.dart` | 네비 바 전체 교체 |
| `lib/presentation/screens/trainer/trainer_shell.dart` | 네비 바 전체 교체 |

### 선택적 수정 (검증 후 판단)
| 파일 | 조건 | 변경 내용 |
|------|------|----------|
| `lib/core/theme/app_theme.dart` | NavigationBarTheme 미사용 시 | 테마 설정 제거 |
| 각 페이지 스크린 | 하단 잘림 발생 시 | 하단 SafeArea/패딩 추가 |

### 미수정 (기능 보존)
- `_calculateSelectedIndex()` — 라우팅 로직 그대로 유지
- `_onItemTapped()` — GoRouter 네비게이션 그대로 유지
- `AnimatedSwitcher` — 페이지 전환 애니메이션 유지
- 전체 라우팅 구조 — 변경 없음

---

## 리스크 & 대응

| 리스크 | 확률 | 대응 |
|--------|------|------|
| extendBody로 콘텐츠 하단 잘림 | 중 | 각 페이지 하단 패딩 추가 |
| 패키지 badge가 99+ 표시 미지원 | 낮 | 패키지 소스 확인 후 커스텀 처리 |
| 다크모드에서 글래스 효과 약함 | 낮 | barBlurSigma 값 조정 |
| 패키지 Flutter SDK 호환성 | 낮 | v0.0.6이 SDK ^3.10 지원 확인 |

---

## 예상 결과

### Before (현재)
- 불투명 흰색/검정 배경의 네비게이션 바
- 상단 border 구분선
- Material 3 `NavigationBar` 스타일

### After (목표)
- 반투명 프로스티드 글래스 배경 (blur σ=16)
- 활성 탭에 글래스 필(pill) 애니메이션 (blur σ=24)
- 화면 콘텐츠가 바 뒤로 비쳐 보이는 효과
- 하단/좌우 12px 마진으로 플로팅 느낌
- iOS 26 Liquid Glass와 유사한 프리미엄 시각 효과
