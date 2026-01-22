import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/web/web_widgets.dart';

/// 트레이너 웹 대시보드 화면
/// SaaS 스타일의 프리미엄 UI 대시보드 - 반응형 3컬럼 그리드
class TrainerDashboardWebScreen extends ConsumerWidget {
  const TrainerDashboardWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersWithUserProvider);
    final trainer = ref.watch(currentTrainerProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final layoutType = getLayoutType(width);
        final padding = _getPadding(layoutType);

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 환영 메시지
              _buildWelcomeSection(context, ref),
              const SizedBox(height: 24),

              // 통계 카드 - 반응형
              membersAsync.when(
                data: (members) => _buildStatsCards(context, ref, members.length, layoutType),
                loading: () => _buildStatsCardsLoading(layoutType),
                error: (_, _) => _buildStatsCards(context, ref, 0, layoutType),
              ),
              const SizedBox(height: 24),

              // 메인 컨텐츠 - 반응형 그리드
              _buildMainContent(context, ref, trainer?.id, layoutType),
            ],
          ),
        );
      },
    );
  }

  double _getPadding(LayoutType layoutType) {
    return switch (layoutType) {
      LayoutType.mobile => 16,
      LayoutType.tablet => 20,
      LayoutType.desktop => 24,
      LayoutType.wideDesktop => 32,
    };
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final insightsAsync = ref.watch(unreadInsightCountProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? '좋은 아침이에요' : hour < 18 ? '좋은 오후에요' : '좋은 저녁이에요';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${authState.displayName ?? '트레이너'}님!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // 알림 표시
        insightsAsync.when(
          data: (count) => count > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Color(0xFFF59E0B), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '새로운 인사이트 $count개',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 통계 카드 빌드 - 반응형
  Widget _buildStatsCards(BuildContext context, WidgetRef ref, int totalMembers, LayoutType layoutType) {
    final membersAsync = ref.watch(membersWithUserProvider);

    // 만료 임박 회원 계산 (5회 이하)
    final expiringCount = membersAsync.whenOrNull(
      data: (members) => members.where((m) => m.member.remainingSessions <= 5).length,
    ) ?? 0;

    // 이번 주 완료 세션 계산
    final trainer = ref.watch(currentTrainerProvider);
    final weeklySchedules = trainer != null
        ? ref.watch(weeklyScheduleStatsProvider(trainer.id))
        : const AsyncValue<int>.data(0);
    final weeklyCount = weeklySchedules.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final cards = [
      WebStatCard(
        title: '전체 회원',
        value: '$totalMembers명',
        icon: Icons.people,
        variant: WebStatCardVariant.primary,
        trend: 5.2,
        trendLabel: '지난 달 대비',
        animationDelay: 100.ms,
        onTap: () => context.go('/trainer/members'),
      ),
      WebStatCard(
        title: '진행중 회원',
        value: '${(totalMembers * 0.7).round()}명',
        icon: Icons.fitness_center,
        variant: WebStatCardVariant.success,
        trend: 2.1,
        trendLabel: '지난 달 대비',
        animationDelay: 150.ms,
      ),
      WebStatCard(
        title: '이번주 수업',
        value: '$weeklyCount회',
        icon: Icons.calendar_today,
        variant: WebStatCardVariant.warning,
        trend: 8.5,
        trendLabel: '지난 주 대비',
        animationDelay: 200.ms,
        onTap: () => context.go('/trainer/calendar'),
      ),
      WebStatCard(
        title: 'PT 임박',
        value: '$expiringCount명',
        subtitle: '5회 이하 남음',
        icon: Icons.warning_amber,
        variant: WebStatCardVariant.error,
        animationDelay: 250.ms,
      ),
    ];

    final crossAxisCount = switch (layoutType) {
      LayoutType.mobile => 1,
      LayoutType.tablet => 2,
      LayoutType.desktop => 4,
      LayoutType.wideDesktop => 4,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  /// 통계 카드 로딩 상태
  Widget _buildStatsCardsLoading(LayoutType layoutType) {
    final crossAxisCount = switch (layoutType) {
      LayoutType.mobile => 1,
      LayoutType.tablet => 2,
      LayoutType.desktop => 4,
      LayoutType.wideDesktop => 4,
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 140,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => WebStatCard(
        title: '',
        value: '',
        isLoading: true,
        animationDelay: (100 * index).ms,
      ),
    );
  }

  /// 메인 컨텐츠 - 반응형 그리드 레이아웃
  Widget _buildMainContent(BuildContext context, WidgetRef ref, String? trainerId, LayoutType layoutType) {
    if (layoutType == LayoutType.mobile) {
      // 모바일: 단일 컬럼
      return Column(
        children: [
          _buildTodayScheduleCard(context, ref, trainerId),
          const SizedBox(height: 24),
          _buildAiInsightsCard(context, ref),
          const SizedBox(height: 24),
          _buildMemberStatusCard(context, ref),
          const SizedBox(height: 24),
          _buildWeeklyChartCard(context, ref, trainerId),
          const SizedBox(height: 24),
          _buildRecentActivityCard(context, ref),
          const SizedBox(height: 24),
          _buildQuickActionsCard(context),
        ],
      );
    }

    if (layoutType == LayoutType.tablet) {
      // 태블릿: 2컬럼
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                _buildTodayScheduleCard(context, ref, trainerId),
                const SizedBox(height: 24),
                _buildWeeklyChartCard(context, ref, trainerId),
                const SizedBox(height: 24),
                _buildRecentActivityCard(context, ref),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildAiInsightsCard(context, ref),
                const SizedBox(height: 24),
                _buildMemberStatusCard(context, ref),
                const SizedBox(height: 24),
                _buildQuickActionsCard(context),
              ],
            ),
          ),
        ],
      );
    }

    // 데스크탑/와이드: 3컬럼 그리드
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 컬럼 (1/3)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildTodayScheduleCard(context, ref, trainerId),
              const SizedBox(height: 24),
              _buildQuickActionsCard(context),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // 중앙 컬럼 (1/3)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildAiInsightsCard(context, ref),
              const SizedBox(height: 24),
              _buildWeeklyChartCard(context, ref, trainerId),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // 오른쪽 컬럼 (1/3)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildMemberStatusCard(context, ref),
              const SizedBox(height: 24),
              _buildRecentActivityCard(context, ref),
            ],
          ),
        ),
      ],
    );
  }

  /// 오늘의 수업 일정 카드
  Widget _buildTodayScheduleCard(BuildContext context, WidgetRef ref, String? trainerId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: AppTheme.primary),
              const SizedBox(width: 12),
              const Text(
                '오늘의 수업 일정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/trainer/calendar'),
                child: const Text('전체 보기'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (trainerId != null)
            _TodayScheduleList(trainerId: trainerId)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text('일정을 불러오는 중...', style: TextStyle(color: Colors.grey[600])),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// AI 인사이트 카드 (high priority 3개)
  Widget _buildAiInsightsCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final insightsAsync = ref.watch(urgentInsightsProvider);

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primary, const Color(0xFF10B981)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI 인사이트',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/trainer/insights'),
                child: const Text('전체 보기'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Builder(
            builder: (context) {
              final insights = insightsAsync;
              if (insights.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text('새로운 인사이트가 없습니다', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: insights.take(3).map((insight) => _InsightItem(insight: insight)).toList(),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// 회원 현황 카드
  Widget _buildMemberStatusCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final membersAsync = ref.watch(membersWithUserProvider);

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.groups, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                '회원 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          membersAsync.when(
            data: (members) {
              final total = members.length;
              final newThisMonth = members.where((m) {
                final startDate = m.member.ptInfo.startDate;
                final now = DateTime.now();
                return startDate.year == now.year && startDate.month == now.month;
              }).length;
              final expiring = members.where((m) => m.member.remainingSessions <= 5).length;

              return Column(
                children: [
                  _MemberStatusRow(
                    label: '총 회원',
                    value: '$total명',
                    icon: Icons.people,
                    color: AppTheme.primary,
                  ),
                  const Divider(height: 24),
                  _MemberStatusRow(
                    label: '신규 (이번 달)',
                    value: '$newThisMonth명',
                    icon: Icons.person_add,
                    color: const Color(0xFF10B981),
                  ),
                  const Divider(height: 24),
                  _MemberStatusRow(
                    label: '만료 임박',
                    value: '$expiring명',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => Center(
              child: Text('회원 정보를 불러올 수 없습니다', style: TextStyle(color: Colors.grey[600])),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// 주간 수업 현황 차트 카드
  Widget _buildWeeklyChartCard(BuildContext context, WidgetRef ref, String? trainerId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF10B981)),
              SizedBox(width: 12),
              Text(
                '주간 수업 현황',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.blueGrey,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      const days = ['월', '화', '수', '목', '금', '토', '일'];
                      return BarTooltipItem(
                        '${days[group.x]}\n${rod.toY.toInt()}회',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['월', '화', '수', '목', '금', '토', '일'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt()],
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: [
                  _makeBarGroup(0, 5),
                  _makeBarGroup(1, 7),
                  _makeBarGroup(2, 4),
                  _makeBarGroup(3, 8),
                  _makeBarGroup(4, 6),
                  _makeBarGroup(5, 3),
                  _makeBarGroup(6, 2),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  BarChartGroupData _makeBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [AppTheme.primary, Color(0xFF10B981)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }

  /// 최근 활동 피드 카드
  Widget _buildRecentActivityCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.history, color: Color(0xFFF59E0B), size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                '최근 활동',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ActivityItem(
            icon: Icons.fitness_center,
            iconColor: AppTheme.primary,
            title: '김철수 회원 PT 완료',
            time: '30분 전',
          ),
          const Divider(height: 24),
          _ActivityItem(
            icon: Icons.person_add,
            iconColor: const Color(0xFF10B981),
            title: '박영희 회원 등록',
            time: '2시간 전',
          ),
          const Divider(height: 24),
          _ActivityItem(
            icon: Icons.chat_bubble,
            iconColor: const Color(0xFFF59E0B),
            title: '이민수 회원 메시지 수신',
            time: '3시간 전',
          ),
          const Divider(height: 24),
          _ActivityItem(
            icon: Icons.auto_awesome,
            iconColor: const Color(0xFF8B5CF6),
            title: 'AI 인사이트 생성',
            time: '5시간 전',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// 빠른 액션 카드
  Widget _buildQuickActionsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _DashboardCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 액션',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _QuickActionButton(
            icon: Icons.person_add,
            label: '회원 등록',
            color: AppTheme.primary,
            onTap: () => context.go('/trainer/members'),
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.calendar_month,
            label: '일정 추가',
            color: const Color(0xFF10B981),
            onTap: () => context.go('/trainer/schedule/add'),
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.auto_awesome,
            label: 'AI 커리큘럼 생성',
            color: const Color(0xFFF59E0B),
            onTap: () => context.go('/trainer/curriculum/create'),
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.insights,
            label: 'AI 인사이트 확인',
            color: const Color(0xFF8B5CF6),
            onTap: () => context.go('/trainer/insights'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 550.ms, duration: 400.ms).slideY(begin: 0.1);
  }
}

/// 대시보드 카드 공통 위젯
/// 통일된 카드 스타일: borderRadius 16, border 1px #E5E7EB(라이트)/#374151(다크), shadow 0.03 alpha
class _DashboardCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _DashboardCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
      child: child,
    );
  }
}

/// 오늘 일정 리스트 위젯
class _TodayScheduleList extends ConsumerWidget {
  final String trainerId;

  const _TodayScheduleList({required this.trainerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(todaySchedulesProvider(trainerId));

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Center(child: Text('일정을 불러올 수 없습니다')),
      data: (schedules) {
        final now = DateTime.now();
        final upcoming = schedules
            .where((s) => s.status == ScheduleStatus.scheduled && s.endTime.isAfter(now))
            .take(5)
            .toList();

        if (upcoming.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.event_available, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('오늘 예정된 수업이 없습니다', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          );
        }

        return Column(
          children: upcoming.map((schedule) => _ScheduleTimelineItem(schedule: schedule)).toList(),
        );
      },
    );
  }
}

/// 일정 타임라인 아이템 위젯
class _ScheduleTimelineItem extends StatelessWidget {
  final ScheduleModel schedule;

  const _ScheduleTimelineItem({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isPt = schedule.isPtSchedule;
    final itemColor = isPt ? AppTheme.primary : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              schedule.timeString,
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary),
            ),
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: itemColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      schedule.displayTitle,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPt ? 'PT' : '개인',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: itemColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 인사이트 아이템 위젯
class _InsightItem extends StatefulWidget {
  final InsightModel insight;

  const _InsightItem({required this.insight});

  @override
  State<_InsightItem> createState() => _InsightItemState();
}

class _InsightItemState extends State<_InsightItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final priorityColor = widget.insight.priorityColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered
              ? priorityColor.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF2D2D2D) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isHovered ? priorityColor.withValues(alpha: 0.5) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(widget.insight.typeIcon, size: 16, color: priorityColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.insight.title,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.insight.message,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

/// 회원 현황 행 위젯
class _MemberStatusRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MemberStatusRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
        ),
      ],
    );
  }
}

/// 활동 아이템 위젯
class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
        Text(
          time,
          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[500]),
        ),
      ],
    );
  }
}

/// 빠른 액션 버튼 위젯
class _QuickActionButton extends StatefulWidget {
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
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? widget.color : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _isHovered ? widget.color : null,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: _isHovered ? widget.color : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 주간 일정 통계 Provider
final weeklyScheduleStatsProvider = FutureProvider.family<int, String>((ref, trainerId) async {
  // TODO: Implement actual weekly schedule count from repository
  return 24; // Placeholder
});
