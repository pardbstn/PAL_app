import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_template_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculum_generator_v2_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculums_provider.dart';
import 'package:flutter_pal_app/presentation/providers/exercise_search_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/exercise_card_widget.dart';

/// AI 커리큘럼 결과 화면
class CurriculumResultScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? memberName;
  final CurriculumSettings? settings;
  final List<String> excludedExerciseIds;
  /// 추가 생성 모드 여부
  final bool isAdditionalMode;
  /// 추가 생성 시 시작 회차 번호
  final int? startSession;
  /// 템플릿에서 불러온 세션들
  final List<TemplateSession>? templateSessions;
  /// 템플릿에서 불러온 경우
  final bool isFromTemplate;
  /// 템플릿 이름
  final String? templateName;

  const CurriculumResultScreen({
    super.key,
    this.memberId,
    this.memberName,
    this.settings,
    this.excludedExerciseIds = const [],
    this.isAdditionalMode = false,
    this.startSession,
    this.templateSessions,
    this.isFromTemplate = false,
    this.templateName,
  });

  @override
  ConsumerState<CurriculumResultScreen> createState() =>
      _CurriculumResultScreenState();
}

class _CurriculumResultScreenState
    extends ConsumerState<CurriculumResultScreen> {
  bool _hasGenerated = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.templateSessions != null && widget.templateSessions!.isNotEmpty) {
        // 템플릿에서 불러온 경우 바로 상태에 설정
        _loadFromTemplate();
      } else {
        _startGeneration();
      }
    });
  }

  Future<void> _loadFromTemplate() async {
    if (_hasGenerated) return;
    _hasGenerated = true;

    final notifier = ref.read(curriculumGeneratorV2Provider.notifier);
    notifier.setFromTemplateSessions(widget.templateSessions!);
  }

  Future<void> _startGeneration() async {
    if (_hasGenerated) return;
    _hasGenerated = true;

    final notifier = ref.read(curriculumGeneratorV2Provider.notifier);
    final settings = widget.settings ?? const CurriculumSettings();

    await notifier.generate(
      memberId: widget.memberId ?? '',
      settings: settings,
      excludedExerciseIds: widget.excludedExerciseIds,
    );
  }

  Future<void> _saveAsTemplate() async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('템플릿 저장'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: '템플릿 이름을 입력해주세요',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty || !mounted) return;

    try {
      final state = ref.read(curriculumGeneratorV2Provider);
      final authState = ref.read(authProvider);
      final trainerId = authState.trainerModel?.id ?? authState.userId ?? '';

      final sessions = <Map<String, dynamic>>[];
      for (int i = 0; i < state.sessions.length; i++) {
        sessions.add({
          'sessionNumber': i + 1,
          'title': '${i + 1}회차',
          'exercises': state.sessions[i].map((e) => e.toJson()).toList(),
        });
      }

      await FirebaseFirestore.instance.collection('curriculum_templates').add({
        'trainerId': trainerId,
        'name': name.trim(),
        'sessionCount': state.sessionCount,
        'sessions': sessions,
        'settings': widget.settings?.toJson(),
        'usageCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${name.trim()}' 템플릿이 저장됐어요."),
            backgroundColor: const Color(0xFF00C471),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('템플릿 저장에 실패했어요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveCurriculum() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final generatorNotifier = ref.read(curriculumGeneratorV2Provider.notifier);
    final settings = widget.settings ?? const CurriculumSettings();
    final authState = ref.read(authProvider);
    final memberId = widget.memberId ?? '';
    final trainerId = authState.userId ?? '';

    bool success = false;

    try {
      if (widget.isAdditionalMode && widget.startSession != null) {
        // 추가 생성 모드: addAdditionalSessions 사용
        final state = ref.read(curriculumGeneratorV2Provider);
        final now = DateTime.now();

        // AI로 생성된 커리큘럼 목록 생성
        final curriculums = <CurriculumModel>[];
        for (int i = 0; i < state.sessions.length; i++) {
          curriculums.add(CurriculumModel(
            id: '',
            memberId: memberId,
            trainerId: trainerId,
            sessionNumber: widget.startSession! + i,
            title: '${widget.startSession! + i}회차',
            exercises: state.sessions[i],
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ));
        }

        // addAdditionalSessions로 저장 (회원 totalSessions도 업데이트됨)
        await ref.read(curriculumsNotifierProvider.notifier).addAdditionalSessions(
          memberId: memberId,
          trainerId: trainerId,
          additionalSessions: state.sessions.length,
          curriculums: curriculums,
        );
        success = true;
      } else {
        // 일반 모드: 기존 방식 사용
        success = await generatorNotifier.saveAllCurriculums(
          memberId: memberId,
          trainerId: trainerId,
          settings: settings,
        );
      }
    } catch (e) {
      success = false;
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      final sessionCount = widget.isAdditionalMode
          ? ref.read(curriculumGeneratorV2Provider).sessions.length
          : ref.read(curriculumGeneratorV2Provider).sessionCount;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isAdditionalMode
              ? '$sessionCount회차 커리큘럼이 추가됐어요!'
              : '$sessionCount회차 커리큘럼이 저장됐어요!'),
          backgroundColor: const Color(0xFF00C471),
        ),
      );
      // 회원 상세 화면의 커리큘럼 탭으로 이동 (memberId가 있으면 해당 회원으로, 없으면 홈으로)
      if (memberId.isNotEmpty) {
        context.go('/trainer/members/$memberId?tab=3'); // 커리큘럼 탭 (index 3)
      } else {
        context.go('/trainer');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했어요. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAlternatives(int index) {
    final state = ref.read(curriculumGeneratorV2Provider);
    if (index >= state.currentExercises.length) return;

    final exercise = state.currentExercises[index];
    if (exercise.exerciseId == null || exercise.exerciseId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운동 ID가 없어서 대체할 수 없어요.')),
      );
      return;
    }

    final currentIds = state.currentExercises
        .where((e) => e.exerciseId != null)
        .map((e) => e.exerciseId!)
        .toList();

    final request = AlternativeRequest(
      exerciseId: exercise.exerciseId!,
      excludedIds: currentIds,
    );

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) => _AlternativesBottomSheet(
        request: request,
        currentExercise: exercise,
        onSelect: (alternative) {
          ref.read(curriculumGeneratorV2Provider.notifier).replaceExercise(
            index,
            Exercise(
              name: alternative.name,
              sets: exercise.sets,
              reps: exercise.reps,
              restSeconds: exercise.restSeconds,
              exerciseId: alternative.exerciseId,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => _AddExerciseBottomSheet(
        onAdd: (exercise) {
          ref.read(curriculumGeneratorV2Provider.notifier).addExercise(exercise);
          Navigator.pop(context);
        },
        settings: widget.settings ?? const CurriculumSettings(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF00C471);
    final state = ref.watch(curriculumGeneratorV2Provider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.memberName != null
              ? '${widget.memberName} 커리큘럼'
              : 'AI 커리큘럼',
        ),
        actions: [
          if (state.status == CurriculumGeneratorStatus.generated)
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: '템플릿으로 저장',
              onPressed: _saveAsTemplate,
            ),
          if (state.status == CurriculumGeneratorStatus.generated)
            TextButton(
              onPressed: () {
                ref.read(curriculumGeneratorV2Provider.notifier).reset();
                if (context.canPop()) {
                  context.pop();
                } else {
                  // 설정 화면으로 다시 이동
                  context.go('/trainer/curriculum/create${widget.memberId != null ? '?memberId=${widget.memberId}' : ''}');
                }
              },
              child: const Text(
                '다시 설정',
                style: TextStyle(color: emerald),
              ),
            ),
        ],
      ),
      body: _buildBody(theme, state, emerald),
      bottomNavigationBar: state.status == CurriculumGeneratorStatus.generated
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveCurriculum,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 20),
                    label: Text(
                      state.sessionCount > 1
                          ? '전체 ${state.sessionCount}회차 확정'
                          : '커리큘럼 확정',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emerald,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(
    ThemeData theme,
    CurriculumGeneratorV2State state,
    Color emerald,
  ) {
    switch (state.status) {
      case CurriculumGeneratorStatus.idle:
      case CurriculumGeneratorStatus.loading:
        return _buildLoading(theme, emerald);
      case CurriculumGeneratorStatus.error:
        return _buildError(theme, state.error);
      case CurriculumGeneratorStatus.generated:
        return _buildResult(theme, state, emerald);
    }
  }

  Widget _buildLoading(ThemeData theme, Color emerald) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [emerald.withValues(alpha: 0.8), emerald],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'AI가 커리큘럼을 생성하고 있어요',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '잠시만 기다려주세요...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              error ?? '오류가 발생했어요.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _hasGenerated = false;
                _startGeneration();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResult(
    ThemeData theme,
    CurriculumGeneratorV2State state,
    Color emerald,
  ) {
    return Column(
      children: [
        // 회차 네비게이션 (여러 회차일 때만)
        if (state.sessionCount > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.currentSessionIndex > 0
                      ? () => ref
                          .read(curriculumGeneratorV2Provider.notifier)
                          .setCurrentSession(state.currentSessionIndex - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 28,
                ),
                GestureDetector(
                  onTap: () => _showSessionPicker(state),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: emerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.currentSessionIndex + 1}회차 / ${state.sessionCount}회차',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: emerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: state.currentSessionIndex < state.sessionCount - 1
                      ? () => ref
                          .read(curriculumGeneratorV2Provider.notifier)
                          .setCurrentSession(state.currentSessionIndex + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 28,
                ),
              ],
            ),
          ),
        // AI 노트
        if (state.currentNotes.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: emerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: emerald.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, size: 16, color: emerald),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.currentNotes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: emerald,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 운동 요약
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Text(
                '${state.currentExercises.length}종목',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '총 ${state.totalSets}세트',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '약 ${state.estimatedDuration}분',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        // 운동 카드 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: state.currentExercises.length + 1, // +1 for add button
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              // 마지막은 추가 버튼
              if (index == state.currentExercises.length) {
                return _buildAddExerciseButton(theme, emerald);
              }
              final exercise = state.currentExercises[index];
              return Dismissible(
                key: ValueKey('${state.currentSessionIndex}_${index}_${exercise.exerciseId ?? exercise.name}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                onDismissed: (_) {
                  ref.read(curriculumGeneratorV2Provider.notifier).removeExercise(index);
                },
                child: ExerciseCardWidget(
                  exercise: exercise,
                  index: index,
                  onReplace: () => _showAlternatives(index),
                  onDelete: () {
                    ref.read(curriculumGeneratorV2Provider.notifier).removeExercise(index);
                  },
                  onEdit: (sets, reps, restSeconds) {
                    ref.read(curriculumGeneratorV2Provider.notifier)
                        .updateExercise(
                      index,
                      sets: sets,
                      reps: reps,
                      restSeconds: restSeconds,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddExerciseButton(ThemeData theme, Color emerald) {
    return InkWell(
      onTap: _showAddExerciseSheet,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: emerald.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          color: emerald.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: emerald, size: 20),
            const SizedBox(width: 8),
            Text(
              '운동 추가',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: emerald,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionPicker(CurriculumGeneratorV2State state) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        final theme = Theme.of(context);
        const emerald = Color(0xFF00C471);
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '회차 선택',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: state.sessionCount,
                  itemBuilder: (context, index) {
                    final isCurrent = index == state.currentSessionIndex;
                    return InkWell(
                      onTap: () {
                        ref.read(curriculumGeneratorV2Provider.notifier)
                            .setCurrentSession(index);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? emerald
                              : emerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent ? Colors.white : emerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// 운동 추가 BottomSheet
class _AddExerciseBottomSheet extends StatefulWidget {
  final ValueChanged<Exercise> onAdd;
  final CurriculumSettings settings;

  const _AddExerciseBottomSheet({
    required this.onAdd,
    required this.settings,
  });

  @override
  State<_AddExerciseBottomSheet> createState() => _AddExerciseBottomSheetState();
}

class _AddExerciseBottomSheetState extends State<_AddExerciseBottomSheet> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    // 초기에 전체 목록 표시
    _searchResults = ExerciseConstants.exercises.take(20).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String keyword) {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchResults = ExerciseConstants.exercises.take(20).toList();
      });
      return;
    }

    final query = keyword.trim().toLowerCase();
    setState(() {
      _searchResults = ExerciseConstants.exercises.where((ex) {
        final name = (ex['nameKo'] as String? ?? '').toLowerCase();
        final equipment = (ex['equipment'] as String? ?? '').toLowerCase();
        final muscle = (ex['primaryMuscle'] as String? ?? '').toLowerCase();
        return name.contains(query) ||
            equipment.contains(query) ||
            muscle.contains(query);
      }).take(20).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF00C471);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '운동 추가',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              // 검색 필드
              TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: '운동명, 장비, 부위로 검색...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              // 검색 결과
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final ex = _searchResults[index];
                    final name = ex['nameKo']?.toString() ?? '';
                    final equipment = ex['equipment']?.toString() ?? '';
                    final muscle = ex['primaryMuscle']?.toString() ?? '';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: emerald.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.fitness_center, color: emerald, size: 20),
                      ),
                      title: Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '$equipment · $muscle',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          // 현재 설정의 세트/렙 기본값 적용
                          int reps = 10;
                          int restSeconds = 60;
                          final styles = widget.settings.styles;
                          if (styles.contains('고중량') || styles.contains('스트렝스')) {
                            reps = 5;
                            restSeconds = 120;
                          } else if (styles.contains('저중량') || styles.contains('고반복')) {
                            reps = 15;
                            restSeconds = 45;
                          } else if (styles.contains('근비대')) {
                            reps = 10;
                            restSeconds = 90;
                          }

                          widget.onAdd(Exercise(
                            name: name,
                            sets: widget.settings.setCount,
                            reps: reps,
                            restSeconds: restSeconds,
                            exerciseId: ex['id']?.toString(),
                          ));
                        },
                        icon: Icon(Icons.add_circle, color: emerald),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 대체 운동 BottomSheet
class _AlternativesBottomSheet extends ConsumerWidget {
  final AlternativeRequest request;
  final Exercise currentExercise;
  final ValueChanged<AlternativeExercise> onSelect;

  const _AlternativesBottomSheet({
    required this.request,
    required this.currentExercise,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF00C471);
    final alternativesAsync = ref.watch(alternativeExercisesProvider(request));

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"${currentExercise.name}" 대체 운동',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          alternativesAsync.when(
            data: (alternatives) {
              if (alternatives.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '대체할 수 있는 운동이 없어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: alternatives.map((alt) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: emerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fitness_center, color: emerald, size: 20),
                    ),
                    title: Text(alt.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    subtitle: Text(
                      '${alt.equipment} · ${alt.reason}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                    ),
                    onTap: () => onSelect(alt),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('대체 운동을 불러올 수 없어요.',
                    style: theme.textTheme.bodyMedium),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
