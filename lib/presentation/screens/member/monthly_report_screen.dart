import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';

/// 월간 피트니스 리포트 화면 (프리미엄 회원용)
class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1))) {
      setState(() {
        _selectedMonth = nextMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(currentMemberProvider);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('월간 리포트')),
        body: const Center(
          child: Text('회원 정보를 불러올 수 없습니다.'),
        ),
      );
    }

    final memberId = member.id;
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('월간 리포트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
            tooltip: '리포트 공유',
          ),
        ],
      ),
      body: Column(
        children: [
          // 월 선택기
          _MonthSelector(
            selectedMonth: _selectedMonth,
            onPrevious: _previousMonth,
            onNext: isCurrentMonth ? null : _nextMonth,
          ),

          // 리포트 내용
          Expanded(
            child: _MonthlyReportContent(
              memberId: memberId,
              selectedMonth: _selectedMonth,
            ),
          ),
        ],
      ),
    );
  }

  void _shareReport(BuildContext context) {
    final monthText = '${_selectedMonth.year}년 ${_selectedMonth.month}월';
    Share.share(
      'PAL 월간 피트니스 리포트 - $monthText\n\n'
      '더 자세한 내용은 PAL 앱에서 확인하세요!',
      subject: 'PAL 월간 리포트',
    );
  }
}

/// 월 선택기
class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthText = '${selectedMonth.year}년 ${selectedMonth.month}월';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Text(
            monthText,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: onNext == null ? Colors.grey.shade400 : null,
            ),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

/// 월간 리포트 내용
class _MonthlyReportContent extends ConsumerWidget {
  final String memberId;
  final DateTime selectedMonth;

