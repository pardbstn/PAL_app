import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_review_model.dart';
import 'package:flutter_pal_app/data/models/trainer_performance_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_review_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/review/review_card.dart';
import 'package:flutter_pal_app/presentation/widgets/review/star_rating_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/trainer/performance_stats_card.dart';

/// 트레이너 리뷰 목록 화면
///
/// 평균 평점, 성과 지표, 개별 리뷰 목록을 표시합니다.
/// 5개 이상의 리뷰가 있어야 개별 리뷰가 공개됩니다.
class TrainerReviewsScreen extends ConsumerWidget {
  const TrainerReviewsScreen({
    super.key,
    required this.trainerId,
  });

  /// 트레이너 ID
  final String trainerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performanceAsync = ref.watch(trainerPerformanceProvider(trainerId));
    final reviewsAsync = ref.watch(trainerReviewsProvider(trainerId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 평가'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trainerPerformanceProvider(trainerId));
          ref.invalidate(trainerReviewsProvider(trainerId));
        },
        child: performanceAsync.when(
          loading: () => _buildLoadingSkeleton(context),
          error: (error, stack) => _buildErrorScreen(context, error.toString(), ref),
          data: (performance) => reviewsAsync.when(
            loading: () => _buildLoadingSkeleton(context),
            error: (error, stack) => _buildErrorScreen(context, error.toString(), ref),
            data: (reviews) => _buildContent(context, performance, reviews),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TrainerPerformanceModel? performance,
    List<TrainerReviewModel> reviews,
  ) {
    // 리뷰가 없는 경우
    if (reviews.isEmpty && (performance == null || performance.totalReviews == 0)) {
      return _buildEmptyState(context);
    }

    // 성과 데이터가 없으면 기본값 사용
    final effectivePerformance = performance ??
        TrainerPerformanceModel(
          id: '',
          trainerId: trainerId,
          totalReviews: reviews.length,
          averageRating: reviews.isEmpty
              ? 0.0
              : reviews.map((r) => r.averageRating).reduce((a, b) => a + b) / reviews.length,
          updatedAt: DateTime.now(),
        );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 성과 지표 카드
          PerformanceStatsCard(performance: effectivePerformance)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),

          // 평균 평점 섹션 (별도 강조)
          if (effectivePerformance.averageRating > 0)
            _buildAverageRatingSection(context, effectivePerformance, reviews.length)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms),
          const SizedBox(height: 24),

          // 리뷰 목록 섹션
          _buildReviewsSection(context, effectivePerformance, reviews)
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildAverageRatingSection(
    BuildContext context,
    TrainerPerformanceModel performance,
    int reviewCount,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.tertiary.withValues(alpha: 0.15),
            AppTheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            '평균 평점',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                performance.ratingText,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.tertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ 5.0',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FullStarRatingDisplay(
            rating: performance.averageRating,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            '${performance.totalReviews}개의 평가',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    TrainerPerformanceModel performance,
    List<TrainerReviewModel> reviews,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final canShowReviews = performance.canShowReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 20,
              color: AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '평가 내역',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (!canShowReviews) ...[
          // 5개 미만일 때 안내
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
                const SizedBox(height: 16),
                Text(
                  '평가 내역이 비공개 상태입니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '회원 프라이버시 보호를 위해\n5개 이상의 평가가 쌓이면 상세 내역이 공개됩니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '현재 ${performance.totalReviews}개 / 5개',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // 5개 이상일 때 리뷰 목록 표시
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return ReviewCard(
                review: reviews[index],
                showExpandableDetails: true,
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: 50 * index),
                  );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_outline_rounded,
                size: 60,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '아직 받은 평가가 없어요',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'PT 8회 이상 완료한 회원이\n평가를 남길 수 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '좋은 평가를 받으려면?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. 전문적인 운동 지도\n2. 명확한 피드백 전달\n3. 시간 약속 준수\n4. 회원의 목표 달성 지원',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '데이터를 불러오지 못했어요',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(trainerPerformanceProvider(trainerId));
                ref.invalidate(trainerReviewsProvider(trainerId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 성과 카드 스켈레톤
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // 평균 평점 스켈레톤
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // 리뷰 헤더 스켈레톤
            Container(
              height: 24,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            // 리뷰 카드 스켈레톤
            for (int i = 0; i < 3; i++) ...[
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
