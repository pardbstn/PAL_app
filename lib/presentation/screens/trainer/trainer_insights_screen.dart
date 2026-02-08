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
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/data/models/insight_model.dart';
import 'package:flutter_pal_app/data/repositories/insight_repository.dart';
import 'package:flutter_pal_app/presentation/providers/insight_provider.dart';
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

/// 필터 카테고리
enum _FilterCategory {
  all,
  urgent,
  performance,
  suggestions,
}

class _TrainerInsightsScreenState extends ConsumerState<TrainerInsightsScreen> {
  _FilterCategory _selectedCategory = _FilterCategory.all;

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

              // 요약 카드
              SliverToBoxAdapter(
                child: _buildSummaryCard(context),
              ),

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
                child: SizedBox(height: 100), // 하단 FAB 공간 확보
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppNavGlass.fabBottomPadding),
        child: FloatingActionButton.extended(
          onPressed: () => _refreshInsights(context),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('새 인사이트 생성'),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
        ),
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
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withValues(alpha: 0.8)
                ],
              ),
              borderRadius: AppRadius.fullBorderRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: AppIconSize.xs),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'AI 인사이트',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppTextStyle.bodyLarge,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: AppRadius.mdBorderRadius,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppTextStyle.bodySmall,
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

  /// 요약 카드 (이번 주 인사이트 N건, 우선순위별 카운트)
  Widget _buildSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final insightsAsync = ref.watch(trainerInsightsProvider);

    return insightsAsync.when(
      data: (insights) {
        final thisWeek = insights.where((i) {
          final diff = DateTime.now().difference(i.createdAt);
          return diff.inDays <= 7;
        }).toList();

        final highCount = thisWeek.where((i) => i.priority == InsightPriority.high).length;
        final mediumCount = thisWeek.where((i) => i.priority == InsightPriority.medium).length;
        final lowCount = thisWeek.where((i) => i.priority == InsightPriority.low).length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.1),
                AppTheme.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.lgBorderRadius,
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.primary, size: AppIconSize.md),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '이번 주 인사이트 ${thisWeek.length}건',
                  style: TextStyle(
                    fontSize: AppTextStyle.bodyLarge,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (highCount > 0) ...[
                _buildPriorityBadge('🔴', highCount, const Color(0xFFF04452)),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (mediumCount > 0) ...[
                _buildPriorityBadge('🟡', mediumCount, const Color(0xFFFF8A00)),
                const SizedBox(width: AppSpacing.xs),
              ],
              if (lowCount > 0) ...[
                _buildPriorityBadge('🔵', lowCount, const Color(0xFF0064FF)),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.02, end: 0);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPriorityBadge(String emoji, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.mdBorderRadius,
      ),
      child: Text(
        '$emoji $count',
        style: TextStyle(
          fontSize: AppTextStyle.caption,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  /// 필터 칩 (4개 카테고리)
  Widget _buildFilterChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // 전체
          _buildCategoryChip(
            context,
            label: '전체',
            icon: Icons.grid_view,
            category: _FilterCategory.all,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          // 긴급
          _buildCategoryChip(
            context,
            label: '긴급',
            icon: Icons.warning,
            category: _FilterCategory.urgent,
            color: const Color(0xFFF04452),
          ),
          const SizedBox(width: AppSpacing.sm),
          // 성과
          _buildCategoryChip(
            context,
            label: '성과',
            icon: Icons.trending_up,
            category: _FilterCategory.performance,
            color: const Color(0xFF00C471),
          ),
          const SizedBox(width: AppSpacing.sm),
          // 제안
          _buildCategoryChip(
            context,
            label: '제안',
            icon: Icons.lightbulb,
            category: _FilterCategory.suggestions,
            color: const Color(0xFF0064FF),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.02, end: 0);
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required _FilterCategory category,
    required Color color,
  }) {
    final isSelected = _selectedCategory == category;

    return FilterChip(
      avatar: Icon(icon, size: AppIconSize.xs, color: isSelected ? Colors.white : color),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _selectedCategory = category);
      },
      backgroundColor: color.withValues(alpha: 0.1),
      selectedColor: color,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgBorderRadius,
        side: BorderSide(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
    );
  }

  /// 인사이트 목록
  Widget _buildInsightsList(
      BuildContext context, List<InsightModel> insights) {
    // 필터 적용
    var filteredInsights = insights;

    // 카테고리 필터
    switch (_selectedCategory) {
      case _FilterCategory.all:
        // 전체 표시
        break;
      case _FilterCategory.urgent:
        // high priority만
        filteredInsights = filteredInsights.where((i) => i.priority == InsightPriority.high).toList();
        break;
      case _FilterCategory.performance:
        // 성과 관련
        filteredInsights = filteredInsights.where((i) {
          return i.type == InsightType.performance ||
              i.type == InsightType.workoutVolume ||
              i.type == InsightType.performanceRanking ||
              i.type == InsightType.renewalLikelihood;
        }).toList();
        break;
      case _FilterCategory.suggestions:
        // 제안 관련
        filteredInsights = filteredInsights.where((i) {
          return i.type == InsightType.recommendation ||
              i.type == InsightType.workoutRecommendation ||
              i.type == InsightType.plateauDetection;
        }).toList();
        break;
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
      padding: const EdgeInsets.all(20),
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
                .fadeIn(delay: (50 * index).ms, duration: 200.ms)
                .slideY(begin: 0.02, end: 0);
          },
          childCount: filteredInsights.length,
        ),
      ),
    );
  }

  /// 로딩 스켈레톤
  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Shimmer.fromColors(
        baseColor: colorScheme.surfaceContainerHighest,
        highlightColor: colorScheme.surface,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.lgBorderRadius,
            border: Border.all(
              color: isDark ? AppColors.gray700 : AppColors.gray200,
            ),
            boxShadow: AppShadows.sm,
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
            size: AppIconSize.xxl + AppSpacing.md,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _selectedCategory != _FilterCategory.all
                ? '해당 조건의 인사이트가 없어요'
                : '아직 인사이트가 없어요',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '새 인사이트 생성 버튼을 눌러\nAI 분석을 시작해보세요',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9));
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
              size: AppIconSize.xxl,
              color: AppTheme.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '인사이트를 불러오지 못했어요',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
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
        content: const Text('모든 인사이트를 읽음 처리할까요?'),
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
        const SnackBar(content: Text('모든 인사이트를 읽음 처리했어요')),
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
            SizedBox(width: AppSpacing.md),
            Text('AI가 회원 데이터를 분석하고 있어요...'),
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
            content: const Text('트레이너 정보를 찾을 수 없어요'),
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
          content: Text('${result?.stats?.newSaved ?? result?.count ?? 0}개의 새 인사이트가 생성됐어요'),
          backgroundColor: AppTheme.secondary,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('인사이트 생성에 실패했어요: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = insight.typeColor; // 새로운 typeColor 사용
    final hasGraph = insight.graphData != null &&
                     insight.graphData!.isNotEmpty &&
                     insight.graphType != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.gray100,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Stack(
            children: [
              // 읽지 않은 표시 (좌측 파란 dot)
              if (!insight.isRead)
                Positioned(
                  top: AppSpacing.lg,
                  left: AppSpacing.md,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  !insight.isRead ? AppSpacing.lg + 4 : AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        // 타입 아이콘 (원형 배경)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            insight.typeIcon,
                            color: typeColor,
                            size: AppIconSize.md,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // 타입 & 회원명
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // 유형 태그 (pill shape)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: typeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getTypeLabel(insight.type),
                                      style: TextStyle(
                                        fontSize: AppTextStyle.caption,
                                        fontWeight: FontWeight.bold,
                                        color: typeColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  // 우선순위 배지
                                  if (insight.priority == InsightPriority.high)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF04452).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '긴급',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFF04452),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // 제목
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
                              // 회원명
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
                      const SizedBox(height: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.md),
                      Center(
                        child: InsightMiniChart(
                          graphType: insight.graphType!,
                          data: insight.graphData!,
                          height: 60,
                          width: MediaQuery.of(context).size.width - 96,
                          primaryColor: typeColor,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    // 메시지
                    Text(
                      insight.message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: insight.isRead
                                ? colorScheme.outline
                                : colorScheme.onSurface,
                            height: 1.4,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 액션 버튼 (actionSuggestion이 있는 경우)
                    if (insight.actionSuggestion != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(context, insight, typeColor),
                        ],
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

  /// 액션 버튼 (인사이트 타입별 다른 액션)
  Widget _buildActionButton(BuildContext context, InsightModel insight, Color color) {
    String label;
    IconData icon;

    switch (insight.type) {
      case InsightType.churnRisk:
      case InsightType.attendanceAlert:
      case InsightType.noshowPattern:
        label = '메시지 보내기';
        icon = Icons.chat_bubble_outline;
        break;
      case InsightType.renewalLikelihood:
      case InsightType.ptExpiry:
        label = '리마인드 보내기';
        icon = Icons.notifications_outlined;
        break;
      case InsightType.performance:
      case InsightType.workoutVolume:
        label = '칭찬 메시지';
        icon = Icons.thumb_up_outlined;
        break;
      default:
        label = '자세히 보기';
        icon = Icons.arrow_forward_rounded;
    }

    return ElevatedButton.icon(
      onPressed: () {
        // 읽음 처리
        if (!insight.isRead) {
          onMarkAsRead();
        }
        // 회원 상세로 이동 (메시지 탭)
        if (insight.memberId != null) {
          context.push('/trainer/members/${insight.memberId}');
        }
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  String _getTypeLabel(InsightType type) {
    switch (type) {
      case InsightType.churnRisk:
        return '이탈 위험';
      case InsightType.attendanceAlert:
        return '출석 알림';
      case InsightType.noshowPattern:
        return '노쇼 패턴';
      case InsightType.renewalLikelihood:
        return '재등록 가능성';
      case InsightType.ptExpiry:
        return 'PT 종료';
      case InsightType.performance:
        return '성과';
      case InsightType.workoutVolume:
        return '운동량';
      case InsightType.performanceRanking:
        return '성과 랭킹';
      case InsightType.recommendation:
        return '추천';
      case InsightType.workoutRecommendation:
        return '운동 추천';
      case InsightType.plateauDetection:
        return '정체기';
      case InsightType.weightProgress:
        return '체중 변화';
      default:
        return '기타';
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
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 내용
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // 헤더
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color:
                                insight.typeColor.withValues(alpha: 0.15),
                            borderRadius: AppRadius.mdBorderRadius,
                          ),
                          child: Icon(
                            insight.typeIcon,
                            color: insight.typeColor,
                            size: AppIconSize.lg,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
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
                    const SizedBox(height: AppSpacing.lg),
                    // 우선순위 배지
                    Row(
                      children: [
                        _buildBadge(
                          context,
                          _getPriorityText(insight.priority),
                          insight.priorityColor,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildBadge(
                          context,
                          _getTypeLabel(insight.type),
                          colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // 메시지
                    Text(
                      '내용',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      insight.message,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    // 조치 제안
                    if (insight.actionSuggestion != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '권장 조치',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.mdBorderRadius,
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
                            const SizedBox(width: AppSpacing.md),
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        '상세 데이터',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...insight.data!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                    const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.lgBorderRadius,
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

  String _getPriorityText(InsightPriority priority) {
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
