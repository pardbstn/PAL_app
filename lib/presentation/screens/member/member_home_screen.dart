import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/insight_mini_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/benchmark_distribution_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/muscle_balance_donut.dart';
import 'package:flutter_pal_app/presentation/widgets/streak/streak_counter_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/member/reregistration_banner.dart';
import 'package:flutter_pal_app/presentation/providers/streak_provider.dart';
import 'package:flutter_pal_app/data/models/streak_model.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../../core/utils/animation_utils.dart';
import '../../widgets/animated/animated_widgets.dart';
import 'package:flutter_pal_app/presentation/widgets/common/app_card.dart';
import 'package:flutter_pal_app/presentation/widgets/common/card_animations.dart';

/// 프리미엄 회원 홈 화면
class MemberHomeScreen extends ConsumerWidget {
  const MemberHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final member = ref.watch(currentMemberProvider);
    final user = ref.watch(currentUserModelProvider);

    // member가 null일 경우: 로딩 중이거나 회원 프로필이 없는 경우
    if (member == null) {
      // 인증되지 않았거나 로딩 중이면 스켈레톤 표시
      if (!authState.isAuthenticated) {
        return Scaffold(
          body: _buildLoadingSkeleton(context),
        );
      }
      // 인증되었지만 회원 프로필이 없는 경우
      return Scaffold(
        body: _buildNoMemberProfile(context, user?.name ?? '회원님', user?.memberCode),
      );
    }