  const _MonthlyReportContent({
    required this.memberId,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 통계 카드들
          _SummarySection(
            memberId: memberId,
            selectedMonth: selectedMonth,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // 체중 변화 차트
          _WeightTrendSection(
            memberId: memberId,
            selectedMonth: selectedMonth,
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // 운동 빈도 차트
          _WorkoutFrequencySection(
            memberId: memberId,
            selectedMonth: selectedMonth,
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // AI 추천 섹션
          _AIRecommendationsSection(
            memberId: memberId,
            selectedMonth: selectedMonth,
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// 요약 통계 섹션
class _SummarySection extends ConsumerWidget {
  final String memberId;
  final DateTime selectedMonth;

  const _SummarySection({
    required this.memberId,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final weightChangeAsync = ref.watch(weightChangeProvider(memberId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '이번 달 요약',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // 체중 변화
            weightChangeAsync.when(
              loading: () => _buildStatSkeleton(context),
              error: (_, __) => _StatCard(
                title: '체중 변화',
                value: '-',
                icon: Icons.monitor_weight_outlined,
                color: AppTheme.primary,
              ),
              data: (data) => _StatCard(
                title: '체중 변화',
                value: data != null
                    ? '${data.isLoss ? '' : '+'}${data.change.toStringAsFixed(1)}kg'
                    : '-',
                icon: Icons.monitor_weight_outlined,
                color: data?.isLoss == true ? AppTheme.secondary : AppTheme.error,
                subtitle: data != null
                    ? '${data.startWeight.toStringAsFixed(1)} -> ${data.currentWeight.toStringAsFixed(1)}'
                    : null,
              ),
            ),
            // 운동 횟수 (예시 데이터)
            _StatCard(
              title: '운동 횟수',
              value: '12회',
              icon: Icons.fitness_center,
              color: AppTheme.primary,
              subtitle: '목표 16회 중',
            ),
            // 식단 기록률 (예시 데이터)
            _StatCard(
              title: '식단 기록률',
              value: '78%',
              icon: Icons.restaurant_outlined,
              color: AppTheme.tertiary,
              subtitle: '${selectedMonth.month}월 기록',
            ),
            // 연속 달성 (예시 데이터)
            _StatCard(
              title: '연속 달성',
              value: '7일',
              icon: Icons.local_fire_department,
              color: AppTheme.error,
              subtitle: '최장 기록!',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// 통계 카드
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

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
          color: color.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 체중 변화 추이 섹션
class _WeightTrendSection extends ConsumerWidget {
  final String memberId;
  final DateTime selectedMonth;

  const _WeightTrendSection({
    required this.memberId,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '체중 변화 추이',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: weightHistoryAsync.when(
              loading: () => _buildChartSkeleton(context),
              error: (error, _) => Center(
                child: Text('데이터를 불러올 수 없습니다.'),
              ),
              data: (history) {
                if (history.length < 2) {
                  return const Center(
                    child: Text('데이터가 부족합니다.\n2개 이상의 기록이 필요해요.'),
                  );
                }
                return _buildWeightChart(context, history);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSkeleton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, List<WeightHistoryData> history) {
    final theme = Theme.of(context);
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: (history.length / 5).ceilToDouble(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < history.length) {
                  final date = history[index].date;
                  return Text(
                    '${date.month}/${date.day}',
                    style: theme.textTheme.labelSmall,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (history.length - 1).toDouble(),
        minY: minWeight - padding - 1,
        maxY: maxWeight + padding + 1,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => theme.colorScheme.surfaceContainerHighest,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final date = history[index].date;
                return LineTooltipItem(
                  '${date.month}/${date.day}\n${spot.y.toStringAsFixed(1)}kg',
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
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == 0 || index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: AppTheme.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.primary.withValues(alpha: 0.5),
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
                  AppTheme.primary.withValues(alpha: 0.3),
                  AppTheme.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 운동 빈도 섹션
class _WorkoutFrequencySection extends StatelessWidget {
  final String memberId;
  final DateTime selectedMonth;

  const _WorkoutFrequencySection({
    required this.memberId,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 예시 데이터 - 실제로는 provider에서 가져옴
    final weeklyData = [3, 4, 2, 5, 3, 4, 2];
    final weekLabels = ['1주', '2주', '3주', '4주', '5주'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '주간 운동 빈도',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 7,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => theme.colorScheme.surfaceContainerHighest,
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}회',
                        TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
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
                        final index = value.toInt();
                        if (index >= 0 && index < weekLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weekLabels[index],
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: theme.textTheme.labelSmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.dividerColor,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(weekLabels.length, (index) {
                  final value = index < weeklyData.length ? weeklyData[index].toDouble() : 0;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondary, AppTheme.primary],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 24,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// AI 추천 섹션
class _AIRecommendationsSection extends StatelessWidget {
  final String memberId;
  final DateTime selectedMonth;

  const _AIRecommendationsSection({
    required this.memberId,
    required this.selectedMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 예시 추천 데이터 - 실제로는 AI에서 생성
    final recommendations = [
      _RecommendationItem(
        icon: Icons.fitness_center,
        title: '하체 운동 강화 추천',
        description: '이번 달 상체 운동 비율이 70%입니다. 균형잡힌 발달을 위해 하체 운동을 늘려보세요.',
        color: AppTheme.primary,
      ),
      _RecommendationItem(
        icon: Icons.restaurant,
        title: '단백질 섭취 증가 권장',
        description: '목표 체중 대비 단백질 섭취가 부족합니다. 하루 120g을 목표로 해보세요.',
        color: AppTheme.secondary,
      ),
      _RecommendationItem(
        icon: Icons.bedtime,
        title: '휴식일 확보 필요',
        description: '연속 5일 이상 운동한 주가 2번 있었습니다. 적절한 휴식으로 회복을 도와주세요.',
        color: AppTheme.tertiary,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            AppTheme.secondary.withValues(alpha: isDark ? 0.2 : 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI 맞춤 추천',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${selectedMonth.month}월 데이터 기반',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < recommendations.length - 1 ? 12 : 0),
              child: _RecommendationCard(item: item),
            );
          }),
        ],
      ),
    );
  }
}

class _RecommendationItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class _RecommendationCard extends StatelessWidget {
  final _RecommendationItem item;

  const _RecommendationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
