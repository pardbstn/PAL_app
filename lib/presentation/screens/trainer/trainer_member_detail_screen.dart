import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/animation_utils.dart';
import '../../widgets/animated/animated_widgets.dart';
import '../../../presentation/widgets/states/states.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';
import 'package:flutter_pal_app/data/repositories/user_repository.dart';
import 'package:flutter_pal_app/presentation/providers/members_provider.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculums_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/charts/weight_line_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/charts/body_composition_pie_chart.dart';
import 'package:flutter_pal_app/presentation/widgets/charts/goal_progress_indicator.dart';
import 'package:flutter_pal_app/presentation/widgets/add_body_record_sheet.dart';
import 'package:flutter_pal_app/presentation/widgets/session_complete_dialog.dart';
import 'package:flutter_pal_app/data/models/session_signature_model.dart';
import 'package:flutter_pal_app/data/repositories/session_signature_repository.dart';
import 'package:flutter_pal_app/presentation/providers/weight_prediction_provider.dart';
import 'package:flutter_pal_app/presentation/providers/inbody_provider.dart';
import 'package:flutter_pal_app/data/models/inbody_record_model.dart';
import 'package:flutter_pal_app/presentation/providers/body_composition_prediction_provider.dart';
import 'package:flutter_pal_app/data/models/body_composition_prediction_model.dart';
import 'package:flutter_pal_app/data/models/body_record_model.dart';
import 'package:flutter_pal_app/data/repositories/body_record_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ============================================================================
// Providers
// ============================================================================

/// 회원 상세 정보 Provider (Member + User)
final memberDetailProvider =
    FutureProvider.family<({MemberModel member, UserModel? user}), String>(
        (ref, memberId) async {
  final memberRepository = ref.watch(memberRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  final member = await memberRepository.get(memberId);
  if (member == null) {
    throw Exception('회원을 찾을 수 없습니다.');
  }

  final user = await userRepository.get(member.userId);
  return (member: member, user: user);
});

// ============================================================================
// Main Screen
// ============================================================================

/// 트레이너 회원 상세 화면
class TrainerMemberDetailScreen extends ConsumerWidget {
  const TrainerMemberDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouter에서 memberId 가져오기
    final memberId = GoRouterState.of(context).pathParameters['id'] ?? '';

    if (memberId.isEmpty) {
      return _buildErrorScaffold(context, ref, '회원 ID가 없습니다.', memberId);
    }

    final memberDetailAsync = ref.watch(memberDetailProvider(memberId));

    return memberDetailAsync.when(
      loading: () => _buildLoadingScaffold(context),
      error: (error, stack) => _buildErrorScaffold(context, ref, error, memberId),
      data: (data) => _MemberDetailContent(
        memberId: memberId,
        member: data.member,
        user: data.user,
      ),
    );
  }

  Widget _buildLoadingScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trainer/members'),
        ),
      ),
      body: _buildShimmerLoading(context),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 헤더 스켈레톤
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            // 정보 섹션 스켈레톤
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 280,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    WidgetRef ref,
    Object error,
    String memberId,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/trainer/members'),
        ),
      ),
      body: ErrorState.fromError(
        error,
        onRetry: memberId.isNotEmpty
            ? () => ref.invalidate(memberDetailProvider(memberId))
            : null,
      ),
    );
  }
}

// ============================================================================
// Content Widget
// ============================================================================

class _MemberDetailContent extends ConsumerStatefulWidget {
  final String memberId;
  final MemberModel member;
  final UserModel? user;

  const _MemberDetailContent({
    required this.memberId,
    required this.member,
    this.user,
  });

  @override
  ConsumerState<_MemberDetailContent> createState() =>
      _MemberDetailContentState();
}

