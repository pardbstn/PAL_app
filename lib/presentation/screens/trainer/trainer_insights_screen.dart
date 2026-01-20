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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
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
                    color: insight.priorityColor,
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
                      // 우선순위 아이콘
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: insight.priorityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          insight.typeIcon,
                          color: insight.priorityColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 타입 & 회원명
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            if (insight.memberName != null)
                              Text(
                                insight.memberName!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.outline,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
