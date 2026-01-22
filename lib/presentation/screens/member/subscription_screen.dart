import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/subscription_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/subscription_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/subscription/subscription_card.dart';

/// 구독 플랜 비교 및 관리 화면
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('구독 관리')),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    final subscriptionAsync = ref.watch(currentSubscriptionProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        centerTitle: true,
      ),
      body: subscriptionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다\n$error', textAlign: TextAlign.center),
            ],
          ),
        ),
        data: (subscription) => _buildContent(context, subscription, userId),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    SubscriptionModel? subscription,
    String userId,
  ) {
    final theme = Theme.of(context);
    final isPremium = subscription?.isPremium ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 섹션
          _buildHeaderSection(context, isPremium).animate().fadeIn().slideY(
                begin: -0.1,
                end: 0,
                duration: 400.ms,
              ),
          const SizedBox(height: 32),

          // 플랜 비교 제목
          Text(
            '플랜 비교',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),

          // 프리미엄 카드 (추천)
          SubscriptionCard(
            plan: SubscriptionPlan.premium,
            monthlyPrice: 4900,
            features: premiumFeatures,
            isCurrentPlan: isPremium,
            isRecommended: !isPremium,
            isLoading: _isProcessing,
            onSelect: isPremium ? null : () => _startPremium(userId),
          ).animate().fadeIn(delay: 200.ms).slideX(
                begin: 0.05,
                end: 0,
                duration: 400.ms,
              ),
          const SizedBox(height: 16),

          // 무료 카드
          SubscriptionCard(
            plan: SubscriptionPlan.free,
            monthlyPrice: 0,
            features: freeFeatures,
            isCurrentPlan: !isPremium,
            isRecommended: false,
            onSelect: null,
          ).animate().fadeIn(delay: 300.ms).slideX(
                begin: 0.05,
                end: 0,
                duration: 400.ms,
              ),
          const SizedBox(height: 32),

          // 프리미엄 해지 옵션 (프리미엄 사용자만)
          if (isPremium) ...[
            _buildCancelSection(context, userId),
            const SizedBox(height: 32),
          ],

          // FAQ 섹션
          _buildFaqSection(context).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 32),

          // 결제 안내
          _buildPaymentInfo(context).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isPremium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8),
                ]
              : [
                  isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF5F5F5),
                  isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPremium
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.trending_up,
              size: 40,
              color: isPremium ? Colors.white : AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          // 제목
          Text(
            isPremium ? '프리미엄 회원' : '더 나은 결과를 위해',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPremium ? Colors.white : null,
            ),
          ),
          const SizedBox(height: 8),
          // 설명
          Text(
            isPremium
                ? '모든 프리미엄 기능을 이용 중입니다'
                : 'AI 기반 맞춤 분석으로 목표에 더 빠르게 도달하세요',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isPremium
                  ? Colors.white70
                  : (isDark ? Colors.white60 : Colors.black54),
              height: 1.5,
            ),
          ),
          if (!isPremium) ...[
            const SizedBox(height: 20),
            // 혜택 요약
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildBenefitChip('AI 운동 추천'),
                _buildBenefitChip('AI 식단 분석'),
                _buildBenefitChip('월간 리포트'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCancelSection(BuildContext context, String userId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                '구독 관리',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '구독을 해지하면 다음 결제일부터 무료 플랜으로 전환됩니다.\n현재 결제 기간이 끝날 때까지는 프리미엄 기능을 계속 이용할 수 있습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white54 : Colors.black45,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _showCancelConfirmation(context, userId),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
              padding: EdgeInsets.zero,
            ),
            child: const Text('구독 해지'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms);
  }

  Widget _buildFaqSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '자주 묻는 질문',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _FaqItem(
          question: '프리미엄은 언제 시작되나요?',
          answer: '결제 완료 즉시 프리미엄 기능을 이용할 수 있습니다.',
        ),
        _FaqItem(
          question: '언제든지 해지할 수 있나요?',
          answer: '네, 언제든지 해지 가능합니다. 해지 후에도 결제 기간이 끝날 때까지는 프리미엄 기능을 이용할 수 있습니다.',
        ),
        _FaqItem(
          question: '트레이너 질문은 어떻게 사용하나요?',
          answer: '프리미엄 회원은 매월 3회까지 이전 담당 트레이너에게 운동, 식단 관련 질문을 할 수 있습니다.',
        ),
      ],
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            size: 24,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '결제는 안전하게 처리되며,\n개인정보는 암호화되어 보호됩니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startPremium(String userId) async {
    setState(() => _isProcessing = true);

    try {
      // TODO: 실제 결제 플로우 연동
      // 현재는 플레이스홀더로 바로 프리미엄 시작
      await ref.read(subscriptionNotifierProvider.notifier).startPremium(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프리미엄이 시작되었습니다!'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showCancelConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 해지'),
        content: const Text(
          '정말 프리미엄 구독을 해지하시겠습니까?\n\n'
          '해지 후에도 현재 결제 기간이 끝날 때까지는\n'
          '프리미엄 기능을 이용할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelPremium(userId);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('해지하기'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelPremium(String userId) async {
    setState(() => _isProcessing = true);

    try {
      await ref.read(subscriptionNotifierProvider.notifier).cancelPremium(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독이 해지되었습니다'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// FAQ 아이템 위젯
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.answer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
