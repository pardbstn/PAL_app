import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/badge_model.dart';
import '../../../data/models/streak_model.dart';
import '../../providers/streak_provider.dart';
import '../../widgets/streak/streak_calendar_widget.dart';

/// 전체 배지 컬렉션을 보여주는 스크린
class BadgesScreen extends ConsumerWidget {
  final String memberId;

  const BadgesScreen({
    super.key,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(memberStreakProvider(memberId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('배지 컬렉션'),
        centerTitle: true,
        elevation: 0,
      ),
      body: streakAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                '데이터를 불러올 수 없습니다',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.refresh(memberStreakProvider(memberId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (streak) => _buildContent(context, ref, streak, theme, colorScheme),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    StreakModel? streak,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final earnedBadges = ref.watch(earnedBadgesProvider(streak));
    final nextBadges = ref.watch(nextBadgesProvider(streak));
    final allBadges = _getAllBadges();

    return CustomScrollView(
      slivers: [
        // 스트릭 요약 헤더
        SliverToBoxAdapter(
          child: _buildStreakSummaryHeader(
            context,
            streak,
            theme,
            colorScheme,
          ),
        ),

        // 섹션: 획득한 배지
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: _buildSectionHeader(
              theme,
              '획득한 배지',
              '🏆',
              earnedBadges.length,
              const Color(0xFF10B981),
            ),
          ),
        ),

        earnedBadges.isEmpty
            ? SliverToBoxAdapter(
                child: _buildEmptyBadgeState(
                  theme,
                  colorScheme,
                  '아직 획득한 배지가 없어요',
                  '기록을 시작해서 첫 배지를 획득해보세요!',
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _BadgeGridItem(
                      badge: earnedBadges[index],
                      isEarned: true,
                      streak: streak,
                      index: index,
                    ),
                    childCount: earnedBadges.length,
                  ),
                ),
              ),

        // 섹션: 다음 목표
        if (nextBadges.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: _buildSectionHeader(
                theme,
                '다음 목표',
                '🎯',
                nextBadges.length,
                const Color(0xFFF59E0B),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _BadgeGridItem(
                  badge: nextBadges[index],
                  isEarned: false,
                  streak: streak,
                  index: index,
                  showProgress: true,
                ),
                childCount: nextBadges.length,
              ),
            ),
          ),
        ],

        // 전체 진행률
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildOverallProgress(
              earnedBadges.length,
              allBadges.length,
              theme,
              colorScheme,
            ),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildStreakSummaryHeader(
    BuildContext context,
    StreakModel? streak,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2563EB).withValues(alpha: 0.1),
            const Color(0xFF10B981).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // 타이틀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '나의 스트릭 기록',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 스트릭 카드들
          Row(
            children: [
              Expanded(
                child: _buildStreakCard(
                  context,
                  theme,
                  colorScheme,
                  streak,
                  StreakType.weight,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStreakCard(
                  context,
                  theme,
                  colorScheme,
                  streak,
                  StreakType.diet,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildStreakCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    StreakModel? streak,
    StreakType type,
  ) {
    final color = type == StreakType.weight
        ? const Color(0xFF2563EB)
        : const Color(0xFF10B981);

    final currentStreak = type == StreakType.weight
        ? streak?.weightStreak ?? 0
        : streak?.dietStreak ?? 0;

    final longestStreak = type == StreakType.weight
        ? streak?.longestWeightStreak ?? 0
        : streak?.longestDietStreak ?? 0;

    return GestureDetector(
      onTap: () => _showCalendarDialog(context, streak, type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == StreakType.weight
                      ? Icons.monitor_weight_outlined
                      : Icons.restaurant_outlined,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '🔥',
                  style: TextStyle(
                    fontSize: currentStreak > 0 ? 20 : 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '$currentStreak',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '일',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '최장 $longestStreak일',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarDialog(
    BuildContext context,
    StreakModel? streak,
    StreakType type,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${type.label} 기록 캘린더',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              StreakCalendarWidget(
                streak: streak,
                type: type,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ThemeData theme,
    String title,
    String emoji,
    int count,
    Color color,
  ) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count개',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBadgeState(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgress(
    int earned,
    int total,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final progress = total > 0 ? earned / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.1),
            const Color(0xFFFF6B35).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '전체 수집 현황',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor:
                      const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFF59E0B),
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                  Text(
                    '$earned / $total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            earned == total
                ? '모든 배지를 획득했어요! 대단해요! 🎉'
                : '${total - earned}개의 배지가 기다리고 있어요!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  List<BadgeModel> _getAllBadges() {
    return DefaultBadges.badges.map((data) {
      return BadgeModel(
        id: data['code'] as String,
        code: data['code'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        iconUrl: data['iconUrl'] as String,
        requiredStreak: data['requiredStreak'] as int,
        streakType: data['streakType'] == 'weight'
            ? StreakType.weight
            : StreakType.diet,
      );
    }).toList();
  }
}

/// 배지 그리드 아이템
class _BadgeGridItem extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final StreakModel? streak;
  final int index;
  final bool showProgress;

  const _BadgeGridItem({
    required this.badge,
    required this.isEarned,
    required this.streak,
    required this.index,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final badgeColor = badge.streakType == StreakType.weight
        ? const Color(0xFF2563EB)
        : const Color(0xFF10B981);

    // 진행률 계산
    final currentStreak = badge.streakType == StreakType.weight
        ? streak?.weightStreak ?? 0
        : streak?.dietStreak ?? 0;
    final progress = (currentStreak / badge.requiredStreak).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, theme, colorScheme, badgeColor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEarned
              ? badgeColor.withValues(alpha: 0.05)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEarned
                ? badgeColor.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: isEarned
              ? [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 배지 아이콘
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: isEarned
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              badgeColor.withValues(alpha: 0.2),
                              badgeColor.withValues(alpha: 0.1),
                            ],
                          )
                        : null,
                    color: isEarned ? null : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isEarned
                          ? badgeColor.withValues(alpha: 0.5)
                          : colorScheme.outline.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    badge.streakType == StreakType.weight
                        ? Icons.monitor_weight
                        : Icons.restaurant,
                    size: 24,
                    color: isEarned
                        ? badgeColor
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
                if (!isEarned)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 배지 이름
            Text(
              badge.name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isEarned
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),

            // 진행률 표시
            if (showProgress && !isEarned) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: badgeColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$currentStreak/${badge.requiredStreak}일',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }

  void _showBadgeDetail(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Color badgeColor,
  ) {
    final currentStreak = badge.streakType == StreakType.weight
        ? streak?.weightStreak ?? 0
        : streak?.dietStreak ?? 0;
    final progress = (currentStreak / badge.requiredStreak).clamp(0.0, 1.0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 배지 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: isEarned
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          badgeColor.withValues(alpha: 0.3),
                          badgeColor.withValues(alpha: 0.1),
                        ],
                      )
                    : null,
                color: isEarned ? null : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEarned
                      ? badgeColor
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: 3,
                ),
              ),
              child: Icon(
                badge.streakType == StreakType.weight
                    ? Icons.monitor_weight
                    : Icons.restaurant,
                size: 40,
                color: isEarned
                    ? badgeColor
                    : colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),

            // 이름
            Text(
              badge.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 설명
            Text(
              badge.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 상태
            if (isEarned)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '획득 완료',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Text(
                    '진행률: $currentStreak / ${badge.requiredStreak}일',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: badgeColor.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(badgeColor),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${badge.requiredStreak - currentStreak}일 더 기록하면 획득!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
