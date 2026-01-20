import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_tokens.dart';

/// 사이드바 확장 상태 Notifier
class WebSidebarExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void expand() => state = true;
  void collapse() => state = false;
}

/// 사이드바 확장 상태 Provider
final webSidebarExpandedProvider =
    NotifierProvider<WebSidebarExpandedNotifier, bool>(
        WebSidebarExpandedNotifier.new);

/// 사이드바 네비게이션 아이템 데이터
class WebSidebarItem {
  const WebSidebarItem({
    required this.icon,
    required this.label,
    required this.path,
    this.badge,
    this.children,
  });

  final IconData icon;
  final String label;
  final String path;
  final int? badge;
  final List<WebSidebarItem>? children;
}

/// 웹 사이드바 위젯
class WebSidebar extends ConsumerStatefulWidget {
  const WebSidebar({
    super.key,
    required this.items,
    required this.currentPath,
    required this.onItemTap,
    this.header,
    this.footer,
    this.expandedWidth = 280,
    this.collapsedWidth = 72,
    this.backgroundColor,
    this.selectedColor,
  });

  final List<WebSidebarItem> items;
  final String currentPath;
  final void Function(String path) onItemTap;
  final Widget? header;
  final Widget? footer;
  final double expandedWidth;
  final double collapsedWidth;
  final Color? backgroundColor;
  final Color? selectedColor;

  @override
  ConsumerState<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends ConsumerState<WebSidebar> {
  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(webSidebarExpandedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? const Color(0xFF121212) : Colors.white);

    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: Curves.easeInOut,
      width: isExpanded ? widget.expandedWidth : widget.collapsedWidth,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          if (widget.header != null) ...[
            widget.header!,
          ] else ...[
            _buildDefaultHeader(context, isExpanded, isDark),
          ],
          const Divider(height: 1),
          // 네비게이션 아이템
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: widget.items.map((item) {
                return _SidebarNavItem(
                  item: item,
                  isExpanded: isExpanded,
                  isSelected: widget.currentPath.startsWith(item.path),
                  selectedColor: widget.selectedColor ?? theme.colorScheme.primary,
                  onTap: () => widget.onItemTap(item.path),
                );
              }).toList(),
            ),
          ),
          // 푸터
          if (widget.footer != null) ...[
            const Divider(height: 1),
            widget.footer!,
          ],
          // 토글 버튼
          _buildToggleButton(context, isExpanded, isDark),
        ],
      ),
    );
  }

  Widget _buildDefaultHeader(BuildContext context, bool isExpanded, bool isDark) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 20 : 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
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
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButton(BuildContext context, bool isExpanded, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          ref.read(webSidebarExpandedProvider.notifier).toggle();
        },
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedRotation(
                duration: AppDurations.normal,
                turns: isExpanded ? 0 : 0.5,
                child: Icon(
                  Icons.chevron_left,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(width: 8),
                Text(
                  '접기',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 사이드바 네비게이션 아이템 위젯
class _SidebarNavItem extends StatefulWidget {
  const _SidebarNavItem({
    required this.item,
    required this.isExpanded,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final WebSidebarItem item;
  final bool isExpanded;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = widget.isSelected
        ? widget.selectedColor.withValues(alpha: 0.1)
        : _isHovered
            ? (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.1))
            : Colors.transparent;

    final iconColor = widget.isSelected
        ? widget.selectedColor
        : _isHovered
            ? (isDark ? Colors.white : Colors.black87)
            : (isDark ? Colors.grey[400] : Colors.grey[600]);

    final textColor = widget.isSelected
        ? widget.selectedColor
        : (isDark ? Colors.grey[300] : Colors.grey[800]);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          margin: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 12 : 8,
            vertical: 2,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isExpanded ? 16 : 0,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: widget.isSelected
                ? Border.all(
                    color: widget.selectedColor.withValues(alpha: 0.3),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: widget.isExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              // 선택 인디케이터
              if (widget.isSelected && widget.isExpanded)
                Container(
                  width: 4,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: widget.selectedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              // 아이콘
              Icon(
                widget.item.icon,
                size: 22,
                color: iconColor,
              ),
              // 라벨
              if (widget.isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                // 뱃지
                if (widget.item.badge != null && widget.item.badge! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.item.badge! > 99 ? '99+' : '${widget.item.badge}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

/// 사이드바 섹션 헤더
class WebSidebarSectionHeader extends StatelessWidget {
  const WebSidebarSectionHeader({
    super.key,
    required this.title,
    required this.isExpanded,
  });

  final String title;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    if (!isExpanded) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
