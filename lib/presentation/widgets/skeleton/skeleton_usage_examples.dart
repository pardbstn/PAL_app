import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'skeleton_base.dart';

// ============================================================================
// Skeletonizer 사용 예제
// ============================================================================

/// 예제 1: 기본 AppSkeletonizer 사용법
/// 실제 위젯을 그대로 사용하면서 로딩 상태만 표시
class BasicSkeletonizerExample extends ConsumerWidget {
  const BasicSkeletonizerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 로딩 상태를 Riverpod으로 관리
    final isLoading = ref.watch(someLoadingProvider);

    return AppSkeletonizer(
      isLoading: isLoading,
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: const Text('홍길동'),
          subtitle: const Text('010-1234-5678'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

/// 예제 2: 회원 목록 화면 스켈레톤
class MemberListExample extends ConsumerWidget {
  const MemberListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersProvider);

    return membersAsync.when(
      loading: () => ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListItemSkeleton(
            hasLeading: true,
            hasSubtitle: true,
            hasTrailing: true,
          ),
        ),
      ),
      error: (error, stack) => Center(child: Text('오류: $error')),
      data: (members) => AppSkeletonizer(
        isLoading: false,
        child: ListView.builder(
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(member.photoUrl),
              ),
              title: Text(member.name),
              subtitle: Text(member.email),
              trailing: const Icon(Icons.chevron_right),
            );
          },
        ),
      ),
    );
  }
}

/// 예제 3: 대시보드 화면 스켈레톤 (복합 레이아웃)
class DashboardExample extends ConsumerWidget {
  const DashboardExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return dashboardAsync.when(
      loading: () => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 헤더
            const SkeletonizerProfileHeader(avatarSize: 80),

            const SizedBox(height: 24),

            // 통계 카드 2개
            Row(
              children: [
                Expanded(child: CardSkeleton(height: 120)),
                const SizedBox(width: 12),
                Expanded(child: CardSkeleton(height: 120)),
              ],
            ),

            const SizedBox(height: 24),

            // 차트
            const SkeletonizerChart(height: 200),

            const SizedBox(height: 24),

            // 최근 활동 리스트
            ...List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: ListItemSkeleton(
                  hasLeading: true,
                  hasSubtitle: true,
                ),
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(child: Text('오류: $error')),
      data: (dashboard) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 실제 데이터 렌더링
            Text('환영합니다, ${dashboard.userName}!'),
            // ... 나머지 UI
          ],
        ),
      ),
    );
  }
}

/// 예제 4: 설정 화면 전체 스켈레톤
class SettingsExample extends ConsumerWidget {
  const SettingsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SettingsScreenSkeleton(),
      error: (error, stack) => Center(child: Text('오류: $error')),
      data: (settings) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 실제 설정 UI
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('알림 설정'),
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (value) {},
            ),
          ),
          // ... 나머지 설정 항목
        ],
      ),
    );
  }
}

/// 예제 5: 회원 상세 화면
class MemberDetailExample extends ConsumerWidget {
  const MemberDetailExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailProvider);

    return memberAsync.when(
      loading: () => const MemberDetailSkeleton(),
      error: (error, stack) => Center(child: Text('오류: $error')),
      data: (member) => Column(
        children: [
          // 실제 회원 상세 UI
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundImage: NetworkImage(member.photoUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  member.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          // ... 나머지 UI
        ],
      ),
    );
  }
}

/// 예제 6: 커스텀 스켈레톤 효과
class CustomEffectExample extends ConsumerWidget {
  const CustomEffectExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(someLoadingProvider);

    return AppSkeletonizer(
      isLoading: isLoading,
      ignoreContainers: true, // 컨테이너 배경색 무시
      containersColor: true, // 컨테이너 배경색 유지
      effect: PulseEffect(
        duration: const Duration(milliseconds: 1000),
      ), // Pulse 애니메이션 사용
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('제목', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              const Text('설명 텍스트입니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: const Text('버튼'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 예제 7: 레거시 Shimmer 컴포넌트 계속 사용
class LegacyShimmerExample extends StatelessWidget {
  const LegacyShimmerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: Column(
        children: [
          const SkeletonCircle(size: 64),
          const SizedBox(height: 16),
          SkeletonLine(width: 200, height: 20),
          const SizedBox(height: 8),
          SkeletonLine(width: 150, height: 16),
        ],
      ),
    );
  }
}

// ============================================================================
// Mock Providers (예제용)
// ============================================================================

// 간단한 로딩 상태 Provider
final someLoadingProvider = Provider<bool>((ref) => false);

// 비동기 데이터 Provider 예제
final membersProvider = FutureProvider<List<Member>>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return [
    Member(name: '홍길동', email: 'hong@example.com', photoUrl: ''),
    Member(name: '김철수', email: 'kim@example.com', photoUrl: ''),
  ];
});

final dashboardProvider = FutureProvider<Dashboard>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return Dashboard(userName: '홍길동');
});

final settingsProvider = FutureProvider<Settings>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return Settings(notificationsEnabled: true);
});

final memberDetailProvider = FutureProvider<MemberDetail>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  return MemberDetail(name: '홍길동', photoUrl: '');
});

// ============================================================================
// Mock 데이터 모델
// ============================================================================

class Member {
  final String name;
  final String email;
  final String photoUrl;
  Member({required this.name, required this.email, required this.photoUrl});
}

class Dashboard {
  final String userName;
  Dashboard({required this.userName});
}

class Settings {
  final bool notificationsEnabled;
  Settings({required this.notificationsEnabled});
}

class MemberDetail {
  final String name;
  final String photoUrl;
  MemberDetail({required this.name, required this.photoUrl});
}
