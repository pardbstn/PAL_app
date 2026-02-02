import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';

/// 트레이너 앱 셸 (Bottom Navigation)
class TrainerShell extends ConsumerWidget {
  final Widget child;

  const TrainerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A2140), const Color(0xFF162035)]
                : [const Color(0xFFDBE1FE), const Color(0xFFD5F5E3)],
          ),
        ),
        // 페이지별 고유 키 + AnimatedSwitcher로 이전 페이지 잔상 방지
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(GoRouterState.of(context).uri.path),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          const NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: '회원',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          // 메시지 배지만 별도로 리빌드되도록 Consumer 사용
          NavigationDestination(
            icon: Consumer(
              builder: (context, ref, _) {
                final unreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  child: const Icon(Icons.message_outlined),
                );
              },
            ),
            selectedIcon: Consumer(
              builder: (context, ref, _) {
                final unreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;
                return Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                  child: const Icon(Icons.message),
                );
              },
            ),
            label: '메시지',
          ),
        ],
      ),
    );
  }


  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/trainer/home')) return 0;
    if (location.startsWith('/trainer/members')) return 1;
    if (location.startsWith('/trainer/calendar')) return 2;
    if (location.startsWith('/trainer/messages')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    // 현재 위치와 동일한 탭이면 네비게이션 스킵 (중복 네비게이션 방지)
    final currentIndex = _calculateSelectedIndex(context);
    if (currentIndex == index) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.trainerHome);
        break;
      case 1:
        context.go(AppRoutes.trainerMembers);
        break;
      case 2:
        context.go(AppRoutes.trainerCalendar);
        break;
      case 3:
        context.go(AppRoutes.trainerMessages);
        break;
    }
  }
}
