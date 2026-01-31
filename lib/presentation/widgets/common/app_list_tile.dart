import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_tokens.dart';

/// 리스트 타일 변형 타입
enum AppListTileVariant {
  /// 기본 스타일: 투명 배경
  standard,

  /// 카드 스타일: 흰색 배경 + 보더
  card,

  /// 강조 스타일: primary 배경 틴트
  accent,
}

/// PAL 앱의 공통 리스트 타일 위젯
///
/// 설정 화면, 메뉴 등에서 사용하는 통일된 리스트 아이템 컴포넌트.
/// 다크모드를 자동으로 지원합니다.
class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.variant = AppListTileVariant.standard,
    this.showDivider = false,
    this.enabled = true,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.contentPadding,
  });

  /// 타이틀 텍스트
  final String title;

  /// 서브타이틀 텍스트 (선택)
  final String? subtitle;

  /// 앞쪽 위젯 (아이콘 등)
  final Widget? leading;

  /// 뒤쪽 위젯 (화살표, 스위치 등)
  final Widget? trailing;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 스타일 변형
  final AppListTileVariant variant;

  /// 하단 구분선 표시 여부
  final bool showDivider;

  /// 활성화 상태
  final bool enabled;

  /// 등장 애니메이션 활성화 여부
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  /// 커스텀 패딩
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final effectivePadding = contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        );

    Widget tile = _buildTileContent(
      context,
      theme,
      isDark,
      colorScheme,
      effectivePadding,
    );

    if (animate) {
      tile = tile
          .animate(delay: animationDelay)
          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
          .slideX(begin: -0.02, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }

    return tile;
  }

  Widget _buildTileContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    ColorScheme colorScheme,
    EdgeInsets padding,
  ) {
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      color: enabled
          ? (isDark ? Colors.white : AppColors.gray900)
          : (isDark ? AppColors.gray500 : AppColors.gray400),
    );

    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: isDark ? AppColors.gray400 : AppColors.gray500,
    );

    Widget content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(
                color: enabled
                    ? colorScheme.primary
                    : (isDark ? AppColors.gray500 : AppColors.gray400),
                size: AppIconSize.md,
              ),
              child: leading!,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: subtitleStyle),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            IconTheme(
              data: IconThemeData(
                color: isDark ? AppColors.gray400 : AppColors.gray500,
                size: AppIconSize.sm,
              ),
              child: trailing!,
            ),
          ] else if (onTap != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.gray500 : AppColors.gray400,
              size: AppIconSize.md,
            ),
          ],
        ],
      ),
    );

    // variant에 따른 스타일 적용
    switch (variant) {
      case AppListTileVariant.standard:
        content = _wrapWithInteraction(content, colorScheme, isDark);
        break;
      case AppListTileVariant.card:
        content = Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: AppRadius.mdBorderRadius,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.gray200,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdBorderRadius,
            child: _wrapWithInteraction(content, colorScheme, isDark),
          ),
        );
        break;
      case AppListTileVariant.accent:
        content = Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: AppRadius.mdBorderRadius,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.mdBorderRadius,
            child: _wrapWithInteraction(content, colorScheme, isDark),
          ),
        );
        break;
    }

    if (showDivider && variant == AppListTileVariant.standard) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
            indent: leading != null ? AppSpacing.md + AppIconSize.md + AppSpacing.md : AppSpacing.md,
            endIndent: AppSpacing.md,
          ),
        ],
      );
    }

    return content;
  }

  Widget _wrapWithInteraction(
    Widget child,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (onTap == null || !enabled) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: colorScheme.primary.withValues(alpha: 0.04),
        child: child,
      ),
    );
  }
}

/// 그룹화된 리스트 타일을 위한 래퍼
/// 여러 AppListTile을 카드 형태로 묶어서 표시
class AppListTileGroup extends StatelessWidget {
  const AppListTileGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.animate = true,
    this.animationDelay = Duration.zero,
  });

  /// 리스트 타일들
  final List<AppListTile> children;

  /// 그룹 헤더 텍스트
  final String? header;

  /// 그룹 푸터 텍스트
  final String? footer;

  /// 등장 애니메이션 활성화
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget group = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              bottom: AppSpacing.sm,
            ),
            child: Text(
              header!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isDark ? AppColors.gray400 : AppColors.gray500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: AppRadius.lgBorderRadius,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.gray200,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgBorderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  AppListTile(
                    title: children[i].title,
                    subtitle: children[i].subtitle,
                    leading: children[i].leading,
                    trailing: children[i].trailing,
                    onTap: children[i].onTap,
                    variant: AppListTileVariant.standard,
                    showDivider: i < children.length - 1,
                    enabled: children[i].enabled,
                    animate: false,
                    contentPadding: children[i].contentPadding,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (footer != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              top: AppSpacing.sm,
            ),
            child: Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.gray500 : AppColors.gray400,
              ),
            ),
          ),
        ],
      ],
    );

    if (animate) {
      group = group
          .animate(delay: animationDelay)
          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
          .slideY(begin: 0.02, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }

    return group;
  }
}
