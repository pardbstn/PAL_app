import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_tokens.dart';

/// 웹 대시보드용 통계 카드 변형
enum WebStatCardVariant {
  /// 기본 스타일
  primary,

  /// 성공/증가 스타일
  success,

  /// 경고 스타일
  warning,

  /// 에러/감소 스타일
  error,

  /// 정보 스타일
  info,
}

/// 웹 대시보드용 통계 카드 위젯
class WebStatCard extends StatefulWidget {
  const WebStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconBackgroundColor,
    this.variant = WebStatCardVariant.primary,
    this.trend,
    this.trendLabel,
    this.onTap,
    this.isLoading = false,
    this.animationDelay = Duration.zero,
  });

  /// 카드 제목
  final String title;

  /// 메인 값 (숫자 또는 텍스트)
  final String value;

  /// 부가 설명
  final String? subtitle;

  /// 아이콘
  final IconData? icon;

  /// 아이콘 배경색 (기본: variant 기반)
  final Color? iconBackgroundColor;

  /// 카드 스타일 변형
  final WebStatCardVariant variant;

  /// 트렌드 수치 (양수: 증가, 음수: 감소)
  final double? trend;

  /// 트렌드 라벨 (예: "지난 주 대비")
  final String? trendLabel;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 로딩 상태
  final bool isLoading;

  /// 애니메이션 딜레이
  final Duration animationDelay;

  @override
  State<WebStatCard> createState() => _WebStatCardState();
}

class _WebStatCardState extends State<WebStatCard> {
  bool _isHovered = false;

  Color _getVariantColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (widget.variant) {
      WebStatCardVariant.primary => colorScheme.primary,
      WebStatCardVariant.success => const Color(0xFF10B981),
      WebStatCardVariant.warning => const Color(0xFFF59E0B),
      WebStatCardVariant.error => colorScheme.error,
      WebStatCardVariant.info => const Color(0xFF3B82F6),
    };
  }

  Color _getTrendColor() {
    if (widget.trend == null) return Colors.grey;
    if (widget.trend! > 0) return const Color(0xFF10B981);
    if (widget.trend! < 0) return const Color(0xFFEF4444);
    return Colors.grey;
  }

  IconData _getTrendIcon() {
    if (widget.trend == null) return Icons.remove;
    if (widget.trend! > 0) return Icons.trending_up;
    if (widget.trend! < 0) return Icons.trending_down;
    return Icons.trending_flat;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final variantColor = _getVariantColor(context);

    final card = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppDurations.fast,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isHovered
                  ? variantColor.withValues(alpha: 0.5)
                  : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2)),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: variantColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : AppShadows.sm,
          ),
          transform: _isHovered ? Matrix4.diagonal3Values(1.02, 1.02, 1.0) : Matrix4.identity(),
          child: widget.isLoading ? _buildLoadingSkeleton(context) : _buildContent(context),
        ),
      ),
    );

    if (widget.animationDelay > Duration.zero) {
      return card
          .animate(delay: widget.animationDelay)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.1, end: 0, duration: 400.ms);
    }

    return card;
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final variantColor = _getVariantColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 헤더: 아이콘 + 제목
        Row(
          children: [
            if (widget.icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (widget.iconBackgroundColor ?? variantColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.iconBackgroundColor ?? variantColor,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 메인 값
        Text(
          widget.value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        // 트렌드 또는 부제목
        if (widget.trend != null || widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.trend != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTrendColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(),
                        size: 14,
                        color: _getTrendColor(),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.trend! > 0 ? '+' : ''}${widget.trend!.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getTrendColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.trendLabel != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.trendLabel!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ] else if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 100,
          height: 32,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 14,
          decoration: BoxDecoration(
            color: skeletonColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: isDark ? Colors.grey[700] : Colors.grey[300]);
  }
}

/// 큰 통계 카드 (차트 포함 가능)
class WebStatCardLarge extends StatelessWidget {
  const WebStatCardLarge({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.minHeight,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final EdgeInsets padding;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: minHeight != null ? BoxConstraints(minHeight: minHeight!) : null,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, padding.top, padding.right, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 콘텐츠
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, padding.bottom),
            child: child,
          ),
        ],
      ),
    );
  }
}
