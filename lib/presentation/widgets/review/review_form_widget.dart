import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/trainer_review_model.dart';
import 'star_rating_widget.dart';

/// 트레이너 리뷰 작성 폼 위젯
///
/// 5개 평가 항목 (전문성, 소통력, 시간준수, 변화만족도, 재등록의향)과
/// 선택적 코멘트 입력을 제공합니다.
class ReviewFormWidget extends ConsumerStatefulWidget {
  const ReviewFormWidget({
    super.key,
    required this.trainerId,
    required this.memberId,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  /// 트레이너 ID
  final String trainerId;

  /// 회원 ID
  final String memberId;

  /// 제출 콜백
  final Future<void> Function(TrainerReviewModel review) onSubmit;

  /// 제출 중 상태
  final bool isSubmitting;

  @override
  ConsumerState<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends ConsumerState<ReviewFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  // 평가 항목별 점수 (1-5)
  int _professionalism = 0;
  int _communication = 0;
  int _punctuality = 0;
  int _satisfaction = 0;
  int _reregistrationIntent = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isValid {
    return _professionalism > 0 &&
        _communication > 0 &&
        _punctuality > 0 &&
        _satisfaction > 0 &&
        _reregistrationIntent > 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 익명 안내 배너
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '평가는 익명으로 처리되며, 트레이너에게 작성자 정보가 공개되지 않습니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 평가 항목들
          _buildRatingSection(
            title: '전문성',
            subtitle: '운동 지식과 지도 능력',
            icon: Icons.school_outlined,
            rating: _professionalism,
            onChanged: (value) => setState(() => _professionalism = value.toInt()),
          ),
          const SizedBox(height: 20),

          _buildRatingSection(
            title: '소통력',
            subtitle: '의사소통 및 피드백 전달력',
            icon: Icons.chat_outlined,
            rating: _communication,
            onChanged: (value) => setState(() => _communication = value.toInt()),
          ),
          const SizedBox(height: 20),

          _buildRatingSection(
            title: '시간준수',
            subtitle: '수업 시간 약속 준수',
            icon: Icons.access_time_outlined,
            rating: _punctuality,
            onChanged: (value) => setState(() => _punctuality = value.toInt()),
          ),
          const SizedBox(height: 20),

          _buildRatingSection(
            title: '변화만족도',
            subtitle: '목표 대비 실제 변화에 대한 만족',
            icon: Icons.trending_up_outlined,
            rating: _satisfaction,
            onChanged: (value) => setState(() => _satisfaction = value.toInt()),
          ),
          const SizedBox(height: 20),

          _buildRatingSection(
            title: '재등록의향',
            subtitle: '다시 등록하고 싶은 정도',
            icon: Icons.refresh_outlined,
            rating: _reregistrationIntent,
            onChanged: (value) => setState(() => _reregistrationIntent = value.toInt()),
          ),
          const SizedBox(height: 28),

          // 코멘트 입력 (선택)
          Text(
            '추가 의견 (선택)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: '트레이너에게 전달하고 싶은 의견을 자유롭게 작성해주세요.',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primary,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),

          // 평균 평점 미리보기
          if (_isValid) ...[
            _buildAverageRatingPreview(),
            const SizedBox(height: 24),
          ],

          // 제출 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isValid && !widget.isSubmitting ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '평가 제출하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // 유효성 안내
          if (!_isValid)
            Center(
              child: Text(
                '모든 항목에 별점을 선택해주세요',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required int rating,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rating > 0
              ? AppTheme.tertiary.withValues(alpha: 0.3)
              : (isDark ? Colors.white12 : Colors.black12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: StarRatingWidget(
              rating: rating.toDouble(),
              onRatingChanged: onChanged,
              size: 36,
              showLabel: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageRatingPreview() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final average = (_professionalism +
            _communication +
            _punctuality +
            _satisfaction +
            _reregistrationIntent) /
        5.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.tertiary.withValues(alpha: 0.1),
            AppTheme.tertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppTheme.tertiary,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            '평균 평점: ${average.toStringAsFixed(1)}점',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_isValid) return;

    final review = TrainerReviewModel(
      id: '',
      trainerId: widget.trainerId,
      memberId: widget.memberId,
      professionalism: _professionalism,
      communication: _communication,
      punctuality: _punctuality,
      satisfaction: _satisfaction,
      reregistrationIntent: _reregistrationIntent,
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await widget.onSubmit(review);
  }
}
