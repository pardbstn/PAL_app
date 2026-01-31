import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_tokens.dart';

/// 액션 버튼 크기
enum AppActionButtonSize {
  /// 작은 크기 - 인라인 액션
  small,

  /// 중간 크기 - 기본
  medium,

  /// 큰 크기 - 주요 액션
  large,
}

/// 액션 버튼 변형
enum AppActionButtonVariant {
  /// Primary - 파란색 배경
  primary,

  /// Secondary - 초록색 배경
  secondary,

  /// Outlined - 테두리만
  outlined,

  /// Ghost - 배경 없음
  ghost,
}

/// PAL 앱의 통일된 액션 버튼
///
/// "기록 추가" 스타일을 기준으로 한 일관된 버튼 컴포넌트.
/// 아이콘 + 텍스트 조합으로 사용합니다.
class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = AppActionButtonSize.medium,
    this.variant = AppActionButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.animate = true,
  });

  /// 버튼 라벨
  final String label;

  /// 탭 콜백
  final VoidCallback? onPressed;

  /// 앞쪽 아이콘 (선택)
  final IconData? icon;

  /// 버튼 크기
  final AppActionButtonSize size;

  /// 버튼 변형
  final AppActionButtonVariant variant;

  /// 로딩 상태
  final bool isLoading;

  /// 전체 너비 사용
  final bool isFullWidth;

  /// 애니메이션 활성화
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 크기별 설정
    final (paddingH, paddingV, fontSize, iconSize) = switch (size) {
      AppActionButtonSize.small => (AppSpacing.md, AppSpacing.sm, AppTextStyle.bodySmall, AppIconSize.sm),
      AppActionButtonSize.medium => (AppSpacing.lg, AppSpacing.md, AppTextStyle.bodyMedium, AppIconSize.md),
      AppActionButtonSize.large => (AppSpacing.xl, AppSpacing.md + 4, AppTextStyle.bodyLarge, AppIconSize.md),
    };

    // 변형별 색상
    final (bgColor, fgColor, borderColor) = switch (variant) {
      AppActionButtonVariant.primary => (
        AppColors.primary,
        Colors.white,
        Colors.transparent,
      ),
      AppActionButtonVariant.secondary => (
        AppColors.secondary,
        Colors.white,
        Colors.transparent,
      ),
      AppActionButtonVariant.outlined => (
        Colors.transparent,
        isDark ? Colors.white : AppColors.gray700,
        isDark ? AppColors.darkBorder : AppColors.gray300,
      ),
      AppActionButtonVariant.ghost => (
        Colors.transparent,
        isDark ? Colors.white : AppColors.gray700,
        Colors.transparent,
      ),
    };

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppRadius.mdBorderRadius,
        splashColor: fgColor.withValues(alpha: 0.1),
        highlightColor: fgColor.withValues(alpha: 0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: paddingH,
            vertical: paddingV,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.mdBorderRadius,
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor)
                : null,
          ),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                  ),
                ),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: fgColor,
                ),
              ],
              if (icon != null || isLoading) const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (animate && variant == AppActionButtonVariant.primary) {
      button = button
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
            duration: 2000.ms,
            color: Colors.white.withValues(alpha: 0.2),
          );
    }

    return button;
  }
}

/// FAB 스타일 액션 버튼 (플로팅)
class AppFloatingActionButton extends StatelessWidget {
  const AppFloatingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_rounded,
    this.animate = true,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    Widget fab = FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: Icon(icon),
      label: Text(label),
    );

    if (animate) {
      fab = fab
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .shimmer(
            duration: 2000.ms,
            color: Colors.white.withValues(alpha: 0.3),
          );
    }

    return fab;
  }
}

/// 아이콘만 있는 액션 버튼 (정사각형)
class AppIconActionButton extends StatelessWidget {
  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 48,
    this.variant = AppActionButtonVariant.primary,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final AppActionButtonVariant variant;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final (bgColor, fgColor) = switch (variant) {
      AppActionButtonVariant.primary => (AppColors.primary, Colors.white),
      AppActionButtonVariant.secondary => (AppColors.secondary, Colors.white),
      AppActionButtonVariant.outlined => (
        Colors.transparent,
        isDark ? Colors.white : AppColors.gray700,
      ),
      AppActionButtonVariant.ghost => (
        isDark ? AppColors.darkSurface : AppColors.gray100,
        isDark ? Colors.white : AppColors.gray700,
      ),
    };

    Widget button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.mdBorderRadius,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.mdBorderRadius,
            border: variant == AppActionButtonVariant.outlined
                ? Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.gray300,
                  )
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: fgColor,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
