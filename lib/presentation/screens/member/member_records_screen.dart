import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/body_composition_prediction_model.dart';
import '../../../data/models/body_record_model.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../data/repositories/body_record_repository.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_composition_prediction_provider.dart';
import '../../providers/body_records_provider.dart';
import '../../providers/curriculums_provider.dart';

/// 회원 내 기록 화면 - 프리미엄 UI
/// [체성분] [운동기록] [서명기록] 3탭 구조
class MemberRecordsScreen extends ConsumerStatefulWidget {
  const MemberRecordsScreen({super.key});

  @override
  ConsumerState<MemberRecordsScreen> createState() =>
      _MemberRecordsScreenState();
}

class _MemberRecordsScreenState extends ConsumerState<MemberRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '내 기록',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 72),
              background: Container(
                color: Colors.transparent,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64),
              child: _buildPremiumTabBar(context),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _BodyCompositionTab(),
            _ExerciseRecordsTab(),
            _SignatureRecordsTab(),
          ],
        ),
      ),
    );
  }

  /// 프리미엄 탭 바 디자인
  Widget _buildPremiumTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge,
        tabs: const [
          Tab(text: '체성분'),
          Tab(text: '운동기록'),
          Tab(text: '서명기록'),
        ],
      ),
    );
  }
}

/// 체성분 탭
class _BodyCompositionTab extends ConsumerStatefulWidget {
  const _BodyCompositionTab();

  @override
  ConsumerState<_BodyCompositionTab> createState() => _BodyCompositionTabState();
}

class _BodyCompositionTabState extends ConsumerState<_BodyCompositionTab> {
  String _selectedMetric = 'weight'; // 'weight', 'muscle', 'bodyFat', 'all'

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 AI 예측 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final member = ref.read(currentMemberProvider);
      if (member != null) {
        ref.read(bodyCompositionPredictionProvider.notifier).predictBodyComposition(member.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final member = ref.watch(currentMemberProvider);
    final memberId = member?.id ?? '';
    final bodyRecordsAsync = ref.watch(bodyRecordsProvider(memberId));
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));
    final latestRecordAsync = ref.watch(latestBodyRecordProvider(memberId));

