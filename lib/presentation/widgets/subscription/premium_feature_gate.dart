import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/subscription_provider.dart';

/// 프리미엄 기능 게이트 위젯
/// 프리미엄 전용 기능을 감싸서 접근 권한이 없으면 잠금 오버레이를 표시
class PremiumFeatureGate extends ConsumerWidget {
  /// 감쌀 자식 위젯
  final Widget child;

  /// 기능 키 (ai_workout_recommendation, ai_diet_analysis, monthly_report, trainer_question)
  final String featureKey;

  /// 잠금 아이콘 크기
  final double iconSize;

  /// 오버레이 blur 강도
  final double blurStrength;

  /// 잠금 메시지 (기본값: 프리미엄 전용)
  final String? lockedMessage;

  /// 잠금 시 탭 콜백 (null이면 기본 업그레이드 프롬프트)
  final VoidCallback? onLockedTap;

  const PremiumFeatureGate({
    super.key,
    required this.child,
    required this.featureKey,
    this.iconSize = 32,
    this.blurStrength = 5.0,
    this.lockedMessage,
    this.onLockedTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.userId;

    // 로그인되지 않은 경우 잠금 상태로 표시
    if (userId == null) {
      return _buildLockedOverlay(context, ref);
    }

    final hasAccessAsync = ref.watch(
      hasFeatureAccessProvider((userId: userId, feature: featureKey)),
    );

    return hasAccessAsync.when(
      loading: () => child, // 로딩 중에는 일단 보여줌
      error: (_, __) => _buildLockedOverlay(context, ref),
      data: (hasAccess) {
        if (hasAccess) {
          return child;
        }
        return _buildLockedOverlay(context, ref);
      },
    );
  }

  Widget _buildLockedOverlay(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // 흐릿하게 처리된 자식 위젯
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.5),
            BlendMode.srcATop,
          ),
          child: child,
        ),
        // 잠금 오버레이
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onLockedTap != null
                  ? onLockedTap!()
                  : _showUpgradePrompt(context, ref),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: iconSize,
                          color: AppTheme.primary,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(
                            duration: 2000.ms,
                            color: AppTheme.primary.withValues(alpha: 0.3),
                          ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.primary.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          lockedMessage ?? '프리미엄 전용',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '탭하여 업그레이드',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpgradePrompt(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              // 프리미엄 아이콘
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary.withValues(alpha: 0.2),
                      AppTheme.secondary.withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  size: 48,
                  color: AppTheme.primary,
                ),
              ).animate().scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 20),
              Text(
                '프리미엄으로 업그레이드',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getFeatureDescription(featureKey),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // 프리미엄 혜택 리스트
              _PremiumBenefitItem(
                icon: Icons.fitness_center,
                title: 'AI 운동 추천',
                description: '맞춤형 운동 프로그램',
              ),
              _PremiumBenefitItem(
                icon: Icons.restaurant_menu,
                title: 'AI 식단 분석',
                description: '영양 밸런스 체크',
              ),
              _PremiumBenefitItem(
                icon: Icons.assessment,
                title: '월간 리포트',
                description: '상세 진행 분석',
              ),
              _PremiumBenefitItem(
                icon: Icons.question_answer,
                title: '트레이너 질문',
                description: '월 3회 질문 가능',
              ),
              const SizedBox(height: 24),
              // 가격
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '월',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '4,900원',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // CTA 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/member/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    '프리미엄 시작하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '나중에',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFeatureDescription(String feature) {
    switch (feature) {
      case 'ai_workout_recommendation':
        return 'AI가 분석한 맞춤 운동 추천을\n프리미엄에서 이용할 수 있어요';
      case 'ai_diet_analysis':
        return 'AI가 분석하는 식단 영양 밸런스를\n프리미엄에서 이용할 수 있어요';
      case 'monthly_report':
        return '상세한 월간 진행 리포트를\n프리미엄에서 이용할 수 있어요';
      case 'trainer_question':
        return '트레이너에게 궁금한 점을 질문하는\n기능은 프리미엄에서 이용할 수 있어요';
      default:
        return '이 기능은 프리미엄 회원 전용입니다';
    }
  }
}

/// 프리미엄 혜택 아이템 위젯
class _PremiumBenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PremiumBenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: AppTheme.secondary,
          ),
        ],
      ),
    );
  }
}
