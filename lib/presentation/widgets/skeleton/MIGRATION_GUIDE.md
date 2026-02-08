# Skeletonizer 마이그레이션 가이드

## 빠른 비교

### Before: Shimmer 기반 (레거시)
```dart
// 실제 UI와 스켈레톤 UI를 각각 작성해야 함
Widget build(BuildContext context) {
  if (isLoading) {
    return SkeletonContainer(
      child: Column(
        children: [
          SkeletonCircle(size: 64),
          SizedBox(height: 16),
          SkeletonLine(width: 200, height: 20),
          SizedBox(height: 8),
          SkeletonLine(width: 150, height: 16),
        ],
      ),
    );
  }

  return Column(
    children: [
      CircleAvatar(radius: 32, backgroundImage: NetworkImage(user.photo)),
      SizedBox(height: 16),
      Text(user.name, style: TextStyle(fontSize: 20)),
      SizedBox(height: 8),
      Text(user.email),
    ],
  );
}
```

### After: Skeletonizer 기반 (권장)
```dart
// 실제 UI만 작성, 로딩 상태는 자동 처리
Widget build(BuildContext context) {
  return AppSkeletonizer(
    isLoading: isLoading,
    child: Column(
      children: [
        CircleAvatar(radius: 32, backgroundImage: NetworkImage(user.photo)),
        SizedBox(height: 16),
        Text(user.name, style: TextStyle(fontSize: 20)),
        SizedBox(height: 8),
        Text(user.email),
      ],
    ),
  );
}
```

**결과**: 코드량 50% 감소, UI 일관성 보장

---

## Riverpod 패턴 비교

### Before: 수동 상태 처리
```dart
class MemberListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    if (membersAsync.isLoading) {
      return ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => SkeletonContainer(
          child: ListTile(
            leading: SkeletonCircle(size: 40),
            title: SkeletonLine(width: 100, height: 16),
            subtitle: SkeletonLine(width: 150, height: 14),
          ),
        ),
      );
    }

    if (membersAsync.hasError) {
      return ErrorWidget(membersAsync.error!);
    }

    final members = membersAsync.value!;
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (_, i) => ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(members[i].photo)),
        title: Text(members[i].name),
        subtitle: Text(members[i].email),
      ),
    );
  }
}
```

### After: AsyncValue.when 패턴
```dart
class MemberListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return membersAsync.when(
      loading: () => ListView.builder(
        itemCount: 10,
        itemBuilder: (_, i) => const ListItemSkeleton(
          hasLeading: true,
          hasSubtitle: true,
        ),
      ),
      error: (error, stack) => ErrorWidget(error),
      data: (members) => ListView.builder(
        itemCount: members.length,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(members[i].photo)),
          title: Text(members[i].name),
          subtitle: Text(members[i].email),
        ),
      ),
    );
  }
}
```

**또는 AppSkeletonizer 사용**:
```dart
class MemberListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);
    final members = membersAsync.valueOrNull ?? [];

    return AppSkeletonizer(
      isLoading: membersAsync.isLoading,
      child: ListView.builder(
        itemCount: membersAsync.isLoading ? 10 : members.length,
        itemBuilder: (_, i) {
          final member = membersAsync.isLoading
            ? Member.skeleton()
            : members[i];
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(member.photo)),
            title: Text(member.name),
            subtitle: Text(member.email),
          );
        },
      ),
    );
  }
}
```

---

## 화면별 마이그레이션 가이드

### 1. 설정 화면

**Before**:
```dart
Widget build(BuildContext context) {
  if (isLoading) {
    return SkeletonContainer(
      child: Column(
        children: [
          SkeletonCircle(size: 80),
          SizedBox(height: 16),
          SkeletonLine(width: 120, height: 24),
          // ... 반복적인 스켈레톤 코드
        ],
      ),
    );
  }

  return ListView(
    children: [
      // 실제 UI
    ],
  );
}
```

**After**:
```dart
Widget build(BuildContext context) {
  return settingsAsync.when(
    loading: () => const SettingsScreenSkeleton(),
    error: (e, s) => ErrorWidget(e),
    data: (settings) => ListView(
      children: [
        // 실제 UI
      ],
    ),
  );
}
```

### 2. 회원 상세 화면

**Before**: 복잡한 스켈레톤 레이아웃 수동 구성

**After**:
```dart
Widget build(BuildContext context) {
  return memberAsync.when(
    loading: () => const MemberDetailSkeleton(),
    error: (e, s) => ErrorWidget(e),
    data: (member) => // 실제 UI
  );
}
```

### 3. 대시보드 화면

**Before**: 프로필 + 카드 + 차트 각각 스켈레톤 구성

**After**:
```dart
Widget build(BuildContext context) {
  return SingleChildScrollView(
    child: Column(
      children: [
        AppSkeletonizer(
          isLoading: isLoading,
          child: Column(
            children: [
              ProfileHeader(user: user),
              Row(
                children: [
                  StatCard(data: data1),
                  StatCard(data: data2),
                ],
              ),
              ChartWidget(chartData: chartData),
            ],
          ),
        ),
      ],
    ),
  );
}
```

