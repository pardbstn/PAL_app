import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/body_composition_prediction_model.dart';
import '../../../data/models/body_record_model.dart';
import '../../../data/models/curriculum_model.dart';
import '../../../data/models/session_signature_model.dart';
import '../../../data/repositories/body_record_repository.dart';
import '../../../data/repositories/session_signature_repository.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_composition_prediction_provider.dart';
import '../../providers/body_records_provider.dart';
import '../../providers/curriculums_provider.dart';
import '../../widgets/common/mesh_gradient_background.dart';

/// 회원의 서명 기록 Provider
final memberSignaturesProvider = StreamProvider.family<List<SessionSignatureModel>, String>((ref, memberId) {
  final repository = ref.watch(sessionSignatureRepositoryProvider);
  return repository.watchByMemberId(memberId);
});

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
    // Personal mode has 2 tabs (체성분, 운동기록), others have 3 tabs (체성분, 운동기록, 서명기록)
    final isPersonal = ref.read(userRoleProvider) == UserRole.personal;
    _tabController = TabController(length: isPersonal ? 2 : 3, vsync: this);
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
    final isPersonal = ref.watch(userRoleProvider) == UserRole.personal;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshGradientBackground(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              floating: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '내 기록',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: colorScheme.onSurface,
                  ),
                ),
                titlePadding:
                    const EdgeInsets.only(left: AppSpacing.md, bottom: 72),
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
            physics: const NeverScrollableScrollPhysics(),
            children: isPersonal
                ? const [
                    _BodyCompositionTab(),
                  _ExerciseRecordsTab(),
                ]
              : const [
                  _BodyCompositionTab(),
                  _ExerciseRecordsTab(),
                  _SignatureRecordsTab(),
                ],
          ),
        ),
      ),
    );
  }

  /// 프리미엄 탭 바 디자인
  Widget _buildPremiumTabBar(BuildContext context) {
    final isPersonal = ref.watch(userRoleProvider) == UserRole.personal;

    return TabBar(
      controller: _tabController,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: const Color(0xFF0064FF), width: 3),
        borderRadius: BorderRadius.circular(2),
      ),
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelColor: const Color(0xFF0064FF),
      unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFB0B0B0)
          : const Color(0xFF8B8B8B),
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      tabs: isPersonal
          ? const [
              Tab(text: '체성분'),
              Tab(text: '운동기록'),
            ]
          : const [
              Tab(text: '체성분'),
              Tab(text: '운동기록'),
              Tab(text: '서명기록'),
            ],
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
  late ScrollController _scrollController;
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // 화면 로드 시 AI 예측 요청
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final member = ref.read(currentMemberProvider);
      if (member != null) {
        ref.read(bodyCompositionPredictionProvider.notifier).predictBodyComposition(member.id);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFabVisible) setState(() => _isFabVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFabVisible) setState(() => _isFabVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
            onAction: () => _showAddRecordOptions(context),
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bodyRecordsProvider(memberId));
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
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
                    child: SizedBox(height: AppSpacing.lg),
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
                    child: SizedBox(height: AppSpacing.md),
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
                        message: '차트를 불러오는데 실패했어요',
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),
                  // AI 예측 카드
                  SliverToBoxAdapter(
                    child: _AIPredictionCard(memberId: memberId),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            // FAB - 기록 추가 (통합)
            Positioned(
              right: 16,
              bottom: AppNavGlass.fabBottomPadding,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 200),
                offset: _isFabVisible ? Offset.zero : const Offset(0, 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isFabVisible ? 1.0 : 0.0,
                  child: _AddRecordFAB(
                    onPressed: () => _showAddRecordOptions(context),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 기록 추가 옵션 바텀시트 (수기 입력 / 사진 분석)
  void _showAddRecordOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 핸들 바
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gray600 : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '기록 추가',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '체성분 기록 방법을 선택해주세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            // 수기 입력 옵션
            _RecordOptionTile(
              icon: Icons.edit_outlined,
              title: '직접 입력',
              subtitle: '체중, 체지방률, 골격근량을 직접 입력해요',
              color: AppColors.primary,
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (context) => const _AddBodyRecordSheet(),
                );
              },
            ),
            const SizedBox(height: 12),
            // 사진 분석 옵션
            _RecordOptionTile(
              icon: Icons.camera_alt_outlined,
              title: '인바디 사진 분석',
              subtitle: '인바디 결과지를 촬영하면 AI가 자동으로 분석해요',
              color: const Color(0xFF00C471),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.memberInbodyOcr);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 기록 추가 옵션 타일
class _RecordOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RecordOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.2 : 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
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
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
          selectedBackgroundColor: const Color(0xFF0064FF).withValues(alpha: 0.1),
          selectedForegroundColor: const Color(0xFF0064FF),
          foregroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFFB0B0B0)
              : const Color(0xFF8B8B8B),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          minimumSize: const Size(0, 36),
        ),
        showSelectedIcon: false,
      ),
    ).animate().fadeIn(duration: 200.ms);
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg - 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.lgBorderRadius,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
      // 에러 메시지가 있으면 안내 표시
      if (predictionState.error != null) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg - 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: AppRadius.lgBorderRadius,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.gray200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    predictionState.error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                Text(
                  '체성분 예측 (4주 후)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (predictionState.isDemo) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '간이 분석',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
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
            const SizedBox(height: AppSpacing.md),
            // 체중 예측
            if (prediction.weightPrediction != null)
              _buildPredictionRow(
                context,
                '체중',
                prediction.weightPrediction!,
                'kg',
                AppColors.primary,
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
                    size: AppIconSize.xs,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
        .fadeIn(duration: 200.ms, delay: 150.ms)
        .slideY(begin: 0.02, end: 0, duration: 200.ms, delay: 150.ms);
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: AppIconSize.xs, color: color),
          ),
          const SizedBox(width: AppSpacing.md / 1.333),
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
                    const SizedBox(width: AppSpacing.xs),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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
