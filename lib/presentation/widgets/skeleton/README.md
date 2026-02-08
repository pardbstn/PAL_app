# PAL 스켈레톤 로딩 시스템

## 개요

PAL 앱의 스켈레톤 로딩 시스템은 두 가지 방식을 지원합니다:

1. **Skeletonizer 기반** (권장): 실제 위젯을 그대로 사용하면서 로딩 상태 표시
2. **Shimmer 기반** (레거시): 수동으로 스켈레톤 UI 구성

## Skeletonizer 기반 컴포넌트 (권장)

### 1. AppSkeletonizer - 기본 래퍼

실제 UI 위젯을 그대로 사용하면서 로딩 상태만 전환합니다.

```dart
AppSkeletonizer(
  isLoading: isLoading,
  child: Card(
    child: ListTile(
      leading: CircleAvatar(child: Icon(Icons.person)),
      title: Text('홍길동'),
      subtitle: Text('010-1234-5678'),
      trailing: Icon(Icons.chevron_right),
    ),
  ),
)
```

#### 주요 파라미터

| 파라미터 | 타입 | 설명 | 기본값 |
|---------|------|------|--------|
| `isLoading` | `bool` | 로딩 상태 여부 | required |
| `child` | `Widget` | 스켈레톤으로 표시할 위젯 | required |
| `ignoreContainers` | `bool` | 컨테이너 요소 무시 | `false` |
| `containersColor` | `bool` | 컨테이너 배경색 유지 | `false` |
| `effect` | `PaintingEffect?` | 애니메이션 효과 | `ShimmerEffect` |

#### 애니메이션 효과

- **ShimmerEffect** (기본): 부드러운 shimmer 애니메이션
- **PulseEffect**: 맥박 효과
- **Custom**: 직접 구현 가능

### 2. 사전 제작된 스켈레톤 컴포넌트

#### SettingsScreenSkeleton
설정 화면 전체 스켈레톤 (프로필 + 리스트 그룹)

```dart
// 로딩 중
const SettingsScreenSkeleton()

// 데이터 로드 완료
ListView(children: [...])
```

#### MemberDetailSkeleton
회원 상세 화면 스켈레톤 (헤더 + 탭 + 차트)

```dart
// 로딩 중
const MemberDetailSkeleton()

// 데이터 로드 완료
Column(children: [...])
```

#### ListItemSkeleton
리스트 아이템 스켈레톤

```dart
ListItemSkeleton(
  hasLeading: true,    // 왼쪽 아이콘/아바타
  hasSubtitle: true,   // 부제목
  hasTrailing: true,   // 오른쪽 아이콘
)
```

#### CardSkeleton
카드형 스켈레톤

```dart
CardSkeleton(
  width: 150,   // 선택사항
  height: 120,  // 선택사항
)
```

#### ProfileHeaderSkeleton
프로필 헤더 스켈레톤

```dart
ProfileHeaderSkeleton(
  avatarSize: 80,  // 아바타 크기
)
```

#### ChartSkeleton
차트 스켈레톤

```dart
ChartSkeleton(
  height: 250,  // 차트 높이
)
```

## Riverpod AsyncValue 패턴

AsyncValue의 `when` 메서드와 함께 사용하는 것을 권장합니다:

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(myDataProvider);

    return dataAsync.when(
      loading: () => const MemberDetailSkeleton(),
      error: (error, stack) => ErrorWidget(error),
      data: (data) => ActualContent(data),
    );
  }
}
```

## 다크모드 지원

모든 스켈레톤 컴포넌트는 자동으로 다크모드를 감지하여 적절한 색상을 적용합니다:

- **라이트 모드**: 밝은 회색 계열
- **다크 모드**: 어두운 회색 계열

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final baseColor = isDark ? Color(0xFF424242) : Color(0xFFE0E0E0);
final highlightColor = isDark ? Color(0xFF616161) : Color(0xFFF5F5F5);
```

## 성능 최적화

### Impeller 렌더링 최적화

모든 `AppSkeletonizer`는 `RepaintBoundary`로 감싸져 있어 Impeller 렌더링 엔진 최적화를 지원합니다:

