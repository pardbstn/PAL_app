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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(memberName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/trainer/members'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '정보 수정',
              onPressed: () => _showEditMemberDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: '회원 삭제',
              onPressed: () => _showDeleteMemberDialog(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: '기본정보'),
              Tab(text: '그래프'),
              Tab(text: '커리큘럼'),
              Tab(text: '메모'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoTab(member: widget.member, user: widget.user),
            _GraphTab(memberId: widget.memberId, member: widget.member),
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
      builder: (context) => AlertDialog(
        title: const Text('회원 정보 수정'),
        content: const Text('회원 정보 수정 기능은 준비 중입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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

class _GraphTab extends ConsumerWidget {
  final String memberId;
  final MemberModel member;

  const _GraphTab({required this.memberId, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyRecordsAsync = ref.watch(bodyRecordsProvider(memberId));
    final weightHistoryAsync = ref.watch(weightHistoryProvider(memberId));
    final latestRecordAsync = ref.watch(latestBodyRecordProvider(memberId));
    final predictionAsync = ref.watch(latestPredictionProvider(memberId));

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
            );
          },
        ),
        // FAB - 기록 추가 버튼
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => AddBodyRecordSheet.show(context, memberId),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('기록 추가'),
          ),
        ),
      ],
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
      onRetry: () => ref.invalidate(bodyRecordsProvider(memberId)),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return EmptyState(
      type: EmptyStateType.bodyRecords,
      onAction: () => AddBodyRecordSheet.show(context, memberId),
    );
  }

  Widget _buildGraphContent(
    BuildContext context,
    WidgetRef ref,
    List records,
    AsyncValue<List<WeightHistoryData>> weightHistoryAsync,
    AsyncValue<dynamic> latestRecordAsync,
    AsyncValue<dynamic> predictionAsync,
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
            error: (_, __) => const SizedBox.shrink(),
            data: (record) {
              if (record == null) return const SizedBox.shrink();
              return _buildCurrentStatus(record);
            },
          ),
          const SizedBox(height: 24),

          // 목표 달성률
          if (member.targetWeight != null)
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
                      targetValue: member.targetWeight!,
                      startValue: history.first.weight,
                      label: member.goalLabel,
                      unit: 'kg',
                      isDecreaseGoal: member.goal == FitnessGoal.diet,
                    );
                  },
                ),
              );
            }).value ??
                const SizedBox.shrink(),
          const SizedBox(height: 24),

          // 체중 변화 그래프 (예측 포함)
          _buildSectionCard(
            context,
            '체중 변화',
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

                final weightData = history.map((h) {
                  return WeightData(
                    label: DateFormat('M/d').format(h.date),
                    weight: h.weight,
                  );
                }).toList();

                final targetWeight =
                    member.targetWeight ?? history.last.weight - 5;

                return WeightLineChart(
                  actualData: weightData,
                  predictedData: predictedData,
                  targetWeight: targetWeight,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // AI 체중 예측 섹션
          _buildPredictionSection(context, ref, predictionAsync, records.length),
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
        ],
      ),
    );
  }

  /// AI 체중 예측 섹션
  Widget _buildPredictionSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<dynamic> predictionAsync,
    int recordCount,
  ) {
    return _buildSectionCard(
      context,
      'AI 체중 예측',
      predictionAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, _) => _buildPredictionError(context, ref, error.toString()),
        data: (prediction) {
          if (prediction == null) {
            return _buildPredictionEmpty(context, ref, recordCount);
          }
          return _buildPredictionResult(context, ref, prediction);
        },
      ),
      trailing: _buildPredictionButton(context, ref, recordCount),
    );
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
      await service.predict(memberId: memberId, weeksAhead: 8);

      // 예측 데이터 갱신
      ref.invalidate(latestPredictionProvider(memberId));

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
              '현재 ${recordCount}개 기록',
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
                    '${prediction.weeklyTrend > 0 ? '+' : ''}${prediction.weeklyTrend.toStringAsFixed(2)} kg/주',
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
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
              ).animateListItem(index);
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
                leading: const Icon(Icons.edit_outlined, color: AppTheme.primary),
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
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showEditExerciseDialog(context, ref, exercise, index);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: !isCompleted
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
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
          curriculum.title,
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
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
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
                        icon: const Icon(Icons.edit_outlined),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '회원의 부상 이력, 주의사항, 운동 제한 등을 기록해두세요.',
                    style: TextStyle(fontSize: 13, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
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
