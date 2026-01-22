import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 카드 변형 타입
enum AppCardVariant {
  /// 기본 스타일: 흰색 배경 + 그레이 테두리 + 미세한 쉐도우
  standard,

  /// 테두리만, 쉐도우 없음
  outlined,

  /// 옅은 그레이 배경
  filled,

  /// 반투명 배경 + 블러 효과 (다크모드용)
  glass,
}

/// PAL 앱의 공통 카드 위젯
///
/// 다양한 스타일 변형과 인터랙션을 지원하는 카드 컴포넌트.
/// 다크모드를 자동으로 지원합니다.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.onTap,
    this.isHoverable = false,
    this.animate = false,
  });

  /// 카드 내부에 표시할 위젯
  final Widget child;

  /// 카드 스타일 변형
  final AppCardVariant variant;

  /// 내부 패딩 (기본값: EdgeInsets.all(16))
  final EdgeInsets? padding;

  /// 탭 콜백 (null이면 탭 불가)
  final VoidCallback? onTap;

  /// 호버 시 확대 효과 활성화 여부
  final bool isHoverable;

  /// 등장 애니메이션 활성화 여부
  final bool animate;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  static const double _borderRadius = 16.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.all(16);

  // 통일된 색상 상수
  static const Color _lightBorderColor = Color(0xFFE5E7EB); // Gray-200
  static const Color _darkBorderColor = Color(0xFF374151); // Gray-700
  static const Color _darkBackgroundColor = Color(0xFF1F2937); // Gray-800

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePadding = widget.padding ?? _defaultPadding;

    Widget card = _buildCardContent(colorScheme, isDark, effectivePadding);

    // 탭 피드백 애니메이션 (터치 시 축소 + 쉐도우 변화)
    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }

    // 호버 효과 적용
    if (widget.isHoverable) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }

    // 등장 애니메이션
    if (widget.animate) {
      card = card
          .animate()
          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
          .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }

    return card;
  }

  Widget _buildCardContent(
      ColorScheme colorScheme, bool isDark, EdgeInsets effectivePadding) {
    switch (widget.variant) {
      case AppCardVariant.standard:
        return _buildStandardCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.outlined:
        return _buildOutlinedCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.filled:
        return _buildFilledCard(isDark, effectivePadding);
      case AppCardVariant.glass:
        return _buildGlassCard(colorScheme, isDark, effectivePadding);
    }
  }

  /// Standard 카드: 흰색 배경 + 그레이 테두리 + 미세한 쉐도우 (통일 스타일)
  Widget _buildStandardCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;
    final borderColor = isDark ? _darkBorderColor : _lightBorderColor;
    final shadowAlpha = isDark ? 0.2 : 0.03;
    final pressedShadowAlpha = isDark ? 0.1 : 0.01;

    return _wrapWithInkWell(
      backgroundColor: backgroundColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: _isPressed ? pressedShadowAlpha : shadowAlpha),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 1 : 2),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Outlined 카드: 테두리만, 쉐도우 없음
  Widget _buildOutlinedCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;
    final borderColor = isDark ? _darkBorderColor : _lightBorderColor;

    return _wrapWithInkWell(
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Filled 카드: 옅은 그레이 배경
  Widget _buildFilledCard(bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return _wrapWithInkWell(
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Glass 카드: 반투명 배경 + 블러 효과
  Widget _buildGlassCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.7)
        : colorScheme.surface.withValues(alpha: 0.7);
    final borderColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.1)
        : colorScheme.surface.withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: _wrapWithInkWell(
          backgroundColor: backgroundColor,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(_borderRadius),
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            padding: padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  /// onTap이 있으면 InkWell로 래핑
  Widget _wrapWithInkWell({
    required Widget child,
    required Color backgroundColor,
  }) {
    if (widget.onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        splashColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
        highlightColor: const Color(0xFF2563EB).withValues(alpha: 0.05),
        child: child,
      ),
    );
  }
}
