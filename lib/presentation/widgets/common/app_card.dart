import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/haptic_utils.dart';

/// 카드 변형 타입
enum AppCardVariant {
  /// 기본 스타일: 흰색 배경 + 미세한 쉐도우 + 그레이 보더 1px
  standard,

  /// 강조 스타일: 흰색 배경 + 더 진한 쉐도우 (돌출된 느낌)
  elevated,

  /// 활성/강조 스타일: 흰색 배경 + primary blue 보더 2px + 쉐도우
  accent,

  /// 기록 스타일: 흰색 배경 + 미세한 쉐도우 + 그레이 보더 1px, 패딩 없음
  record,

  /// 그라데이션 테두리 스타일: 파란색 그라데이션 보더 + 흰색 배경
  gradientBorder,

  /// @deprecated standard와 동일하게 처리됩니다
  outlined,

  /// @deprecated standard와 동일하게 처리됩니다
  filled,

  /// @deprecated standard와 동일하게 처리됩니다
  glass,
}

/// PAL 앱의 공통 카드 위젯
///
/// 프리미엄한 "화이트 배경 + 쉐도우" 스타일로 통일된 카드 컴포넌트.
/// 다크모드를 자동으로 지원합니다.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.standard,
    this.padding,
    this.onTap,
    this.isHoverable = false,
    this.animate = true,
    this.animationDelay = Duration.zero,
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

  /// 등장 애니메이션 활성화 여부 (기본값: true)
  final bool animate;

  /// 애니메이션 지연 시간 (리스트에서 순차적 등장에 사용)
  final Duration animationDelay;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  static const double _borderRadius = 20.0;
  static const EdgeInsets _defaultPadding = EdgeInsets.all(20);

  // 디자인 토큰: 통일된 색상 상수
  static const Color _lightBorderColor = Color(0xFFEBEBEB); // Toss Gray
  static const Color _darkBorderColor = Color(0xFF2A2A2A); // Toss dark border
  static const Color _darkBackgroundColor = Color(0xFF1A1A1A); // Toss dark surface
  static const Color _primaryBlue = Color(0xFF0064FF); // Toss Blue

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectivePadding = widget.padding ?? _defaultPadding;

    Widget card = _buildCardContent(colorScheme, isDark, effectivePadding);

    // 탭 피드백 애니메이션 (터치 시 축소 + 쉐도우 변화)
    if (widget.onTap != null) {
      card = GestureDetector(
        onTapDown: (_) {
          HapticUtils.selection();
          setState(() => _isPressed = true);
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
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

    // 등장 애니메이션 (fadeIn + slideY)
    if (widget.animate) {
      card = card
          .animate(delay: widget.animationDelay)
          .fadeIn(duration: 200.ms, curve: Curves.easeOut)
          .slideY(
              begin: 0.01, end: 0, duration: 200.ms, curve: Curves.easeOut);
    }

    return card;
  }

  /// variant에 따라 적절한 카드 스타일을 빌드
  Widget _buildCardContent(
      ColorScheme colorScheme, bool isDark, EdgeInsets effectivePadding) {
    switch (widget.variant) {
      case AppCardVariant.standard:
      case AppCardVariant.outlined:
      case AppCardVariant.filled:
      case AppCardVariant.glass:
        // outlined, filled, glass는 standard와 동일하게 처리 (하위 호환성)
        return _buildStandardCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.elevated:
        return _buildElevatedCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.accent:
        return _buildAccentCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.record:
        return _buildRecordCard(colorScheme, isDark, effectivePadding);
      case AppCardVariant.gradientBorder:
        return _buildGradientBorderCard(colorScheme, isDark, effectivePadding);
    }
  }

  /// Standard 카드: 흰색 배경 + 미세한 쉐도우 (보더 없음)
  Widget _buildStandardCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;

    return _wrapWithInkWell(
      colorScheme: colorScheme,
      backgroundColor: backgroundColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.01 : 0.02),
              blurRadius: _isPressed ? 1 : 2,
              offset: Offset(0, _isPressed ? 0 : 1),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Elevated 카드: 흰색 배경 + 더 진한 쉐도우 (돌출된 느낌)
  Widget _buildElevatedCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;
    final borderColor = isDark ? _darkBorderColor : _lightBorderColor;

    return _wrapWithInkWell(
      colorScheme: colorScheme,
      backgroundColor: backgroundColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: borderColor,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 3 : 6,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Accent 카드: 흰색 배경 + primary blue 보더 1.5px + 쉐도우 (진행중 상태용)
  Widget _buildAccentCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;
    final borderColor = isDark
        ? colorScheme.primary.withValues(alpha: 0.8)
        : _primaryBlue;

    return _wrapWithInkWell(
      colorScheme: colorScheme,
      backgroundColor: backgroundColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.01 : 0.02),
              blurRadius: _isPressed ? 1 : 2,
              offset: Offset(0, _isPressed ? 0 : 1),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// Record 카드: 흰색 배경 + 미세한 쉐도우 (보더 없음), 패딩 없음 (자식이 직접 처리)
  Widget _buildRecordCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;

    return _wrapWithInkWell(
      colorScheme: colorScheme,
      backgroundColor: backgroundColor,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.01 : 0.02),
              blurRadius: _isPressed ? 1 : 2,
              offset: Offset(0, _isPressed ? 0 : 1),
            ),
          ],
        ),
        padding: EdgeInsets.zero, // 자식이 패딩을 직접 처리
        child: widget.child,
      ),
    );
  }

  /// Gradient Border 카드: PAL Design System - 표준 카드 + 미세한 primary 틴트 보더
  Widget _buildGradientBorderCard(
      ColorScheme colorScheme, bool isDark, EdgeInsets padding) {
    final backgroundColor = isDark ? _darkBackgroundColor : Colors.white;
    final borderColor = isDark
        ? _primaryBlue.withValues(alpha: 0.3)
        : _primaryBlue.withValues(alpha: 0.2);

    return _wrapWithInkWell(
      colorScheme: colorScheme,
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
              color: Colors.black.withValues(alpha: _isPressed ? 0.01 : 0.02),
              blurRadius: _isPressed ? 1 : 2,
              offset: Offset(0, _isPressed ? 0 : 1),
            ),
          ],
        ),
        padding: padding,
        child: widget.child,
      ),
    );
  }

  /// onTap이 있으면 InkWell로 래핑 (프리미엄 터치 피드백)
  Widget _wrapWithInkWell({
    required Widget child,
    required Color backgroundColor,
    required ColorScheme colorScheme,
  }) {
    if (widget.onTap == null) {
      return child;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(_borderRadius),
        splashColor: colorScheme.primary.withValues(alpha: 0.03),
        highlightColor: colorScheme.primary.withValues(alpha: 0.01),
        child: child,
      ),
    );
  }

  // ==================== 정적 헬퍼 위젯 ====================

  /// 날짜 뱃지 위젯 (pill shape)
  ///
  /// [dateText] 날짜 텍스트 (예: "2024-01-15")
  // ignore: unused_element
  static Widget dateBadge(String dateText) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = AppColors.primary;

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }

  /// 통계 항목 위젯
  ///
  /// [label] 라벨 텍스트 (예: "세트 수")
  /// [value] 값 텍스트 (예: "3")
  /// [valueColor] 값 색상 (선택사항)
  // ignore: unused_element
  static Widget statItem({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final defaultTextColor = isDark ? Colors.white : AppColors.gray900;
        final grayColor = isDark ? AppColors.gray400 : AppColors.gray500;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppTextStyle.bodySmall,
                color: grayColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: AppTextStyle.titleMedium,
                fontWeight: FontWeight.bold,
                color: valueColor ?? defaultTextColor,
              ),
            ),
          ],
        );
      },
    );
  }
}
