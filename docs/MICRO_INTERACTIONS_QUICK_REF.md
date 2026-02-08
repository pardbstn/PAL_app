# 마이크로 인터렉션 빠른 참조

## 🎯 위젯 선택 가이드

### 내가 만들려는 것은...

#### 버튼
```dart
// 주요 액션 버튼
PremiumTapFeedback(
  onTap: () => save(),
  child: ElevatedButton(...),
)

// 아이콘 버튼
PremiumInkEffect(
  onTap: () => action(),
  child: IconButton(...),
)
```

#### 카드
```dart
// 모바일 카드
PremiumTapFeedback(
  onTap: () => navigate(),
  child: Card(...),
)

// 웹 카드 (호버 효과)
PremiumHoverEffect(
  onTap: () => navigate(),
  glowIntensity: 0.5,
  child: Card(...),
)

// 웹 프리미엄 카드 (3D)
InteractiveCard(
  onTap: () => details(),
  child: Card(...),
)
```

#### 리스트
```dart
// 일반 리스트 아이템
PremiumTapFeedback(
  onTap: () => view(),
  child: ListTile(...),
)

// 삭제 가능한 아이템
SwipeDeleteFeedback(
  onDelete: () => remove(),
  child: ListTile(...),
)

// 컨텍스트 메뉴가 있는 아이템
LongPressFeedback(
  onTap: () => view(),
  onLongPress: () => menu(),
  child: ListTile(...),
)
```

#### 토글/스위치
```dart
// 커스텀 토글
ToggleFeedback(
  value: enabled,
  onChanged: (v) => setState(() => enabled = v),
  child: CustomSwitch(...),
)
```

---

## 📖 Import

```dart
import 'package:pal/presentation/widgets/animated/micro_interactions.dart';
```

---

## 🚀 빠른 사용법

### 1. PremiumTapFeedback (가장 많이 사용)
```dart
PremiumTapFeedback(
  onTap: () {},              // 필수
  child: Widget(),           // 필수
  // 선택적
  onLongPress: () {},
  scaleFactor: 0.97,
  enableHaptic: true,
  enableShadow: true,
)
```

### 2. PremiumHoverEffect (웹 전용)
```dart
PremiumHoverEffect(
  onTap: () {},
  child: Widget(),
  // 선택적
  hoverScale: 1.02,
  glowColor: Colors.blue,
  glowIntensity: 0.3,
)
```

### 3. PremiumInkEffect (작은 버튼)
```dart
PremiumInkEffect(
  onTap: () {},
  child: Widget(),
  // 선택적
  borderRadius: BorderRadius.circular(12),
  enableRipple: true,
)
```

### 4. SwipeDeleteFeedback (삭제)
```dart
SwipeDeleteFeedback(
  onDelete: () {},
  child: Widget(),
  // 선택적
  deleteColor: Colors.red,
)
```

### 5. ToggleFeedback (토글)
```dart
ToggleFeedback(
  value: bool,
  onChanged: (v) {},
  child: Widget(),
)
```

### 6. LongPressFeedback (롱프레스)
```dart
LongPressFeedback(
  onTap: () {},
  onLongPress: () {},
  child: Widget(),
  // 선택적
  longPressDuration: Duration(milliseconds: 500),
)
```

### 7. InteractiveCard (웹 3D)
```dart
InteractiveCard(
  onTap: () {},
  child: Widget(),
  // 선택적
  enableTilt: true,
  enableReflection: true,
  maxTiltAngle: 10.0,
)
```

---

## 🎨 커스터마이징

### 강도 조절
```dart
// 강한 피드백
PremiumTapFeedback(
  scaleFactor: 0.95,     // 더 작게
  enableHaptic: true,
  enableShadow: true,
  child: widget,
)

// 약한 피드백
PremiumTapFeedback(
  scaleFactor: 0.98,     // 덜 작게
  enableHaptic: false,
  enableShadow: false,
  child: widget,
)
```

### 브랜드 컬러
```dart
PremiumHoverEffect(
  glowColor: Theme.of(context).colorScheme.primary,
  glowIntensity: 0.5,
  child: widget,
)
```

