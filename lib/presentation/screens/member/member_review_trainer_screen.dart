import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_rating_provider.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 회원 → 트레이너 리뷰 작성 화면
class MemberReviewTrainerScreen extends ConsumerStatefulWidget {
  final String trainerId;
  final String memberId;

  const MemberReviewTrainerScreen({
    super.key,
    required this.trainerId,
    required this.memberId,
  });

  @override
  ConsumerState<MemberReviewTrainerScreen> createState() => _MemberReviewTrainerScreenState();
}

class _MemberReviewTrainerScreenState extends ConsumerState<MemberReviewTrainerScreen> {
  int _coachingSatisfaction = 5;
  int _communication = 5;
  int _kindness = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final submitState = ref.watch(reviewSubmitProvider);

    // 제출 성공 시 뒤로가기
    ref.listen<ReviewSubmitState>(reviewSubmitProvider, (prev, next) {
      if (next.status == ReviewSubmitStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다'), backgroundColor: Color(0xFF10B981)),
        );
        ref.read(reviewSubmitProvider.notifier).reset();
        context.pop();
      } else if (next.status == ReviewSubmitStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: ${next.errorMessage ?? "알 수 없는 오류"}'), backgroundColor: const Color(0xFFEF4444)),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('트레이너 평가'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 안내 텍스트
            Text(
              'PT는 어떠셨나요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              '솔직한 평가가 트레이너의 성장에 도움됩니다',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // 코칭 만족도
            _buildRatingSection(
              title: '코칭 만족도',
              subtitle: '운동 프로그램과 지도가 만족스러웠나요?',
              value: _coachingSatisfaction,
              onChanged: (v) => setState(() => _coachingSatisfaction = v),
              isDark: isDark,
              delay: 200,
            ),

            const SizedBox(height: 24),

            // 소통
            _buildRatingSection(
              title: '소통',
              subtitle: '피드백과 의사소통이 원활했나요?',
              value: _communication,
              onChanged: (v) => setState(() => _communication = v),
              isDark: isDark,
              delay: 300,
            ),

            const SizedBox(height: 24),

            // 친절도
            _buildRatingSection(
              title: '친절도',
              subtitle: '친절하고 편안한 분위기였나요?',
              value: _kindness,
              onChanged: (v) => setState(() => _kindness = v),
              isDark: isDark,
              delay: 400,
            ),

            const SizedBox(height: 32),

            // 한줄평
            Container(
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
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '한줄평 (선택)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLength: 100,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: '트레이너에게 한마디 남겨주세요',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF2E3B5E) : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF162035) : Colors.grey.shade50,
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 40),

            // 제출 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: submitState.status == ReviewSubmitStatus.submitting
                    ? null
                    : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: submitState.status == ReviewSubmitStatus.submitting
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
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 별점 입력 섹션 빌드
  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required int value,
    required ValueChanged<int> onChanged,
    required bool isDark,
    required int delay,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: () => onChanged(starValue),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starValue <= value ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 40,
                    color: starValue <= value
                        ? const Color(0xFFF59E0B)
                        : (isDark ? Colors.white24 : Colors.grey.shade300),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getRatingLabel(value),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFF59E0B),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  /// 별점에 따른 라벨
  String _getRatingLabel(int value) {
    switch (value) {
      case 1: return '별로예요';
      case 2: return '부족해요';
      case 3: return '보통이에요';
      case 4: return '좋아요';
      case 5: return '최고예요!';
      default: return '';
    }
  }

  /// 리뷰 제출
  void _submitReview() {
    final authState = ref.read(authProvider);
    final memberName = authState.displayName ?? '회원';

    ref.read(reviewSubmitProvider.notifier).submitReview(
      trainerId: widget.trainerId,
      memberId: widget.memberId,
      memberName: memberName,
      coachingSatisfaction: _coachingSatisfaction,
      communication: _communication,
      kindness: _kindness,
      comment: _commentController.text.trim(),
    );
  }
}