class _CurrentStatsCards extends ConsumerWidget {
  const _CurrentStatsCards({required this.record});

  final BodyRecordModel record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final memberId = record.memberId;
    final recordsAsync = ref.watch(bodyRecordsProvider(memberId));

    // 이전 기록에서 변화량 계산
    double? weightChange;
    double? muscleChange;
    double? fatChange;

    recordsAsync.whenData((records) {
      if (records.length >= 2) {
        final previous = records[1]; // 두 번째가 이전 기록
        weightChange = record.weight - previous.weight;
        if (record.muscleMass != null && previous.muscleMass != null) {
          muscleChange = record.muscleMass! - previous.muscleMass!;
        }
        if (record.bodyFatPercent != null && previous.bodyFatPercent != null) {
          fatChange = record.bodyFatPercent! - previous.bodyFatPercent!;
        }
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // 벤토 그리드: 왼쪽 큰 카드 + 오른쪽 작은 카드 2개
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 체중 (큰 카드)
              Expanded(
                child: _BentoStatCard(
                  label: '체중',
                  value: record.weight.toStringAsFixed(1),
                  unit: 'kg',
                  change: weightChange,
                  icon: Icons.monitor_weight_rounded,
                  iconColor: AppColors.primary,
                  height: 180,
                  isPositiveGood: false,
                  isPrimary: true,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // 오른쪽: 골격근량 + 체지방률 (작은 카드 2개)
              Expanded(
                child: Column(
                  children: [
                    _BentoStatCard(
                      label: '골격근량',
                      value: record.muscleMass?.toStringAsFixed(1) ?? '-',
                      unit: 'kg',
                      change: muscleChange,
                      icon: Icons.fitness_center_rounded,
                      iconColor: const Color(0xFF10B981),
                      height: 84,
                      isPositiveGood: true,
                      isPrimary: false,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    _BentoStatCard(
                      label: '체지방률',
                      value: record.bodyFatPercent?.toStringAsFixed(1) ?? '-',
                      unit: '%',
                      change: fatChange,
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      height: 84,
                      isPositiveGood: false,
                      isPrimary: false,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideY(begin: 0.02, end: 0, duration: 200.ms);
  }
}

/// 벤토 그리드 스타일 통계 카드
class _BentoStatCard extends StatelessWidget {
  const _BentoStatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.iconColor,
    required this.height,
    required this.isPositiveGood,
    required this.isPrimary,
    required this.isDark,
    this.change,
  });

  final String label;
  final String value;
  final String unit;
  final double? change;
  final IconData icon;
  final Color iconColor;
  final double height;
  final bool isPositiveGood;
  final bool isPrimary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 변화량 색상: 골격근량은 증가가 좋고, 체중/체지방은 감소가 좋음
    Color? changeColor;
    String? changeText;
    if (change != null && change != 0) {
      final isGood = isPositiveGood ? change! > 0 : change! < 0;
      changeColor = isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      final sign = change! > 0 ? '+' : '';
      changeText = '$sign${change!.toStringAsFixed(1)}';
    }

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 24,
            offset: Offset.zero,
          ),
        ],
      ),
      child: isPrimary
          ? _buildPrimaryContent(theme, colorScheme, changeColor, changeText)
          : _buildCompactContent(theme, colorScheme, changeColor, changeText),
    );
  }

  /// 큰 카드 (체중) - 아이콘, 라벨, 큰 값, 변화량 표시
  Widget _buildPrimaryContent(
    ThemeData theme,
    ColorScheme colorScheme,
    Color? changeColor,
    String? changeText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const Spacer(),
            if (changeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor!.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  changeText,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 작은 카드 (골격근량, 체지방률) - 컴팩트 레이아웃
  Widget _buildCompactContent(
    ThemeData theme,
    ColorScheme colorScheme,
    Color? changeColor,
    String? changeText,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (changeText != null)
          Text(
            changeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: changeColor,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
      ],
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
        primaryColor = AppColors.secondary;
        break;
      case 'bodyFat':
        chartTitle = '체지방률 변화 추이';
        primaryColor = AppColors.error;
        break;
      case 'all':
        chartTitle = '체성분 종합 추이';
        primaryColor = AppColors.primary;
        break;
      default:
        chartTitle = '체중 변화 추이';
        primaryColor = AppColors.primary;
    }

    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.smBorderRadius,
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: AppIconSize.sm,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.md / 1.333),
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
            const SizedBox(height: AppSpacing.lg),
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
        .fadeIn(duration: 200.ms, delay: 100.ms)
        .slideY(begin: 0.02, end: 0, duration: 200.ms, delay: 100.ms);
  }

  /// 범례 위젯
  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendItem(context, '체중', AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _legendItem(context, '근육', AppColors.secondary),
        const SizedBox(width: AppSpacing.sm),
        _legendItem(context, '체지방', AppColors.error),
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
        const SizedBox(width: AppSpacing.xs),
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
          '데이터가 없어요',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final minValue = validValues.reduce((a, b) => a < b ? a : b);
    final maxValue = validValues.reduce((a, b) => a > b ? a : b);
    // 모든 값이 동일할 때 (데이터 1개 또는 동일값) 기본 패딩 적용
    final range = maxValue - minValue;
    final valuePadding = range > 0 ? range * 0.2 : maxValue * 0.1;
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
          // horizontalInterval이 0이 되지 않도록 최소값 보장
          horizontalInterval: ((adjustedMax - adjustedMin) / 4).clamp(0.1, double.infinity),
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
            curveSmoothness: 0.35,
            color: color,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.15),
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
              curveSmoothness: 0.35,
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
            tooltipBorderRadius: AppRadius.smBorderRadius,
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
          '데이터가 없어요',
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
    // 모든 값이 동일할 때 기본 패딩 적용
    final range = maxValue - minValue;
    final valuePadding = range > 0 ? range * 0.2 : maxValue * 0.1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          // horizontalInterval이 0이 되지 않도록 최소값 보장
          horizontalInterval: ((maxValue - minValue + valuePadding * 2) / 4).clamp(0.1, double.infinity),
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
            _buildLineBarData(weightSpots, AppColors.primary, colorScheme),
          // 골격근량 라인
          if (muscleSpots.isNotEmpty)
            _buildLineBarData(muscleSpots, AppColors.secondary, colorScheme),
          // 체지방률 라인
          if (bodyFatSpots.isNotEmpty)
            _buildLineBarData(bodyFatSpots, AppColors.error, colorScheme),
          // 예측 라인 (점선)
          if (weightPredSpots.isNotEmpty)
            _buildPredictionLineBarData(weightPredSpots, AppColors.primary),
          if (musclePredSpots.isNotEmpty)
            _buildPredictionLineBarData(musclePredSpots, AppColors.secondary),
          if (bodyFatPredSpots.isNotEmpty)
            _buildPredictionLineBarData(bodyFatPredSpots, AppColors.error),
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
                      strokeColor: barData.color ?? AppColors.primary,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colorScheme.inverseSurface,
            tooltipBorderRadius: AppRadius.smBorderRadius,
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final index = spot.spotIndex;
                if (index < 0 || index >= chartData.length) return null;

                String label;
                String unit;

                // 색상으로 어떤 라인인지 판별
                if (spot.bar.color == AppColors.primary) {
                  label = '체중';
                  unit = 'kg';
                } else if (spot.bar.color == AppColors.secondary) {
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
      curveSmoothness: 0.35,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
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
      curveSmoothness: 0.35,
      color: color.withValues(alpha: 0.6),
      barWidth: 2.5,
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
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
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
              padding: const EdgeInsets.only(top: AppSpacing.sm),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md / 1.333),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.smBorderRadius,
                      ),
                      child: Text(
                        DateFormat('yyyy.MM.dd HH:mm').format(record.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (record.isInbodyData) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'InBody',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
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
                        size: AppIconSize.sm,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showDeleteDialog(context, ref),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _RecordItem(
                      label: '체중',
                      value: '${record.weight.toStringAsFixed(1)} kg',
                    ),
                  ),
                  VerticalDivider(
                    width: AppSpacing.lg * 2,
                    thickness: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                  Expanded(
                    child: _RecordItem(
                      label: '체지방률',
                      value: record.bodyFatPercent != null
                          ? '${record.bodyFatPercent!.toStringAsFixed(1)} %'
                          : '-',
                    ),
                  ),
                  VerticalDivider(
                    width: AppSpacing.lg * 2,
                    thickness: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.gray200,
                  ),
                  Expanded(
                    child: _RecordItem(
                      label: '골격근량',
                      value: record.muscleMass != null
                          ? '${record.muscleMass!.toStringAsFixed(1)} kg'
                          : '-',
                    ),
                  ),
                ],
              ),
            ),
            if (record.note != null && record.note!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md / 1.333),
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
        .fadeIn(duration: 200.ms, delay: (50 * index).ms)
        .slideX(begin: 0.02, end: 0, duration: 200.ms, delay: (50 * index).ms);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 체성분 기록을 삭제할까요?'),
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
                      content: Text('기록이 삭제됐어요'),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 실패: $e'),
                      backgroundColor: AppColors.error,
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
    final isPersonal = ref.watch(userRoleProvider) == UserRole.personal;