### 플랫폼 분기
```dart
// 웹/데스크톱: 호버
// 모바일: 탭
final interactive = (kIsWeb || Platform.isMacOS)
    ? PremiumHoverEffect(child: widget)
    : PremiumTapFeedback(child: widget);
```

---

## ⚡ 성능 팁

### DO ✅
```dart
// RepaintBoundary는 자동 적용됨
PremiumTapFeedback(child: widget)

// const 사용
const PremiumTapFeedback(
  scaleFactor: 0.97,
  child: MyStaticWidget(),
)

// 리스트에서 간단한 위젯 사용
ListView.builder(
  itemBuilder: (_, i) => PremiumTapFeedback(...),
)
```

### DON'T ❌
```dart
// 중복 효과 피하기
PremiumTapFeedback(
  child: PremiumHoverEffect(...),  // 중복!
)

// 리스트에서 과한 효과 피하기
ListView.builder(
  itemBuilder: (_, i) => InteractiveCard(...),  // 너무 무거움
)
```

---

## 🐛 디버깅

### 햅틱이 안 됨
```dart
// 햅틱 비활성화
PremiumTapFeedback(
  enableHaptic: false,
  child: widget,
)
```

### 호버가 안 보임
```dart
// 모바일에서는 호버 불가
// PremiumTapFeedback 사용
```

### 애니메이션 끊김
```dart
// itemExtent 추가
ListView.builder(
  itemExtent: 80,  // 고정 높이
  itemBuilder: ...,
)
```

---

## 📏 접근성

### 최소 터치 영역
```dart
SizedBox(
  width: 48,   // 최소 48
  height: 48,  // 최소 48
  child: PremiumTapFeedback(...),
)
```

### Semantics
```dart
Semantics(
  button: true,
  label: '추가',
  child: PremiumTapFeedback(...),
)
```

---

## 📱 햅틱 강도

| 상황 | 햅틱 |
|------|------|
| 탭 다운 | selectionClick (약함) |
| 탭 업 | lightImpact (중간) |
| 롱프레스 | mediumImpact (강함) |
| 삭제 | heavyImpact (매우 강함) |

---

## 🎯 일반적인 패턴

### 로그인 버튼
```dart
PremiumTapFeedback(
  onTap: _handleLogin,
  child: ElevatedButton(
    onPressed: null,  // onTap에서 처리
    child: Text('로그인'),
  ),
)
```

### 프로덕트 카드 (웹)
```dart
PremiumHoverEffect(
  onTap: () => Navigator.push(...),
  glowIntensity: 0.4,
  child: Card(
    child: ProductInfo(),
  ),
)
```

### 삭제 가능한 메모
```dart
SwipeDeleteFeedback(
  onDelete: () async {
    final confirm = await showDialog(...);
    if (confirm) deleteNote();
  },
  child: NoteCard(),
)
```

### 설정 스위치
```dart
ToggleFeedback(
  value: _notificationsEnabled,
  onChanged: (v) => setState(() => _notificationsEnabled = v),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _notificationsEnabled ? Colors.blue : Colors.grey,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(_notificationsEnabled ? Icons.check : Icons.close),
  ),
)
```

---

## 🔗 더 많은 정보

- **전체 가이드**: `/docs/MICRO_INTERACTIONS_GUIDE.md`
- **구현 요약**: `/docs/MICRO_INTERACTIONS_SUMMARY.md`
- **변경 로그**: `/CHANGELOG_MICRO_INTERACTIONS.md`
- **데모 화면**: `/lib/presentation/screens/examples/micro_interactions_demo.dart`

---

## 📊 치트시트

| 원하는 것 | 위젯 |
|----------|------|
| 버튼 탭 피드백 | PremiumTapFeedback |
| 웹 호버 효과 | PremiumHoverEffect |
| 리플 효과 | PremiumInkEffect |
| 3D 카드 | InteractiveCard |
| 토글 피드백 | ToggleFeedback |
| 스와이프 삭제 | SwipeDeleteFeedback |
| 롱프레스 메뉴 | LongPressFeedback |
| 간단한 탭 | TapFeedback (레거시) |
| 간단한 호버 | HoverEffect (레거시) |

---

**빠른 참조 v1.0** | 2026-02-01
