import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';

/// Liquid Glass 네비게이션 바 아이템
class LiquidGlassNavItem {
  const LiquidGlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;
}

/// iOS 26 Liquid Glass 스타일 커스텀 하단 네비게이션 바
///
/// BackdropFilter 기반 프로스티드 글래스 효과 + 슬라이딩 pill 애니메이션
/// Scaffold(extendBody: true) 필수
class LiquidGlassNavBar extends StatefulWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<LiquidGlassNavItem> items;

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: AppNavGlass.margin.copyWith(
        bottom: AppNavGlass.margin.bottom + bottomPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppNavGlass.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppNavGlass.barBlurSigma,
            sigmaY: AppNavGlass.barBlurSigma,
          ),
          child: Container(
            height: AppNavGlass.height,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: AppNavGlass.darkOpacity)
                  : Colors.white.withValues(alpha: AppNavGlass.lightOpacity),
              borderRadius: BorderRadius.circular(AppNavGlass.borderRadius),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.6),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / widget.items.length;
                final activeColor = isDark
                    ? AppNavGlass.activeColorDark
                    : AppNavGlass.activeColor;

                return Stack(
                  children: [
                    // 슬라이딩 pill 인디케이터
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      left: widget.currentIndex * itemWidth + 4,
                      top: 8,
                      bottom: 8,
                      width: itemWidth - 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: activeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    // 네비게이션 아이템
                    Row(
                      children: List.generate(widget.items.length, (index) {
                        return _NavBarItem(
                          item: widget.items[index],
                          isActive: widget.currentIndex == index,
                          onTap: () => widget.onTap(index),
                          isDark: isDark,
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 개별 네비게이션 바 아이템
class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  final LiquidGlassNavItem item;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark
        ? AppNavGlass.activeColorDark
        : AppNavGlass.activeColor;
    final inactiveColor = isDark ? AppColors.gray300 : AppColors.gray400;
    final inactiveLabelColor = isDark ? AppColors.gray300 : AppColors.gray500;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 (+ Badge)
              _buildIcon(activeColor, inactiveColor),
              const SizedBox(height: 2),
              // 라벨
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? activeColor : inactiveLabelColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color activeColor, Color inactiveColor) {
    final icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isActive ? item.activeIcon : item.icon,
        key: ValueKey(isActive),
        size: 22,
        color: isActive ? activeColor : inactiveColor,
      ),
    );

    if (item.badge != null && item.badge! > 0) {
      return Badge(
        isLabelVisible: true,
        label: Text(
          item.badge! > 99 ? '99+' : '${item.badge}',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
        child: icon,
      );
    }

    return icon;
  }
}
