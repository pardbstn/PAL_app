import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_tokens.dart';

/// PAL 앱의 공통 섹션 위젯
///
/// 제목 + 컨텐츠 + 간격을 포함한 섹션 래퍼 컴포넌트.
/// 화면을 논리적인 섹션으로 구분할 때 사용합니다.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.padding,
    this.titlePadding,
    this.spacing = AppSpacing.md,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.showMoreButton = false,
    this.onMorePressed,
  });

  /// 섹션 제목
  final String? title;

  /// 섹션 부제목 (선택)
  final String? subtitle;

  /// 제목 옆에 표시할 위젯 (예: 더보기 버튼)
  final Widget? trailing;

  /// 섹션 내용
  final Widget child;

  /// 섹션 전체 패딩 (기본값: EdgeInsets.zero)
  final EdgeInsets? padding;

  /// 제목 영역 패딩
  final EdgeInsets? titlePadding;

  /// 제목과 내용 사이 간격
  final double spacing;

  /// 등장 애니메이션 활성화 여부
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  /// '더보기' 버튼 표시 여부
  final bool showMoreButton;

  /// '더보기' 버튼 탭 콜백
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectivePadding = padding ?? EdgeInsets.zero;
    final effectiveTitlePadding = titlePadding ??
        const EdgeInsets.symmetric(horizontal: AppSpacing.md);

    Widget section = Padding(
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: effectiveTitlePadding,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.gray900,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.gray400 : AppColors.gray500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (showMoreButton && onMorePressed != null)
                    _buildMoreButton(context, isDark),
                ],
              ),
            ),
            SizedBox(height: spacing),
          ],
          child,
        ],
      ),
    );

    if (animate) {
      section = section
          .animate(delay: animationDelay)
          .fadeIn(duration: 300.ms, curve: Curves.easeOut)
          .slideY(begin: 0.02, end: 0, duration: 300.ms, curve: Curves.easeOut);
    }

    return section;
  }

  Widget _buildMoreButton(BuildContext context, bool isDark) {
    return TextButton(
      onPressed: onMorePressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '더보기',
            style: TextStyle(
              fontSize: AppTextStyle.bodySmall,
              color: isDark ? AppColors.gray400 : AppColors.gray500,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.chevron_right_rounded,
            size: AppIconSize.sm,
            color: isDark ? AppColors.gray400 : AppColors.gray500,
          ),
        ],
      ),
    );
  }
}

/// 수평 스크롤 섹션
/// 가로로 스크롤되는 카드 목록을 위한 섹션
class AppHorizontalSection extends StatelessWidget {
  const AppHorizontalSection({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.itemSpacing = AppSpacing.md,
    this.padding,
    this.height = 160,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.showMoreButton = false,
    this.onMorePressed,
  });

  /// 섹션 제목
  final String? title;

  /// 섹션 부제목
  final String? subtitle;

  /// 제목 옆에 표시할 위젯
  final Widget? trailing;

  /// 가로 스크롤할 아이템들
  final List<Widget> children;

  /// 아이템 간 간격
  final double itemSpacing;

  /// 섹션 패딩
  final EdgeInsets? padding;

  /// 스크롤 영역 높이
  final double height;

  /// 등장 애니메이션 활성화
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  /// '더보기' 버튼 표시 여부
  final bool showMoreButton;

  /// '더보기' 버튼 탭 콜백
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      padding: padding,
      animate: animate,
      animationDelay: animationDelay,
      showMoreButton: showMoreButton,
      onMorePressed: onMorePressed,
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: children.length,
          separatorBuilder: (context, index) => SizedBox(width: itemSpacing),
          itemBuilder: (context, index) => children[index],
        ),
      ),
    );
  }
}

/// 그리드 섹션
/// 그리드 레이아웃의 아이템들을 위한 섹션
class AppGridSection extends StatelessWidget {
  const AppGridSection({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = AppSpacing.md,
    this.crossAxisSpacing = AppSpacing.md,
    this.childAspectRatio = 1.0,
    this.padding,
    this.animate = true,
    this.animationDelay = Duration.zero,
    this.showMoreButton = false,
    this.onMorePressed,
  });

  /// 섹션 제목
  final String? title;

  /// 섹션 부제목
  final String? subtitle;

  /// 제목 옆에 표시할 위젯
  final Widget? trailing;

  /// 그리드 아이템들
  final List<Widget> children;

  /// 열 개수
  final int crossAxisCount;

  /// 세로 간격
  final double mainAxisSpacing;

  /// 가로 간격
  final double crossAxisSpacing;

  /// 아이템 가로세로 비율
  final double childAspectRatio;

  /// 섹션 패딩
  final EdgeInsets? padding;

  /// 등장 애니메이션 활성화
  final bool animate;

  /// 애니메이션 지연 시간
  final Duration animationDelay;

  /// '더보기' 버튼 표시 여부
  final bool showMoreButton;

  /// '더보기' 버튼 탭 콜백
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    return AppSection(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      padding: padding,
      animate: animate,
      animationDelay: animationDelay,
      showMoreButton: showMoreButton,
      onMorePressed: onMorePressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: children,
        ),
      ),
    );
  }
}
