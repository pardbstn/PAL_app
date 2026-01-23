import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_performance_model.dart';
import 'package:flutter_pal_app/presentation/providers/ranking_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/review/star_rating_widget.dart';

/// 트레이너 랭킹 화면
///
/// 평점 순위와 재등록률 순위를 탭으로 구분하여 표시합니다.
class TrainerRankingScreen extends ConsumerStatefulWidget {
  const TrainerRankingScreen({super.key});

  @override
  ConsumerState<TrainerRankingScreen> createState() =>
      _TrainerRankingScreenState();
}

class _TrainerRankingScreenState extends ConsumerState<TrainerRankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('트레이너 랭킹'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: '평점 순위'),
            Tab(text: '재등록률 순위'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RankingByRatingTab(),
          _RankingByReregistrationTab(),
        ],
      ),
    );
  }
}

/// 평점 순위 탭
class _RankingByRatingTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(ratingRankingProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ratingRankingProvider);
      },
      child: rankingAsync.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, stack) => _buildErrorState(context, error.toString(), ref),
        data: (trainers) => trainers.isEmpty
            ? _buildEmptyState(context, '평점')
            : _buildRankingList(context, trainers, _RankingType.rating),
      ),
    );
  }
}

/// 재등록률 순위 탭
class _RankingByReregistrationTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingAsync = ref.watch(reregistrationRankingProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reregistrationRankingProvider);
      },
      child: rankingAsync.when(
        loading: () => _buildLoadingSkeleton(context),
        error: (error, stack) => _buildErrorState(context, error.toString(), ref),
        data: (trainers) => trainers.isEmpty
            ? _buildEmptyState(context, '재등록률')
            : _buildRankingList(context, trainers, _RankingType.reregistration),
      ),
    );
  }
}

enum _RankingType { rating, reregistration }

/// 랭킹 리스트 빌드
Widget _buildRankingList(
  BuildContext context,
  List<TrainerPerformanceModel> trainers,
  _RankingType type,
) {
  return ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    itemCount: trainers.length,
    itemBuilder: (context, index) {
      final trainer = trainers[index];
      final rank = index + 1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _RankingCard(
          rank: rank,
          trainer: trainer,
          type: type,
        ),
      );
    },
  );
}

/// 랭킹 카드 위젯
class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.rank,
    required this.trainer,
    required this.type,
  });

  final int rank;
  final TrainerPerformanceModel trainer;
  final _RankingType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? _getBorderColor(isDark)
              : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
          width: rank <= 3 ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 순위 뱃지
          _RankBadge(rank: rank),
          const SizedBox(width: 16),
          // 트레이너 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '트레이너 ${trainer.trainerId.length >= 6 ? trainer.trainerId.substring(0, 6) : trainer.trainerId}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _buildSubInfo(context),
              ],
            ),
          ),
          // 주요 지표
          _buildMainMetric(context),
        ],
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return isDark ? Colors.white12 : Colors.black12;
    }
  }

  Widget _buildSubInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (type == _RankingType.rating) {
      return Text(
        '리뷰 ${trainer.totalReviews}개',
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      );
    } else {
      return Row(
        children: [
          CompactStarRating(
            rating: trainer.averageRating,
            size: 14,
            showRatingText: true,
            textStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '(${trainer.totalReviews}개)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMainMetric(BuildContext context) {
    final theme = Theme.of(context);

    if (type == _RankingType.rating) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CompactStarRating(
            rating: trainer.averageRating,
            size: 20,
            showRatingText: true,
            textStyle: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.tertiary,
            ),
          ),
          const SizedBox(height: 4),
          FullStarRatingDisplay(
            rating: trainer.averageRating,
            size: 14,
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          trainer.reregistrationRateText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondary,
          ),
        ),
      );
    }
  }
}

/// 순위 뱃지 위젯
class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});

  final int rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 1, 2, 3등은 메달 아이콘
    if (rank <= 3) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getMedalGradient(),
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _getMedalColor().withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            rank.toString(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // 4등 이후는 숫자만
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }

  List<Color> _getMedalGradient() {
    switch (rank) {
      case 1:
        return [
          const Color(0xFFFFD700),
          const Color(0xFFFFA500),
        ]; // Gold
      case 2:
        return [
          const Color(0xFFC0C0C0),
          const Color(0xFF808080),
        ]; // Silver
      case 3:
        return [
          const Color(0xFFCD7F32),
          const Color(0xFF8B4513),
        ]; // Bronze
      default:
        return [Colors.grey, Colors.grey];
    }
  }

  Color _getMedalColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }
}

/// 로딩 스켈레톤
Widget _buildLoadingSkeleton(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
  final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

  return Shimmer.fromColors(
    baseColor: baseColor,
    highlightColor: highlightColor,
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// 빈 상태 위젯
Widget _buildEmptyState(BuildContext context, String rankingType) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Center(
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                Icons.leaderboard_outlined,
                size: 60,
                color: AppTheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '$rankingType 랭킹 데이터가 없어요',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '아직 충분한 데이터가 쌓이지 않았습니다.\n트레이너들의 활동이 누적되면 랭킹이 표시됩니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

/// 에러 상태 위젯
Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Center(
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
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
                ref.invalidate(ratingRankingProvider);
                ref.invalidate(reregistrationRankingProvider);
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
    ),
  );
}