class _MemberDetailContentState extends ConsumerState<_MemberDetailContent> {
  String get memberName => widget.user?.name ?? '회원';
  String? get profileImageUrl => widget.user?.profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(memberName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/trainer/members'),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: '정보 수정',
              onPressed: () => _showEditMemberDialog(),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
              tooltip: '회원 삭제',
              onPressed: () => _showDeleteMemberDialog(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '기본정보'),
              Tab(text: '그래프'),
              Tab(text: '인바디'),
              Tab(text: '커리큘럼'),
              Tab(text: '메모'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(member: widget.member, user: widget.user),
            _GraphTab(memberId: widget.memberId, member: widget.member),
            _InbodyTab(memberId: widget.memberId),
            _CurriculumTab(memberId: widget.memberId),
            _MemoTab(memberId: widget.memberId, member: widget.member),
          ],
        ),
      ),
    );
  }

  void _showEditMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => _EditMemberDialog(
        memberId: widget.memberId,
        member: widget.member,
        user: widget.user,
        onSaved: () {
          ref.invalidate(memberDetailProvider(widget.memberId));
          ref.invalidate(membersProvider);
        },
      ),
    );
  }

  void _showDeleteMemberDialog() {
    final memberName = widget.user?.name ?? '회원';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('회원 삭제'),
        content: Text('$memberName 회원을 삭제하시겠습니까?\n\n삭제된 회원 정보는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(membersNotifierProvider.notifier)
                    .deleteMember(widget.memberId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$memberName 회원이 삭제되었습니다.')),
                  );
                  context.go('/trainer/members');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('회원 삭제 중 오류가 발생했습니다.')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Info Tab
// ============================================================================

class _InfoTab extends StatelessWidget {
  final MemberModel member;
  final UserModel? user;

  const _InfoTab({required this.member, this.user});

  String get memberName => user?.name ?? '회원';
  String? get profileImageUrl => user?.profileImageUrl;
  String get email => user?.email ?? '-';
  String get phone => user?.phone ?? '-';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 헤더에 슬라이드 다운 애니메이션 적용
          _buildProfileHeader(context).animateSlideDown(),
          const SizedBox(height: 24),
          // 기본 정보 섹션에 스태거 애니메이션 적용
          _buildInfoSection(context, '기본 정보', [
            _buildInfoRow(context, '이메일', email),
            _buildInfoRow(context, '연락처', phone),
          ]).animateListItem(0),
          const SizedBox(height: 16),
          // PT 정보 섹션에 스태거 애니메이션 적용
          _buildInfoSection(context, 'PT 정보', [
            _buildInfoRow(context, '운동 목표', member.goalLabel),
            _buildInfoRow(context, '운동 경력', member.experienceLabel),
            _buildInfoRow(context, '총 회차', '${member.ptInfo.totalSessions}회'),
            _buildInfoRow(context, '완료 회차', '${member.ptInfo.completedSessions}회'),
            _buildInfoRow(context, '잔여 회차', '${member.remainingSessions}회'),
            _buildInfoRow(
              context,
              'PT 시작일',
              DateFormat('yyyy.MM.dd').format(member.ptInfo.startDate),
            ),
            if (member.targetWeight != null)
              _buildInfoRow(context, '목표 체중', '${member.targetWeight}kg'),
          ]).animateListItem(1),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final goalColor = _getGoalColor(member.goal);
    final initials = memberName.isNotEmpty
        ? memberName.substring(0, memberName.length >= 2 ? 2 : 1)
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goalColor, goalColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: profileImageUrl != null
                ? ClipOval(
                    child: Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(initials, goalColor),
                    ),
                  )
                : _buildInitials(initials, goalColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memberName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(context),
                    const SizedBox(width: 8),
                    _buildGoalBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitials(String initials, Color color) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final isActive = member.remainingSessions > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.secondary : Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? '활성 회원' : 'PT 완료',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildGoalBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        member.goalLabel,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getGoalColor(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => AppTheme.error,
      FitnessGoal.bulk => AppTheme.primary,
      FitnessGoal.fitness => AppTheme.secondary,
      FitnessGoal.rehab => AppTheme.tertiary,
    };
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ============================================================================
// Graph Tab
// ============================================================================

/// 그래프 지표 선택 타입
enum GraphMetricType {
  weight('체중', 'kg'),
  muscle('골격근량', 'kg'),
  bodyFat('체지방률', '%'),
  all('전체', '');

  final String label;
  final String unit;
  const GraphMetricType(this.label, this.unit);
}

class _GraphTab extends ConsumerStatefulWidget {
  final String memberId;
  final MemberModel member;

  const _GraphTab({required this.memberId, required this.member});

  @override
  ConsumerState<_GraphTab> createState() => _GraphTabState();
}

class _GraphTabState extends ConsumerState<_GraphTab> {
  GraphMetricType _selectedMetric = GraphMetricType.weight;

  @override
  Widget build(BuildContext context) {
    final bodyRecordsAsync = ref.watch(bodyRecordsProvider(widget.memberId));
    final weightHistoryAsync = ref.watch(weightHistoryProvider(widget.memberId));
    final latestRecordAsync = ref.watch(latestBodyRecordProvider(widget.memberId));
    final predictionAsync = ref.watch(latestPredictionProvider(widget.memberId));
    final bodyCompPredictionState = ref.watch(bodyCompositionPredictionProvider);

    return Stack(
      children: [
        bodyRecordsAsync.when(
          loading: () => _buildShimmerLoading(context),
          error: (error, _) => _buildErrorView(context, ref, error),
          data: (records) {
            if (records.isEmpty) {
              return _buildEmptyView(context);
            }
            return _buildGraphContent(
              context,
              ref,
              records,
              weightHistoryAsync,
              latestRecordAsync,
              predictionAsync,
              bodyCompPredictionState,
            );
          },
        ),
        // FAB - 기록 추가 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => AddBodyRecordSheet.show(context, widget.memberId),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('기록 추가'),
          ),
        ),
      ],
    );
  }

  /// 지표 선택 탭 바 빌드
  Widget _buildMetricSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: GraphMetricType.values.map((metric) {
          final isSelected = _selectedMetric == metric;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMetric = metric),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  metric.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return ErrorState.fromError(
      error,
      onRetry: () => ref.invalidate(bodyRecordsProvider(widget.memberId)),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return EmptyState(
      type: EmptyStateType.bodyRecords,
      onAction: () => AddBodyRecordSheet.show(context, widget.memberId),
    );
  }

  Widget _buildGraphContent(
    BuildContext context,
    WidgetRef ref,
    List<BodyRecordModel> records,
    AsyncValue<List<WeightHistoryData>> weightHistoryAsync,
    AsyncValue<dynamic> latestRecordAsync,
    AsyncValue<dynamic> predictionAsync,
    BodyCompositionPredictionState bodyCompPredictionState,
  ) {
    // 예측 데이터를 WeightData로 변환
    List<WeightData> predictedData = [];
    final prediction = predictionAsync.value;
    if (prediction != null) {
      predictedData = prediction.predictedWeights.map<WeightData>((p) {
        return WeightData(
          label: DateFormat('M/d').format(p.date),
          weight: p.weight,
        );
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 상태 요약
          latestRecordAsync.when(
            loading: () => _buildCurrentStatusShimmer(context),
            error: (_, _) => const SizedBox.shrink(),
            data: (record) {
              if (record == null) return const SizedBox.shrink();
              return _buildCurrentStatus(record);
            },
          ),
          const SizedBox(height: 24),

          // 목표 달성률
          if (widget.member.targetWeight != null)
            latestRecordAsync.whenData((record) {
              if (record == null) return const SizedBox.shrink();
              return _buildSectionCard(
                context,
                '목표 달성률',
                weightHistoryAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, st) => const Center(
                    child: Text('데이터 로드 실패'),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return const Center(child: Text('데이터가 없습니다'));
                    }
                    return GoalProgressIndicator(
                      currentValue: record.weight,
                      targetValue: widget.member.targetWeight!,
                      startValue: history.first.weight,
                      label: widget.member.goalLabel,
                      unit: 'kg',
                      isDecreaseGoal: widget.member.goal == FitnessGoal.diet,
                    );
                  },
                ),
              );
            }).value ??
                const SizedBox.shrink(),
          const SizedBox(height: 24),

          // 지표 선택 탭
          _buildMetricSelector(context),
          const SizedBox(height: 16),

          // 체성분 변화 그래프 (선택된 지표에 따라)
          _buildBodyCompositionChart(
            context,
            weightHistoryAsync,
            records,
            predictedData,
            bodyCompPredictionState,
          ),
          const SizedBox(height: 16),

          // AI 체성분 예측 섹션
          _buildBodyCompositionPredictionSection(
            context,
            ref,
            bodyCompPredictionState,
            records.length,
          ),
          const SizedBox(height: 24),

          // 체성분 비율
          latestRecordAsync.whenData((record) {
            if (record == null ||
                record.muscleMass == null ||
                record.fatMass == null) {
              return const SizedBox.shrink();
            }
            return _buildSectionCard(
              context,
              '체성분 분석',
              BodyCompositionPieChart(
                muscleMass: record.muscleMass!,
                fatMass: record.fatMass!,
                totalWeight: record.weight,
              ),
            );
          }).value ??
              const SizedBox.shrink(),
          const SizedBox(height: 24),

          // 기록 히스토리
          _buildRecordHistory(context, ref, records),
        ],
      ),
    );
  }

  /// 체성분 변화 그래프 빌드
  Widget _buildBodyCompositionChart(
    BuildContext context,
    AsyncValue<List<WeightHistoryData>> weightHistoryAsync,
    List records,
    List<WeightData> predictedData,
    BodyCompositionPredictionState bodyCompPredictionState,
  ) {
    final bodyCompPrediction = bodyCompPredictionState.prediction;

    return _buildSectionCard(
      context,
      _getChartTitle(),
      weightHistoryAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => Center(
          child: Text('로드 실패: $error'),
        ),
        data: (history) {
          if (history.length < 2) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('그래프를 표시하려면 2개 이상의 기록이 필요합니다'),
              ),
            );
          }

          // 선택된 지표에 따라 차트 빌드
          if (_selectedMetric == GraphMetricType.all) {
            return _buildMultiMetricChart(context, history, records, bodyCompPrediction);
          } else {
            return _buildSingleMetricChart(
              context,
              history,
              records,
              predictedData,
              bodyCompPrediction,
            );
          }
        },
      ),
    );
  }

  String _getChartTitle() {
    return switch (_selectedMetric) {
      GraphMetricType.weight => '체중 변화',
      GraphMetricType.muscle => '골격근량 변화',
      GraphMetricType.bodyFat => '체지방률 변화',
      GraphMetricType.all => '체성분 종합 변화',
    };
  }

  /// 단일 지표 차트 빌드
  Widget _buildSingleMetricChart(
    BuildContext context,
    List<WeightHistoryData> history,
    List records,
    List<WeightData> predictedData,
    BodyCompositionPredictionModel? bodyCompPrediction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // 데이터 추출
    List<_ChartDataPoint> dataPoints = [];
    List<_ChartDataPoint> predictionPoints = [];

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final date = record.recordDate as DateTime;
      double? value;

      switch (_selectedMetric) {
        case GraphMetricType.weight:
          value = record.weight as double?;
          break;
        case GraphMetricType.muscle:
          value = record.muscleMass as double?;
          break;
        case GraphMetricType.bodyFat:
          value = record.bodyFatPercent as double?;
          break;
        case GraphMetricType.all:
          break;
      }

      if (value != null) {
        dataPoints.add(_ChartDataPoint(
          date: date,
          value: value,
          label: DateFormat('M/d').format(date),
        ));
      }
    }

    // 날짜 오름차순 정렬 (과거 → 최신)
    dataPoints.sort((a, b) => a.date.compareTo(b.date));

    // 예측 데이터 추가
    if (bodyCompPrediction != null && dataPoints.isNotEmpty) {
      final MetricPrediction? metricPred = switch (_selectedMetric) {
        GraphMetricType.weight => bodyCompPrediction.weightPrediction,
        GraphMetricType.muscle => bodyCompPrediction.musclePrediction,
        GraphMetricType.bodyFat => bodyCompPrediction.bodyFatPrediction,
        GraphMetricType.all => null,
      };

      if (metricPred != null) {
        final lastDate = dataPoints.last.date;
        // 1주 후 예측만 표시
        final predDate = lastDate.add(const Duration(days: 7));
        final predValue = metricPred.current + metricPred.weeklyTrend;
        predictionPoints.add(_ChartDataPoint(
          date: predDate,
          value: predValue,
          label: DateFormat('M/d').format(predDate),
        ));
      }
    }

    if (dataPoints.length < 2) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('${_selectedMetric.label} 데이터가 부족합니다'),
        ),
      );
    }

    // 차트 빌드
    final allValues = [
      ...dataPoints.map((e) => e.value),
      ...predictionPoints.map((e) => e.value),
    ];
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 2;

    final metricColor = _getMetricColor(_selectedMetric);

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)}${_selectedMetric.unit}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  final allPoints = [...dataPoints, ...predictionPoints];
                  if (index < 0 || index >= allPoints.length) {
                    return const SizedBox();
                  }
                  if (index % 2 != 0 && allPoints.length > 6) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      allPoints[index].label,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => colorScheme.inverseSurface,
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItems: (spots) => spots.map((spot) {
                final isActual = spot.x < dataPoints.length;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}${_selectedMetric.unit}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '\n${isActual ? "실제" : "예측"}',
                      style: TextStyle(
                        color: colorScheme.onInverseSurface.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            // 실제 데이터
            LineChartBarData(
              spots: dataPoints.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.value);
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: metricColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: colorScheme.surface,
                    strokeWidth: 3,
                    strokeColor: metricColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    metricColor.withValues(alpha: 0.3),
                    metricColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            // 예측 데이터
            if (predictionPoints.isNotEmpty)
              LineChartBarData(
                spots: predictionPoints.asMap().entries.map((e) {
                  return FlSpot(
                    (dataPoints.length + e.key).toDouble(),
                    e.value.value,
                  );
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: metricColor.withValues(alpha: 0.6),
                barWidth: 3,
                isStrokeCapRound: true,
                dashArray: [8, 4],
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 5,
                      color: colorScheme.surface,
                      strokeWidth: 3,
                      strokeColor: metricColor.withValues(alpha: 0.6),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 다중 지표 차트 빌드 (전체)
  Widget _buildMultiMetricChart(
    BuildContext context,
    List<WeightHistoryData> history,
    List records,
    BodyCompositionPredictionModel? prediction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // 데이터 추출
    List<_ChartDataPoint> weightData = [];
    List<_ChartDataPoint> muscleData = [];
    List<_ChartDataPoint> bodyFatData = [];

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      final date = record.recordDate as DateTime;
      final label = DateFormat('M/d').format(date);

      if (record.weight != null) {
        weightData.add(_ChartDataPoint(
          date: date,
          value: record.weight as double,
          label: label,
        ));
      }
      if (record.muscleMass != null) {
        muscleData.add(_ChartDataPoint(
          date: date,
          value: record.muscleMass as double,
          label: label,
        ));
      }
      if (record.bodyFatPercent != null) {
        bodyFatData.add(_ChartDataPoint(
          date: date,
          value: record.bodyFatPercent as double,
          label: label,
        ));
      }
    }

    // 날짜 오름차순 정렬 (과거 → 최신)
    weightData.sort((a, b) => a.date.compareTo(b.date));
    muscleData.sort((a, b) => a.date.compareTo(b.date));
    bodyFatData.sort((a, b) => a.date.compareTo(b.date));

    final hasWeight = weightData.length >= 2;
    final hasMuscle = muscleData.length >= 2;
    final hasBodyFat = bodyFatData.length >= 2;

    if (!hasWeight && !hasMuscle && !hasBodyFat) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('표시할 데이터가 부족합니다'),
        ),
      );
    }

    // 최대 길이 계산
    final maxLength = [weightData.length, muscleData.length, bodyFatData.length]
        .reduce((a, b) => a > b ? a : b);

    // Y 범위 계산
    List<double> allValues = [];
    if (hasWeight) allValues.addAll(weightData.map((e) => e.value));
    if (hasMuscle) allValues.addAll(muscleData.map((e) => e.value));
    if (hasBodyFat) allValues.addAll(bodyFatData.map((e) => e.value));

    final minY = allValues.reduce((a, b) => a < b ? a : b) - 5;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 5;

    return Column(
      children: [
        // 범례
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasWeight) _buildLegendItem('체중', AppTheme.primary),
            if (hasMuscle) ...[
              const SizedBox(width: 16),
              _buildLegendItem('골격근량', AppTheme.secondary),
            ],
            if (hasBodyFat) ...[
              const SizedBox(width: 16),
              _buildLegendItem('체지방률', AppTheme.tertiary),
            ],
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= maxLength) return const SizedBox();
                      if (index % 2 != 0 && maxLength > 6) return const SizedBox();

                      // weightData 기준으로 라벨 표시
                      String label = '';
                      if (index < weightData.length) {
                        label = weightData[index].label;
                      } else if (index < muscleData.length) {
                        label = muscleData[index].label;
                      } else if (index < bodyFatData.length) {
                        label = bodyFatData[index].label;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (hasWeight)
                  _buildLineBarData(weightData, AppTheme.primary, colorScheme),
                if (hasMuscle)
                  _buildLineBarData(muscleData, AppTheme.secondary, colorScheme),
                if (hasBodyFat)
                  _buildLineBarData(bodyFatData, AppTheme.tertiary, colorScheme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildLineBarData(
    List<_ChartDataPoint> data,
    Color color,
    ColorScheme colorScheme,
  ) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value.value);
      }).toList(),
      isCurved: true,
      curveSmoothness: 0.3,
      color: color,
      barWidth: 2,
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
    );
  }

  Color _getMetricColor(GraphMetricType metric) {
    return switch (metric) {
      GraphMetricType.weight => AppTheme.primary,
      GraphMetricType.muscle => AppTheme.secondary,
      GraphMetricType.bodyFat => AppTheme.tertiary,
      GraphMetricType.all => AppTheme.primary,
    };
  }

  /// AI 체성분 예측 섹션
  Widget _buildBodyCompositionPredictionSection(
    BuildContext context,
    WidgetRef ref,
    BodyCompositionPredictionState predictionState,
    int recordCount,
  ) {
    return _buildSectionCard(
      context,
      '체성분 예측',
      predictionState.isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          : predictionState.error != null
              ? _buildBodyCompPredictionError(context, ref, predictionState.error!)
              : predictionState.prediction != null
                  ? _buildBodyCompPredictionResult(
                      context, ref, predictionState.prediction!)
                  : _buildBodyCompPredictionEmpty(context, ref, recordCount),
      trailing: _buildBodyCompPredictionButton(context, ref, recordCount),
    );
  }

  /// 체성분 예측 버튼
  Widget _buildBodyCompPredictionButton(
    BuildContext context,
    WidgetRef ref,
    int recordCount,
  ) {
    final canPredict = recordCount >= 4;

    return TextButton.icon(
      onPressed: canPredict
          ? () => _runBodyCompositionPrediction(context, ref)
          : null,
      icon: Icon(
        Icons.auto_graph,
        size: 18,
        color: canPredict ? AppTheme.primary : Colors.grey,
      ),
      label: Text(
        '예측하기',
        style: TextStyle(
          color: canPredict ? AppTheme.primary : Colors.grey,
        ),
      ),
    );
  }

  /// 체성분 예측 실행
  Future<void> _runBodyCompositionPrediction(
    BuildContext context,
    WidgetRef ref,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI가 체성분 변화를 분석 중입니다...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      await ref
          .read(bodyCompositionPredictionProvider.notifier)
          .predictBodyComposition(widget.memberId);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체성분 예측이 완료되었습니다!'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// 체성분 예측 결과 없음 상태
  Widget _buildBodyCompPredictionEmpty(
    BuildContext context,
    WidgetRef ref,
    int recordCount,
  ) {
    final canPredict = recordCount >= 4;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.auto_graph,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            canPredict
                ? '체성분 예측을 실행해보세요\n체중, 골격근량, 체지방률 변화를 예측합니다'
                : '예측을 위해 최소 4개의 기록이 필요합니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (canPredict) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _runBodyCompositionPrediction(context, ref),
              icon: const Icon(Icons.auto_graph),
              label: const Text('예측 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '현재 $recordCount개 기록',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 체성분 예측 에러 상태
  Widget _buildBodyCompPredictionError(
    BuildContext context,
    WidgetRef ref,
    String error,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            error.replaceAll('Exception: ', ''),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _runBodyCompositionPrediction(context, ref),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 체성분 예측 결과 표시
  Widget _buildBodyCompPredictionResult(
    BuildContext context,
    WidgetRef ref,
    BodyCompositionPredictionModel prediction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 예측 결과 카드들
          Row(
            children: [
              if (prediction.weightPrediction != null)
                Expanded(
                  child: _buildMetricPredictionCard(
                    context,
                    '체중',
                    prediction.weightPrediction!,
                    'kg',
                    AppTheme.primary,
                  ),
                ),
              if (prediction.musclePrediction != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricPredictionCard(
                    context,
                    '골격근량',
                    prediction.musclePrediction!,
                    'kg',
                    AppTheme.secondary,
                  ),
                ),
              ],
            ],
          ),
          if (prediction.bodyFatPrediction != null) ...[
            const SizedBox(height: 8),
            _buildMetricPredictionCard(
              context,
              '체지방률',
              prediction.bodyFatPrediction!,
              '%',
              AppTheme.tertiary,
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 16),

          // 신뢰도 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getConfidenceColor(prediction.overallConfidence)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  size: 18,
                  color: _getConfidenceColor(prediction.overallConfidence),
                ),
                const SizedBox(width: 8),
                Text(
                  '예측 신뢰도: ${(prediction.overallConfidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: _getConfidenceColor(prediction.overallConfidence),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _getConfidenceLabel(prediction.overallConfidence),
                  style: TextStyle(
                    color: _getConfidenceColor(prediction.overallConfidence),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 분석 메시지
          if (prediction.analysisMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.analysisMessage,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 예측 정보
          const SizedBox(height: 12),
          Text(
            '데이터 기반: ${prediction.dataPointsUsed.entries.map((e) => '${_getMetricLabel(e.key)} ${e.value}개').join(', ')} | ${DateFormat('M/d HH:mm').format(prediction.createdAt)}',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 지표 예측 카드 빌드
  Widget _buildMetricPredictionCard(
    BuildContext context,
    String label,
    MetricPrediction prediction,
    String unit,
    Color color, {
    bool fullWidth = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = prediction.weeklyTrend > 0;
    final isNeutral = prediction.weeklyTrend.abs() < 0.05;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                isNeutral
                    ? Icons.trending_flat
                    : (isPositive ? Icons.trending_up : Icons.trending_down),
                size: 16,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  prediction.current.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Flexible(
                child: Text(
                  prediction.predicted.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${prediction.change >= 0 ? "▲" : "▼"}${prediction.change.abs().toStringAsFixed(1)}$unit/월',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return AppTheme.secondary;
    if (confidence >= 0.4) return AppTheme.primary;
    return AppTheme.tertiary;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.7) return '높음';
    if (confidence >= 0.4) return '보통';
    return '낮음';
  }

  String _getMetricLabel(String key) {
    return switch (key) {
      'weight' => '체중',
      'skeletalMuscleMass' => '골격근량',
      'bodyFatPercent' => '체지방률',
      _ => key,
    };
  }

  /// 예측 버튼
  Widget _buildPredictionButton(BuildContext context, WidgetRef ref, int recordCount) {
    final canPredict = recordCount >= 4;

    return TextButton.icon(
      onPressed: canPredict
          ? () => _runPrediction(context, ref)
          : null,
      icon: Icon(
        Icons.auto_graph,
        size: 18,
        color: canPredict ? AppTheme.primary : Colors.grey,
      ),
      label: Text(
        '예측하기',
        style: TextStyle(
          color: canPredict ? AppTheme.primary : Colors.grey,
        ),
      ),
    );
  }

  /// 예측 실행
  Future<void> _runPrediction(BuildContext context, WidgetRef ref) async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('AI가 체중 변화를 분석 중입니다...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final service = ref.read(weightPredictionServiceProvider);
      await service.predict(memberId: widget.memberId, weeksAhead: 8);

      // 예측 데이터 갱신
      ref.invalidate(latestPredictionProvider(widget.memberId));

      if (context.mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체중 예측이 완료되었습니다!'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  /// 예측 결과 없음 상태
  Widget _buildPredictionEmpty(BuildContext context, WidgetRef ref, int recordCount) {
    final canPredict = recordCount >= 4;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.auto_graph,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            canPredict
                ? 'AI 체중 예측을 실행해보세요'
                : '예측을 위해 최소 4개의 기록이 필요합니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (canPredict) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _runPrediction(context, ref),
              icon: const Icon(Icons.auto_graph),
              label: const Text('예측 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '현재 $recordCount개 기록',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 예측 에러 상태
  Widget _buildPredictionError(BuildContext context, WidgetRef ref, String error) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            error.replaceAll('Exception: ', ''),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _runPrediction(context, ref),
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 예측 결과 표시
  Widget _buildPredictionResult(BuildContext context, WidgetRef ref, dynamic prediction) {
    final isLosing = prediction.weeklyTrend < 0;
    final isMaintaining = prediction.weeklyTrend.abs() < 0.1;
    final trendColor = isLosing
        ? AppTheme.secondary
        : (isMaintaining ? Colors.blue : AppTheme.tertiary);
    final trendIcon = isLosing
        ? Icons.trending_down
        : (isMaintaining ? Icons.trending_flat : Icons.trending_up);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 주간 변화 트렌드
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(trendIcon, color: trendColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '주간 변화',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${prediction.change >= 0 ? "▲" : "▼"}${prediction.change.abs().toStringAsFixed(1)} kg/월',
                    style: TextStyle(
                      color: trendColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // 신뢰도
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '신뢰도',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${(prediction.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 목표 도달 예상
          if (prediction.estimatedWeeksToTarget != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '목표 도달 예상: 약 ${prediction.estimatedWeeksToTarget}주 후',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 분석 메시지
          if (prediction.analysisMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      prediction.analysisMessage,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 예측 정보
          const SizedBox(height: 12),
          Text(
            '데이터 ${prediction.dataPointsUsed}개 기반 예측 • ${DateFormat('M/d HH:mm').format(prediction.createdAt)}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildCurrentStatus(dynamic record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '현재 체중',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                DateFormat('yyyy.MM.dd').format(record.recordDate),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // AnimatedDoubleCounter로 체중 애니메이션
              AnimatedDoubleCounter(
                value: record.weight,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 4),
                child: Text(
                  'kg',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),
            ],
          ),
          if (record.bodyFatPercent != null || record.muscleMass != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                if (record.bodyFatPercent != null)
                  _buildAnimatedStatusItem('체지방률', record.bodyFatPercent, '%'),
                if (record.muscleMass != null) ...[
                  const SizedBox(width: 24),
                  _buildAnimatedStatusItem('골격근량', record.muscleMass, 'kg'),
                ],
              ],
            ),
          ],
        ],
      ),
    ).animateSlideDown();
  }

  /// 애니메이션이 적용된 상태 아이템
  Widget _buildAnimatedStatusItem(String label, double value, String suffix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        AnimatedDoubleCounter(
          value: value,
          suffix: suffix,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    Widget child, {
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  /// 기록 히스토리 빌드
  Widget _buildRecordHistory(BuildContext context, WidgetRef ref, List<BodyRecordModel> records) {
    final theme = Theme.of(context);

    return _buildSectionCard(
      context,
      '기록 히스토리',
      Column(
        children: [
          Text(
            '총 ${records.length}개',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          ...records.asMap().entries.take(10).map((entry) {
            final index = entry.key;
            final record = entry.value;
            return _BodyRecordCard(
              record: record,
              index: index,
              memberId: widget.memberId,
            );
          }),
          if (records.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... 외 ${records.length - 10}개',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 체성분 기록 카드 (회원앱과 동일한 UI)
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
                        DateFormat('yyyy.MM.dd HH:mm').format(record.createdAt),
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

// ============================================================================
// Curriculum Tab
// ============================================================================

/// 서명 Provider - 특정 커리큘럼의 서명 조회
final signatureByCurriculumProvider =
    StreamProvider.family<SessionSignatureModel?, String>((ref, curriculumId) {
  final repo = ref.watch(sessionSignatureRepositoryProvider);
  return repo.watchByCurriculumId(curriculumId);
});

class _CurriculumTab extends ConsumerWidget {
  final String memberId;

  const _CurriculumTab({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final curriculumsAsync = ref.watch(curriculumsProvider(memberId));
    final statsAsync = ref.watch(curriculumStatsProvider(memberId));

    return curriculumsAsync.when(
      loading: () => _buildShimmerLoading(context),
      error: (error, _) => _buildErrorView(context, ref, error),
      data: (curriculums) {
        if (curriculums.isEmpty) {
          return _buildEmptyView(context);
        }
        return _buildCurriculumContent(context, ref, curriculums, statsAsync);
      },
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, Object error) {
    return ErrorState.fromError(
      error,
      onRetry: () => ref.invalidate(curriculumsProvider(memberId)),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return EmptyState(
      type: EmptyStateType.curriculums,
      onAction: () => context.go('/trainer/curriculum/create?memberId=$memberId'),
    );
  }

  Widget _buildCurriculumContent(
    BuildContext context,
    WidgetRef ref,
    List<CurriculumModel> curriculums,
    AsyncValue<CurriculumStats> statsAsync,
  ) {
    // 첫 번째 커리큘럼에서 trainerId 가져오기
    final trainerId = curriculums.isNotEmpty ? curriculums.first.trainerId : '';

    return Column(
      children: [
        // 진행률 헤더
        statsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
          data: (stats) => _buildStatsHeader(stats),
        ),

        // 커리큘럼 목록 - 스태거 애니메이션 적용
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: curriculums.length,
            itemBuilder: (context, index) {
              final curriculum = curriculums[index];
              return _CurriculumCard(
                curriculum: curriculum,
                memberId: memberId,
                trainerId: trainerId,
                onToggleComplete: () async {
                  final notifier = ref.read(curriculumsNotifierProvider.notifier);
                  if (curriculum.isCompleted) {
                    await notifier.markAsIncomplete(curriculum.id);
                  } else {
                    await notifier.markAsCompleted(curriculum.id);
                  }
                },
              ).animate()
                .fadeIn(delay: Duration(milliseconds: index * 80), duration: 300.ms)
                .slideY(begin: 0.03, duration: 300.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(CurriculumStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.secondary, AppTheme.secondary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '커리큘럼 진행률',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // AnimatedCounter로 숫자 애니메이션 적용
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCounter(
                      value: stats.completed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' / ${stats.total} 완료',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // AnimatedProgressBar를 원형으로 대체 (TweenAnimationBuilder 사용)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: stats.progressRate),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: animatedProgress,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '${(animatedProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animateSlideDown();
  }
}

class _CurriculumCard extends ConsumerWidget {
  final CurriculumModel curriculum;
  final String memberId;
  final String trainerId;
  final VoidCallback onToggleComplete;

  const _CurriculumCard({
    required this.curriculum,
    required this.memberId,
    required this.trainerId,
    required this.onToggleComplete,
  });

  /// 커리큘럼 제목 수정 다이얼로그
  Future<void> _showEditTitleDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: curriculum.title);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('커리큘럼 제목 수정'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '제목',
            hintText: '예: 상체 운동',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != curriculum.title) {
      final repo = ref.read(curriculumRepositoryProvider);
      await repo.update(curriculum.id, {'title': result});
      ref.invalidate(curriculumsProvider(memberId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목이 수정되었습니다')),
        );
      }
    }
  }

  /// 운동 수정 다이얼로그
  Future<void> _showEditExerciseDialog(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
    int index,
  ) async {
    final nameController = TextEditingController(text: exercise.name);
    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps.toString());
    final weightController =
        TextEditingController(text: exercise.weight?.toString() ?? '');
    final noteController = TextEditingController(text: exercise.note ?? '');

    final result = await showDialog<Exercise?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 수정'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '운동명',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: '세트',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: '횟수',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '중량 (kg, 선택)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('운동명을 입력해주세요')),
                );
                return;
              }
              Navigator.pop(
                context,
                Exercise(
                  name: name,
                  sets: int.tryParse(setsController.text) ?? 3,
                  reps: int.tryParse(repsController.text) ?? 10,
                  weight: double.tryParse(weightController.text),
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                ),
              );
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (result != null) {
      final exercises = List<Exercise>.from(curriculum.exercises);
      exercises[index] = result;
      final repo = ref.read(curriculumRepositoryProvider);
      await repo.updateExercises(curriculum.id, exercises);
      ref.invalidate(curriculumsProvider(memberId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동이 수정되었습니다')),
        );
      }
    }
  }

  /// 운동 추가 다이얼로그
  Future<void> _showAddExerciseDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController();
    final noteController = TextEditingController();

    final result = await showDialog<Exercise?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '운동명',
                  hintText: '예: 벤치프레스',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        labelText: '세트',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: '횟수',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: '중량 (kg, 선택)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '메모 (선택)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('운동명을 입력해주세요')),
                );
                return;
              }
              Navigator.pop(
                context,
                Exercise(
                  name: name,
                  sets: int.tryParse(setsController.text) ?? 3,
                  reps: int.tryParse(repsController.text) ?? 10,
                  weight: double.tryParse(weightController.text),
                  note: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                ),
              );
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (result != null) {
      final exercises = List<Exercise>.from(curriculum.exercises)..add(result);
      final repo = ref.read(curriculumRepositoryProvider);
      await repo.updateExercises(curriculum.id, exercises);
      ref.invalidate(curriculumsProvider(memberId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동이 추가되었습니다')),
        );
      }
    }
  }

  /// 운동 삭제 확인 다이얼로그
  Future<void> _showDeleteExerciseDialog(
    BuildContext context,
    WidgetRef ref,
    int index,
  ) async {
    final exercise = curriculum.exercises[index];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 삭제'),
        content: Text("'${exercise.name}'을(를) 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final exercises = List<Exercise>.from(curriculum.exercises)..removeAt(index);
      final repo = ref.read(curriculumRepositoryProvider);
      await repo.updateExercises(curriculum.id, exercises);
      ref.invalidate(curriculumsProvider(memberId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동이 삭제되었습니다')),
        );
      }
    }
  }

  /// 수정 옵션 바텀시트
  void _showEditOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(sheetContext).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${curriculum.sessionNumber}회차 수정',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: Colors.grey[500]),
                title: const Text('제목 수정'),
                subtitle: Text(curriculum.title),
                onTap: () {
                  Navigator.pop(context);
                  _showEditTitleDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: AppTheme.secondary),
                title: const Text('운동 추가'),
                subtitle: const Text('새로운 운동을 추가합니다'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddExerciseDialog(context, ref);
                },
              ),
              if (curriculum.exercises.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: AppTheme.tertiary),
                  title: const Text('운동 수정/삭제'),
                  subtitle: Text('${curriculum.exercises.length}개 운동'),
                  onTap: () {
                    Navigator.pop(context);
                    _showExerciseListDialog(context, ref);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 운동 목록 관리 다이얼로그
  void _showExerciseListDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 관리'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: curriculum.exercises.length,
            itemBuilder: (context, index) {
              final exercise = curriculum.exercises[index];
              return ListTile(
                title: Text(exercise.name),
                subtitle: Text('${exercise.sets}세트 x ${exercise.reps}회'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 20, color: Colors.grey[500]),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditExerciseDialog(context, ref, exercise, index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20, color: Colors.grey[500]),
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteExerciseDialog(context, ref, index);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = curriculum.isCompleted;
    final signatureAsync = ref.watch(signatureByCurriculumProvider(curriculum.id));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !isCompleted
              ? AppTheme.primary.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB)),
          width: !isCompleted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.secondary.withValues(alpha: 0.1)
                : AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppTheme.secondary)
                : Text(
                    '${curriculum.sessionNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
          ),
        ),
        title: Text(
          // sessionNumber를 기반으로 타이틀 생성 (기존 title에서 부위만 추출)
          '${curriculum.sessionNumber}회차${curriculum.title.replaceAll(RegExp(r'^\d+회차'), '')}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Theme.of(context).colorScheme.outline : null,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${curriculum.sessionNumber}회차',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.secondary.withValues(alpha: 0.1)
                    : AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isCompleted ? '완료' : '진행중',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isCompleted ? AppTheme.secondary : AppTheme.primary,
                ),
              ),
            ),
            if (curriculum.isAiGenerated) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tertiary,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.outline),
          onPressed: () => _showEditOptions(context, ref),
          tooltip: '수정',
        ),
        children: [
          // 운동 목록
          if (curriculum.exercises.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: curriculum.exercises.map((exercise) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.fitness_center,
                            size: 16, color: AppTheme.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercise.summary,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '운동 목록이 없습니다',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),

          // 수업 완료 / 서명 보기 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: signatureAsync.when(
              loading: () => const SizedBox(
                height: 40,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, st) => const SizedBox.shrink(),
              data: (signature) {
                if (isCompleted && signature != null) {
                  // 완료된 회차 - 서명 보기 버튼
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        SignatureViewDialog.show(context, signature: signature);
                      },
                      icon: const Icon(Icons.draw_outlined, size: 18),
                      label: const Text('서명 보기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        side: const BorderSide(color: AppTheme.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                } else if (!isCompleted) {
                  // 미완료 회차 - 수업 완료 버튼
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await SessionCompleteDialog.show(
                          context,
                          curriculum: curriculum,
                          memberId: memberId,
                          trainerId: trainerId,
                        );
                        if (result == true) {
                          // 성공 시 provider 갱신 (다이얼로그에서 이미 처리됨)
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('수업 완료'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  );
                } else {
                  // 완료됐지만 서명이 없는 경우 (기존 데이터)
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onToggleComplete,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('완료 취소'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Memo Tab
// ============================================================================

class _MemoTab extends ConsumerStatefulWidget {
  final String memberId;
  final MemberModel member;

  const _MemoTab({required this.memberId, required this.member});

  @override
  ConsumerState<_MemoTab> createState() => _MemoTabState();
}

class _MemoTabState extends ConsumerState<_MemoTab> {
  late TextEditingController _memoController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.member.memo ?? '');
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메모 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.note_outlined, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Text(
                          '트레이너 메모',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (!_isEditing)
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.grey[500]),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                  ],
                ),
                const Divider(height: 24),
                if (_isEditing) _buildEditMode() else _buildViewMode(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 안내 문구
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surface
                      : AppTheme.primary.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3B5E) : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '회원의 부상 이력, 주의사항, 운동 제한 등을 기록해두세요.',
                        style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final memo = widget.member.memo;
    if (memo == null || memo.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.note_add_outlined, size: 48, color: Theme.of(context).colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              '메모가 없습니다',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.add),
              label: const Text('메모 추가'),
            ),
          ],
        ),
      );
    }

    return Text(
      memo,
      style: const TextStyle(fontSize: 15, height: 1.6),
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        TextField(
          controller: _memoController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '회원에 대한 메모를 입력하세요...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      _memoController.text = widget.member.memo ?? '';
                      setState(() => _isEditing = false);
                    },
              child: const Text('취소'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveMemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('저장'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveMemo() async {
    setState(() => _isSaving = true);

    try {
      await ref
          .read(membersNotifierProvider.notifier)
          .updateMemo(widget.memberId, _memoController.text);

      // Provider 무효화하여 데이터 새로고침
      ref.invalidate(memberDetailProvider(widget.memberId));
      ref.invalidate(membersProvider);

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('메모가 저장되었습니다'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}

// ============================================================================
// 인바디 탭
// ============================================================================

/// 인바디 탭 위젯
class _InbodyTab extends ConsumerWidget {
  final String memberId;

  const _InbodyTab({required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestAsync = ref.watch(latestInbodyProvider(memberId));
    final historyAsync = ref.watch(inbodyHistoryProvider(memberId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(latestInbodyProvider(memberId));
        ref.invalidate(inbodyHistoryProvider(memberId));
      },
      child: latestAsync.when(
        loading: () => const _InbodyTabSkeleton(),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다\n$e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(latestInbodyProvider(memberId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (latest) {
          if (latest == null) {
            return _buildEmptyState(context, ref, colorScheme);
          }
          return _buildContent(context, ref, latest, historyAsync, colorScheme);
        },
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
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
            '회원이 인바디 결과지를 촬영하면 여기에 표시됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.construction,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '인바디 연동 기능 추가 예정',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
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
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최신 인바디 결과 카드
          _InbodyResultCardCompact(record: latest)
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // 체성분 도넛 차트
          _InbodyPieChartCard(record: latest)
              .animate()
              .fadeIn(duration: 300.ms, delay: 100.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 16),

          // 히스토리 그래프
          historyAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, st) => const SizedBox.shrink(),
            data: (history) {
              if (history.length < 2) {
                return const SizedBox.shrink();
              }
              return _InbodyLineChartCard(records: history)
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),

          const SizedBox(height: 16),

          // 히스토리 리스트
          _buildHistorySection(context, ref, historyAsync),

          const SizedBox(height: 16),
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
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '측정 기록',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
                return _InbodyHistoryListTile(
                  record: record,
                  colorScheme: colorScheme,
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

/// 인바디 결과 카드 (컴팩트 버전)
class _InbodyResultCardCompact extends StatelessWidget {
  final InbodyRecordModel record;

  const _InbodyResultCardCompact({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '최근 측정',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatDate(record.measuredAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(context, '체중', '${record.weight.toStringAsFixed(1)}kg',
                    colorScheme.primary),
                _buildMetric(context, '골격근량',
                    '${record.skeletalMuscleMass.toStringAsFixed(1)}kg', Colors.green),
                _buildMetric(context, '체지방률',
                    '${record.bodyFatPercent.toStringAsFixed(1)}%', Colors.orange),
              ],
            ),
            if (record.inbodyScore != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 4),
                  Text('인바디 점수 ', style: theme.textTheme.bodySmall),
                  Text(
                    '${record.inbodyScore}점',
                    style: theme.textTheme.titleSmall?.copyWith(
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

  Widget _buildMetric(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 체성분 도넛 차트 카드
class _InbodyPieChartCard extends StatelessWidget {
  final InbodyRecordModel record;

  const _InbodyPieChartCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalWeight = record.weight;
    final fatMass =
        record.bodyFatMass ?? (totalWeight * record.bodyFatPercent / 100);
    final muscleMass = record.skeletalMuscleMass;
    final otherMass = totalWeight - fatMass - muscleMass;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '체성분 분석',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: muscleMass,
                            title: '',
                            color: Colors.green,
                            radius: 40,
                          ),
                          PieChartSectionData(
                            value: fatMass,
                            title: '',
                            color: Colors.orange,
                            radius: 40,
                          ),
                          PieChartSectionData(
                            value: otherMass > 0 ? otherMass : 0,
                            title: '',
                            color: Colors.blue,
                            radius: 40,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegend('골격근량', '${muscleMass.toStringAsFixed(1)}kg',
                          Colors.green),
                      const SizedBox(height: 8),
                      _buildLegend(
                          '체지방량', '${fatMass.toStringAsFixed(1)}kg', Colors.orange),
                      const SizedBox(height: 8),
                      _buildLegend(
                          '기타', '${otherMass.toStringAsFixed(1)}kg', Colors.blue),
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

  Widget _buildLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

/// 히스토리 라인 차트 카드
class _InbodyLineChartCard extends StatelessWidget {
  final List<InbodyRecordModel> records;

  const _InbodyLineChartCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sortedRecords = List<InbodyRecordModel>.from(records)
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final displayRecords = sortedRecords.length > 8
        ? sortedRecords.sublist(sortedRecords.length - 8)
        : sortedRecords;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '변화 추이',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChartLegend('체중', colorScheme.primary),
                const SizedBox(width: 12),
                _buildChartLegend('골격근량', Colors.green),
                const SizedBox(width: 12),
                _buildChartLegend('체지방률', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
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
                    leftTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                fontSize: 9,
                                color:
                                    colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        interval: 1,
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.weight);
                      }).toList(),
                      isCurved: true,
                      color: colorScheme.primary,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(
                            e.key.toDouble(), e.value.skeletalMuscleMass);
                      }).toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 2,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: displayRecords.asMap().entries.map((e) {
                        return FlSpot(e.key.toDouble(), e.value.bodyFatPercent);
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
          width: 10,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

/// 히스토리 리스트 타일
class _InbodyHistoryListTile extends StatelessWidget {
  final InbodyRecordModel record;
  final ColorScheme colorScheme;
  final VoidCallback onDelete;

  const _InbodyHistoryListTile({
    required this.record,
    required this.colorScheme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${record.measuredAt.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${record.measuredAt.month}월',
                style: TextStyle(
                  fontSize: 9,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '${record.weight.toStringAsFixed(1)}kg',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '골격근 ${record.skeletalMuscleMass.toStringAsFixed(1)}kg · '
          '체지방 ${record.bodyFatPercent.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record.imageUrl != null && record.imageUrl!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.photo_outlined, size: 18),
                onPressed: () => _showImageDialog(context, record.imageUrl!),
                color: colorScheme.primary,
                tooltip: '인바디 결과지 보기',
              ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: Colors.grey[500]),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('인바디 결과지'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48),
                        SizedBox(height: 8),
                        Text('이미지를 불러올 수 없습니다'),
                      ],
                    ),
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

/// 인바디 탭 스켈레톤 로딩
class _InbodyTabSkeleton extends StatelessWidget {
  const _InbodyTabSkeleton();

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
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
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
}

// ============================================================================
// Helper Classes
// ============================================================================

/// 차트 데이터 포인트 헬퍼 클래스
class _ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;

  const _ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
  });
}

// ============================================================================
// 회원 정보 수정 다이얼로그
// ============================================================================

class _EditMemberDialog extends ConsumerStatefulWidget {
  final String memberId;
  final MemberModel member;
  final UserModel? user;
  final VoidCallback onSaved;

  const _EditMemberDialog({
    required this.memberId,
    required this.member,
    this.user,
    required this.onSaved,
  });

  @override
  ConsumerState<_EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends ConsumerState<_EditMemberDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _totalSessionsController;
  late TextEditingController _completedSessionsController;
  late TextEditingController _targetWeightController;
  late String _selectedGoal;
  late String _selectedExperience;
  bool _isSaving = false;

  final _goals = ['체력 향상', '다이어트', '근력 증가', '재활', '기타'];
  final _experiences = ['입문', '초급', '중급', '고급'];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _totalSessionsController = TextEditingController(
      text: widget.member.ptInfo.totalSessions.toString(),
    );
    _completedSessionsController = TextEditingController(
      text: widget.member.ptInfo.completedSessions.toString(),
    );
    _targetWeightController = TextEditingController(
      text: widget.member.targetWeight?.toString() ?? '',
    );
    _selectedGoal = widget.member.goalLabel;
    _selectedExperience = widget.member.experienceLabel;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _totalSessionsController.dispose();
    _completedSessionsController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.edit_outlined, color: colorScheme.primary),
          const SizedBox(width: 8),
          const Text('회원 정보 수정'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 기본 정보 섹션
              _buildSectionTitle('기본 정보'),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '연락처',
                  hintText: '010-0000-0000',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // PT 정보 섹션
              _buildSectionTitle('PT 정보'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _goals.contains(_selectedGoal) ? _selectedGoal : _goals.first,
                decoration: const InputDecoration(
                  labelText: '운동 목표',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _goals.map((goal) {
                  return DropdownMenuItem(value: goal, child: Text(goal));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedGoal = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _experiences.contains(_selectedExperience)
                    ? _selectedExperience
                    : _experiences.first,
                decoration: const InputDecoration(
                  labelText: '운동 경력',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: OutlineInputBorder(),
                ),
                items: _experiences.map((exp) {
                  return DropdownMenuItem(value: exp, child: Text(exp));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedExperience = value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _totalSessionsController,
                      decoration: const InputDecoration(
                        labelText: '총 회차',
                        suffixText: '회',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _completedSessionsController,
                      decoration: const InputDecoration(
                        labelText: '완료 회차',
                        suffixText: '회',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: '목표 체중 (선택)',
                  suffixText: 'kg',
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveChanges,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('저장'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final totalSessions = int.tryParse(_totalSessionsController.text) ??
          widget.member.ptInfo.totalSessions;
      final completedSessions = int.tryParse(_completedSessionsController.text) ??
          widget.member.ptInfo.completedSessions;
      final targetWeight = double.tryParse(_targetWeightController.text);

      // goal 문자열을 enum으로 변환
      String goalValue;
      switch (_selectedGoal) {
        case '다이어트':
          goalValue = 'diet';
          break;
        case '근력 증가':
          goalValue = 'bulk';
          break;
        case '재활':
          goalValue = 'rehab';
          break;
        case '체력 향상':
        default:
          goalValue = 'fitness';
      }

      // experience 문자열을 enum으로 변환
      String experienceValue;
      switch (_selectedExperience) {
        case '중급':
          experienceValue = 'intermediate';
          break;
        case '고급':
          experienceValue = 'advanced';
          break;
        case '입문':
        case '초급':
        default:
          experienceValue = 'beginner';
      }

      // 회원 정보 업데이트 (Map으로 변환)
      final updates = <String, dynamic>{
        'goal': goalValue,
        'experience': experienceValue,
        'ptInfo': {
          'totalSessions': totalSessions,
          'completedSessions': completedSessions,
          'startDate': widget.member.ptInfo.startDate,
        },
      };
      if (targetWeight != null) {
        updates['targetWeight'] = targetWeight;
      }

      await ref
          .read(membersNotifierProvider.notifier)
          .updateMember(widget.memberId, updates);

      // 연락처 업데이트 (User 모델)
      if (widget.user != null && _phoneController.text != widget.user!.phone) {
        final userRepository = ref.read(userRepositoryProvider);
        await userRepository.update(
          widget.user!.uid,
          {'phone': _phoneController.text},
        );
      }

      widget.onSaved();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원 정보가 수정되었습니다'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('수정 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