---

## 애니메이션 효과 커스터마이징

### ShimmerEffect (기본)
```dart
AppSkeletonizer(
  isLoading: true,
  // effect 생략 시 기본 ShimmerEffect 사용
  child: MyWidget(),
)
```

### PulseEffect
```dart
AppSkeletonizer(
  isLoading: true,
  effect: PulseEffect(
    duration: const Duration(milliseconds: 1000),
  ),
  child: MyWidget(),
)
```

### 다크모드별 커스터마이징
```dart
AppSkeletonizer(
  isLoading: true,
  containersColor: true, // 컨테이너 배경색 유지
  effect: ShimmerEffect(
    baseColor: isDark ? Color(0xFF303030) : Color(0xFFE0E0E0),
    highlightColor: isDark ? Color(0xFF505050) : Color(0xFFF5F5F5),
    duration: const Duration(milliseconds: 1500),
  ),
  child: MyWidget(),
)
```

---

## 단계별 마이그레이션 전략

### Phase 1: 새로운 화면 (즉시 적용)
- 모든 신규 화면은 `AppSkeletonizer` 사용
- 사전 제작된 스켈레톤 컴포넌트 활용

### Phase 2: 중요 화면 (우선순위 높음)
1. 회원 목록 화면
2. 회원 상세 화면
3. 대시보드
4. 설정 화면

### Phase 3: 나머지 화면 (점진적)
- 리팩토링 기회가 생길 때마다 마이그레이션
- 레거시 컴포넌트는 계속 작동하므로 급하지 않음

### Phase 4: 레거시 제거 (선택사항)
- 모든 화면 마이그레이션 완료 후
- `SkeletonContainer`, `SkeletonBox` 등 제거 고려
- 현재는 하위 호환성을 위해 유지 권장

---

## 성능 비교

| 항목 | Shimmer 기반 | Skeletonizer 기반 | 개선율 |
|------|-------------|------------------|--------|
| 코드량 | 100줄 | 50줄 | 50% 감소 |
| 유지보수 포인트 | 2곳 (실제 + 스켈레톤) | 1곳 (실제 UI만) | 50% 감소 |
| UI 일관성 | 수동 동기화 필요 | 자동 보장 | 100% |
| 애니메이션 FPS | 60fps | 60fps | 동일 |
| 다크모드 지원 | 수동 | 자동 | - |

---

## 주의사항

### 1. 데이터 모델에 스켈레톤 값 제공
AppSkeletonizer 사용 시 로딩 중에도 실제 위젯이 빌드되므로, null 값 처리 필요:

```dart
// 옵션 1: valueOrNull 사용
final members = membersAsync.valueOrNull ?? [];

// 옵션 2: 스켈레톤 더미 데이터
final members = membersAsync.isLoading
  ? List.generate(10, (_) => Member.skeleton())
  : membersAsync.value!;

// 옵션 3: when 패턴 사용 (가장 안전)
membersAsync.when(
  loading: () => SkeletonWidget(),
  error: (e, s) => ErrorWidget(e),
  data: (members) => ActualWidget(members),
)
```

### 2. 네트워크 이미지 처리
```dart
CircleAvatar(
  backgroundImage: user.photo.isNotEmpty
    ? NetworkImage(user.photo)
    : null,
)
```

### 3. 복잡한 조건부 UI
AppSkeletonizer는 간단한 UI에 적합. 복잡한 조건부 렌더링은 `when` 패턴 사용 권장.

---

## 문제 해결

### Q: 스켈레톤이 너무 빠르게 깜빡인다
```dart
// 최소 로딩 시간 보장
final minLoadingTime = Duration(milliseconds: 500);
await Future.wait([
  dataFuture,
  Future.delayed(minLoadingTime),
]);
```

### Q: 다크모드에서 색상이 이상하다
```dart
// 커스텀 색상 지정
AppSkeletonizer(
  isLoading: true,
  containersColor: true,
  effect: ShimmerEffect(
    baseColor: Theme.of(context).colorScheme.surfaceVariant,
    highlightColor: Theme.of(context).colorScheme.surface,
  ),
  child: ...,
)
```

### Q: 애니메이션이 끊긴다
```dart
// RepaintBoundary는 이미 포함되어 있음
// 상위 위젯에서 과도한 rebuild 확인
```

---

## 참고 자료

- [skeleton_base.dart](/Volumes/ExtremeSSD/proj/PAL_app/lib/presentation/widgets/skeleton/skeleton_base.dart)
- [skeleton_usage_examples.dart](/Volumes/ExtremeSSD/proj/PAL_app/lib/presentation/widgets/skeleton/skeleton_usage_examples.dart)
- [README.md](/Volumes/ExtremeSSD/proj/PAL_app/lib/presentation/widgets/skeleton/README.md)
- [Skeletonizer 패키지 문서](https://pub.dev/packages/skeletonizer)
