import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/subscription_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';
import 'package:flutter_pal_app/presentation/providers/subscription_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/subscription/premium_feature_gate.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';

/// 셀프 트레이닝 모드 홈 화면
/// PT가 종료된 회원이 스스로 운동을 관리하는 화면
class SelfTrainingHomeScreen extends ConsumerWidget {
  const SelfTrainingHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = ref.watch(currentUserModelProvider);
    final userId = authState.userId;

    if (userId == null) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    final subscriptionAsync = ref.watch(currentSubscriptionProvider(userId));
    final isPremiumAsync = ref.watch(isPremiumProvider(userId));

    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentSubscriptionProvider(userId));
          ref.invalidate(isPremiumProvider(userId));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 인사말 섹션
              _GreetingSection(userName: user?.name ?? '회원님')
                  .animateListItem(0),
              const SizedBox(height: 20),

              // 2. 구독 상태 배너
              subscriptionAsync.when(
                loading: () => _buildSubscriptionBannerSkeleton(context),
                error: (_, __) => const SizedBox.shrink(),
                data: (subscription) => _SubscriptionBanner(
                  subscription: subscription,
                  onUpgrade: () => context.push('/member/subscription'),
                ).animateListItem(1),
              ),
              const SizedBox(height: 24),

              // 3. 무료 기능 섹션 제목
              Text(
                '기본 기능',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ).animateListItem(2),
              const SizedBox(height: 12),

              // 4. 체중/운동 기록 (무료)
              _FreeFeatureCard(
                icon: Icons.fitness_center,
                title: '체중/운동 기록',
                description: '오늘의 운동과 체중을 기록하세요',
                color: AppTheme.primary,
                onTap: () => context.push('/member/records'),
              ).animateListItem(3),
              const SizedBox(height: 12),

              // 5. 진행 그래프 (무료)
              _ProgressGraphCard(userId: userId).animateListItem(4),
              const SizedBox(height: 24),

              // 6. 프리미엄 기능 섹션 제목
              Row(
                children: [
                  Text(
                    '프리미엄 기능',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animateListItem(5),
              const SizedBox(height: 12),

              // 7. AI 운동 추천 (프리미엄)
              PremiumFeatureGate(
                featureKey: 'ai_workout_recommendation',
                child: _PremiumFeatureCard(
                  icon: Icons.auto_awesome,
                  title: 'AI 운동 추천',
                  description: 'AI가 분석한 맞춤 운동 프로그램을 받아보세요',
                  color: AppTheme.secondary,
                  onTap: () {
                    // TODO: AI 운동 추천 화면으로 이동
                  },
                ),
              ).animateListItem(6),
              const SizedBox(height: 12),

              // 8. AI 식단 분석 (프리미엄)
              PremiumFeatureGate(
                featureKey: 'ai_diet_analysis',
                child: _PremiumFeatureCard(
                  icon: Icons.restaurant_menu,
                  title: 'AI 식단 분석',
                  description: '식단 사진을 찍으면 AI가 영양을 분석해드려요',
                  color: AppTheme.tertiary,
                  onTap: () => context.push('/member/diet'),
                ),
              ).animateListItem(7),
              const SizedBox(height: 12),

              // 9. 월간 리포트 (프리미엄)
              PremiumFeatureGate(
                featureKey: 'monthly_report',
                child: _PremiumFeatureCard(
                  icon: Icons.assessment,
                  title: '월간 리포트',
                  description: '이번 달 운동 성과를 한눈에 확인하세요',
                  color: AppTheme.primary,
                  onTap: () {
                    // TODO: 월간 리포트 화면으로 이동
                  },
                ),
              ).animateListItem(8),
              const SizedBox(height: 12),

              // 10. 트레이너 질문 (프리미엄 - 월 3회)
              _TrainerQuestionCard(userId: userId).animateListItem(9),
              const SizedBox(height: 32),

              // 11. 업그레이드 CTA (무료 사용자만)
              isPremiumAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (isPremium) => isPremium
                    ? const SizedBox.shrink()
                    : _UpgradeCta(
                        onTap: () => context.push('/member/subscription'),
                      ).animateListItem(10),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('셀프 트레이닝'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: 알림 화면으로 이동
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go('/member/settings'),
        ),
      ],
    );
  }

  Widget _buildSubscriptionBannerSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// 인사말 섹션
class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안녕하세요, $userName님!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '오늘도 꾸준히 운동해볼까요?',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 구독 상태 배너
class _SubscriptionBanner extends StatelessWidget {
  final SubscriptionModel? subscription;
  final VoidCallback onUpgrade;

