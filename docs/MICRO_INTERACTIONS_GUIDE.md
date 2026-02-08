# 마이크로 인터렉션 가이드

PAL 앱의 프리미엄 터치 피드백 및 마이크로 인터렉션 사용 가이드

## 목차
- [개요](#개요)
- [프리미엄 인터렉션](#프리미엄-인터렉션)
- [기존 위젯 (하위 호환)](#기존-위젯-하위-호환)
- [성능 최적화](#성능-최적화)
- [접근성](#접근성)
- [베스트 프랙티스](#베스트-프랙티스)

---

## 개요

모든 마이크로 인터렉션 위젯은 `/lib/presentation/widgets/animated/micro_interactions.dart`에 정의되어 있습니다.

### 철학
- **프리미엄한 느낌**: 스프링 애니메이션, 그림자, 글로우 효과
- **햅틱 피드백**: iOS/Android 네이티브 햅틱 지원
- **Impeller 최적화**: RepaintBoundary로 불필요한 리페인트 방지
- **접근성**: 최소 48x48 터치 영역, Semantics 지원

---

## 프리미엄 인터렉션

### 1. PremiumTapFeedback

**용도**: 버튼, 카드, 리스트 아이템 등 모든 탭 가능한 요소

**특징**:
- 스프링 애니메이션 (Curves.easeOutBack)
- 그림자 변화 (누를 때 그림자 감소)
- 햅틱 피드백 (탭 다운/업/롱프레스)
- 롱프레스 지원

**기본 사용법**:
```dart
PremiumTapFeedback(
  onTap: () => print('탭!'),
  child: Container(
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text('탭하세요'),
  ),
)
```

**고급 사용법**:
```dart
PremiumTapFeedback(
  onTap: () => _handleTap(),
  onLongPress: () => _showContextMenu(),
  scaleFactor: 0.95,              // 기본 0.97 (더 작게: 0.95, 덜 작게: 0.98)
  enableHaptic: true,              // 햅틱 피드백 활성화
  enableShadow: true,              // 그림자 변화 활성화
  duration: Duration(milliseconds: 150),
  child: YourWidget(),
)
```

**언제 사용**:
- ✅ 주요 버튼 (CTA)
- ✅ 카드 전체 영역
- ✅ 리스트 아이템
- ✅ 롱프레스 메뉴가 필요한 곳
- ❌ 매우 작은 아이콘 버튼 (PremiumInkEffect 사용)

---

### 2. PremiumHoverEffect

**용도**: 웹/데스크톱 호버 효과

**특징**:
- 마우스 오버 시 스케일 + 그림자 + 글로우
- 부드러운 전환 애니메이션
- 브랜드 컬러 글로우 효과

**기본 사용법**:
```dart
PremiumHoverEffect(
  onTap: () => _navigate(),
  child: ProductCard(),
)
```

**고급 사용법**:
```dart
PremiumHoverEffect(
  onTap: () => _handleClick(),
  hoverScale: 1.03,                          // 기본 1.02
  glowColor: Theme.of(context).primaryColor, // 글로우 색상
  glowIntensity: 0.5,                        // 0.0 ~ 1.0
  enableElevation: true,                     // 그림자 활성화
  child: YourWidget(),
)
```

**언제 사용**:
- ✅ 웹/데스크톱 카드
- ✅ 내비게이션 메뉴 아이템
- ✅ 프로덕트 그리드
- ❌ 모바일 전용 화면

---

### 3. PremiumInkEffect

**용도**: Material 리플 효과가 필요한 곳

**특징**:
- 네이티브 InkWell 개선
- 커스터마이즈 가능한 리플/하이라이트 색상
- 리플 효과 켜기/끄기

**기본 사용법**:
```dart
PremiumInkEffect(
  onTap: () => _action(),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('버튼'),
  ),
)
```

**고급 사용법**:
```dart
PremiumInkEffect(
  onTap: () => _handleTap(),
  borderRadius: BorderRadius.circular(12),
  splashColor: Colors.blue.withOpacity(0.2),
  highlightColor: Colors.blue.withOpacity(0.1),
  enableRipple: true,               // false면 리플 없이 하이라이트만
  child: YourWidget(),
)
```

**언제 사용**:
- ✅ 아이콘 버튼
- ✅ 리스트 타일
- ✅ 작은 버튼 (탭 영역이 명확한 곳)
- ❌ 카드 전체 (PremiumTapFeedback 사용)

---

### 4. InteractiveCard

**용도**: 웹/데스크톱 3D 인터랙티브 카드

**특징**:
- 마우스 위치에 따라 3D 기울기
- 반사 효과 (그라데이션 오버레이)
- 원근감 있는 Transform

**기본 사용법**:
```dart
InteractiveCard(
  onTap: () => _viewDetails(),
  child: ProductCard(),
)
```

**고급 사용법**:
```dart
InteractiveCard(
  onTap: () => _handleClick(),
  enableTilt: true,          // 3D 기울기
  enableReflection: true,    // 반사 효과
  maxTiltAngle: 15.0,        // 최대 기울기 각도 (도)
  child: YourWidget(),
)
```

**언제 사용**:
- ✅ 웹 히어로 카드
- ✅ 프리미엄 프로덕트 카드
- ✅ 포트폴리오 아이템
- ❌ 모바일 (효과가 보이지 않음)
- ❌ 리스트 뷰 (과도한 효과)

---

### 5. ToggleFeedback

**용도**: 스위치, 체크박스 등 토글 가능한 요소

**특징**:
- 토글 시 스케일 애니메이션
- on/off에 따라 다른 햅틱 강도
- 부드러운 전환

**사용법**:
```dart
bool _isEnabled = false;

ToggleFeedback(
  value: _isEnabled,
  onChanged: (value) => setState(() => _isEnabled = value),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _isEnabled ? Colors.blue : Colors.grey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(_isEnabled ? Icons.check : Icons.close),
  ),
)
```

**언제 사용**:
- ✅ 커스텀 스위치
- ✅ 토글 버튼
- ✅ 선택 가능한 칩
- ❌ 기본 Switch 위젯 (이미 피드백 있음)

---

### 6. SwipeDeleteFeedback

**용도**: 리스트 아이템 슬라이드 삭제

**특징**:
- 왼쪽으로 스와이프하여 삭제
- 삭제 임계값 (100px)
- 진행도에 따른 배경 색상 변화
- 햅틱 피드백

**사용법**:
```dart
SwipeDeleteFeedback(
  onDelete: () {
    setState(() => items.removeAt(index));
  },
  deleteColor: Theme.of(context).colorScheme.error,
  child: ListTile(
    title: Text('Item'),
  ),
)
```

**언제 사용**:
- ✅ 삭제 가능한 리스트
- ✅ 장바구니 아이템
- ✅ 북마크 목록
- ❌ 실행 취소가 없는 중요한 삭제 (다이얼로그 사용)

---

### 7. LongPressFeedback

**용도**: 롱프레스 진행 표시

**특징**:
- 롱프레스 진행률을 시각적으로 표시
- 완료 시 햅틱
- 일반 탭과 롱프레스 모두 지원

**사용법**:
```dart
LongPressFeedback(
  onTap: () => _quickAction(),
  onLongPress: () => _showMenu(),
  longPressDuration: Duration(milliseconds: 500),
  child: Container(
    padding: EdgeInsets.all(24),
    child: Text('탭 또는 길게 누르기'),
  ),
)
```

**언제 사용**:
- ✅ 컨텍스트 메뉴 트리거
- ✅ 드래그 앤 드롭 시작
- ✅ 듀얼 액션 버튼
- ❌ 단순 탭만 필요한 곳

---

## 기존 위젯 (하위 호환)

### TapFeedback
간단한 탭 스케일 효과. 기존 코드와의 호환성을 위해 유지.

```dart
TapFeedback(
  onTap: () => _action(),
  scaleFactor: 0.97,
  child: YourWidget(),
)
```

### HoverEffect
간단한 호버 효과. 기존 코드와의 호환성을 위해 유지.

```dart
HoverEffect(
  onTap: () => _action(),
  scale: 1.02,
  child: YourWidget(),
)
```

**마이그레이션 팁**:
- `TapFeedback` → `PremiumTapFeedback` (햅틱 + 그림자)
- `HoverEffect` → `PremiumHoverEffect` (글로우 + 고급 그림자)

---

## 성능 최적화

### 1. RepaintBoundary
모든 프리미엄 위젯은 내부적으로 `RepaintBoundary`를 사용하여 리페인트 격리.

### 2. AnimationController Dispose
모든 컨트롤러는 자동으로 dispose됨. 추가 작업 불필요.

### 3. 리스트 뷰 최적화
```dart
// ❌ 나쁜 예: 모든 아이템에 InteractiveCard
ListView.builder(
  itemBuilder: (context, index) => InteractiveCard(...),
)

// ✅ 좋은 예: 간단한 PremiumTapFeedback
ListView.builder(
  itemBuilder: (context, index) => PremiumTapFeedback(...),
)
```

### 4. 중첩 피하기
```dart
// ❌ 나쁜 예: 중복 효과
PremiumTapFeedback(
  child: PremiumHoverEffect(  // 중복!
    child: Widget(),
  ),
)

// ✅ 좋은 예: 하나만 선택
PremiumTapFeedback(  // 모바일
  child: Widget(),
)

// 또는
PremiumHoverEffect(  // 데스크톱
  child: Widget(),
)
```

---

## 접근성

### 터치 영역
모든 인터렉티브 요소는 최소 48x48 픽셀을 보장하세요.

```dart
PremiumTapFeedback(
  onTap: () => _action(),
  child: SizedBox(
    width: 48,   // 최소 크기
    height: 48,
    child: Center(child: Icon(Icons.add)),
  ),
)
```

### Semantics
```dart
Semantics(
  button: true,
  label: '추가 버튼',
  child: PremiumTapFeedback(
    onTap: () => _add(),
    child: Icon(Icons.add),
  ),
)
```

### 햅틱 비활성화 옵션
사용자가 햅틱을 원하지 않을 수 있으므로 설정 제공 고려:

```dart
PremiumTapFeedback(
  enableHaptic: settingsController.enableHaptics,
  child: Widget(),
)
```

---

## 베스트 프랙티스

### 1. 플랫폼별 인터렉션
```dart
// 웹/데스크톱
if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
  return PremiumHoverEffect(child: card);
}

// 모바일
return PremiumTapFeedback(child: card);
```

### 2. 일관된 애니메이션 타이밍
```dart
// 전체 앱에서 동일한 duration 사용
const kTapDuration = Duration(milliseconds: 150);
const kHoverDuration = Duration(milliseconds: 200);

PremiumTapFeedback(
  duration: kTapDuration,
  child: Widget(),
)
```

### 3. 브랜드 컬러 활용
```dart
PremiumHoverEffect(
  glowColor: Theme.of(context).colorScheme.primary,
  glowIntensity: 0.4,
  child: Widget(),
)
```

### 4. 계층별 강도 조절
```dart
// 주요 액션: 강한 피드백
PremiumTapFeedback(
  scaleFactor: 0.95,
  enableHaptic: true,
  child: PrimaryButton(),
)

// 보조 액션: 약한 피드백
PremiumTapFeedback(
  scaleFactor: 0.98,
  enableShadow: false,
  child: SecondaryButton(),
)
```

### 5. 삭제 작업 확인
```dart
SwipeDeleteFeedback(
  onDelete: () async {
    // 확인 다이얼로그
    final confirmed = await showDialog(...);
    if (confirmed) {
      deleteItem();
    }
  },
  child: ListItem(),
)
```

---

## 예제 화면

전체 데모는 `/lib/presentation/screens/examples/micro_interactions_demo.dart`를 참고하세요.

```dart
import 'package:pal/presentation/screens/examples/micro_interactions_demo.dart';

// 네비게이션
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MicroInteractionsDemo(),
  ),
);
```

---

## 문제 해결

### 햅틱이 작동하지 않음
- iOS: Info.plist에 UIRequiredDeviceCapabilities 확인
- Android: AndroidManifest.xml에 VIBRATE 권한 추가

### 호버 효과가 보이지 않음
- 모바일에서는 호버가 없음 (PremiumTapFeedback 사용)
- 웹에서 터치 이벤트 대신 마우스 이벤트 확인

### 애니메이션이 끊김
- RepaintBoundary 확인
- 리스트 뷰에서 itemExtent 사용
- const 생성자 사용

---

## 참고 자료

- [Flutter 애니메이션 가이드](https://docs.flutter.dev/ui/animations)
- [Material Design 모션](https://m3.material.io/styles/motion)
- [Impeller 렌더링 엔진](https://docs.flutter.dev/perf/impeller)
