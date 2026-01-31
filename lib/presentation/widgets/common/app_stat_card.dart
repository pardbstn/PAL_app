import 'package:flutter/material.dart';
import '../../../core/theme/app_tokens.dart';
import 'app_card.dart';

/// 통계 카드 크기
enum AppStatCardSize {
  /// 작은 크기 - 간단한 숫자 표시
  small,

  /// 중간 크기 - 기본 크기
  medium,

  /// 큰 크기 - 강조 표시
  large,
}

/// 통계 카드 레이아웃
enum AppStatCardLayout {
  /// 세로 레이아웃: 아이콘 → 값 → 라벨
  vertical,

  /// 가로 레이아웃: 아이콘 | 값 + 라벨
  horizontal,

  /// 컴팩트 레이아웃: 값 + 라벨 (아이콘 없음)
  compact,
}

/// PAL 앱의 통계 카드 위젯
///
/// 숫자 + 라벨 + 아이콘을 포함한 통계 표시 컴포넌트.
/// 대시보드, 요약 화면에서 주요 지표 표시에 사용합니다.
class AppStatCard extends StatelessWidget {
  const AppStatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.trend,
    this.trendValue,
    this.size = AppStatCardSize.medium,
    this.layout = AppStatCardLayout.vertical,
    this.onTap,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.cardVariant = AppCardVariant.standard,
  });

  /// 표시할 값 (숫자, 텍스트 등)
  final String value;

  /// 값 설명 라벨
  final String label;

  /// 아이콘 (선택)
  final IconData? icon;

  /// 아이콘 색상 (기본값: primary)
  final Color? iconColor;

  /// 아이콘 배경 색상 (기본값: primary의 투명도 적용)
  final Color? iconBackgroundColor;

  /// 추세 방향: 'up', 'down', 'neutral'
  final String? trend;

  /// 추세 값 (예: "+12%", "-5%")
  final String? trendValue;

  /// 카드 크기
  final AppStatCardSize size;

  /// 레이아웃 방식
  final AppStatCardLayout layout;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 등장 애니메이션 활성화
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  /// 카드 스타일 변형
  final AppCardVariant cardVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final effectiveIconColor = iconColor ?? colorScheme.primary;
    final effectiveIconBgColor = iconBackgroundColor ??
        colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1);

    Widget content;
    switch (layout) {
      case AppStatCardLayout.vertical:
        content = _buildVerticalLayout(
          theme,
          isDark,
          effectiveIconColor,
          effectiveIconBgColor,
        );
        break;
      case AppStatCardLayout.horizontal:
        content = _buildHorizontalLayout(
          theme,
          isDark,
          effectiveIconColor,
          effectiveIconBgColor,
        );
        break;
      case AppStatCardLayout.compact:
        content = _buildCompactLayout(theme, isDark);
        break;
    }

    return AppCard(
      variant: cardVariant,
      onTap: onTap,
      padding: _getPadding(),
      animate: animate,
      animationDelay: animationDelay,
      isHoverable: onTap != null,
      child: content,
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppStatCardSize.small:
        return const EdgeInsets.all(AppSpacing.sm);
      case AppStatCardSize.medium:
        return const EdgeInsets.all(AppSpacing.md);
      case AppStatCardSize.large:
        return const EdgeInsets.all(AppSpacing.lg);
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppStatCardSize.small:
        return AppIconSize.sm;
      case AppStatCardSize.medium:
        return AppIconSize.md;
      case AppStatCardSize.large:
        return AppIconSize.lg;
    }
  }

  double _getIconContainerSize() {
    switch (size) {
      case AppStatCardSize.small:
        return 32;
      case AppStatCardSize.medium:
        return 44;
      case AppStatCardSize.large:
        return 56;
    }
  }

  TextStyle _getValueStyle(ThemeData theme, bool isDark) {
    final baseColor = isDark ? Colors.white : AppColors.gray900;
    switch (size) {
      case AppStatCardSize.small:
        return theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: baseColor,
        );
      case AppStatCardSize.medium:
        return theme.textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w700,
          color: baseColor,
        );
      case AppStatCardSize.large:
        return theme.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.w700,
          color: baseColor,
        );
    }
  }

  TextStyle _getLabelStyle(ThemeData theme, bool isDark) {
    final baseColor = isDark ? AppColors.gray400 : AppColors.gray500;
    switch (size) {
      case AppStatCardSize.small:
        return theme.textTheme.bodySmall!.copyWith(color: baseColor);
      case AppStatCardSize.medium:
        return theme.textTheme.bodyMedium!.copyWith(color: baseColor);
      case AppStatCardSize.large:
        return theme.textTheme.bodyLarge!.copyWith(color: baseColor);
    }
  }

  Widget _buildVerticalLayout(
    ThemeData theme,
    bool isDark,
    Color iconColor,
    Color iconBgColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          _buildIconContainer(iconColor, iconBgColor),
          SizedBox(height: size == AppStatCardSize.small ? AppSpacing.sm : AppSpacing.md),
        ],
        Text(value, style: _getValueStyle(theme, isDark)),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: _getLabelStyle(theme, isDark),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trend != null && trendValue != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildTrendBadge(theme, isDark),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalLayout(
    ThemeData theme,
    bool isDark,
    Color iconColor,
    Color iconBgColor,
  ) {
    return Row(
      children: [
        if (icon != null) ...[
          _buildIconContainer(iconColor, iconBgColor),
          SizedBox(width: size == AppStatCardSize.small ? AppSpacing.sm : AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(value, style: _getValueStyle(theme, isDark)),
                  if (trend != null && trendValue != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    _buildTrendBadge(theme, isDark),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: _getLabelStyle(theme, isDark),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: _getValueStyle(theme, isDark)),
            if (trend != null && trendValue != null) ...[
              const SizedBox(width: AppSpacing.sm),
              _buildTrendBadge(theme, isDark),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: _getLabelStyle(theme, isDark),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildIconContainer(Color iconColor, Color bgColor) {
    final containerSize = _getIconContainerSize();
    final iconSize = _getIconSize();

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildTrendBadge(ThemeData theme, bool isDark) {
    Color trendColor;
    IconData trendIcon;

    switch (trend) {
      case 'up':
        trendColor = AppColors.secondary;
        trendIcon = Icons.trending_up_rounded;
        break;
      case 'down':
        trendColor = AppColors.error;
        trendIcon = Icons.trending_down_rounded;
        break;
      default:
        trendColor = isDark ? AppColors.gray400 : AppColors.gray500;
        trendIcon = Icons.trending_flat_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: trendColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: AppIconSize.xs,
            color: trendColor,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            trendValue!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 통계 카드 그룹
/// 여러 AppStatCard를 그리드 형태로 배치
class AppStatCardGroup extends StatelessWidget {
  const AppStatCardGroup({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = AppSpacing.md,
    this.crossAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1.2,
    this.animate = true,
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  /// 통계 카드들
  final List<AppStatCard> children;

  /// 열 개수
  final int crossAxisCount;

  /// 세로 간격
  final double mainAxisSpacing;

  /// 가로 간격
  final double crossAxisSpacing;

  /// 아이템 가로세로 비율
  final double childAspectRatio;

  /// 등장 애니메이션 활성화
  final bool animate;

  /// 순차적 애니메이션 지연
  final Duration staggerDelay;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final card = children[index];
        return AppStatCard(
          value: card.value,
          label: card.label,
          icon: card.icon,
          iconColor: card.iconColor,
          iconBackgroundColor: card.iconBackgroundColor,
          trend: card.trend,
          trendValue: card.trendValue,
          size: card.size,
          layout: card.layout,
          onTap: card.onTap,
          cardVariant: card.cardVariant,
          animate: animate,
          animationDelay: animate ? staggerDelay * index : Duration.zero,
        );
      },
    );
  }
}