  const _SubscriptionBanner({
    this.subscription,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = subscription?.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8),
                ],
              )
            : null,
        color: isPremium
            ? null
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(16),
        border: isPremium
            ? null
            : Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPremium
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPremium ? Icons.workspace_premium : Icons.star_outline,
              color: isPremium ? Colors.white : AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? '프리미엄 회원' : '무료 플랜',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.white : null,
                  ),
                ),
                Text(
                  isPremium
                      ? '모든 기능을 이용 중입니다'
                      : '프리미엄으로 더 많은 기능을 이용해보세요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPremium
                        ? Colors.white70
                        : (isDark ? Colors.white60 : Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          if (!isPremium)
            TextButton(
              onPressed: onUpgrade,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('업그레이드'),
            ),
        ],
      ),
    );
  }
}

/// 무료 기능 카드
class _FreeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FreeFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 진행 그래프 카드 (무료)
class _ProgressGraphCard extends ConsumerWidget {
  final String userId;

  const _ProgressGraphCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // member가 없을 수 있으므로 userId 기반으로 체중 기록 조회
    // 실제로는 member ID가 필요하지만 여기서는 간단히 처리
    final member = ref.watch(currentMemberProvider);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    color: AppTheme.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '진행 그래프',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/member/records'),
                  child: const Text('더보기'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: member != null
                  ? _buildMiniWeightChart(context, ref, member.id)
                  : Center(
                      child: Text(
                        '기록을 시작해보세요',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniWeightChart(BuildContext context, WidgetRef ref, String memberId) {
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return weightHistoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: Text(
          '데이터를 불러올 수 없습니다',
          style: theme.textTheme.bodySmall,
        ),
      ),
      data: (history) {
        if (history.length < 2) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_chart,
                  size: 32,
                  color: isDark ? Colors.white38 : Colors.black26,
                ),
                const SizedBox(height: 8),
                Text(
                  '2개 이상의 기록이 필요해요',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ],
            ),
          );
        }

        final spots = <FlSpot>[];
        for (var i = 0; i < history.length; i++) {
          spots.add(FlSpot(i.toDouble(), history[i].weight));
        }

        final weights = history.map((e) => e.weight).toList();
        final minWeight = weights.reduce((a, b) => a < b ? a : b);
        final maxWeight = weights.reduce((a, b) => a > b ? a : b);
        final padding = (maxWeight - minWeight) * 0.2;

        return LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (history.length - 1).toDouble(),
            minY: minWeight - padding - 1,
            maxY: maxWeight + padding + 1,
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppTheme.secondary,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.secondary.withValues(alpha: 0.3),
                      AppTheme.secondary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 프리미엄 기능 카드
class _PremiumFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _PremiumFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AI',
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 트레이너 질문 카드 (프리미엄 - 월 3회)
class _TrainerQuestionCard extends ConsumerWidget {
  final String userId;

  const _TrainerQuestionCard({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionCountAsync = ref.watch(availableQuestionCountProvider(userId));
    final isPremiumAsync = ref.watch(isPremiumProvider(userId));

    return isPremiumAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isPremium) {
        if (!isPremium) {
          // 무료 사용자는 PremiumFeatureGate로 감싸서 표시
          return PremiumFeatureGate(
            featureKey: 'trainer_question',
            child: _buildCard(context, ref, 0, false),
          );
        }
        // 프리미엄 사용자는 남은 횟수 표시
        return questionCountAsync.when(
          loading: () => _buildCard(context, ref, 0, true),
          error: (_, __) => _buildCard(context, ref, 0, true),
          data: (count) => _buildCard(context, ref, count, true),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, int remainingCount, bool isPremium) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: remainingCount > 0
            ? () {
                // TODO: 트레이너 질문 화면으로 이동
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.question_answer,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '트레이너 질문',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: remainingCount > 0
                                  ? AppTheme.secondary.withValues(alpha: 0.1)
                                  : AppTheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$remainingCount회 남음',
                              style: TextStyle(
                                color: remainingCount > 0
                                    ? AppTheme.secondary
                                    : AppTheme.error,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '이전 담당 트레이너에게 질문해보세요',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: remainingCount > 0
                    ? (isDark ? Colors.white38 : Colors.black38)
                    : (isDark ? Colors.white12 : Colors.black12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 업그레이드 CTA
class _UpgradeCta extends StatelessWidget {
  final VoidCallback onTap;

  const _UpgradeCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: 0.1),
            AppTheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '더 빠른 성장을 원하시나요?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 기반 맞춤 분석으로\n목표에 더 빠르게 도달하세요',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '월',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '4,900원',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
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
        ],
      ),
    );
  }
}
