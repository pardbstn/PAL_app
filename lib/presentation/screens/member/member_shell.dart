import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';

/// 회원 앱 셸 (Bottom Navigation - 5개 탭)
/// 1. 홈 2. 내 기록 3. 캘린더 4. 식단 5. 메시지
class MemberShell extends ConsumerWidget {
  final Widget child;

  const MemberShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;
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
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: '내 기록',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: '식단',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: const Icon(Icons.message_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: const Icon(Icons.message),
            ),
            label: '메시지',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/member/home')) return 0;
    if (location.startsWith('/member/records')) return 1;
    if (location.startsWith('/member/calendar')) return 2;
    if (location.startsWith('/member/diet')) return 3;
    if (location.startsWith('/member/messages')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    // 현재 위치와 동일한 탭이면 네비게이션 스킵 (중복 네비게이션 방지)
    final currentIndex = _calculateSelectedIndex(context);
    if (currentIndex == index) return;

    switch (index) {
      case 0:
        context.go(AppRoutes.memberHome);
        break;
      case 1:
        context.go(AppRoutes.memberRecords);
        break;
      case 2:
        context.go(AppRoutes.memberCalendar);
        break;
      case 3:
        context.go(AppRoutes.memberDiet);
        break;
      case 4:
        context.go(AppRoutes.memberMessages);
        break;
    }
  }
}
