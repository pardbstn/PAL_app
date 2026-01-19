import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/routes.dart';

/// 트레이너 앱 셸 (Bottom Navigation)
class TrainerShell extends StatelessWidget {
  final Widget child;

  const TrainerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: '회원',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
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
