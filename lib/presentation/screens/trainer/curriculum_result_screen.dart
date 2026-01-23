import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/curriculum_generator_v2_provider.dart';
import 'package:flutter_pal_app/presentation/providers/exercise_search_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/exercise_card_widget.dart';

/// AI 커리큘럼 결과 화면
class CurriculumResultScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? memberName;
  final CurriculumSettings? settings;
  final List<String> excludedExerciseIds;

  const CurriculumResultScreen({
    super.key,
    this.memberId,
    this.memberName,
    this.settings,
    this.excludedExerciseIds = const [],
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
      _startGeneration();
    });
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

  Future<void> _saveCurriculum() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(curriculumGeneratorV2Provider.notifier);
    final settings = widget.settings ?? const CurriculumSettings();
    final authState = ref.read(authProvider);

    final success = await notifier.saveAllCurriculums(
      memberId: widget.memberId ?? '',
      trainerId: authState.userId ?? '',
      settings: settings,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${ref.read(curriculumGeneratorV2Provider).sessionCount}회차 커리큘럼이 저장되었습니다!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      context.pop();
      context.pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('저장에 실패했습니다. 다시 시도해주세요.'),
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
        const SnackBar(content: Text('운동 ID가 없어 대체를 할 수 없습니다.')),
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
    const emerald = Color(0xFF10B981);
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
            TextButton(
              onPressed: () {
                ref.read(curriculumGeneratorV2Provider.notifier).reset();
                context.pop();
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
            'AI가 커리큘럼을 생성하고 있습니다',
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
              error ?? '오류가 발생했습니다.',
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
      builder: (context) {
        final theme = Theme.of(context);
        const emerald = Color(0xFF10B981);
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
    const emerald = Color(0xFF10B981);

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
    const emerald = Color(0xFF10B981);
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
                      '대체할 수 있는 운동이 없습니다.',
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
                child: Text('대체 운동을 불러올 수 없습니다.',
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
