# 스켈레톤 시스템 빠른 시작 가이드

## 5분 안에 시작하기

### 1단계: 기본 사용법

```dart
import 'package:flutter_pal_app/presentation/widgets/skeleton/skeleton_base.dart';

// 가장 간단한 사용법
AppSkeletonizer(
  isLoading: isLoading,
  child: YourActualWidget(),
)
```

### 2단계: Riverpod과 함께 사용

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(myDataProvider);

    return dataAsync.when(
      loading: () => const MemberDetailSkeleton(), // 사전 제작된 스켈레톤
      error: (error, stack) => ErrorWidget(error),
      data: (data) => ActualContent(data),
    );
  }
}
```

### 3단계: 완료!

이제 아름답고 부드러운 로딩 애니메이션이 자동으로 적용됩니다.

---

## 사전 제작된 스켈레톤 컴포넌트

복사해서 바로 사용하세요:

### 설정 화면
```dart
const SettingsScreenSkeleton()
```

### 회원 상세 화면
```dart
const MemberDetailSkeleton()
```

### 리스트 아이템
```dart
const ListItemSkeleton(
  hasLeading: true,
  hasSubtitle: true,
  hasTrailing: true,
)
```

### 카드
```dart
CardSkeleton(height: 120)
```

### 프로필 헤더
```dart
const SkeletonizerProfileHeader(avatarSize: 80)
```

### 차트
```dart
const SkeletonizerChart(height: 250)
```

---

## 실전 예제

### 회원 목록 화면
```dart
class MemberListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('회원 목록')),
      body: membersAsync.when(
        loading: () => ListView.builder(
          itemCount: 10,
          itemBuilder: (_, i) => const ListItemSkeleton(
            hasLeading: true,
            hasSubtitle: true,
            hasTrailing: true,
          ),
        ),
        error: (e, s) => Center(child: Text('오류: $e')),
        data: (members) => ListView.builder(
          itemCount: members.length,
          itemBuilder: (_, i) {
            final member = members[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.photoUrl),
              ),
              title: Text(member.name),
              subtitle: Text(member.email),
              trailing: Icon(Icons.chevron_right),
            );
          },
        ),
      ),
    );
  }
}
```

### 대시보드 화면
```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      body: dashboardAsync.when(
        loading: () => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              const SkeletonizerProfileHeader(avatarSize: 80),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: CardSkeleton(height: 120)),
                  SizedBox(width: 12),
                  Expanded(child: CardSkeleton(height: 120)),
                ],
              ),
              SizedBox(height: 24),
              const SkeletonizerChart(height: 200),
            ],
          ),
        ),
        error: (e, s) => ErrorWidget(e),
        data: (dashboard) => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ProfileHeader(user: dashboard.user),
              Row(
                children: [
                  Expanded(child: StatCard(data: dashboard.stat1)),
                  SizedBox(width: 12),
                  Expanded(child: StatCard(data: dashboard.stat2)),
                ],
              ),
              ChartWidget(data: dashboard.chartData),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 커스터마이징

### 애니메이션 변경
```dart
// Shimmer 효과 (기본)
AppSkeletonizer(
  isLoading: true,
  child: MyWidget(),
)

// Pulse 효과
AppSkeletonizer(
  isLoading: true,
  effect: PulseEffect(
    duration: Duration(milliseconds: 1000),
  ),
  child: MyWidget(),
)
```

### 색상 커스터마이징
```dart
AppSkeletonizer(
  isLoading: true,
  containersColor: true, // 컨테이너 색상 유지
  effect: ShimmerEffect(
    baseColor: Color(0xFFE0E0E0),
    highlightColor: Color(0xFFF5F5F5),
  ),
  child: MyWidget(),
)
```

---

## 체크리스트

신규 화면 개발 시 확인사항:

- [ ] AsyncValue.when 패턴 사용
- [ ] loading: 콜백에 적절한 스켈레톤 사용
- [ ] error: 콜백에 에러 처리
- [ ] data: 콜백에 실제 UI
- [ ] 다크모드 테스트 완료
- [ ] 로딩 애니메이션 60fps 유지

---

## 자주 묻는 질문

**Q: 기존 Shimmer 코드는 어떻게 하나요?**
A: 그대로 사용 가능합니다. 신규 개발 시에만 Skeletonizer 사용하세요.

**Q: 커스텀 스켈레톤이 필요하면?**
A: AppSkeletonizer로 감싸고 Bone 위젯을 사용하세요.

**Q: 성능 문제가 있나요?**
A: RepaintBoundary로 최적화되어 있어 성능 이슈 없습니다.

**Q: 다크모드는?**
A: 자동으로 감지하여 적용됩니다.

---

## 더 알아보기

- **상세 문서**: [README.md](README.md)
- **마이그레이션 가이드**: [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
- **구현 요약**: [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)
- **실제 예제**: [skeleton_usage_examples.dart](skeleton_usage_examples.dart)

---

## 도움말

문제가 있거나 질문이 있으면:
1. README.md의 Best Practices 섹션 확인
2. skeleton_usage_examples.dart에서 유사한 예제 찾기
3. MIGRATION_GUIDE.md의 문제 해결 섹션 참고
