import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/inbody_record_model.dart';
import '../../providers/inbody_provider.dart';
import '../../widgets/inbody/inbody_input_form.dart';

/// 회원 인바디 화면
/// 최근 인바디 결과, 체성분 차트, 히스토리 표시
class MemberInbodyScreen extends ConsumerWidget {
  final String memberId;
  final String? memberName;

  const MemberInbodyScreen({
    super.key,
    required this.memberId,
    this.memberName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestInbodyProvider(memberId));
    final historyAsync = ref.watch(inbodyHistoryProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: Text(memberName != null ? '$memberName 인바디' : '인바디 기록'),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(latestInbodyProvider(memberId));
          ref.invalidate(inbodyHistoryProvider(memberId));
        },
        child: latestAsync.when(
          loading: () => const _InbodyScreenSkeleton(),
          error: (e, st) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('오류가 발생했습니다\n$e'),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(latestInbodyProvider(memberId));
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          data: (latest) {
            if (latest == null) {
              return _buildEmptyState(context, ref);
            }
            return _buildContent(context, ref, latest, historyAsync);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInputForm(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('기록 추가'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            '인바디 기록이 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 인바디 기록을 추가해보세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showInputForm(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('기록 추가'),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    InbodyRecordModel latest,
    AsyncValue<List<InbodyRecordModel>> historyAsync,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최신 인바디 결과 카드
          _InbodyResultCard(record: latest)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // 체성분 도넛 차트
          _BodyCompositionChart(record: latest)
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // 히스토리 그래프
          historyAsync.when(
            loading: () => const _ChartSkeleton(),
            error: (e, st) => const SizedBox.shrink(),
            data: (history) {
              if (history.length < 2) {
                return const SizedBox.shrink();
              }
              return _InbodyHistoryChart(records: history)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),

          const SizedBox(height: 24),

          // 히스토리 리스트
          _buildHistorySection(context, ref, historyAsync),

          const SizedBox(height: 80), // FAB 공간
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<InbodyRecordModel>> historyAsync,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '측정 기록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const _HistoryListSkeleton(),
          error: (e, st) => Text('오류: $e'),
          data: (history) {
            if (history.isEmpty) {
              return const Text('기록이 없습니다');
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final record = history[index];
                return _InbodyHistoryTile(
                  record: record,
                  onDelete: () => _deleteRecord(context, ref, record),
                ).animate().fadeIn(
                      duration: 200.ms,
                      delay: Duration(milliseconds: 50 * index),
                    );
              },
            );
          },
        ),
      ],
    );
  }

  Future<void> _showInputForm(BuildContext context, WidgetRef ref) async {
    final data = await InbodyInputForm.showAsBottomSheet(
      context,
      memberId: memberId,
    );

    if (data != null) {
      final notifier = ref.read(inbodyNotifierProvider.notifier);
      final id = await notifier.saveManualEntry(
        memberId: data.memberId,
        weight: data.weight,
        skeletalMuscleMass: data.skeletalMuscleMass,
        bodyFatPercent: data.bodyFatPercent,
        bodyFatMass: data.bodyFatMass,
        bmi: data.bmi,
        basalMetabolicRate: data.basalMetabolicRate,
        totalBodyWater: data.totalBodyWater,
        protein: data.protein,
        minerals: data.minerals,
        visceralFatLevel: data.visceralFatLevel,
        inbodyScore: data.inbodyScore,
        memo: data.memo,
        measuredAt: data.measuredAt,
      );

      if (id != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인바디 기록이 저장되었습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    InbodyRecordModel record,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 인바디 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(inbodyNotifierProvider.notifier);
      final success = await notifier.deleteRecord(memberId, record.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('기록이 삭제되었습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// 최신 인바디 결과 카드
class _InbodyResultCard extends StatelessWidget {
  final InbodyRecordModel record;

  const _InbodyResultCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 측정 결과',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _formatDate(record.measuredAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '체중',
                    '${record.weight.toStringAsFixed(1)}kg',
                    Icons.monitor_weight_outlined,
                    colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '골격근량',
                    '${record.skeletalMuscleMass.toStringAsFixed(1)}kg',
                    Icons.fitness_center,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    '체지방률',
                    '${record.bodyFatPercent.toStringAsFixed(1)}%',
                    Icons.water_drop_outlined,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            if (record.inbodyScore != null) ...[
              const Divider(height: 32),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '인바디 점수',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    '${record.inbodyScore}점',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 체성분 도넛 차트
class _BodyCompositionChart extends StatelessWidget {
  final InbodyRecordModel record;

  const _BodyCompositionChart({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 체성분 비율 계산
    final totalWeight = record.weight;
    final fatMass = record.bodyFatMass ?? (totalWeight * record.bodyFatPercent / 100);
    final muscleMass = record.skeletalMuscleMass;
    final otherMass = totalWeight - fatMass - muscleMass;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '체성분 분석',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: muscleMass,
                            title:
                                '${(muscleMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.green,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: fatMass,
                            title:
                                '${(fatMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.orange,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: otherMass > 0 ? otherMass : 0,
                            title:
                                '${(otherMass / totalWeight * 100).toStringAsFixed(0)}%',
                            color: Colors.blue,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        '골격근량',
                        '${muscleMass.toStringAsFixed(1)}kg',
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        '체지방량',
                        '${fatMass.toStringAsFixed(1)}kg',
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildLegendItem(
                        '기타',
                        '${otherMass.toStringAsFixed(1)}kg',
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 히스토리 라인 차트
class _InbodyHistoryChart extends StatelessWidget {
  final List<InbodyRecordModel> records;

  const _InbodyHistoryChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 날짜순 정렬 (오래된 것 먼저)
    final sortedRecords = List<InbodyRecordModel>.from(records)
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    // 최근 10개만 표시
    final displayRecords = sortedRecords.length > 10
        ? sortedRecords.sublist(sortedRecords.length - 10)
        : sortedRecords;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '변화 추이',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChartLegend('체중', colorScheme.primary),
                const SizedBox(width: 16),
                _buildChartLegend('골격근량', Colors.green),
                const SizedBox(width: 16),
                _buildChartLegend('체지방률', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < displayRecords.length) {
                            final date = displayRecords[index].measuredAt;
                            return Text(
                              '${date.month}/${date.day}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 24,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // 체중 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.weight);
                      }).toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    // 골격근량 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(),
                            e.value.skeletalMuscleMass);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    // 체지방률 라인
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.bodyFatPercent);
                      }).toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}

/// 히스토리 타일
class _InbodyHistoryTile extends StatelessWidget {
  final InbodyRecordModel record;
  final VoidCallback onDelete;

  const _InbodyHistoryTile({
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${record.measuredAt.day}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${record.measuredAt.month}월',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '${record.weight.toStringAsFixed(1)}kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '골격근 ${record.skeletalMuscleMass.toStringAsFixed(1)}kg · '
          '체지방 ${record.bodyFatPercent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: onDelete,
          color: colorScheme.error,
        ),
      ),
    );
  }
}

/// 스켈레톤 로딩
class _InbodyScreenSkeleton extends StatelessWidget {
  const _InbodyScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

class _HistoryListSkeleton extends StatelessWidget {
  const _HistoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
