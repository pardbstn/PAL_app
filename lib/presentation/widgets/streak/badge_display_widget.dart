import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/badge_model.dart';
import '../../../data/models/streak_model.dart';
import '../../providers/streak_provider.dart';

/// 획득한 배지를 가로 스크롤 목록으로 보여주는 위젯
class BadgeDisplayWidget extends ConsumerWidget {
  final StreakModel? streak;
  final bool showLocked;
  final int maxVisible;
  final VoidCallback? onViewAll;

  const BadgeDisplayWidget({
    super.key,
    required this.streak,
    this.showLocked = true,
    this.maxVisible = 10,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final earnedBadges = ref.watch(earnedBadgesProvider(streak));
    final allBadges = _getAllBadges();

    // 획득 배지 + 미획득 배지 (showLocked가 true인 경우)
    final displayBadges = showLocked
        ? allBadges
        : earnedBadges;

    final earnedCount = earnedBadges.length;
    final totalCount = allBadges.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    '🏆',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '획득 배지',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$earnedCount개 획득',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('전체보기'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 배지 리스트
        SizedBox(
          height: 100,
          child: displayBadges.isEmpty
              ? _buildEmptyState(theme, colorScheme)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: displayBadges.length.clamp(0, maxVisible),
                  itemBuilder: (context, index) {
                    final badge = displayBadges[index];
                    final isEarned = earnedBadges.any((b) => b.code == badge.code);

                    return _BadgeItem(
                      badge: badge,
                      isEarned: isEarned,
                      index: index,
                      streak: streak,
                    );
                  },
                ),
        ),

        // 진행률 표시
        if (earnedCount < totalCount)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _buildProgressIndicator(
              earnedCount,
              totalCount,
              theme,
              colorScheme,
            ),
          ),
      ],
    );
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
    }).toList()
      ..sort((a, b) => a.requiredStreak.compareTo(b.requiredStreak));
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 32,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 획득한 배지가 없어요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            '기록을 시작해보세요!',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    int earned,
    int total,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final progress = earned / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '배지 수집 진행률',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '$earned / $total',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

/// 개별 배지 아이템
class _BadgeItem extends StatelessWidget {
  final BadgeModel badge;
  final bool isEarned;
  final int index;
  final StreakModel? streak;

  const _BadgeItem({
    required this.badge,
    required this.isEarned,
    required this.index,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 배지 타입별 색상
    final badgeColor = badge.streakType == StreakType.weight
        ? const Color(0xFF2563EB)
        : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, theme, colorScheme, badgeColor),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // 배지 아이콘
            Container(
              width: 56,
              height: 56,
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
                color: isEarned ? null : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isEarned
                      ? badgeColor.withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: isEarned
                    ? [
                        BoxShadow(
                          color: badgeColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    badge.streakType == StreakType.weight
                        ? Icons.monitor_weight
                        : Icons.restaurant,
                    size: 28,
                    color: isEarned
                        ? badgeColor
                        : colorScheme.onSurface.withValues(alpha: 0.3),
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
                        ),
                        child: Icon(
                          Icons.lock,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 배지 이름
            Text(
              '${badge.requiredStreak}일',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isEarned
                    ? badgeColor
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            // 타입 표시
            Text(
              badge.streakType.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    )
        .animate(delay: (index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  void _showBadgeDetail(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    Color badgeColor,
  ) {
    // 진행률 계산
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
            // 배지 아이콘 (큰 버전)
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

            // 배지 이름
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
