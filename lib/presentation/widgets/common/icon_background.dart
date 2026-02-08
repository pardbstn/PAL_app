import 'package:flutter/material.dart';

/// 아이콘 배경 형태
enum IconBackgroundShape {
  /// 원형
  circle,

  /// 둥근 사각형 (radius: 12)
  rounded,

  /// 사각형 (radius: 8)
  square,
}

/// 아이콘 배경 크기 프리셋
enum IconBackgroundSize {
  /// 36x36, 아이콘 18
  small,

  /// 44x44, 아이콘 22
  medium,

  /// 48x48, 아이콘 24
  large,

  /// 56x56, 아이콘 28
  xlarge,
}

/// 재사용 가능한 아이콘 배경 위젯
///
/// 아이콘에 원형/사각형 배경을 추가하여 시각적 강조 효과 제공
/// 다크모드를 자동으로 지원
///
/// 사용 예시:
/// ```dart
/// IconBackground(
///   icon: Icons.fitness_center,
///   iconColor: AppColors.primary,
///   shape: IconBackgroundShape.circle,
///   size: IconBackgroundSize.medium,
/// )
/// ```
class IconBackground extends StatelessWidget {
  /// 표시할 아이콘
  final IconData icon;

  /// 아이콘 색상 (기본값: colorScheme.primary)
  final Color? iconColor;

  /// 배경 색상 (기본값: iconColor의 10% 투명도)
  final Color? backgroundColor;

  /// 배경 형태 (기본값: circle)
  final IconBackgroundShape shape;

  /// 크기 프리셋 (기본값: medium, 44x44)
  final IconBackgroundSize size;

  /// 커스텀 컨테이너 크기 (프리셋 무시)
  final double? customSize;

  /// 커스텀 아이콘 크기 (프리셋 무시)
  final double? customIconSize;

  /// 탭 콜백
  final VoidCallback? onTap;

  const IconBackground({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.shape = IconBackgroundShape.circle,
    this.size = IconBackgroundSize.medium,
    this.customSize,
    this.customIconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveBgColor =
        backgroundColor ??
        effectiveIconColor.withValues(alpha: isDark ? 0.12 : 0.08);

    final (containerSize, iconSize) = _getSizes();
    final borderRadius = _getBorderRadius(containerSize);

    Widget container = Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(icon, size: iconSize, color: effectiveIconColor),
      ),
    );

    if (onTap != null) {
      container = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: effectiveIconColor.withValues(alpha: 0.1),
          highlightColor: effectiveIconColor.withValues(alpha: 0.05),
          child: container,
        ),
      );
    }

    return container;
  }

  (double, double) _getSizes() {
    if (customSize != null && customIconSize != null) {
      return (customSize!, customIconSize!);
    }
    return switch (size) {
      IconBackgroundSize.small => (36.0, 18.0),
      IconBackgroundSize.medium => (44.0, 22.0),
      IconBackgroundSize.large => (48.0, 24.0),
      IconBackgroundSize.xlarge => (56.0, 28.0),
    };
  }

  BorderRadius _getBorderRadius(double containerSize) {
    return switch (shape) {
      IconBackgroundShape.circle => BorderRadius.circular(containerSize / 2),
      IconBackgroundShape.rounded => BorderRadius.circular(16),
      IconBackgroundShape.square => BorderRadius.circular(8),
    };
  }
}
