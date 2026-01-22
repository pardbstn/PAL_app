import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/notification/notification_badge.dart';

/// 회원 앱 셸 (Bottom Navigation - 5개 탭)
/// 1. 홈 2. 내 기록 3. 캘린더 4. 식단 5. 메시지
class MemberShell extends ConsumerWidget {
  final Widget child;

  const MemberShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(context)),
        actions: [
          if (userId != null)
            NotificationActionButton(
              userId: userId,
              onTap: () => context.push('/notifications'),
            ),
        ],
      ),
      body: child,
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

  String _getTitle(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/member/home')) return '홈';
    if (location.startsWith('/member/records')) return '내 기록';
    if (location.startsWith('/member/calendar')) return '캘린더';
    if (location.startsWith('/member/diet')) return '식단';
    if (location.startsWith('/member/messages')) return '메시지';
    return 'PAL';
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
