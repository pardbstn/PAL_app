import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/liquid_glass_nav_bar.dart';

/// 트레이너 앱 셸 (Bottom Navigation - 4개 탭)
/// 스와이프 탭 전환 + 슬라이드 애니메이션 지원
class TrainerShell extends ConsumerStatefulWidget {
  final Widget child;

  const TrainerShell({super.key, required this.child});

  @override
  ConsumerState<TrainerShell> createState() => _TrainerShellState();
}

class _TrainerShellState extends ConsumerState<TrainerShell> {
  /// 탭 전환 방향 (true = 오른쪽 탭으로 이동)
  bool _slideForward = true;

  /// 탭 라우트 목록 (순서대로)
  static const _routes = [
    AppRoutes.trainerHome,
    AppRoutes.trainerMembers,
    AppRoutes.trainerCalendar,
    AppRoutes.trainerMessages,
  ];

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/trainer/home')) return 0;
    if (location.startsWith('/trainer/members')) return 1;
    if (location.startsWith('/trainer/calendar')) return 2;
    if (location.startsWith('/trainer/messages')) return 3;
    return 0;
  }

  void _navigateToIndex(int index, BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    if (currentIndex == index || index < 0 || index >= _routes.length) return;
    _slideForward = index > currentIndex;
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(totalUnreadCountProvider).value ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _calculateSelectedIndex(context);
    final currentPath = GoRouterState.of(context).uri.path;

    return Scaffold(
      extendBody: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          // 왼쪽 스와이프 → 다음 탭
          if (details.primaryVelocity! < -400) {
            _navigateToIndex(currentIndex + 1, context);
          }
          // 오른쪽 스와이프 → 이전 탭
          else if (details.primaryVelocity! > 400) {
            _navigateToIndex(currentIndex - 1, context);
          }
        },
        child: Container(
          color: isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              // 들어오는 화면: 방향에 따라 슬라이드 + 페이드
              final isIncoming = child.key == ValueKey(currentPath);
              if (isIncoming) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(_slideForward ? 0.15 : -0.15, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              }
              // 나가는 화면: 페이드 아웃만
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey(currentPath),
              child: widget.child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: LiquidGlassNavBar(
        currentIndex: currentIndex,
        onTap: (index) => _navigateToIndex(index, context),
        items: [
          const LiquidGlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: '홈',
          ),
          const LiquidGlassNavItem(
            icon: Icons.people_outlined,
            activeIcon: Icons.people_rounded,
            label: '회원',
          ),
          const LiquidGlassNavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: '캘린더',
          ),
          LiquidGlassNavItem(
            icon: Icons.chat_bubble_outline_rounded,
            activeIcon: Icons.chat_bubble_rounded,
            label: '메시지',
            badge: unreadCount > 0 ? unreadCount : null,
          ),
        ],
      ),
    );
  }
}
