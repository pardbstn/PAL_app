import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/member_review_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';
import 'package:flutter_pal_app/presentation/widgets/common/card_animations.dart';

/// 트레이너 평점 상세 화면
class TrainerRatingDetailScreen extends ConsumerWidget {
  final String? externalTrainerId;

  const TrainerRatingDetailScreen({super.key, this.externalTrainerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final trainerId = externalTrainerId ?? authState.trainerModel?.id ?? '';

    if (trainerId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('로그인이 필요해요')),
      );
    }

    final ratingAsync = ref.watch(trainerRatingProvider(trainerId));
    final reviewsAsync = ref.watch(sortedTrainerReviewsProvider(trainerId));
    final categoryAverages = ref.watch(categoryAveragesProvider(trainerId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(externalTrainerId != null ? '트레이너 평점' : '내 평점'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 전체 평점 카드
                _OverallRatingCard(
                  ratingAsync: ratingAsync,
                  isDark: isDark,
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.02, duration: 200.ms),
                const SizedBox(height: AppSpacing.lg),

                // 카테고리별 평점
                _CategoryBreakdownSection(
                  categoryAverages: categoryAverages,
                  isDark: isDark,
                ).animate(delay: 50.ms).fadeIn(duration: 200.ms).slideY(begin: 0.02, duration: 200.ms),
                const SizedBox(height: AppSpacing.lg),

                // 정렬 옵션
                _SortOptionsRow(isDark: isDark)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 200.ms),
                const SizedBox(height: AppSpacing.md),

                // 리뷰 목록
                _ReviewsList(
                  reviewsAsync: reviewsAsync,
                  isDark: isDark,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// 전체 평점 카드
class _OverallRatingCard extends StatelessWidget {
  final AsyncValue ratingAsync;
  final bool isDark;

  const _OverallRatingCard({
    required this.ratingAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ratingAsync.when(
          data: (rating) {
            final overall = rating?.overall ?? 0.0;
            final reviewCount = rating?.reviewCount ?? 0;

            return Column(
              children: [
                // 별점 시각화
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    if (overall >= starValue) {
                      return const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 36);
                    } else if (overall >= starValue - 0.5) {
                      return const Icon(Icons.star_half_rounded, color: AppColors.tertiary, size: 36);
                    } else {
                      return Icon(Icons.star_outline_rounded,
                          color: isDark ? Colors.white30 : Colors.grey.shade300, size: 36);
                    }
                  }),
                ),
                const SizedBox(height: AppSpacing.md),

                // 평점 숫자
                Text(
                  overall > 0 ? overall.toStringAsFixed(1) : '-',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // 리뷰 수
                Text(
                  '$reviewCount개의 리뷰',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : const Color(0xFF64748B),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox(
            height: 150,
            child: Center(child: Text('평점을 불러올 수 없어요')),
          ),
        ),
      ),
    );
  }
}

/// 카테고리별 평점 섹션
class _CategoryBreakdownSection extends StatelessWidget {
  final ({double coaching, double communication, double kindness})? categoryAverages;
  final bool isDark;

  const _CategoryBreakdownSection({
    required this.categoryAverages,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 평점',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            if (categoryAverages != null) ...[
              _CategoryProgressBar(
                label: '코칭 만족도',
                value: categoryAverages!.coaching,
                color: AppColors.primary,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CategoryProgressBar(
                label: '소통',
                value: categoryAverages!.communication,
                color: AppColors.secondary,
                isDark: isDark,
              ),
              const SizedBox(height: AppSpacing.sm),
              _CategoryProgressBar(
                label: '친절도',
                value: categoryAverages!.kindness,
                color: AppColors.tertiary,
                isDark: isDark,
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    '아직 리뷰가 없어요',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 진행바
class _CategoryProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isDark;

  const _CategoryProgressBar({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
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
              value: value / 5,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 32,
          child: Text(
            value.toStringAsFixed(1),
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}

/// 정렬 옵션 Row
class _SortOptionsRow extends ConsumerWidget {
  final bool isDark;

  const _SortOptionsRow({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSort = ref.watch(reviewSortOptionProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ReviewSortOption.values.map((option) {
          final isSelected = currentSort == option;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(reviewSortOptionProvider.notifier).setOption(option);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.gray100),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 리뷰 목록
class _ReviewsList extends StatelessWidget {
  final AsyncValue<List<MemberReviewModel>> reviewsAsync;
  final bool isDark;

  const _ReviewsList({
    required this.reviewsAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return reviewsAsync.when(
      data: (reviews) {
        if (reviews.isEmpty) {
          return _EmptyReviewsState(isDark: isDark);
        }

        return AnimatedListWrapper(
          child: Column(
            children: reviews.asMap().entries.map((entry) {
              final index = entry.key;
              final review = entry.value;
              return AnimatedListWrapper.item(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ReviewCard(review: review, isDark: isDark),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            '리뷰를 불러올 수 없어요',
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

/// 빈 리뷰 상태
class _EmptyReviewsState extends StatelessWidget {
  final bool isDark;

  const _EmptyReviewsState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl * 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '아직 리뷰가 없어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '회원들의 리뷰가 이곳에 표시돼요',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 리뷰 카드
class _ReviewCard extends StatelessWidget {
  final MemberReviewModel review;
  final bool isDark;

  const _ReviewCard({
    required this.review,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final avgRating = MemberReviewModel.averageRating(review);
    final dateStr = DateFormat('yyyy.MM.dd').format(review.createdAt);

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 아바타 + 이름 + 날짜
            Row(
              children: [
                // 아바타
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      review.memberName.isNotEmpty ? review.memberName[0] : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // 이름 + 날짜
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.memberName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),

                // 평균 평점
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.tertiary, size: 18),
                    const SizedBox(width: 2),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // 개별 평점
            Row(
              children: [
                _RatingChip(label: '코칭', value: review.coachingSatisfaction, isDark: isDark),
                const SizedBox(width: AppSpacing.xs),
                _RatingChip(label: '소통', value: review.communication, isDark: isDark),
                const SizedBox(width: AppSpacing.xs),
                _RatingChip(label: '친절', value: review.kindness, isDark: isDark),
              ],
            ),

            // 코멘트
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.comment,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 평점 칩
class _RatingChip extends StatelessWidget {
  final String label;
  final int value;
  final bool isDark;

  const _RatingChip({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
