import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/utils/animation_utils.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/schedule_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/animated/animated_widgets.dart';

/// 트레이너 웹 대시보드 화면
/// SaaS 스타일의 프리미엄 UI 대시보드
class TrainerDashboardWebScreen extends ConsumerWidget {
  const TrainerDashboardWebScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersWithUserProvider);
    final trainer = ref.watch(currentTrainerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 환영 메시지
          _buildWelcomeSection(context, ref),
          const SizedBox(height: 24),

          // 통계 카드 4개
          membersAsync.when(
            data: (members) => _buildStatsCards(context, members.length),
            loading: () => _buildStatsCardsLoading(),
            error: (_, __) => _buildStatsCards(context, 0),
          ),
          const SizedBox(height: 24),

          // 메인 컨텐츠 (2열)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽 (2/3)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    _buildTodayScheduleCard(context, ref, trainer?.id),
                    const SizedBox(height: 24),
                    _buildWeeklyChartCard(context),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 오른쪽 (1/3)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildExpiringMembersCard(context, ref),
                    const SizedBox(height: 24),
                    _buildQuickActionsCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 환영 메시지 섹션
  Widget _buildWelcomeSection(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? '좋은 아침이에요'
        : hour < 18
            ? '좋은 오후에요'
            : '좋은 저녁이에요';

    return Row(
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
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  /// 통계 카드 4개 빌드
  Widget _buildStatsCards(BuildContext context, int totalMembers) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            iconBgColor: AppTheme.primary,
            label: '전체 회원',
            numericValue: totalMembers,
            suffix: '명',
            change: '+2',
            isPositive: true,
            index: 0,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            iconBgColor: const Color(0xFF10B981),
            label: '진행중 회원',
            numericValue: (totalMembers * 0.7).round(),
            suffix: '명',
            change: '+1',
            isPositive: true,
            index: 1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            iconBgColor: const Color(0xFFF59E0B),
            label: '이번주 수업',
            numericValue: 24,
            suffix: '회',
            change: '+5',
            isPositive: true,
            index: 2,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.warning_amber,
            iconBgColor: const Color(0xFFEF4444),
            label: 'PT 임박',
            numericValue: 3,
            suffix: '명',
            change: '',
            isPositive: false,
            index: 3,
          ),
        ),
      ],
    );
  }

  /// 통계 카드 로딩 상태
  Widget _buildStatsCardsLoading() {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            height: 120,
            margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  /// 오늘의 수업 일정 카드
  Widget _buildTodayScheduleCard(
      BuildContext context, WidgetRef ref, String? trainerId) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: AppTheme.primary),
              const SizedBox(width: 12),
              const Text(
                '오늘의 수업 일정',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                child: Text(
                  '일정을 불러오는 중...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// 주간 수업 현황 차트 카드
  Widget _buildWeeklyChartCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: Color(0xFF10B981)),
              SizedBox(width: 12),
              Text(
                '주간 수업 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(begin: 0.1);
  }

  /// 바 차트 그룹 데이터 생성
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

  /// PT 종료 임박 회원 카드
  Widget _buildExpiringMembersCard(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber,
                    color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'PT 종료 임박',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _ExpiringMemberItem(name: '김철수', remaining: 2),
          const Divider(height: 24),
          const _ExpiringMemberItem(name: '박영희', remaining: 4),
          const Divider(height: 24),
          const _ExpiringMemberItem(name: '이민수', remaining: 5),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.1);
  }

  /// 빠른 액션 카드
  Widget _buildQuickActionsCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 액션',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
            onTap: () => context.go('/trainer/calendar'),
          ),
          const SizedBox(height: 12),
          _QuickActionButton(
            icon: Icons.auto_awesome,
            label: 'AI 커리큘럼 생성',
            color: const Color(0xFFF59E0B),
            onTap: () {},
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideX(begin: 0.1);
  }
}

/// 통계 카드 위젯
class _StatCard extends StatefulWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final int numericValue;
  final String suffix;
  final String change;
  final bool isPositive;
  final int index;

  const _StatCard({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.numericValue,
    this.suffix = '명',
    required this.change,
    required this.isPositive,
    required this.index,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.identity()
          ..translate(0.0, _isHovered ? -4.0 : 0.0)
          ..scale(_isHovered ? 1.02 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.iconBgColor.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.iconBgColor,
                        widget.iconBgColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const Spacer(),
                if (widget.change.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isPositive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.isPositive
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12,
                          color: widget.isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.change,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isPositive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // AnimatedCounter로 숫자 카운트업 애니메이션 적용
            AnimatedCounter(
              value: widget.numericValue,
              suffix: widget.suffix,
              duration: const Duration(milliseconds: 1200),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    ).animate(effects: AppAnimations.cardEntrance(widget.index));
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
            .where((s) =>
                s.status == ScheduleStatus.scheduled && s.endTime.isAfter(now))
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
                  Text(
                    '오늘 예정된 수업이 없습니다',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: upcoming
              .map((schedule) => _ScheduleTimelineItem(schedule: schedule))
              .toList(),
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
          // 시간
          SizedBox(
            width: 60,
            child: Text(
              schedule.timeString,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
          // 타임라인 점
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: itemColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // 일정 정보
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: itemColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    schedule.displayTitle,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

/// PT 종료 임박 회원 아이템 위젯
class _ExpiringMemberItem extends StatelessWidget {
  final String name;
  final int remaining;

  const _ExpiringMemberItem({required this.name, required this.remaining});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
          child: Text(
            name.substring(0, 1),
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$remaining회 남음',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444),
            ),
          ),
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color:
                _isHovered ? widget.color.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? widget.color : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: _isHovered ? widget.color : null,
                ),
              ),
              const Spacer(),
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