```dart
RepaintBoundary(
  child: Skeletonizer(...)
)
```

### 애니메이션 성능

- Shimmer 효과 duration: 1500ms (부드러운 느낌)
- GPU 가속 애니메이션 사용
- 불필요한 rebuild 방지

## 레거시 Shimmer 컴포넌트 (하위 호환성)

기존 코드와의 호환성을 위해 계속 사용 가능합니다:

### SkeletonContainer
Shimmer 효과를 적용하는 래퍼

```dart
SkeletonContainer(
  child: Column(
    children: [
      SkeletonCircle(size: 64),
      SkeletonLine(width: 200, height: 20),
    ],
  ),
)
```

### SkeletonBox
기본 박스 형태 스켈레톤

```dart
SkeletonBox(
  width: 100,
  height: 50,
  borderRadius: 8,
)
```

### SkeletonCircle
원형 스켈레톤 (아바타용)

```dart
SkeletonCircle(size: 48)
```

### SkeletonLine
텍스트 라인 스켈레톤

```dart
SkeletonLine(
  width: double.infinity,
  height: 16,
)
```

## 마이그레이션 가이드

### 기존 Shimmer 기반 → Skeletonizer

**Before (수동 스켈레톤 구성)**
```dart
isLoading
  ? SkeletonContainer(
      child: Column(
        children: [
          SkeletonCircle(size: 64),
          SizedBox(height: 16),
          SkeletonLine(width: 200, height: 20),
          SizedBox(height: 8),
          SkeletonLine(width: 150, height: 16),
        ],
      ),
    )
  : Column(
      children: [
        CircleAvatar(radius: 32),
        SizedBox(height: 16),
        Text('홍길동', style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        Text('010-1234-5678'),
      ],
    )
```

**After (실제 위젯 재사용)**
```dart
AppSkeletonizer(
  isLoading: isLoading,
  child: Column(
    children: [
      CircleAvatar(radius: 32),
      SizedBox(height: 16),
      Text('홍길동', style: TextStyle(fontSize: 20)),
      SizedBox(height: 8),
      Text('010-1234-5678'),
    ],
  ),
)
```

### 장점

1. **코드 중복 제거**: 실제 UI와 스켈레톤 UI를 따로 작성할 필요 없음
2. **유지보수성**: UI 변경 시 한 곳만 수정
3. **일관성**: 실제 레이아웃과 스켈레톤 레이아웃이 항상 일치
4. **간결함**: 코드량 50% 감소

## Best Practices

### 1. AsyncValue와 함께 사용
```dart
dataAsync.when(
  loading: () => const ScreenSkeleton(),
  error: (e, s) => ErrorWidget(e),
  data: (data) => ActualContent(data),
)
```

### 2. 사전 제작된 컴포넌트 활용
```dart
// 좋음: 재사용 가능한 스켈레톤
const MemberDetailSkeleton()

// 나쁨: 매번 새로 구성
Column(children: [
  SkeletonCircle(...),
  SkeletonLine(...),
  // ...
])
```

### 3. 적절한 애니메이션 선택
```dart
// 일반적인 경우: Shimmer (기본값)
AppSkeletonizer(isLoading: true, child: ...)

// 차분한 느낌: Pulse
AppSkeletonizer(
  isLoading: true,
  effect: const PulseEffect(),
  child: ...,
)
```

### 4. 로딩 상태 관리
```dart
// Riverpod StateNotifier 사용
final isLoadingProvider = StateProvider<bool>((ref) => true);

// 데이터 로드
ref.read(isLoadingProvider.notifier).state = true;
try {
  await fetchData();
} finally {
  ref.read(isLoadingProvider.notifier).state = false;
}
```

## 참고 자료

- [Skeletonizer 패키지](https://pub.dev/packages/skeletonizer)
- [Shimmer 패키지](https://pub.dev/packages/shimmer)
- [Flutter 성능 최적화](https://docs.flutter.dev/perf/rendering-performance)
- [Impeller 렌더링 엔진](https://docs.flutter.dev/perf/impeller)
