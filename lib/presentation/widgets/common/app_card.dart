import 'dart:ui';
import 'package:flutter/material.dart';

/// 카드 변형 타입
enum AppCardVariant {
  /// 흰색 배경 + 그림자
  elevated,

  /// 흰색 배경 + 테두리
  outlined,

  /// 회색 배경 + 그림자 없음
  filled,

  /// 반투명 배경 + 블러 효과
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
    this.variant = AppCardVariant.elevated,
    this.padding,
    this.onTap,
    this.isHoverable = false,
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

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  static const double _borderRadius = 16.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.all(16);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePadding = widget.padding ?? _defaultPadding;

    Widget card = _buildCardContent(isDark, effectivePadding);

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

    return card;
  }

  Widget _buildCardContent(bool isDark, EdgeInsets effectivePadding) {
    switch (widget.variant) {
      case AppCardVariant.elevated:
        return _buildElevatedCard(isDark, effectivePadding);
      case AppCardVariant.outlined:
        return _buildOutlinedCard(isDark, effectivePadding);
      case AppCardVariant.filled:
        return _buildFilledCard(isDark, effectivePadding);
      case AppCardVariant.glass:
        return _buildGlassCard(isDark, effectivePadding);
    }
  }

  /// Elevated 카드: 흰색 배경 + 그림자
  Widget _buildElevatedCard(bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? Colors.grey[850]! : Colors.white;

    return _wrapWithInkWell(
      backgroundColor: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Outlined 카드: 흰색 배경 + 1px 테두리
  Widget _buildOutlinedCard(bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? Colors.grey[850]! : Colors.white;
    final borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;

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

  /// Filled 카드: 회색 배경 + 그림자 없음
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
  Widget _buildGlassCard(bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark
        ? Colors.grey[900]!.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.5);

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