    final memberId = member.id;
    final weightChangeAsync = ref.watch(weightChangeProvider(memberId));
    final nextPtScheduleAsync = ref.watch(nextMemberPtScheduleProvider(memberId));
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));
    final memberInsightsAsync = ref.watch(memberInsightsStreamProvider(memberId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          // 데이터 새로고침
          ref.invalidate(weightChangeProvider(memberId));
          ref.invalidate(nextMemberPtScheduleProvider(memberId));
          ref.invalidate(weightHistoryProvider(memberId));
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 상단 인사말 + 알림/설정 아이콘
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _GreetingSection(userName: user?.name ?? '회원님'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.push('/notifications'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/member/settings'),
                  ),
                ],
              ).animateListItem(0),
              const SizedBox(height: 16),

              // 재등록 배너 (80% 이상 완료 시)
              ReregistrationBanner(memberId: memberId),
              const SizedBox(height: 16),

              // 스트릭 카운터
              Consumer(
                builder: (context, ref, child) {
                  final streakAsync = ref.watch(memberStreakProvider(memberId));
                  return streakAsync.when(
                    data: (streak) => Row(
                      children: [
                        Expanded(
                          child: StreakCounterWidget(
                            streak: streak,
                            type: StreakType.weight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StreakCounterWidget(
                            streak: streak,
                            type: StreakType.diet,
                          ),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 2. PT 진행 현황 카드 (index 1)
              _PtProgressCard(
                completed: member.ptInfo.completedSessions,
                total: member.ptInfo.totalSessions,
                progressRate: member.progressRate,
              ).animateListItem(1),
              const SizedBox(height: 16),

              // 3. 다음 수업 카드 (index 2) - 캘린더 PT 일정 기반
              nextPtScheduleAsync.when(
                loading: () => _buildNextClassSkeleton(context),
                error: (error, _) => _NextClassCard(schedule: null, error: error.toString())
                    .animateListItem(2),
                data: (schedule) => _NextClassCard(schedule: schedule)
                    .animateListItem(2),
              ),
              const SizedBox(height: 16),

              // 4. 체중 변화 미니 차트 (index 3)
              weightChangeAsync.when(
                loading: () => _buildWeightChartSkeleton(context),
                error: (error, _) => _WeightChangeCard(
                  weightChange: null,
                  weightHistory: const [],
                  error: error.toString(),
                ).animateListItem(3),
                data: (weightChange) => weightHistoryAsync.when(
                  loading: () => _buildWeightChartSkeleton(context),
                  error: (error, _) => _WeightChangeCard(
                    weightChange: weightChange,
                    weightHistory: const [],
                    error: error.toString(),
                  ).animateListItem(3),
                  data: (history) => _WeightChangeCard(
                    weightChange: weightChange,
                    weightHistory: history,
                  ).animateListItem(3),
                ),
              ),
              const SizedBox(height: 16),

              // 5. AI 인사이트 카드 (index 4)
              memberInsightsAsync.when(
                loading: () => _buildInsightSkeleton(context),
                error: (e, s) => _EmptyInsightSection(memberId: memberId).animateListItem(4),
                data: (insights) => insights.isEmpty
                    ? _EmptyInsightSection(memberId: memberId).animateListItem(4)
                    : _InsightCardsSection(
                        insights: insights,
                        memberId: memberId,
                      ).animateListItem(4),
              ),
              const SizedBox(height: 24),

              // 6. 빠른 액션 버튼들 (index 5)
              _QuickActionsSection()
                  .animateListItem(5),
              const SizedBox(height: 32),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인사말 스켈레톤
            Container(
              height: 32,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),
            // PT 진행 카드 스켈레톤
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 다음 수업 카드 스켈레톤
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            // 체중 차트 스켈레톤
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClassSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildWeightChartSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildInsightSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  /// 회원 프로필이 없을 때 표시할 UI
  Widget _buildNoMemberProfile(BuildContext context, String userName, String? memberCode) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayTag = memberCode != null ? '$userName#$memberCode' : userName;

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
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 48,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '안녕하세요, $userName님!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '아직 트레이너와 연결되지 않았습니다.\n아래 회원 코드를 트레이너에게 알려주세요.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // 회원 코드 표시
            if (memberCode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '내 회원 코드',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      displayTag,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '회원 등록 방법',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. 위의 회원 코드를 트레이너에게 알려주세요\n2. 트레이너가 회원으로 등록하면\n3. 이 화면이 자동으로 업데이트됩니다',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white54 : Colors.black45,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
}

/// 상단 인사말 섹션
class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final greeting = _getTimeBasedGreeting();

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
          greeting,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '좋은 아침이에요! 오늘도 화이팅!';
    } else if (hour < 18) {
      return '오늘도 화이팅! 멋진 하루 보내세요!';
    } else {
      return '좋은 저녁이에요! 오늘 하루도 수고하셨어요!';
    }
  }
}

/// PT 진행 현황 카드 - 프리미엄 애니메이션 적용
class _PtProgressCard extends StatefulWidget {
  final int completed;
  final int total;
  final double progressRate;

  const _PtProgressCard({
    required this.completed,
    required this.total,
    required this.progressRate,
  });

  @override
  State<_PtProgressCard> createState() => _PtProgressCardState();
}

class _PtProgressCardState extends State<_PtProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.progressRate,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    // 위젯이 빌드된 후 애니메이션 시작
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _PtProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressRate != widget.progressRate) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progressRate,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final remaining = widget.total - widget.completed;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E40AF),
                  const Color(0xFF3B82F6),
                ]
              : [
                  AppTheme.primary,
                  const Color(0xFF60A5FA),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: PT 상세 페이지로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    // 원형 프로그레스 - 애니메이션 적용
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: CircularProgressIndicator(
                                  value: _progressAnimation.value,
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              // 퍼센트 카운트업 애니메이션
                              AnimatedCounter(
                                value: (_progressAnimation.value * 100).toInt(),
                                duration: const Duration(milliseconds: 1200),
                                suffix: '%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 텍스트 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PT 진행 현황',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 회차 카운트업 애니메이션
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              AnimatedCounter(
                                value: widget.completed,
                                duration: const Duration(milliseconds: 1000),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ' / ${widget.total} 회차 완료',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // 남은 회차 카운트업
                          Row(
                            children: [
                              const Text(
                                '남은 회차: ',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              AnimatedCounter(
                                value: remaining,
                                duration: const Duration(milliseconds: 800),
                                suffix: '회',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 하단 프로그레스 바 추가
                AnimatedProgressBar(
                  progress: widget.progressRate,
                  height: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  progressColor: Colors.white,
                  duration: const Duration(milliseconds: 1200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 다음 수업 카드 (캘린더 PT 일정 기반)
class _NextClassCard extends StatelessWidget {
  final ScheduleModel? schedule;
  final String? error;

  const _NextClassCard({
    this.schedule,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 에러 상태
    if (error != null) {
      return _buildErrorCard(context, error!);
    }

    // 예정된 수업 없음
    if (schedule == null) {
      return _buildEmptyCard(context);
    }

    final scheduledDate = schedule!.scheduledAt;
    final formattedDate = _formatDate(scheduledDate);
    final formattedTime = _formatTime(scheduledDate);
    final duration = schedule!.duration;

    // D-Day 계산
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final daysUntil = scheduleDay.difference(today).inDays;

    String dDayText;
    if (daysUntil == 0) {
      dDayText = '오늘';
    } else if (daysUntil == 1) {
      dDayText = '내일';
    } else {
      dDayText = 'D-$daysUntil';
    }

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 캘린더 화면으로 이동
            context.go('/member/calendar');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '다음 PT 수업',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: daysUntil == 0
                                      ? AppTheme.secondary.withValues(alpha: 0.15)
                                      : theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  dDayText,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: daysUntil == 0
                                        ? AppTheme.secondary
                                        : theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  schedule!.memberName ?? 'PT 수업',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$formattedDate $formattedTime (${duration}분)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const EmptyState(
        type: EmptyStateType.sessions,
        customMessage: '트레이너에게 문의해보세요',
        iconSize: 80,
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ErrorState.fromError(
        error,
        onRetry: null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return '오늘';
    if (diff == 1) return '내일';
    if (diff == 2) return '모레';

    return '${date.month}월 ${date.day}일';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (minute == 0) {
      return '$period $displayHour시';
    }
    return '$period $displayHour시 $minute분';
  }
}

/// 체중 변화 미니 차트 카드
class _WeightChangeCard extends StatelessWidget {
  final WeightChange? weightChange;
  final List<WeightHistoryData> weightHistory;
  final String? error;

  const _WeightChangeCard({
    this.weightChange,
    required this.weightHistory,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 에러 상태
    if (error != null) {
      return _buildErrorCard(context, error!);
    }

    // 데이터 없음
    if (weightChange == null || weightHistory.length < 2) {
      return _buildEmptyCard(context);
    }

    final isLoss = weightChange!.isLoss;
    final changeColor = isLoss ? AppTheme.secondary : AppTheme.error;
    final changeSign = isLoss ? '' : '+';

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isLoss ? Icons.trending_down : Icons.trending_up,
                        color: changeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '체중 변화',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // 체중 변화량 카운트업 애니메이션
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedDoubleCounter(
                    value: weightChange!.change.abs(),
                    duration: const Duration(milliseconds: 1000),
                    prefix: changeSign,
                    suffix: 'kg',
                    decimalPlaces: 1,
                    style: TextStyle(
                      color: changeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 시작/현재 체중 카운트업 애니메이션
            Row(
              children: [
                Text(
                  '시작: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedDoubleCounter(
                  value: weightChange!.startWeight,
                  duration: const Duration(milliseconds: 1000),
                  suffix: 'kg',
                  decimalPlaces: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '  ->  현재: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AnimatedDoubleCounter(
                  value: weightChange!.currentWeight,
                  duration: const Duration(milliseconds: 1000),
                  suffix: 'kg',
                  decimalPlaces: 1,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: _buildMiniChart(context, changeColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniChart(BuildContext context, Color lineColor) {
    if (weightHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    // 날짜 오름차순 정렬 (왼쪽=과거, 오른쪽=최신)
    final sortedHistory = List<WeightHistoryData>.from(weightHistory)
      ..sort((a, b) => a.date.compareTo(b.date));

    final theme = Theme.of(context);
    final spots = <FlSpot>[];

    for (var i = 0; i < sortedHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedHistory[i].weight));
    }

    // 최소/최대 체중 계산 (차트 범위 설정용)
    final weights = sortedHistory.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedHistory.length - 1).toDouble(),
        minY: minWeight - padding - 1,
        maxY: maxWeight + padding + 1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => theme.colorScheme.surfaceContainerHighest,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}kg',
                  TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // 첫 번째와 마지막 점만 표시
                if (index == 0 || index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const EmptyState(
        type: EmptyStateType.bodyRecords,
        customTitle: '체중 기록이 부족합니다',
        customMessage: '2개 이상의 기록이 필요해요',
        iconSize: 80,
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ErrorState.fromError(
        error,
        onRetry: null,
      ),
    );
  }
}

/// 빠른 액션 버튼 섹션
class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 액션',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.camera_alt_outlined,
                label: '식단 기록',
                color: AppTheme.tertiary,
                onTap: () {
                  context.go('/member/diet');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.bar_chart_outlined,
                label: '내 기록',
                color: AppTheme.primary,
                onTap: () {
                  context.go('/member/records');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 빠른 액션 버튼 위젯
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 빈 인사이트 섹션 (인사이트 생성 유도)
class _EmptyInsightSection extends ConsumerWidget {
  final String memberId;

  const _EmptyInsightSection({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final generationState = ref.watch(memberInsightsGenerationProvider);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome, size: 20, color: AppTheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                'AI 인사이트',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.insights,
            size: 48,
            color: AppTheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'AI가 분석한 맞춤 인사이트를 확인해보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: generationState.isGenerating
                  ? null
                  : () => ref.read(memberInsightsGenerationProvider.notifier).generate(memberId),
              icon: generationState.isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome, size: 18),
              label: Text(generationState.isGenerating ? '분석 중...' : '인사이트 생성하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // 에러 메시지 표시
          if (generationState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              generationState.errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// _MemberInsightCard에서 사용할 통일된 카드 데코레이션
BoxDecoration _getUnifiedCardDecoration(BuildContext context, Color? accentColor) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  // 기본 그레이 보더, accentColor가 있으면 아주 미세하게만 적용
  final borderColor = accentColor != null
      ? Color.lerp(
          isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
          accentColor,
          0.15,
        )!
      : (isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB));

  return BoxDecoration(
    color: isDark ? const Color(0xFF1E2A4A) : Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: borderColor,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// AI 인사이트 카드 섹션
class _InsightCardsSection extends ConsumerWidget {
  final List<MemberInsight> insights;
  final String memberId;

  const _InsightCardsSection({
    required this.insights,
    required this.memberId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final generationState = ref.watch(memberInsightsGenerationProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 20, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI 인사이트',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // 새로고침 버튼
              IconButton(
                icon: generationState.isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 20),
                onPressed: generationState.isGenerating
                    ? null
                    : () => _refreshInsights(ref),
                tooltip: '인사이트 새로고침',
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: AnimatedListWrapper(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: insights.length > 5 ? 5 : insights.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final insight = insights[index];
                return AnimatedListWrapper.item(
                  index: index,
                  horizontalOffset: 50.0,
                  verticalOffset: 0.0,
                  child: _MemberInsightCard(insight: insight),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 인사이트 새로고침
  void _refreshInsights(WidgetRef ref) {
    ref.read(memberInsightsGenerationProvider.notifier).generate(memberId);
  }
}

/// 개별 인사이트 카드 (미니 그래프 지원)
class _MemberInsightCard extends StatelessWidget {
  final MemberInsight insight;

  const _MemberInsightCard({required this.insight});

  /// 인사이트 타입에 따른 네비게이션 경로 반환
  String? _getNavigationRoute() {
    switch (insight.type) {
      // 체성분 관련 - 기록 화면으로
      case 'bodyPrediction':
      case 'bodyChangeReport':
      case 'weightProgress':
        return '/member/records';
      // 영양/식단 관련 - 식단 화면으로
      case 'nutritionBalance':
        return '/member/diet';
      // 출석/일정 관련 - 캘린더 화면으로
      case 'attendanceHabit':
      case 'attendanceAlert':
        return '/member/calendar';
      // 벤치마크 - 기록 화면으로
      case 'benchmark':
        return '/member/records';
      // 운동 관련 - 기록 화면으로
      case 'workoutAchievement':
      case 'workoutVolume':
        return '/member/records';
      // 목표 진행률 - 기록 화면으로
      case 'goalProgress':
        return '/member/records';
      // 컨디션 패턴 - 기록 화면으로
      case 'conditionPattern':
        return '/member/records';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final navigationRoute = _getNavigationRoute();

    return GestureDetector(
      onTap: navigationRoute != null
          ? () => context.push(navigationRoute)
          : null,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 0),
        padding: const EdgeInsets.all(12),
        decoration: _getUnifiedCardDecoration(context, insight.priorityColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 아이콘 + 우선순위 배지
            Row(
              children: [
                Icon(
                  insight.typeIcon,
                  size: 20,
                  color: insight.priorityColor,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: insight.priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    insight.title,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: insight.priorityColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 미니 그래프 영역 (데이터가 있는 경우)
            if (insight.graphData != null && insight.graphType != null)
              Expanded(
                child: _buildChart(),
              )
            else
              const Spacer(),
            const SizedBox(height: 8),
            // 메시지
            Text(
              insight.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 그래프 타입과 인사이트 타입에 따른 차트 위젯 빌드
  Widget _buildChart() {
    // 벤치마크 타입이고 distribution 그래프인 경우 BenchmarkDistributionChart 사용
    if (insight.type == 'benchmark' && insight.graphType == 'distribution') {
      final data = insight.graphData!;
      // graphData에서 필요한 정보 추출
      final overallPercentile = data.isNotEmpty && data[0].containsKey('overallPercentile')
          ? (data[0]['overallPercentile'] as num).toInt()
          : 50;
      final goal = data.isNotEmpty && data[0].containsKey('goal')
          ? data[0]['goal'] as String
          : 'fitness';
      final categories = data.isNotEmpty && data[0].containsKey('categories')
          ? (data[0]['categories'] as List<dynamic>)
              .map((c) => c as Map<String, dynamic>)
              .toList()
          : <Map<String, dynamic>>[];

      return BenchmarkDistributionChart.fromMaps(
        overallPercentile: overallPercentile,
        categories: categories,
        goal: goal,
      );
    }

    // workout_volume 타입이고 donut 그래프인 경우 MuscleBalanceDonut 사용
    if (insight.type == 'workoutVolume' && insight.graphType == 'donut') {
      final data = insight.graphData!;
      if (data.isNotEmpty && data[0].containsKey('muscleGroupBalance')) {
        final muscleBalance = data[0]['muscleGroupBalance'] as Map<String, dynamic>;
        final isImbalanced = data[0]['isImbalanced'] as bool? ?? false;
        final imbalanceType = data[0]['imbalanceType'] as String?;

        return MuscleBalanceDonut(
          muscleGroupBalance: muscleBalance.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
          isImbalanced: isImbalanced,
          imbalanceType: imbalanceType,
        );
      }
    }

    // 기본 InsightMiniChart 사용
    return InsightMiniChart(
      graphType: insight.graphType!,
      data: insight.graphData!,
      primaryColor: insight.priorityColor,
    );
  }
}

