import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_review_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_review_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/review/review_form_widget.dart';

/// 회원이 트레이너를 평가하는 화면
///
/// 평가 자격 확인 후 폼을 표시하고, 제출 후 감사 화면을 보여줍니다.
class TrainerReviewScreen extends ConsumerStatefulWidget {
  const TrainerReviewScreen({
    super.key,
    required this.trainerId,
    required this.memberId,
  });

  /// 평가할 트레이너 ID
  final String trainerId;

  /// 평가하는 회원 ID
  final String memberId;

  @override
  ConsumerState<TrainerReviewScreen> createState() => _TrainerReviewScreenState();
}

class _TrainerReviewScreenState extends ConsumerState<TrainerReviewScreen> {
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final eligibilityParams = ReviewCheckParams(
      memberId: widget.memberId,
      trainerId: widget.trainerId,
    );
    final eligibilityAsync = ref.watch(reviewEligibilityProvider(eligibilityParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('트레이너 평가'),
        centerTitle: true,
      ),
      body: _isSubmitted
          ? _buildSuccessScreen(context)
          : eligibilityAsync.when(
              loading: () => _buildLoadingSkeleton(context),
              error: (error, stack) => _buildErrorScreen(context, error.toString()),
              data: (eligibility) => _buildContentByEligibility(context, eligibility),
            ),
    );
  }

  Widget _buildContentByEligibility(BuildContext context, ReviewEligibility eligibility) {
    switch (eligibility) {
      case ReviewEligibility.eligible:
        return _buildReviewForm(context);
      case ReviewEligibility.alreadyReviewed:
        return _buildAlreadyReviewedScreen(context);
      case ReviewEligibility.notEnoughSessions:
        return _buildNotEligibleScreen(
          context,
          icon: Icons.fitness_center_outlined,
          title: 'PT 8회 이상 완료 후 평가할 수 있어요',
          message: '트레이너와 충분히 운동한 후에\n정확한 평가를 남겨주세요.',
        );
      case ReviewEligibility.expired:
        return _buildNotEligibleScreen(
          context,
          icon: Icons.schedule_outlined,
          title: '평가 기간이 지났어요',
          message: 'PT 종료 후 14일 이내에만\n평가를 남길 수 있습니다.',
        );
      case ReviewEligibility.noCompletedPt:
        return _buildNotEligibleScreen(
          context,
          icon: Icons.sports_outlined,
          title: '완료된 PT가 없어요',
          message: '트레이너와 PT를 진행한 후에\n평가를 남길 수 있습니다.',
        );
    }
  }

  Widget _buildReviewForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '트레이너에 대한\n솔직한 평가를 남겨주세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            '여러분의 평가가 더 나은 PT 환경을 만듭니다.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
          const SizedBox(height: 24),

          // 리뷰 폼
          ReviewFormWidget(
            trainerId: widget.trainerId,
            memberId: widget.memberId,
            isSubmitting: _isSubmitting,
            onSubmit: _handleSubmitReview,
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context) {
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
                color: AppTheme.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: AppTheme.secondary,
              ),
            )
                .animate()
                .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              '평가가 완료되었습니다!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              '소중한 의견 감사합니다.\n여러분의 평가가 더 나은 PT 환경을 만듭니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '홈으로 돌아가기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildAlreadyReviewedScreen(BuildContext context) {
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
                color: AppTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rate_review,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '이미 평가를 완료했어요',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '한 트레이너에 대해 한 번만\n평가를 남길 수 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotEligibleScreen(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
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
                color: AppTheme.tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.tertiary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
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
              '오류가 발생했어요',
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
            OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('돌아가기'),
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
            Container(
              height: 32,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 32),
            // 평가 항목 스켈레톤
            for (int i = 0; i < 5; i++) ...[
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmitReview(TrainerReviewModel review) async {
    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(trainerReviewNotifierProvider.notifier);
      await notifier.submitReview(review);

      // 성과 지표 업데이트
      await notifier.updatePerformance(widget.trainerId);

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('평가 제출 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
