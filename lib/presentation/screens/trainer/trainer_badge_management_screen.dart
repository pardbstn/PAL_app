import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/data/models/trainer_badge_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_badge_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_stats_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';

/// 트레이너 배지 관리 화면
class TrainerBadgeManagementScreen extends ConsumerWidget {
  const TrainerBadgeManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final trainerId = authState.trainerModel?.id ?? '';

    if (trainerId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    final badgesAsync = ref.watch(trainerBadgesProvider(trainerId));
    final statsAsync = ref.watch(trainerStatsProvider(trainerId));
    final ratingAsync = ref.watch(trainerRatingProvider(trainerId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '배지 관리',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 평점 요약 카드
            ratingAsync.when(
              data: (rating) => _buildRatingCard(context, isDark, rating),
              loading: () => const SizedBox(height: 80),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // 보유 배지 섹션
            Text(
              '보유 배지',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            badgesAsync.when(
              data: (badges) => _buildActiveBadges(context, isDark, badges),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('배지 로딩 실패'),
            ),
            const SizedBox(height: 32),

            // 배지 진행률 섹션
            Text(
              '배지 진행률',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            statsAsync.when(
              data: (stats) => _buildBadgeProgressList(context, isDark, ref, stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('통계 로딩 실패'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 평점 요약 카드
  Widget _buildRatingCard(BuildContext context, bool isDark, dynamic rating) {
    final overall = rating?.overall ?? 0.0;
    final memberRating = rating?.memberRating ?? 0.0;
    final aiRating = rating?.aiRating ?? 0.0;
    final reviewCount = rating?.reviewCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 큰 별점
              Column(
                children: [
                  Icon(Icons.star_rounded, color: const Color(0xFFF59E0B), size: 40),
                  const SizedBox(height: 4),
                  Text(
                    overall > 0 ? overall.toStringAsFixed(1) : '-',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '$reviewCount개 리뷰',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // 세부 점수
              Expanded(
                child: Column(
                  children: [
                    _buildRatingRow('회원 평가', memberRating, isDark),
                    const SizedBox(height: 8),
                    _buildRatingRow('AI 분석', aiRating, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 가중치 안내
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF162035) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '종합 평점 = 회원 평가(60%) + AI 분석(40%)',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRatingRow(String label, double value, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5.0,
              backgroundColor: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value > 0 ? value.toStringAsFixed(1) : '-',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  /// 보유 배지 그리드
  Widget _buildActiveBadges(BuildContext context, bool isDark, dynamic badges) {
    final activeBadges = badges?.activeBadges ?? [];
    if (activeBadges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                size: 48,
                color: isDark ? Colors.white24 : Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                '아직 획득한 배지가 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '아래 진행률을 확인해 배지를 획득해보세요!',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: 100.ms).fadeIn(duration: 400.ms);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: activeBadges.length,
      itemBuilder: (context, index) {
        final badge = activeBadges[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(badge.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                badge.name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 100 + index * 50))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 300.ms);
      },
    );
  }

  /// 배지 진행률 리스트
  Widget _buildBadgeProgressList(BuildContext context, bool isDark, WidgetRef ref, dynamic stats) {
    final progressList = ref.watch(badgeProgressProvider(stats));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: progressList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final progress = progressList[index];
        return _buildBadgeProgressItem(context, isDark, progress, index);
      },
    );
  }

  Widget _buildBadgeProgressItem(BuildContext context, bool isDark, BadgeProgress progress, int index) {
    final badgeType = progress.badgeType;
    final isEarned = progress.isEarned;

    // 응답시간 배지는 "이하"이므로 진행률 역산
    final isResponseBadge = badgeType == TrainerBadgeType.lightningResponse ||
        badgeType == TrainerBadgeType.fastResponse;
    final displayProgress = isResponseBadge
        ? (progress.currentValue > 0
            ? (progress.targetValue / progress.currentValue).clamp(0.0, 1.0)
            : 0.0)
        : progress.progress;

    String currentDisplay;
    String targetDisplay;
    if (isResponseBadge) {
      currentDisplay = '${progress.currentValue.toStringAsFixed(0)}분';
      targetDisplay = '${progress.targetValue.toStringAsFixed(0)}분 이내';
    } else if (badgeType == TrainerBadgeType.bodyTransformExpert) {
      currentDisplay = '${progress.currentValue.toStringAsFixed(1)}%';
      targetDisplay = '-${progress.targetValue.toStringAsFixed(0)}% 이상';
    } else if (badgeType == TrainerBadgeType.zeroNoShow) {
      currentDisplay = '${progress.currentValue.toStringAsFixed(1)}%';
      targetDisplay = '0%';
    } else if (progress.targetValue >= 50) {
      currentDisplay = '${progress.currentValue.toStringAsFixed(0)}';
      targetDisplay = '${progress.targetValue.toStringAsFixed(0)}';
    } else if (progress.targetValue > 5) {
      currentDisplay = '${progress.currentValue.toStringAsFixed(0)}%';
      targetDisplay = '${progress.targetValue.toStringAsFixed(0)}%';
    } else {
      currentDisplay = '${progress.currentValue.toStringAsFixed(0)}';
      targetDisplay = '${progress.targetValue.toStringAsFixed(0)}';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEarned
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : (isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(badgeType.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          badgeType.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        if (isEarned) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '획득',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badgeType.description,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              // 수치 표시
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentDisplay,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isEarned
                          ? const Color(0xFF10B981)
                          : (isDark ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                  Text(
                    '/ $targetDisplay',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // 진행률 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: displayProgress,
              backgroundColor: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isEarned ? const Color(0xFF10B981) : const Color(0xFF2563EB),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 200 + index * 40))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }
}
