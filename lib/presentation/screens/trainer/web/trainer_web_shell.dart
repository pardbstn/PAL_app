import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 사이드바 확장 상태 Notifier
class SidebarExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void expand() => state = true;
  void collapse() => state = false;
}

/// 사이드바 확장 상태 Provider
final sidebarExpandedProvider =
    NotifierProvider<SidebarExpandedNotifier, bool>(() => SidebarExpandedNotifier());

/// 트레이너 웹 Shell
/// SaaS 대시보드 스타일의 사이드바 레이아웃
class TrainerWebShell extends ConsumerWidget {
  final Widget child;

  const TrainerWebShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(sidebarExpandedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          _WebSidebar(isExpanded: isExpanded),
          // 메인 컨텐츠
          Expanded(
            child: Column(
              children: [
                const _WebHeader(),
                Expanded(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 웹 사이드바 위젯
class _WebSidebar extends ConsumerWidget {
  final bool isExpanded;

  const _WebSidebar({required this.isExpanded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;
    final authState = ref.watch(authProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 280 : 72,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // 로고 영역
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 24 : 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF10B981)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    'PAL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          const SizedBox(height: 16),

          // 네비게이션 아이템
          _NavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: '대시보드',
            path: '/trainer/home',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),
          _NavItem(
            icon: Icons.people_outlined,
            selectedIcon: Icons.people,
            label: '회원 관리',
            path: '/trainer/members',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),
          _NavItem(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month,
            label: '캘린더',
            path: '/trainer/calendar',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),
          _NavItem(
            icon: Icons.message_outlined,
            selectedIcon: Icons.message,
            label: '메시지',
            path: '/trainer/messages',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),
          _NavItem(
            icon: Icons.payments_outlined,
            selectedIcon: Icons.payments,
            label: '매출 관리',
            path: '/trainer/revenue',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),

          const Spacer(),

          Divider(
            height: 1,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          // 설정
          _NavItem(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings,
            label: '설정',
            path: '/trainer/settings',
            currentPath: currentPath,
            isExpanded: isExpanded,
          ),

          const SizedBox(height: 8),

          // 사이드바 토글
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 12),
            child: IconButton(
              onPressed: () =>
                  ref.read(sidebarExpandedProvider.notifier).toggle(),
              icon: Icon(
                isExpanded ? Icons.chevron_left : Icons.chevron_right,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              tooltip: isExpanded ? '사이드바 접기' : '사이드바 펼치기',
            ),
          ),

          const SizedBox(height: 8),

          // 프로필 영역
          Container(
            padding: EdgeInsets.all(isExpanded ? 16 : 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isExpanded ? 20 : 18,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                  child: Text(
                    authState.displayName?.isNotEmpty == true
                        ? authState.displayName!.substring(0, 1)
                        : 'T',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.displayName ?? '트레이너',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text(
                          'Pro 플랜',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 네비게이션 아이템 위젯
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
  final String currentPath;
  final bool isExpanded;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.currentPath,
    required this.isExpanded,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovered = false;

  bool get isSelected => widget.currentPath.startsWith(widget.path);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isExpanded ? 12 : 8,
        vertical: 2,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: isSelected ? null : () => context.go(widget.path),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.1)
                  : _isHovered
                      ? (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05))
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? const Border(
                      left: BorderSide(
                        color: AppTheme.primary,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? widget.selectedIcon : widget.icon,
                  size: 22,
                  color: isSelected
                      ? AppTheme.primary
                      : isDark
                          ? Colors.white70
                          : Colors.black54,
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppTheme.primary
                          : isDark
                              ? Colors.white70
                              : Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 웹 헤더 위젯
class _WebHeader extends ConsumerWidget {
  const _WebHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;

    String title = '대시보드';
    if (currentPath.contains('/members')) title = '회원 관리';
    if (currentPath.contains('/calendar')) title = '캘린더';
    if (currentPath.contains('/messages')) title = '메시지';
    if (currentPath.contains('/revenue')) title = '매출 관리';
    if (currentPath.contains('/settings')) title = '설정';

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          // 검색바
          Container(
            width: 300,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '회원, 일정 검색...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 알림
          IconButton(
            onPressed: () {},
            icon: Badge(
              label: const Text('3'),
              child: Icon(
                Icons.notifications_outlined,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 프로필 드롭다운
          PopupMenuButton(
            offset: const Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20),
                    SizedBox(width: 12),
                    Text('프로필'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => ref.read(authProvider.notifier).signOut(),
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('로그아웃', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