    return curriculumsAsync.when(
      loading: () => const _ExerciseRecordsShimmer(),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(curriculumsProvider(memberId)),
      ),
      data: (curriculums) {
        // 전체 커리큘럼을 회차순으로 정렬
        final allCurriculums = List<CurriculumModel>.from(curriculums)
          ..sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));

        final completedCount = allCurriculums.where((c) => c.isCompleted).length;
        final totalCount = allCurriculums.length;

        if (allCurriculums.isEmpty) {
          // Personal mode: show workout logging
          if (isPersonal) {
            return EmptyState(
              type: EmptyStateType.curriculums,
              customTitle: '운동을 기록해보세요',
              customMessage: '직접 운동을 기록하고\n진행 상황을 확인해보세요',
              actionLabel: '운동 기록하기',
              onAction: () => context.push('/member/workout-log'),
            );
          }

          // 회원용 빈 상태 - 트레이너가 커리큘럼을 생성해야 함
          return const EmptyState(
            type: EmptyStateType.curriculums,
            customTitle: '배정된 커리큘럼이 없어요',
            customMessage: '트레이너가 커리큘럼을 생성하면\n여기에 표시됩니다',
            actionLabel: null, // 버튼 숨김 (회원은 커리큘럼 생성 불가)
          );
        }

        // For personal mode, add FAB for workout logging
        if (isPersonal) {
          return Stack(
            children: [
              RefreshIndicator(
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
                        title: '전체 커리큘럼',
                        subtitle: '$completedCount / $totalCount 완료',
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 16),
                    ),
                    // 타임라인 리스트
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ExerciseTimelineCard(
                            curriculum: allCurriculums[index],
                            index: index,
                            isLast: index == allCurriculums.length - 1,
                          ),
                          childCount: allCurriculums.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
              // FAB for personal mode workout logging
              Positioned(
                right: 16,
                bottom: AppNavGlass.fabBottomPadding,
                child: _AddRecordFAB(
                  onPressed: () => context.push('/member/workout-log'),
                ),
              ),
            ],
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
                  title: '전체 커리큘럼',
                  subtitle: '$completedCount / $totalCount 완료',
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
              // 타임라인 리스트
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ExerciseTimelineCard(
                      curriculum: allCurriculums[index],
                      index: index,
                      isLast: index == allCurriculums.length - 1,
                    ),
                    childCount: allCurriculums.length,
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
    final isCompleted = curriculum.isCompleted;
    final circleColor = isCompleted ? AppColors.primary : colorScheme.outlineVariant;

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
                    color: isCompleted ? circleColor : colorScheme.surface,
                    shape: BoxShape.circle,
                    border: isCompleted ? null : Border.all(color: circleColor, width: 2),
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Text(
                            '${curriculum.sessionNumber}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Text(
                            '${curriculum.sessionNumber}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md / 1.333),
          // 카드 컨텐츠
          Expanded(
            child: GestureDetector(
              onTap: () => _showExerciseDetailSheet(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.gray100,
                  ),
                  boxShadow: AppShadows.md,
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
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '완료',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                          size: AppIconSize.sm,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (curriculum.exercises.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md / 1.333),
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
                                    borderRadius: AppRadius.smBorderRadius,
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
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            '+${curriculum.exercises.length - 4}개 더보기',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
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
        .fadeIn(duration: 200.ms, delay: (40 * index).ms)
        .slideX(begin: 0.02, end: 0, duration: 200.ms, delay: (40 * index).ms);
  }

  /// 운동 상세 정보 바텀시트 표시
  void _showExerciseDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
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
            margin: const EdgeInsets.only(top: AppSpacing.md / 1.333),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg - 4),
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
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: AppRadius.smBorderRadius,
                                ),
                                child: Text(
                                  '${curriculum.sessionNumber}회차',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: AppColors.secondary,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      '완료',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md / 1.333),
                          Text(
                            curriculum.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
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
                const SizedBox(height: AppSpacing.md),
                // 요약 통계
                Row(
                  children: [
                    _SummaryChip(
                      icon: Icons.fitness_center_rounded,
                      label: '${curriculum.exercises.length}개 운동',
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppSpacing.md / 1.333),
                    _SummaryChip(
                      icon: Icons.repeat_rounded,
                      label: '${curriculum.totalSets}세트',
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: AppSpacing.md / 1.333),
                    _SummaryChip(
                      icon: Icons.timer_rounded,
                      label: '약 ${curriculum.estimatedDuration}분',
                      color: AppColors.secondary,
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
                          size: AppIconSize.xl,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md / 1.333),
                        Text(
                          '등록된 운동이 없어요',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(AppSpacing.lg - 4),
                    itemCount: curriculum.exercises.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md / 1.333),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md / 1.333, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.xs,
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.lgBorderRadius,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                  color: AppColors.primary,
                  borderRadius: AppRadius.smBorderRadius,
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
              const SizedBox(width: AppSpacing.md / 1.333),
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
          const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.md / 1.333),
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
                    size: AppIconSize.xs,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
        .fadeIn(duration: 200.ms, delay: (50 * index).ms)
        .slideX(begin: 0.02, end: 0, duration: 200.ms, delay: (50 * index).ms);
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
        const SizedBox(height: AppSpacing.xs),
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
class _SignatureRecordsTab extends ConsumerWidget {
  const _SignatureRecordsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final member = ref.watch(currentMemberProvider);
    final memberId = member?.id ?? '';

    if (memberId.isEmpty) {
      return const EmptyState(type: EmptyStateType.signatures);
    }

    final signaturesAsync = ref.watch(memberSignaturesProvider(memberId));

    return signaturesAsync.when(
      data: (signatures) {
        if (signatures.isEmpty) {
          return const EmptyState(type: EmptyStateType.signatures);
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: '서명 기록',
                subtitle: '총 ${signatures.length}개',
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SignatureCard(
                    signature: signatures[index],
                    index: index,
                  ),
                  childCount: signatures.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('서명 기록을 불러올 수 없어요: $error'),
      ),
    );
  }
}

/// 서명 카드
class _SignatureCard extends StatelessWidget {
  const _SignatureCard({
    required this.signature,
    required this.index,
  });

  final SessionSignatureModel signature;
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
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: signature.signatureImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: signature.signatureImageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.draw_rounded,
                            size: AppIconSize.xl,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.draw_rounded,
                            size: AppIconSize.xl,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${signature.sessionNumber}회차',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: AppIconSize.xs,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('yyyy.MM.dd').format(signature.signedAt),
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
        .fadeIn(duration: 200.ms, delay: (30 * index).ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 200.ms,
          delay: (30 * index).ms,
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.xlBorderRadius,
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
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: AppRadius.lgBorderRadius,
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: AppRadius.lgBorderRadius,
                  child: signature.signatureImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: signature.signatureImageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: AppIconSize.xl,
                                  color: colorScheme.error.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '이미지 로드 실패',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.draw_rounded,
                                size: 64,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '서명 이미지 없음',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                DateFormat('yyyy년 M월 d일').format(signature.signedAt),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: AppRadius.mdBorderRadius,
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
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
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
  String? _dateWarning;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingRecord(_selectedDate);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// 같은 날짜에 기록이 있는지 확인
  Future<void> _checkExistingRecord(DateTime date) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;
    final repository = ref.read(bodyRecordRepositoryProvider);
    final existingRecord = await repository.getByDate(member.id, date);
    if (mounted) {
      setState(() {
        _dateWarning = existingRecord != null
            ? '이 날짜에 이미 기록이 있어요. 다른 날짜를 선택해주세요'
            : null;
      });
    }
  }

  Future<void> _saveRecord() async {
    // 같은 날짜 경고가 있으면 저장 불가
    if (_dateWarning != null) {
      return;
    }

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
          content: Text('회원 정보를 찾을 수 없어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(bodyRecordRepositoryProvider);

      // 같은 날짜에 기록이 이미 있는지 다시 확인 (동시성 방지)
      final existingRecord = await repository.getByDate(member.id, _selectedDate);
      if (existingRecord != null) {
        if (mounted) {
          setState(() {
            _isSaving = false;
            _dateWarning = '이 날짜에 이미 기록이 있어요. 다른 날짜를 선택해주세요';
          });
        }
        return;
      }

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
            content: Text('체성분 기록이 저장됐어요'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.lg),
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
                _checkExistingRecord(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: AppRadius.mdBorderRadius,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: _dateWarning != null ? AppColors.error : null,
                  ),
                  const SizedBox(width: AppSpacing.md / 1.333),
                  Text(
                    DateFormat('yyyy년 M월 d일').format(_selectedDate),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          if (_dateWarning != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorderRadius,
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _dateWarning!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
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
              const SizedBox(width: AppSpacing.md / 1.333),
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
          const SizedBox(height: AppSpacing.md / 1.333),
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
              const SizedBox(width: AppSpacing.md / 1.333),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: AppSpacing.md / 1.333),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: '메모',
              hintText: '메모를 입력해주세요',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveRecord,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                  AppColors.primary,
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
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md / 1.333, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: AppRadius.smBorderRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: AppIconSize.xs,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
        const SizedBox(height: AppSpacing.xs),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.lgBorderRadius,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.gray200,
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
                size: AppIconSize.xl,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md / 1.333),
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // 통계 카드 시머
            const _StatsCardsShimmer(),
            const SizedBox(height: AppSpacing.lg),
            // 차트 시머
            const _ChartShimmer(),
            const SizedBox(height: AppSpacing.lg),
            // 리스트 시머
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md / 1.333),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.lgBorderRadius,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 큰 카드 시머
            Expanded(
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 오른쪽: 작은 카드 2개 시머
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Container(
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.lg - 4),
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
        padding: const EdgeInsets.all(AppSpacing.md),
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
                        borderRadius: AppRadius.lgBorderRadius,
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
