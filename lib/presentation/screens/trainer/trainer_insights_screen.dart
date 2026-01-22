/// 트레이너 인사이트 화면
///
/// AI가 생성한 회원 관리 인사이트 목록을 표시
/// 출석률 알림, PT 종료 임박, 성과 알림, 추천 등을 제공
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/data/repositories/insight_repository.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/glass_card.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/insight_mini_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/churn_gauge_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/insights/volume_bar_chart.dart';

/// 트레이너 인사이트 화면
class TrainerInsightsScreen extends ConsumerStatefulWidget {
  const TrainerInsightsScreen({super.key});

  @override
  ConsumerState<TrainerInsightsScreen> createState() =>
      _TrainerInsightsScreenState();
}

class _TrainerInsightsScreenState extends ConsumerState<TrainerInsightsScreen> {
  InsightType? _selectedFilter;
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final insightsAsync = ref.watch(trainerInsightsProvider);
    final unreadCount = ref.watch(unreadInsightCountProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withValues(alpha: 0.1),
              colorScheme.surface,
              colorScheme.secondary.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 앱바
              _buildSliverAppBar(context, unreadCount),

              // 필터 칩
              SliverToBoxAdapter(
                child: _buildFilterChips(context),
              ),

              // 인사이트 목록
              insightsAsync.when(
                data: (insights) => _buildInsightsList(context, insights),
                loading: () => _buildLoadingSkeleton(),
                error: (error, stack) => _buildErrorState(context, error),
              ),

              // 하단 여백
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _refreshInsights(context),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('새 인사이트 생성'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Sliver 앱바
  Widget _buildSliverAppBar(BuildContext context, AsyncValue<int> unreadCount) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'AI 인사이트',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // 읽지 않은 인사이트 배지
          unreadCount.when(
            data: (count) => count > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
      actions: [
        // 모두 읽음 처리
        IconButton(
          icon: const Icon(Icons.done_all),
          tooltip: '모두 읽음 처리',
          onPressed: () => _markAllAsRead(context),
        ),
      ],
    );
  }

  /// 필터 칩
  Widget _buildFilterChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 읽지 않은 것만 토글
          FilterChip(
            label: const Text('읽지 않은 것만'),
            selected: _showUnreadOnly,
            onSelected: (selected) {
              setState(() => _showUnreadOnly = selected);
            },
            selectedColor: AppTheme.primary.withValues(alpha: 0.2),
            checkmarkColor: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          // 전체
          FilterChip(
            label: const Text('전체'),
            selected: _selectedFilter == null,
            onSelected: (_) {
              setState(() => _selectedFilter = null);
            },
            selectedColor: colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          // 타입별 필터
          ..._buildTypeFilterChips(context),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1, end: 0);
  }

  List<Widget> _buildTypeFilterChips(BuildContext context) {
    final filters = [
      (InsightType.attendanceAlert, '출석 알림', Icons.event_busy),
      (InsightType.ptExpiry, 'PT 종료', Icons.timer_off),
      (InsightType.performance, '성과', Icons.trending_up),
      (InsightType.weightProgress, '체중 변화', Icons.monitor_weight),
      (InsightType.recommendation, '추천', Icons.recommend),
      (InsightType.churnRisk, '이탈 위험', Icons.person_off),
      (InsightType.renewalLikelihood, '재등록', Icons.refresh),
      (InsightType.plateauDetection, '정체기', Icons.trending_flat),
      (InsightType.workoutRecommendation, '운동 추천', Icons.sports_gymnastics),
      (InsightType.noshowPattern, '노쇼 패턴', Icons.event_busy),
      (InsightType.performanceRanking, '성과 랭킹', Icons.leaderboard),
    ];

    return filters.map((filter) {
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: FilterChip(
          avatar: Icon(filter.$3, size: 16),
          label: Text(filter.$2),
          selected: _selectedFilter == filter.$1,
          onSelected: (_) {
            setState(() {
              _selectedFilter =
                  _selectedFilter == filter.$1 ? null : filter.$1;
            });
          },
          selectedColor: _getTypeColor(filter.$1).withValues(alpha: 0.2),
          checkmarkColor: _getTypeColor(filter.$1),
        ),
      );
    }).toList();
  }