    return bodyRecordsAsync.when(
      loading: () => const _BodyCompositionShimmer(),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(bodyRecordsProvider(memberId)),
      ),
      data: (records) {
        if (records.isEmpty) {
          return EmptyState(
            type: EmptyStateType.bodyRecords,
            onAction: () => _showAddBodyRecordDialog(context),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bodyRecordsProvider(memberId));
              },
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  // 현재 체성분 요약 카드들
                  SliverToBoxAdapter(
                    child: latestRecordAsync.when(
                      data: (record) => record != null
                          ? _CurrentStatsCards(record: record)
                          : const SizedBox.shrink(),
                      loading: () => const _StatsCardsShimmer(),
                      error: (e, st) => const SizedBox.shrink(),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                  // 메트릭 선택 세그먼트 버튼
                  SliverToBoxAdapter(
                    child: _MetricSegmentedButton(
                      selectedMetric: _selectedMetric,
                      onSelectionChanged: (metric) {
                        setState(() => _selectedMetric = metric);
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  // 체성분 변화 그래프
                  SliverToBoxAdapter(
                    child: weightHistoryAsync.when(
                      data: (history) => history.length >= 2
                          ? _BodyCompositionChart(
                              history: history,
                              selectedMetric: _selectedMetric,
                            )
                          : history.length == 1
                              ? _SingleRecordDisplay(record: history.first)
                              : const _ChartPlaceholder(
                                  message: '기록을 추가하면 변화 그래프가 표시됩니다',
                                ),
                      loading: () => const _ChartShimmer(),
                      error: (e, st) => const _ChartPlaceholder(
                        message: '차트를 불러오는데 실패했습니다',
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  // AI 예측 카드
                  SliverToBoxAdapter(
                    child: _AIPredictionCard(memberId: memberId),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                  // 섹션 헤더
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: '기록 히스토리',
                      subtitle: '총 ${records.length}개',
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 12),
                  ),
                  // 기록 리스트
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _BodyRecordCard(
                          record: records[index],
                          index: index,
                          memberId: memberId,
                        ),
                        childCount: records.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: _AddRecordFAB(
                onPressed: () => _showAddBodyRecordDialog(context),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddBodyRecordDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AddBodyRecordSheet(),
    );
  }
}

/// 메트릭 선택 세그먼트 버튼
class _MetricSegmentedButton extends StatelessWidget {
  const _MetricSegmentedButton({
    required this.selectedMetric,
    required this.onSelectionChanged,
  });

  final String selectedMetric;
  final ValueChanged<String> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'weight', label: Text('체중')),
            ButtonSegment(value: 'muscle', label: Text('골격근량')),
            ButtonSegment(value: 'bodyFat', label: Text('체지방률')),
            ButtonSegment(value: 'all', label: Text('전체')),
          ],
          selected: {selectedMetric},
          onSelectionChanged: (Set<String> selection) {
            onSelectionChanged(selection.first);
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.transparent,
            selectedBackgroundColor: colorScheme.primary,
            selectedForegroundColor: colorScheme.onPrimary,
            foregroundColor: colorScheme.onSurfaceVariant,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          showSelectedIcon: false,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// AI 예측 카드
class _AIPredictionCard extends ConsumerWidget {
  const _AIPredictionCard({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final predictionState = ref.watch(bodyCompositionPredictionProvider);

    final isDark = theme.brightness == Brightness.dark;

    if (predictionState.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
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
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final prediction = predictionState.prediction;
    if (prediction == null) {
      if (predictionState.error != null) {
        return const SizedBox.shrink();
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 20,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '체성분 예측 (4주 후)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(prediction.overallConfidence)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '신뢰도 ${(prediction.overallConfidence * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getConfidenceColor(prediction.overallConfidence),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 체중 예측
            if (prediction.weightPrediction != null)
              _buildPredictionRow(
                context,
                '체중',
                prediction.weightPrediction!,
                'kg',
                AppTheme.primary,
                Icons.monitor_weight_rounded,
              ),
            // 골격근량 예측
            if (prediction.musclePrediction != null)
              _buildPredictionRow(
                context,
                '골격근량',
                prediction.musclePrediction!,
                'kg',
                Colors.green,
                Icons.fitness_center_rounded,
              ),
            // 체지방률 예측
            if (prediction.bodyFatPrediction != null)
              _buildPredictionRow(
                context,
                '체지방률',
                prediction.bodyFatPrediction!,
                '%',
                Colors.orange,
                Icons.water_drop_rounded,
              ),
            if (prediction.analysisMessage.isNotEmpty) ...[
              const Divider(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.analysisMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 300.ms);
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  Widget _buildPredictionRow(
    BuildContext context,
    String label,
    MetricPrediction pred,
    String unit,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 변화에 따른 색상 결정 (체중/체지방은 감소가 좋음, 근육량은 증가가 좋음)
    Color changeColor;
    if (label == '골격근량') {
      changeColor = pred.weeklyTrend > 0 ? Colors.green : Colors.red;
    } else {
      changeColor = pred.weeklyTrend < 0 ? Colors.green : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${pred.current.toStringAsFixed(1)}$unit',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${pred.predicted.toStringAsFixed(1)}$unit',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(4주 후)',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${pred.change >= 0 ? "▲" : "▼"}${pred.change.abs().toStringAsFixed(1)}$unit/월',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: changeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 현재 체성분 요약 카드들
class _CurrentStatsCards extends StatelessWidget {
  const _CurrentStatsCards({required this.record});

  final BodyRecordModel record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: '체중',
              value: record.weight.toStringAsFixed(1),
              unit: 'kg',
              icon: Icons.monitor_weight_rounded,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '체지방률',
              value: record.bodyFatPercent?.toStringAsFixed(1) ?? '-',
              unit: '%',
              icon: Icons.water_drop_rounded,
              color: AppTheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: '골격근량',
              value: record.muscleMass?.toStringAsFixed(1) ?? '-',
              unit: 'kg',
              icon: Icons.fitness_center_rounded,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }
}

/// 개별 통계 카드
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 체성분 변화 그래프 (체중/골격근량/체지방률 지원)
class _BodyCompositionChart extends ConsumerWidget {
  const _BodyCompositionChart({
    required this.history,
    required this.selectedMetric,
  });

  final List<WeightHistoryData> history;
  final String selectedMetric;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final predictionState = ref.watch(bodyCompositionPredictionProvider);

    // 날짜 오름차순으로 정렬 후 최근 10개만 표시
    final sortedHistory = List<WeightHistoryData>.from(history)
      ..sort((a, b) => a.date.compareTo(b.date));
    final chartData = sortedHistory.length > 10
        ? sortedHistory.sublist(sortedHistory.length - 10)
        : sortedHistory;

    // 선택된 메트릭에 따른 타이틀과 색상
    String chartTitle;
    Color primaryColor;

    switch (selectedMetric) {
      case 'muscle':
        chartTitle = '골격근량 변화 추이';
        primaryColor = Colors.green;
        break;
      case 'bodyFat':
        chartTitle = '체지방률 변화 추이';
        primaryColor = Colors.orange;
        break;
      case 'all':
        chartTitle = '체성분 종합 추이';
        primaryColor = AppTheme.primary;
        break;
      default:
        chartTitle = '체중 변화 추이';
        primaryColor = AppTheme.primary;
    }

    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 20,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  chartTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedMetric == 'all') ...[
                  const Spacer(),
                  _buildLegend(context),
                ],
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: selectedMetric == 'all'
                  ? _buildMultiLineChart(context, chartData, colorScheme, theme, predictionState)
                  : _buildSingleLineChart(context, chartData, colorScheme, theme, selectedMetric, primaryColor, predictionState),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms);
  }

  /// 범례 위젯
  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(context, '체중', AppTheme.primary),
        const SizedBox(width: 8),
        _legendItem(context, '근육', Colors.green),
        const SizedBox(width: 8),
        _legendItem(context, '체지방', Colors.orange),
      ],
    );
  }

  Widget _legendItem(BuildContext context, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 단일 라인 차트 (체중/골격근량/체지방률 중 하나)
  Widget _buildSingleLineChart(
    BuildContext context,
    List<WeightHistoryData> chartData,
    ColorScheme colorScheme,
    ThemeData theme,
    String metric,
    Color color,
    BodyCompositionPredictionState predictionState,
  ) {
    // 데이터 추출
    List<double?> values;
    String unit;
    MetricPrediction? prediction;

    switch (metric) {
      case 'muscle':
        values = chartData.map((e) => e.muscleMass).toList();
        unit = 'kg';
        prediction = predictionState.prediction?.musclePrediction;
        break;
      case 'bodyFat':
        values = chartData.map((e) => e.bodyFatPercent).toList();
        unit = '%';
        prediction = predictionState.prediction?.bodyFatPrediction;
        break;
      default:
        values = chartData.map((e) => e.weight as double?).toList();
        unit = 'kg';
        prediction = predictionState.prediction?.weightPrediction;
    }

    // null이 아닌 값만 필터링
    final validValues = values.whereType<double>().toList();
    if (validValues.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final minValue = validValues.reduce((a, b) => a < b ? a : b);
    final maxValue = validValues.reduce((a, b) => a > b ? a : b);
    final valuePadding = (maxValue - minValue) * 0.2;
    final adjustedMin = minValue - valuePadding;
    final adjustedMax = maxValue + valuePadding;

    // 실제 데이터 스팟 생성
    final spots = <FlSpot>[];
    for (int i = 0; i < chartData.length; i++) {
      final value = values[i];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    // 예측 데이터 스팟 생성 (1주 후)
    final predictionSpots = <FlSpot>[];
    if (prediction != null && spots.isNotEmpty) {
      // 마지막 실제 데이터 포인트
      final lastSpot = spots.last;
      predictionSpots.add(lastSpot);
      // 1주 후 예측값 (주간 추세 기반)
      final predictedValue = prediction.current + prediction.weeklyTrend;
      predictionSpots.add(FlSpot(lastSpot.x + 1, predictedValue));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (adjustedMax - adjustedMin) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(chartData, theme, colorScheme),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chartData.length - 1 + (predictionSpots.isNotEmpty ? 1 : 0)).toDouble(),
        minY: adjustedMin,
        maxY: adjustedMax,
        lineBarsData: [
          // 실제 데이터 라인 (실선)
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorScheme.surface,
                  strokeWidth: 2,
                  strokeColor: color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // 예측 데이터 라인 (점선)
          if (predictionSpots.isNotEmpty)
            LineChartBarData(
              spots: predictionSpots,
              isCurved: true,
              color: color.withValues(alpha: 0.6),
              barWidth: 2,
              isStrokeCapRound: true,
              dashArray: [5, 5],
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // 마지막 점만 표시 (예측값)
                  if (index == 0) {
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 5,
                    color: colorScheme.surface,
                    strokeWidth: 2,
                    strokeColor: color.withValues(alpha: 0.6),
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          // 세로 점선 인디케이터 숨기기
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                const FlLine(color: Colors.transparent), // 세로선 숨김
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, idx) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: colorScheme.surface,
                      strokeWidth: 2,
                      strokeColor: color,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colorScheme.inverseSurface,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.spotIndex;
                final isPrediction = spot.x >= chartData.length;

                if (isPrediction) {
                  return LineTooltipItem(
                    '예측: ${spot.y.toStringAsFixed(1)}$unit\n',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '1주 후',
                        style: TextStyle(
                          color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }

                if (index >= 0 && index < chartData.length) {
                  final data = chartData[index];
                  return LineTooltipItem(
                    '${spot.y.toStringAsFixed(1)}$unit\n',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('yyyy.MM.dd').format(data.date),
                        style: TextStyle(
                          color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).whereType<LineTooltipItem>().toList();
            },
          ),
        ),
      ),
    );
  }

  /// 멀티 라인 차트 (전체 메트릭)
  Widget _buildMultiLineChart(
    BuildContext context,
    List<WeightHistoryData> chartData,
    ColorScheme colorScheme,
    ThemeData theme,
    BodyCompositionPredictionState predictionState,
  ) {
    // 각 메트릭 별 스팟 생성
    final weightSpots = <FlSpot>[];
    final muscleSpots = <FlSpot>[];
    final bodyFatSpots = <FlSpot>[];

    for (int i = 0; i < chartData.length; i++) {
      final data = chartData[i];
      weightSpots.add(FlSpot(i.toDouble(), data.weight));
      if (data.muscleMass != null) {
        muscleSpots.add(FlSpot(i.toDouble(), data.muscleMass!));
      }
      if (data.bodyFatPercent != null) {
        bodyFatSpots.add(FlSpot(i.toDouble(), data.bodyFatPercent!));
      }
    }

    // 모든 값의 범위 계산
    final allValues = <double>[
      ...weightSpots.map((s) => s.y),
      ...muscleSpots.map((s) => s.y),
      ...bodyFatSpots.map((s) => s.y),
    ];

    if (allValues.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // 예측 스팟 생성
    final weightPred = predictionState.prediction?.weightPrediction;
    final musclePred = predictionState.prediction?.musclePrediction;
    final bodyFatPred = predictionState.prediction?.bodyFatPrediction;

    final weightPredSpots = <FlSpot>[];
    if (weightPred != null && weightSpots.isNotEmpty) {
      weightPredSpots.add(weightSpots.last);
      weightPredSpots.add(FlSpot(weightSpots.last.x + 1, weightPred.current + weightPred.weeklyTrend));
    }
    final musclePredSpots = <FlSpot>[];
    if (musclePred != null && muscleSpots.isNotEmpty) {
      musclePredSpots.add(muscleSpots.last);
      musclePredSpots.add(FlSpot(muscleSpots.last.x + 1, musclePred.current + musclePred.weeklyTrend));
    }
    final bodyFatPredSpots = <FlSpot>[];
    if (bodyFatPred != null && bodyFatSpots.isNotEmpty) {
      bodyFatPredSpots.add(bodyFatSpots.last);
      bodyFatPredSpots.add(FlSpot(bodyFatSpots.last.x + 1, bodyFatPred.current + bodyFatPred.weeklyTrend));
    }

    final hasPrediction = weightPredSpots.isNotEmpty || musclePredSpots.isNotEmpty || bodyFatPredSpots.isNotEmpty;

    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final valuePadding = (maxValue - minValue) * 0.2;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxValue - minValue + valuePadding * 2) / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: _buildTitlesData(chartData, theme, colorScheme),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (chartData.length - 1 + (hasPrediction ? 1 : 0)).toDouble(),
        minY: minValue - valuePadding,
        maxY: maxValue + valuePadding,
        lineBarsData: [
          // 체중 라인
          if (weightSpots.isNotEmpty)
            _buildLineBarData(weightSpots, AppTheme.primary, colorScheme),
          // 골격근량 라인
          if (muscleSpots.isNotEmpty)
            _buildLineBarData(muscleSpots, Colors.green, colorScheme),
          // 체지방률 라인
          if (bodyFatSpots.isNotEmpty)
            _buildLineBarData(bodyFatSpots, Colors.orange, colorScheme),
          // 예측 라인 (점선)
          if (weightPredSpots.isNotEmpty)
            _buildPredictionLineBarData(weightPredSpots, AppTheme.primary),
          if (musclePredSpots.isNotEmpty)
            _buildPredictionLineBarData(musclePredSpots, Colors.green),
          if (bodyFatPredSpots.isNotEmpty)
            _buildPredictionLineBarData(bodyFatPredSpots, Colors.orange),
        ],
        lineTouchData: LineTouchData(
          // 세로 점선 인디케이터 숨기기
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                const FlLine(color: Colors.transparent), // 세로선 숨김
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, idx) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: colorScheme.surface,
                      strokeWidth: 2,
                      strokeColor: barData.color ?? AppTheme.primary,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colorScheme.inverseSurface,
            tooltipBorderRadius: BorderRadius.circular(8),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.spotIndex;
                if (index < 0 || index >= chartData.length) return null;

                String label;
                String unit;

                // 색상으로 어떤 라인인지 판별
                if (spot.bar.color == AppTheme.primary) {
                  label = '체중';
                  unit = 'kg';
                } else if (spot.bar.color == Colors.green) {
                  label = '골격근량';
                  unit = 'kg';
                } else {
                  label = '체지방률';
                  unit = '%';
                }

                return LineTooltipItem(
                  '$label: ${spot.y.toStringAsFixed(1)}$unit',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).whereType<LineTooltipItem>().toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(
    List<FlSpot> spots,
    Color color,
    ColorScheme colorScheme,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 3,
            color: colorScheme.surface,
            strokeWidth: 2,
            strokeColor: color,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  /// 예측 점선 라인
  LineChartBarData _buildPredictionLineBarData(
    List<FlSpot> spots,
    Color color,
  ) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color.withValues(alpha: 0.6),
      barWidth: 2,
      isStrokeCapRound: true,
      dashArray: [5, 5],
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (index == 0) {
            return FlDotCirclePainter(
              radius: 0,
              color: Colors.transparent,
              strokeWidth: 0,
              strokeColor: Colors.transparent,
            );
          }
          return FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: color.withValues(alpha: 0.6),
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );
  }

  FlTitlesData _buildTitlesData(
    List<WeightHistoryData> chartData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => Text(
            '${value.toInt()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= chartData.length) {
              return const SizedBox.shrink();
            }
            // 3개 간격으로만 표시
            if (index % 3 != 0 && index != chartData.length - 1) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                DateFormat('M/d').format(chartData[index].date),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 체성분 기록 카드
class _BodyRecordCard extends ConsumerWidget {
  const _BodyRecordCard({
    required this.record,
    required this.index,
    required this.memberId,
  });

  final BodyRecordModel record;
  final int index;
  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        DateFormat('yyyy.MM.dd HH:mm').format(record.recordDate),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (record.isInbodyData) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'InBody',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showDeleteDialog(context, ref),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _RecordItem(
                  label: '체중',
                  value: '${record.weight.toStringAsFixed(1)} kg',
                ),
                const SizedBox(width: 24),
                _RecordItem(
                  label: '체지방률',
                  value: record.bodyFatPercent != null
                      ? '${record.bodyFatPercent!.toStringAsFixed(1)} %'
                      : '-',
                ),
                const SizedBox(width: 24),
                _RecordItem(
                  label: '골격근량',
                  value: record.muscleMass != null
                      ? '${record.muscleMass!.toStringAsFixed(1)} kg'
                      : '-',
                ),
              ],
            ),
            if (record.note != null && record.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                record.note!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms, delay: (50 * index).ms);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 체성분 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final repository = ref.read(bodyRecordRepositoryProvider);
                await repository.delete(record.id);
                ref.invalidate(bodyRecordsProvider(memberId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('기록이 삭제되었습니다'),
                      backgroundColor: AppTheme.secondary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            child: Text(
              '삭제',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// 기록 항목
class _RecordItem extends StatelessWidget {
  const _RecordItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 운동기록 탭
class _ExerciseRecordsTab extends ConsumerWidget {
  const _ExerciseRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    final memberId = member?.id ?? '';
    final curriculumsAsync = ref.watch(curriculumsProvider(memberId));

    return curriculumsAsync.when(
      loading: () => const _ExerciseRecordsShimmer(),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(curriculumsProvider(memberId)),
      ),
      data: (curriculums) {
        // 완료된 커리큘럼만 필터링
        final completedCurriculums = curriculums
            .where((c) => c.isCompleted)
            .toList()
          ..sort((a, b) =>
              (b.completedDate ?? b.scheduledDate ?? DateTime.now())
                  .compareTo(a.completedDate ?? a.scheduledDate ?? DateTime.now()));

        if (completedCurriculums.isEmpty) {
          return const EmptyState(
            type: EmptyStateType.curriculums,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(curriculumsProvider(memberId));
          },
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: '완료된 운동',
                  subtitle: '총 ${completedCurriculums.length}회',
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              // 타임라인 리스트
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ExerciseTimelineCard(
                      curriculum: completedCurriculums[index],
                      index: index,
                      isLast: index == completedCurriculums.length - 1,
                    ),
                    childCount: completedCurriculums.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 운동 타임라인 카드
class _ExerciseTimelineCard extends StatelessWidget {
  const _ExerciseTimelineCard({
    required this.curriculum,
    required this.index,
    required this.isLast,
  });

  final CurriculumModel curriculum;
  final int index;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedDate =
        curriculum.completedDate ?? curriculum.scheduledDate ?? DateTime.now();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 라인
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${curriculum.sessionNumber}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 카드 컨텐츠
          Expanded(
            child: GestureDetector(
              onTap: () => _showExerciseDetailSheet(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2E3B5E)
                        : const Color(0xFFE5E7EB),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            curriculum.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppTheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '완료',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('yyyy년 M월 d일 (E)', 'ko').format(completedDate),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (curriculum.exercises.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: curriculum.exercises
                            .take(4)
                            .map((exercise) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    exercise.name,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                      if (curriculum.exercises.length > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '+${curriculum.exercises.length - 4}개 더보기',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: (80 * index).ms)
        .slideX(begin: 0.15, end: 0, duration: 400.ms, delay: (80 * index).ms);
  }

  /// 운동 상세 정보 바텀시트 표시
  void _showExerciseDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExerciseDetailSheet(curriculum: curriculum),
    );
  }
}

/// 운동 상세 정보 바텀시트
class _ExerciseDetailSheet extends StatelessWidget {
  const _ExerciseDetailSheet({required this.curriculum});

  final CurriculumModel curriculum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedDate =
        curriculum.completedDate ?? curriculum.scheduledDate ?? DateTime.now();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${curriculum.sessionNumber}회차',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: AppTheme.secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '완료',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppTheme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            curriculum.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy년 M월 d일 (E)', 'ko').format(completedDate),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 요약 통계
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.fitness_center_rounded,
                      label: '${curriculum.exercises.length}개 운동',
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.repeat_rounded,
                      label: '${curriculum.totalSets}세트',
                      color: AppTheme.tertiary,
                    ),
                    const SizedBox(width: 12),
                    _SummaryChip(
                      icon: Icons.timer_rounded,
                      label: '약 ${curriculum.estimatedDuration}분',
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          // 운동 목록
          Flexible(
            child: curriculum.exercises.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '등록된 운동이 없습니다',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20),
                    itemCount: curriculum.exercises.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exercise = curriculum.exercises[index];
                      return _ExerciseDetailCard(
                        exercise: exercise,
                        index: index,
                      );
                    },
                  ),
          ),
        ],
      ),
    ).animate().slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// 요약 칩 위젯
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 운동 상세 카드
class _ExerciseDetailCard extends StatelessWidget {
  const _ExerciseDetailCard({
    required this.exercise,
    required this.index,
  });

  final Exercise exercise;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 순번 뱃지
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 운동 이름
              Expanded(
                child: Text(
                  exercise.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 세트 정보
          Row(
            children: [
              Expanded(
                child: _ExerciseInfoItem(
                  icon: Icons.repeat_rounded,
                  label: '세트',
                  value: '${exercise.sets}',
                ),
              ),
              Expanded(
                child: _ExerciseInfoItem(
                  icon: Icons.numbers_rounded,
                  label: '횟수',
                  value: '${exercise.reps}회',
                ),
              ),
              Expanded(
                child: _ExerciseInfoItem(
                  icon: Icons.fitness_center_rounded,
                  label: '무게',
                  value: exercise.weight != null
                      ? '${exercise.weight!.toStringAsFixed(1)}kg'
                      : '-',
                ),
              ),
              if (exercise.restSeconds != null)
                Expanded(
                  child: _ExerciseInfoItem(
                    icon: Icons.timer_rounded,
                    label: '휴식',
                    value: '${exercise.restSeconds}초',
                  ),
                ),
            ],
          ),
          // 메모
          if (exercise.note != null && exercise.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notes_rounded,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercise.note!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (50 * index).ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms, delay: (50 * index).ms);
  }
}

/// 운동 정보 항목
class _ExerciseInfoItem extends StatelessWidget {
  const _ExerciseInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 서명기록 탭
class _SignatureRecordsTab extends StatelessWidget {
  const _SignatureRecordsTab();

  // 더미 서명 데이터
  static final List<_SignatureRecord> _dummySignatures = [
    _SignatureRecord(
      id: '1',
      sessionNumber: 10,
      date: DateTime.now().subtract(const Duration(days: 2)),
      signatureUrl: 'assets/images/signature_placeholder.png',
    ),
    _SignatureRecord(
      id: '2',
      sessionNumber: 9,
      date: DateTime.now().subtract(const Duration(days: 5)),
      signatureUrl: 'assets/images/signature_placeholder.png',
    ),
    _SignatureRecord(
      id: '3',
      sessionNumber: 8,
      date: DateTime.now().subtract(const Duration(days: 9)),
      signatureUrl: 'assets/images/signature_placeholder.png',
    ),
    _SignatureRecord(
      id: '4',
      sessionNumber: 7,
      date: DateTime.now().subtract(const Duration(days: 12)),
      signatureUrl: 'assets/images/signature_placeholder.png',
    ),
    _SignatureRecord(
      id: '5',
      sessionNumber: 6,
      date: DateTime.now().subtract(const Duration(days: 16)),
      signatureUrl: 'assets/images/signature_placeholder.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_dummySignatures.isEmpty) {
      return const EmptyState(
        type: EmptyStateType.signatures,
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverToBoxAdapter(
          child: _SectionHeader(
            title: '서명 기록',
            subtitle: '총 ${_dummySignatures.length}개',
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _SignatureCard(
                signature: _dummySignatures[index],
                index: index,
              ),
              childCount: _dummySignatures.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }
}

/// 서명 기록 모델
class _SignatureRecord {
  final String id;
  final int sessionNumber;
  final DateTime date;
  final String signatureUrl;

  const _SignatureRecord({
    required this.id,
    required this.sessionNumber,
    required this.date,
    required this.signatureUrl,
  });
}

/// 서명 카드
class _SignatureCard extends StatelessWidget {
  const _SignatureCard({
    required this.signature,
    required this.index,
  });

  final _SignatureRecord signature;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSignatureDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 서명 썸네일
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.draw_rounded,
                    size: 48,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            // 정보
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${signature.sessionNumber}회차',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('yyyy.MM.dd').format(signature.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (60 * index).ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: (60 * index).ms,
        );
  }

  void _showSignatureDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${signature.sessionNumber}회차 서명',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.draw_rounded,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '서명 이미지',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('yyyy년 M월 d일').format(signature.date),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ).animate().scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1, 1),
              duration: 200.ms,
            ),
      ),
    );
  }
}

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 기록 추가 FAB
class _AddRecordFAB extends StatelessWidget {
  const _AddRecordFAB({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text('기록 추가'),
    )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .shimmer(
          duration: 2000.ms,
          color: colorScheme.onPrimary.withValues(alpha: 0.3),
        );
  }
}

/// 체성분 기록 추가 바텀시트
class _AddBodyRecordSheet extends ConsumerStatefulWidget {
  const _AddBodyRecordSheet();

  @override
  ConsumerState<_AddBodyRecordSheet> createState() => _AddBodyRecordSheetState();
}

class _AddBodyRecordSheetState extends ConsumerState<_AddBodyRecordSheet> {
  bool _isSaving = false;
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    // 체중 필수 입력 검증
    final weightText = _weightController.text.trim();
    if (weightText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('체중을 입력해주세요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final weight = double.tryParse(weightText);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 체중을 입력해주세요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 회원 ID 가져오기
    final member = ref.read(currentMemberProvider);
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원 정보를 찾을 수 없습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(bodyRecordRepositoryProvider);

      // 체성분 기록 생성
      final record = BodyRecordModel(
        id: '',
        memberId: member.id,
        recordDate: _selectedDate,
        weight: weight,
        bodyFatPercent: double.tryParse(_bodyFatController.text.trim()),
        muscleMass: double.tryParse(_muscleMassController.text.trim()),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        createdAt: DateTime.now(),
      );

      await repository.create(record);

      // 데이터 갱신
      ref.invalidate(bodyRecordsProvider(member.id));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체성분 기록이 저장되었습니다'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '체성분 기록 추가',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 날짜 선택
          GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('yyyy년 M월 d일').format(_selectedDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 입력 필드들
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '체중 (kg) *',
                    hintText: '0.0',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bodyFatController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '체지방률 (%)',
                    hintText: '0.0',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _muscleMassController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: '골격근량 (kg)',
                    hintText: '0.0',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: '메모',
              hintText: '메모를 입력하세요',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveRecord,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('저장'),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}

/// 기록 1개일 때 현재 데이터 표시
class _SingleRecordDisplay extends StatelessWidget {
  const _SingleRecordDisplay({required this.record});

  final WeightHistoryData record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
            Row(
              children: [
                Icon(
                  Icons.monitor_weight_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '현재 체성분',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${record.date.month}/${record.date.day}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  '체중',
                  '${record.weight.toStringAsFixed(1)}kg',
                  AppTheme.primary,
                ),
                if (record.bodyFatPercent != null)
                  _buildMetricItem(
                    context,
                    '체지방률',
                    '${record.bodyFatPercent!.toStringAsFixed(1)}%',
                    Colors.orange,
                  ),
                if (record.muscleMass != null)
                  _buildMetricItem(
                    context,
                    '골격근량',
                    '${record.muscleMass!.toStringAsFixed(1)}kg',
                    Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '기록을 추가하면 변화 그래프가 표시됩니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 차트 플레이스홀더
class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surface,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Shimmer 로딩 위젯들
// ============================================================

/// 체성분 탭 시머 로딩
class _BodyCompositionShimmer extends StatelessWidget {
  const _BodyCompositionShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 통계 카드 시머
            const _StatsCardsShimmer(),
            const SizedBox(height: 24),
            // 차트 시머
            const _ChartShimmer(),
            const SizedBox(height: 24),
            // 리스트 시머
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 통계 카드 시머
class _StatsCardsShimmer extends StatelessWidget {
  const _StatsCardsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(left: index > 0 ? 12 : 0),
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 차트 시머
class _ChartShimmer extends StatelessWidget {
  const _ChartShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

/// 운동기록 탭 시머 로딩
class _ExerciseRecordsShimmer extends StatelessWidget {
  const _ExerciseRecordsShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            4,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