  /// 인사이트 목록
  Widget _buildInsightsList(
      BuildContext context, List<InsightModel> insights) {
    // 필터 적용
    var filteredInsights = insights;

    if (_showUnreadOnly) {
      filteredInsights =
          filteredInsights.where((i) => !i.isRead).toList();
    }

    if (_selectedFilter != null) {
      filteredInsights =
          filteredInsights.where((i) => i.type == _selectedFilter).toList();
    }

    // CRITICAL/HIGH 이탈 위험 회원 상단 정렬
    filteredInsights.sort((a, b) {
      // 1. churnRisk 타입 우선
      final aIsChurn = a.type == InsightType.churnRisk;
      final bIsChurn = b.type == InsightType.churnRisk;

      if (aIsChurn && !bIsChurn) return -1;
      if (!aIsChurn && bIsChurn) return 1;

      // 2. churnRisk 내에서 priority 높은 순 (high > medium > low)
      if (aIsChurn && bIsChurn) {
        final priorityOrder = {
          InsightPriority.high: 0,
          InsightPriority.medium: 1,
          InsightPriority.low: 2,
        };
        final aPriority = priorityOrder[a.priority] ?? 2;
        final bPriority = priorityOrder[b.priority] ?? 2;
        if (aPriority != bPriority) return aPriority.compareTo(bPriority);
      }

      // 3. 나머지는 생성일 역순
      return b.createdAt.compareTo(a.createdAt);
    });

    if (filteredInsights.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(context),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final insight = filteredInsights[index];
            return _InsightCard(
              insight: insight,
              onTap: () => _showInsightDetail(context, insight),
              onMarkAsRead: () => _markAsRead(insight.id),
              onActionTaken: insight.actionSuggestion != null
                  ? () => _markActionTaken(insight.id)
                  : null,
            )
                .animate()
                .fadeIn(delay: (50 * index).ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0);
          },
          childCount: filteredInsights.length,
        ),
      ),
    );
  }

  /// 로딩 스켈레톤
  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildSkeletonCard(context),
          childCount: 5,
        ),
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter != null || _showUnreadOnly
                ? '해당 조건의 인사이트가 없습니다'
                : '아직 인사이트가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '새 인사이트 생성 버튼을 눌러\nAI 분석을 시작해보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  /// 에러 상태
  Widget _buildErrorState(BuildContext context, Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '인사이트를 불러오지 못했습니다',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => ref.invalidate(trainerInsightsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 인사이트 상세 보기
  void _showInsightDetail(BuildContext context, InsightModel insight) {
    // 읽음 처리
    if (!insight.isRead) {
      _markAsRead(insight.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InsightDetailSheet(insight: insight),
    );
  }

  /// 읽음 처리
  Future<void> _markAsRead(String insightId) async {
    await ref.read(insightRepositoryProvider).markAsRead(insightId);
    ref.invalidate(trainerInsightsProvider);
    ref.invalidate(unreadInsightCountProvider);
  }

  /// 모두 읽음 처리
  Future<void> _markAllAsRead(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모두 읽음 처리'),
        content: const Text('모든 인사이트를 읽음 처리하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final trainerId = ref.read(currentTrainerIdProvider);
      if (trainerId != null) {
        await ref.read(insightsServiceProvider).markAllAsRead(trainerId);
      }
      ref.invalidate(trainerInsightsProvider);
      ref.invalidate(unreadInsightCountProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 인사이트를 읽음 처리했습니다')),
      );
    }
  }

  /// 조치 완료 처리
  Future<void> _markActionTaken(String insightId) async {
    await ref.read(insightRepositoryProvider).markActionTaken(insightId);
    ref.invalidate(trainerInsightsProvider);
  }

  /// 새 인사이트 생성
  Future<void> _refreshInsights(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('AI가 회원 데이터를 분석 중입니다...'),
          ],
        ),
      ),
    );

    try {
      final trainerId = ref.read(currentTrainerIdProvider);
      if (trainerId == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('트레이너 정보를 찾을 수 없습니다'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }
      await ref.read(insightsGenerationProvider.notifier).generate(trainerId: trainerId);
      final generationState = ref.read(insightsGenerationProvider);
      if (generationState.errorMessage != null) {
        throw Exception(generationState.errorMessage);
      }
      final result = generationState.result;

      if (!context.mounted) return;
      Navigator.pop(context); // 로딩 다이얼로그 닫기

      ref.invalidate(trainerInsightsProvider);
      ref.invalidate(unreadInsightCountProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result?.stats?.newSaved ?? result?.count ?? 0}개의 새 인사이트가 생성되었습니다'),
          backgroundColor: AppTheme.secondary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인사이트 생성 실패: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Color _getTypeColor(InsightType type) {
    switch (type) {
      // 기존 트레이너 인사이트
      case InsightType.attendanceAlert:
        return AppTheme.error;
      case InsightType.ptExpiry:
        return AppTheme.tertiary;
      case InsightType.performance:
        return AppTheme.secondary;
      case InsightType.recommendation:
        return AppTheme.primary;
      case InsightType.weightProgress:
        return Colors.purple;
      case InsightType.workoutVolume:
        return Colors.teal;
      // 신규 트레이너 인사이트
      case InsightType.churnRisk:
        return const Color(0xFFEF4444); // 빨간색 - 이탈 위험
      case InsightType.renewalLikelihood:
        return const Color(0xFF10B981); // 초록색 - 재등록 가능성
      case InsightType.plateauDetection:
        return const Color(0xFFF59E0B); // 주황색 - 정체기
      case InsightType.workoutRecommendation:
        return AppTheme.primary;
      case InsightType.noshowPattern:
        return const Color(0xFFEF4444); // 빨간색 - 노쇼
      case InsightType.performanceRanking:
        return const Color(0xFF8B5CF6); // 보라색 - 랭킹
      // 회원 인사이트 (필터에는 나오지 않지만 처리)
      case InsightType.bodyPrediction:
      case InsightType.workoutAchievement:
      case InsightType.attendanceHabit:
      case InsightType.nutritionBalance:
      case InsightType.bodyChangeReport:
      case InsightType.conditionPattern:
      case InsightType.goalProgress:
      case InsightType.benchmark:
        return AppTheme.primary;
    }
  }
}

/// 인사이트 카드 위젯
class _InsightCard extends StatelessWidget {
  final InsightModel insight;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback? onActionTaken;

  const _InsightCard({
    required this.insight,
    required this.onTap,
    required this.onMarkAsRead,
    this.onActionTaken,
  });

  /// 우선순위 색상 반환
  Color _getPriorityColor(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.high:
        return const Color(0xFFEF4444); // Red
      case InsightPriority.medium:
        return const Color(0xFFF59E0B); // Orange
      case InsightPriority.low:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _getPriorityColor(insight.priority);
    final hasGraph = insight.graphData != null &&
                     insight.graphData!.isNotEmpty &&
                     insight.graphType != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // 회원 ID가 있으면 회원 상세 페이지로 이동
          if (insight.memberId != null) {
            context.push('/trainer/members/${insight.memberId}');
          } else {
            // 회원 ID가 없으면 기존 상세 보기
            onTap();
          }
        },
        child: GlassCard(
          child: Stack(
            children: [
              // 읽지 않은 표시
              if (!insight.isRead)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        // 타입 아이콘
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            insight.typeIcon,
                            color: priorityColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 타입 & 회원명
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      insight.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: insight.isRead
                                                ? colorScheme.outline
                                                : colorScheme.onSurface,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // 우선순위 배지
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getPriorityLabel(insight.priority),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: priorityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (insight.memberName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    insight.memberName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // 미니 그래프 - 타입별 전용 위젯 사용
                    if (insight.type == InsightType.churnRisk &&
                        insight.data != null) ...[
                      const SizedBox(height: 12),
                      ChurnGaugeChart(
                        churnScore:
                            (insight.data!['churnScore'] as num?)?.toInt() ?? 0,
                        riskLevel:
                            insight.data!['riskLevel'] as String? ?? 'LOW',
                        breakdown: _parseBreakdown(insight.data!['breakdown']),
                        riskFactors: _parseRiskFactors(insight.data!),
                        size: 120,
                        animate: true,
                      ),
                    ] else if (insight.type == InsightType.workoutVolume &&
                        insight.data != null) ...[
                      const SizedBox(height: 12),
                      VolumeBarChart(
                        weeklyVolumes: _parseWeeklyVolumes(
                            insight.data!['weeklyVolumes']),
                        fourWeekAverage:
                            (insight.data!['fourWeekAverage'] as num?)
                                    ?.toDouble() ??
                                0.0,
                        volumeTrend:
                            insight.data!['volumeTrend'] as String? ?? 'normal',
                        weeklyChanges: _parseWeeklyChanges(
                            insight.data!['weeklyChanges']),
                      ),
                    ] else if (hasGraph) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: InsightMiniChart(
                          graphType: insight.graphType!,
                          data: insight.graphData!,
                          height: 60,
                          width: MediaQuery.of(context).size.width - 96,
                          primaryColor: priorityColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    // 메시지
                    Text(
                      insight.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: insight.isRead
                                ? colorScheme.outline
                                : colorScheme.onSurface,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 조치 제안
                    if (insight.actionSuggestion != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                insight.actionSuggestion!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.primary,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.high:
        return '즉시 확인';
      case InsightPriority.medium:
        return '확인 권장';
      case InsightPriority.low:
        return '참고';
    }
  }

  /// ChurnGaugeChart용 breakdown 파싱
  Map<String, Map<String, dynamic>> _parseBreakdown(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, Map<String, dynamic>>) return data;
    if (data is Map) {
      return data.map((key, value) {
        if (value is Map) {
          return MapEntry(
            key.toString(),
            value.map((k, v) => MapEntry(k.toString(), v)),
          );
        }
        return MapEntry(key.toString(), <String, dynamic>{'score': value});
      });
    }
    return {};
  }

  /// ChurnGaugeChart용 riskFactors 파싱
  List<String> _parseRiskFactors(Map<String, dynamic> data) {
    final factors = <String>[];
    final breakdown = data['breakdown'];
    if (breakdown is Map) {
      breakdown.forEach((key, value) {
        final score = value is Map ? value['score'] : value;
        if (score != null && (score as num) > 50) {
          switch (key) {
            case 'attendanceDrop':
              factors.add('출석률 하락');
            case 'weightPlateau':
              factors.add('체중 정체');
            case 'messageNoResponse':
              factors.add('메시지 무응답');
            case 'remainingSessions':
              factors.add('세션 부족');
            case 'goalProgress':
              factors.add('목표 미달');
          }
        }
      });
    }
    return factors;
  }

  /// VolumeBarChart용 weeklyVolumes 파싱
  List<int> _parseWeeklyVolumes(dynamic data) {
    if (data == null) return [0, 0, 0, 0, 0];
    if (data is List) {
      return data.map((e) => (e as num?)?.toInt() ?? 0).toList();
    }
    return [0, 0, 0, 0, 0];
  }

  /// VolumeBarChart용 weeklyChanges 파싱
  List<double> _parseWeeklyChanges(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => (e as num?)?.toDouble() ?? 0.0).toList();
    }
    return [];
  }
}

/// 인사이트 상세 바텀시트
class _InsightDetailSheet extends StatelessWidget {
  final InsightModel insight;

  const _InsightDetailSheet({required this.insight});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                insight.priorityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            insight.typeIcon,
                            color: insight.priorityColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (insight.memberName != null)
                                Text(
                                  insight.memberName!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.outline,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 우선순위 배지
                    Row(
                      children: [
                        _buildBadge(
                          context,
                          _getPriorityLabel(insight.priority),
                          insight.priorityColor,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          context,
                          _getTypeLabel(insight.type),
                          colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 메시지
                    Text(
                      '내용',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    // 조치 제안
                    if (insight.actionSuggestion != null) ...[
                      const SizedBox(height: 24),
                      Text(
                        '권장 조치',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: AppTheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insight.actionSuggestion!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // 추가 데이터
                    if (insight.data != null && insight.data!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text(
                        '상세 데이터',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...insight.data!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                              ),
                              Text(
                                entry.value.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    // 생성일
                    Text(
                      '생성일: ${_formatDate(insight.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                    if (insight.expiresAt != null)
                      Text(
                        '만료일: ${_formatDate(insight.expiresAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _getPriorityLabel(InsightPriority priority) {
    switch (priority) {
      case InsightPriority.high:
        return '즉시 확인';
      case InsightPriority.medium:
        return '확인 권장';
      case InsightPriority.low:
        return '참고';
    }
  }

  String _getTypeLabel(InsightType type) {
    switch (type) {
      // 기존 트레이너 인사이트
      case InsightType.attendanceAlert:
        return '출석 알림';
      case InsightType.ptExpiry:
        return 'PT 종료';
      case InsightType.performance:
        return '성과';
      case InsightType.recommendation:
        return '추천';
      case InsightType.weightProgress:
        return '체중 변화';
      case InsightType.workoutVolume:
        return '운동량';
      // 신규 트레이너 인사이트
      case InsightType.churnRisk:
        return '이탈 위험';
      case InsightType.renewalLikelihood:
        return '재등록 가능성';
      case InsightType.plateauDetection:
        return '정체기';
      case InsightType.workoutRecommendation:
        return '운동 추천';
      case InsightType.noshowPattern:
        return '노쇼 패턴';
      case InsightType.performanceRanking:
        return '성과 랭킹';
      // 회원 인사이트
      case InsightType.bodyPrediction:
        return '체성분 예측';
      case InsightType.workoutAchievement:
        return '운동 성과';
      case InsightType.attendanceHabit:
        return '출석 습관';
      case InsightType.nutritionBalance:
        return '영양 밸런스';
      case InsightType.bodyChangeReport:
        return '체성분 변화';
      case InsightType.conditionPattern:
        return '컨디션 패턴';
      case InsightType.goalProgress:
        return '목표 달성';
      case InsightType.benchmark:
        return '벤치마킹';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
