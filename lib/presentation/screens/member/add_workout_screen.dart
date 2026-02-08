import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/haptic_utils.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/workout_log_provider.dart';
import 'package:flutter_pal_app/data/models/workout_log_model.dart';

// ---------------------------------------------------------------------------
// 근육 그룹 필터 정의
// ---------------------------------------------------------------------------

/// 근육 그룹 필터 항목
class _MuscleGroup {
  final String label;
  final String filterKey; // ExerciseConstants의 primaryMuscle 값과 매칭
  final IconData icon;

  const _MuscleGroup({
    required this.label,
    required this.filterKey,
    required this.icon,
  });
}

/// 근육 그룹 -> WorkoutCategory 매핑
WorkoutCategory _muscleToCategory(String muscle) {
  switch (muscle) {
    case '가슴':
      return WorkoutCategory.chest;
    case '등':
      return WorkoutCategory.back;
    case '하체':
      return WorkoutCategory.leg;
    case '어깨':
      return WorkoutCategory.shoulder;
    case '팔':
      return WorkoutCategory.arm;
    case '복근':
      return WorkoutCategory.core;
    case '전신':
      return WorkoutCategory.other;
    case '유산소':
      return WorkoutCategory.cardio;
    default:
      return WorkoutCategory.other;
  }
}

/// 카테고리 한글 이름
String _categoryLabel(WorkoutCategory category) {
  switch (category) {
    case WorkoutCategory.chest:
      return '가슴';
    case WorkoutCategory.back:
      return '등';
    case WorkoutCategory.shoulder:
      return '어깨';
    case WorkoutCategory.arm:
      return '팔';
    case WorkoutCategory.leg:
      return '하체';
    case WorkoutCategory.core:
      return '코어';
    case WorkoutCategory.cardio:
      return '유산소';
    case WorkoutCategory.other:
      return '기타';
  }
}

/// 카테고리별 색상
Color _categoryColor(WorkoutCategory category) {
  switch (category) {
    case WorkoutCategory.chest:
      return const Color(0xFFF04452);
    case WorkoutCategory.back:
      return const Color(0xFF3B82F6);
    case WorkoutCategory.shoulder:
      return const Color(0xFF8B5CF6);
    case WorkoutCategory.arm:
      return const Color(0xFFFF8A00);
    case WorkoutCategory.leg:
      return const Color(0xFF00C471);
    case WorkoutCategory.core:
      return const Color(0xFF06B6D4);
    case WorkoutCategory.cardio:
      return const Color(0xFFEC4899);
    case WorkoutCategory.other:
      return const Color(0xFF6B7280);
  }
}

// ---------------------------------------------------------------------------
// 선택된 운동 모델 (Step 2에서 세트/반복/무게 설정용)
// ---------------------------------------------------------------------------

/// 선택된 운동 정보 (내부 편집용, 최종 저장 시 WorkoutExercise로 변환)
class _SelectedExercise {
  final String id;
  final String nameKo;
  final String equipment;
  final String primaryMuscle;
  int sets;
  int reps;
  double weight;

  _SelectedExercise({
    required this.id,
    required this.nameKo,
    required this.equipment,
    required this.primaryMuscle,
    // ignore: unused_element_parameter
    this.sets = 3,
    // ignore: unused_element_parameter
    this.reps = 10,
    // ignore: unused_element_parameter
    this.weight = 0.0,
  });

  /// WorkoutExercise로 변환
  WorkoutExercise toWorkoutExercise() {
    return WorkoutExercise(
      name: nameKo,
      category: _muscleToCategory(primaryMuscle),
      sets: sets,
      reps: reps,
      weight: weight,
      restSeconds: 60,
    );
  }
}

// ---------------------------------------------------------------------------
// 메인 화면
// ---------------------------------------------------------------------------

/// 운동 추가 화면 (Toss 스타일 2단계 UX)
class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen> {
  // Step 관리: 0 = 운동 선택, 1 = 세부 설정
  int _currentStep = 0;

  // 검색
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // 근육 그룹 필터
  String? _selectedMuscleGroup;

  // 선택된 운동 목록
  final List<_SelectedExercise> _selectedExercises = [];

  // 메모
  final _memoController = TextEditingController();
  bool _showMemo = false;

  // 운동 시간 타이머
  DateTime? _startTime;
  int _elapsedMinutes = 0;

  // 저장 중 상태
  bool _isSaving = false;

  // 근육 그룹 필터 목록
  static const List<_MuscleGroup> _muscleGroups = [
    _MuscleGroup(label: '가슴', filterKey: '가슴', icon: Icons.fitness_center),
    _MuscleGroup(label: '등', filterKey: '등', icon: Icons.accessibility_new),
    _MuscleGroup(label: '하체', filterKey: '하체', icon: Icons.directions_run),
    _MuscleGroup(label: '어깨', filterKey: '어깨', icon: Icons.sports_martial_arts),
    _MuscleGroup(label: '팔', filterKey: '팔', icon: Icons.front_hand),
    _MuscleGroup(label: '복근', filterKey: '복근', icon: Icons.star_outline),
    _MuscleGroup(label: '전신', filterKey: '전신', icon: Icons.self_improvement),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
    // 1분마다 경과 시간 업데이트
    Future.delayed(const Duration(minutes: 1), _updateElapsedTime);
  }

  void _updateElapsedTime() {
    if (!mounted || _startTime == null) return;
    setState(() {
      _elapsedMinutes = DateTime.now().difference(_startTime!).inMinutes;
    });
    Future.delayed(const Duration(minutes: 1), _updateElapsedTime);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // 운동 검색 및 필터링
  // ---------------------------------------------------------------------------

  /// ExerciseConstants에서 필터링된 운동 목록 반환
  List<Map<String, dynamic>> _getFilteredExercises() {
    var list = ExerciseConstants.exercises;

    // 근육 그룹 필터
    if (_selectedMuscleGroup != null) {
      list = list
          .where((e) => e['primaryMuscle'] == _selectedMuscleGroup)
          .toList();
    }

    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list
          .where((e) =>
              (e['nameKo'] as String).toLowerCase().contains(query))
          .toList();

      // 정렬: 정확 일치 > 시작 일치 > 포함
      list.sort((a, b) {
        final aName = (a['nameKo'] as String).toLowerCase();
        final bName = (b['nameKo'] as String).toLowerCase();
        final aExact = aName == query;
        final bExact = bName == query;
        if (aExact != bExact) return aExact ? -1 : 1;
        final aStarts = aName.startsWith(query);
        final bStarts = bName.startsWith(query);
        if (aStarts != bStarts) return aStarts ? -1 : 1;
        return aName.compareTo(bName);
      });
    }

    return list;
  }

  /// 운동이 이미 선택되었는지 확인
  bool _isExerciseSelected(String id) {
    return _selectedExercises.any((e) => e.id == id);
  }

  /// 운동 선택/해제 토글
  void _toggleExercise(Map<String, dynamic> exercise) {
    HapticUtils.light();
    final id = exercise['id'] as String;
    setState(() {
      if (_isExerciseSelected(id)) {
        _selectedExercises.removeWhere((e) => e.id == id);
      } else {
        _selectedExercises.add(_SelectedExercise(
          id: id,
          nameKo: exercise['nameKo'] as String,
          equipment: exercise['equipment'] as String,
          primaryMuscle: exercise['primaryMuscle'] as String,
        ));
      }
    });
  }

  /// Step 2로 이동
  void _goToDetails() {
    if (_selectedExercises.isEmpty) return;
    HapticUtils.medium();
    setState(() {
      _currentStep = 1;
    });
  }

  /// Step 1로 돌아가기
  void _goBackToPicker() {
    HapticUtils.light();
    setState(() {
      _currentStep = 0;
    });
  }

  // ---------------------------------------------------------------------------
  // 저장
  // ---------------------------------------------------------------------------

  Future<void> _saveWorkout() async {
    if (_selectedExercises.isEmpty) return;

    final userId = ref.read(authProvider).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요해요')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final exercises =
        _selectedExercises.map((e) => e.toWorkoutExercise()).toList();

    final workoutLog = WorkoutLogModel(
      userId: userId,
      workoutDate: DateTime.now(),
      exercises: exercises,
      durationMinutes: _elapsedMinutes,
      memo: _memoController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await ref
          .read(workoutLogNotifierProvider.notifier)
          .addWorkoutLog(workoutLog);

      if (!mounted) return;
      HapticUtils.success();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('운동을 저장했어요')),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      HapticUtils.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // 빌드
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
      appBar: _buildAppBar(theme, isDark),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          // Step 전환 시 슬라이드 애니메이션
          final offset = _currentStep == 1
              ? Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              : Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero);
          return SlideTransition(
            position: offset.animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
        child: _currentStep == 0
            ? _StepPickExercises(
                key: const ValueKey('step0'),
                searchController: _searchController,
                searchQuery: _searchQuery,
                selectedMuscleGroup: _selectedMuscleGroup,
                muscleGroups: _muscleGroups,
                filteredExercises: _getFilteredExercises(),
                selectedExercises: _selectedExercises,
                onMuscleGroupSelected: (group) {
                  HapticUtils.selection();
                  setState(() {
                    _selectedMuscleGroup =
                        _selectedMuscleGroup == group ? null : group;
                  });
                },
                isExerciseSelected: _isExerciseSelected,
                onToggleExercise: _toggleExercise,
                onNext: _goToDetails,
              )
            : _StepSetDetails(
                key: const ValueKey('step1'),
                selectedExercises: _selectedExercises,
                memoController: _memoController,
                showMemo: _showMemo,
                isSaving: _isSaving,
                onToggleMemo: () {
                  setState(() => _showMemo = !_showMemo);
                },
                onExerciseChanged: () => setState(() {}),
                onRemoveExercise: (index) {
                  HapticUtils.light();
                  setState(() {
                    _selectedExercises.removeAt(index);
                    // 운동이 모두 삭제되면 Step 1로 돌아감
                    if (_selectedExercises.isEmpty) {
                      _currentStep = 0;
                    }
                  });
                },
                onSave: _saveWorkout,
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      backgroundColor:
          isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          _currentStep == 0 ? Icons.close : Icons.arrow_back,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        onPressed: () {
          if (_currentStep == 1) {
            _goBackToPicker();
          } else {
            context.pop();
          }
        },
      ),
      title: Text(
        _currentStep == 0 ? '운동 추가' : '세부 설정',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // 경과 시간 표시
        if (_elapsedMinutes > 0)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: AppTheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_elapsedMinutes분',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// Step 1: 운동 선택 화면
// =============================================================================

class _StepPickExercises extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedMuscleGroup;
  final List<_MuscleGroup> muscleGroups;
  final List<Map<String, dynamic>> filteredExercises;
  final List<_SelectedExercise> selectedExercises;
  final ValueChanged<String> onMuscleGroupSelected;
  final bool Function(String id) isExerciseSelected;
  final ValueChanged<Map<String, dynamic>> onToggleExercise;
  final VoidCallback onNext;

  const _StepPickExercises({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedMuscleGroup,
    required this.muscleGroups,
    required this.filteredExercises,
    required this.selectedExercises,
    required this.onMuscleGroupSelected,
    required this.isExerciseSelected,
    required this.onToggleExercise,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // 검색바
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.sm,
          ),
          child: _SearchBar(
            controller: searchController,
            isDark: isDark,
          ),
        ),

        // 근육 그룹 필터 칩
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: muscleGroups.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final group = muscleGroups[index];
              final isActive = selectedMuscleGroup == group.filterKey;
              return _FilterChip(
                label: group.label,
                icon: group.icon,
                isActive: isActive,
                isDark: isDark,
                onTap: () => onMuscleGroupSelected(group.filterKey),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // 운동 목록
        Expanded(
          child: filteredExercises.isEmpty
              ? _EmptySearchResult(isDark: isDark)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                  ),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    final id = exercise['id'] as String;
                    final isSelected = isExerciseSelected(id);
                    return _ExercisePickerTile(
                      exercise: exercise,
                      isSelected: isSelected,
                      isDark: isDark,
                      onTap: () => onToggleExercise(exercise),
                    )
                        .animate()
                        .fadeIn(
                          duration: 150.ms,
                          delay: (index.clamp(0, 15) * 20).ms,
                        )
                        .slideY(
                          begin: 0.02,
                          end: 0,
                          duration: 150.ms,
                          delay: (index.clamp(0, 15) * 20).ms,
                        );
                  },
                ),
        ),

        // 하단 선택 바
        _BottomSelectionBar(
          count: selectedExercises.length,
          isDark: isDark,
          onNext: onNext,
        ),
      ],
    );
  }
}

// =============================================================================
// Step 2: 세부 설정 화면
// =============================================================================

class _StepSetDetails extends StatelessWidget {
  final List<_SelectedExercise> selectedExercises;
  final TextEditingController memoController;
  final bool showMemo;
  final bool isSaving;
  final VoidCallback onToggleMemo;
  final VoidCallback onExerciseChanged;
  final ValueChanged<int> onRemoveExercise;
  final VoidCallback onSave;

  const _StepSetDetails({
    super.key,
    required this.selectedExercises,
    required this.memoController,
    required this.showMemo,
    required this.isSaving,
    required this.onToggleMemo,
    required this.onExerciseChanged,
    required this.onRemoveExercise,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // 운동 세부 설정 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.sm,
              AppSpacing.screenPadding,
              AppSpacing.xl,
            ),
            itemCount: selectedExercises.length + 1, // +1 메모 영역
            itemBuilder: (context, index) {
              if (index < selectedExercises.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.compact),
                  child: _ExerciseDetailCard(
                    exercise: selectedExercises[index],
                    isDark: isDark,
                    onChanged: onExerciseChanged,
                    onRemove: () => onRemoveExercise(index),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms, delay: (index * 50).ms)
                      .slideY(
                        begin: 0.03,
                        end: 0,
                        duration: 200.ms,
                        delay: (index * 50).ms,
                      ),
                );
              }
              // 메모 영역
              return _MemoSection(
                controller: memoController,
                showMemo: showMemo,
                isDark: isDark,
                onToggle: onToggleMemo,
              );
            },
          ),
        ),

        // 저장 버튼
        Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.compact,
            AppSpacing.screenPadding,
            bottomPadding + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 0.5,
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: _PrimaryButton(
              label: isSaving ? '저장 중...' : '저장하기',
              isEnabled: !isSaving && selectedExercises.isNotEmpty,
              isLoading: isSaving,
              onTap: onSave,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// 공용 서브 위젯
// =============================================================================

/// 검색바
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const _SearchBar({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.gray100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 15,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '운동을 검색해보세요',
          hintStyle: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    controller.clear();
                    HapticUtils.light();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// 근육 그룹 필터 칩 (커스텀 스타일)
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.compact,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor
              : isDark
                  ? AppColors.darkSurface
                  : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive
                ? activeColor
                : isDark
                    ? AppColors.borderDark
                    : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? Colors.white
                  : isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 운동 선택 타일 (Step 1)
class _ExercisePickerTile extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ExercisePickerTile({
    required this.exercise,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nameKo = exercise['nameKo'] as String;
    final equipment = exercise['equipment'] as String;
    final primaryMuscle = exercise['primaryMuscle'] as String;
    final category = _muscleToCategory(primaryMuscle);
    final color = _categoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.compact,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.primary50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            // 운동 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nameKo,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // 장비 뱃지
                      _SmallBadge(
                        label: equipment,
                        color: isDark ? AppColors.gray600 : AppColors.gray200,
                        textColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      // 근육 그룹 뱃지
                      _SmallBadge(
                        label: primaryMuscle,
                        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                        textColor: color,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 선택 표시
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.darkSurface
                        : AppColors.gray100,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? AppColors.borderDark
                          : AppColors.gray300,
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 작은 뱃지 (장비, 근육 그룹 표시용)
class _SmallBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _SmallBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// 하단 선택 바 (Step 1)
class _BottomSelectionBar extends StatelessWidget {
  final int count;
  final bool isDark;
  final VoidCallback onNext;

  const _BottomSelectionBar({
    required this.count,
    required this.isDark,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isActive = count > 0;

    return AnimatedSlide(
      offset: isActive ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.compact,
            AppSpacing.screenPadding,
            bottomPadding + AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.appBackgroundDark : AppColors.appBackground,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // 선택 개수
              Expanded(
                child: Text(
                  '$count개 운동 선택됨',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              // 다음 버튼
              SizedBox(
                height: 48,
                child: _PrimaryButton(
                  label: '다음',
                  isEnabled: isActive,
                  onTap: onNext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 검색 결과 없음
class _EmptySearchResult extends StatelessWidget {
  final bool isDark;

  const _EmptySearchResult({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: isDark ? AppColors.gray600 : AppColors.gray300,
          ),
          const SizedBox(height: AppSpacing.compact),
          Text(
            '검색 결과가 없어요',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 2 서브 위젯
// =============================================================================

/// 운동 세부 설정 카드
class _ExerciseDetailCard extends StatelessWidget {
  final _SelectedExercise exercise;
  final bool isDark;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _ExerciseDetailCard({
    required this.exercise,
    required this.isDark,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final category = _muscleToCategory(exercise.primaryMuscle);
    final color = _categoryColor(category);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 운동 이름 + 근육 뱃지 + 삭제 버튼
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        exercise.nameKo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SmallBadge(
                      label: _categoryLabel(category),
                      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                      textColor: color,
                    ),
                  ],
                ),
              ),
              // 삭제 버튼
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: isDark ? AppColors.gray400 : AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // 세트 / 반복 / 무게 컨트롤
          Row(
            children: [
              // 세트
              Expanded(
                child: _StepperControl(
                  label: '세트',
                  value: exercise.sets,
                  unit: '세트',
                  isDark: isDark,
                  onDecrement: () {
                    if (exercise.sets > 1) {
                      exercise.sets--;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                  onIncrement: () {
                    if (exercise.sets < 20) {
                      exercise.sets++;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 반복
              Expanded(
                child: _StepperControl(
                  label: '반복',
                  value: exercise.reps,
                  unit: '회',
                  isDark: isDark,
                  onDecrement: () {
                    if (exercise.reps > 1) {
                      exercise.reps--;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                  onIncrement: () {
                    if (exercise.reps < 100) {
                      exercise.reps++;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // 무게
              Expanded(
                child: _WeightControl(
                  weight: exercise.weight,
                  isDark: isDark,
                  onDecrement: () {
                    if (exercise.weight >= 2.5) {
                      exercise.weight -= 2.5;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                  onIncrement: () {
                    if (exercise.weight < 500) {
                      exercise.weight += 2.5;
                      HapticUtils.light();
                      onChanged();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 스텝퍼 컨트롤 (세트, 반복)
class _StepperControl extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final bool isDark;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _StepperControl({
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 레이블
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        // [-] 값 [+] 가로 배치
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.gray50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              // 감소 버튼
              _StepperButton(
                icon: Icons.remove,
                isDark: isDark,
                onTap: onDecrement,
              ),
              // 값 표시
              Expanded(
                child: Center(
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              // 증가 버튼
              _StepperButton(
                icon: Icons.add,
                isDark: isDark,
                onTap: onIncrement,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 무게 컨트롤 (+/- 2.5kg)
class _WeightControl extends StatelessWidget {
  final double weight;
  final bool isDark;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _WeightControl({
    required this.weight,
    required this.isDark,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    // 소수점 없으면 정수로 표시
    final weightText =
        weight == weight.roundToDouble() && weight % 1 == 0
            ? weight.toInt().toString()
            : weight.toStringAsFixed(1);

    return Column(
      children: [
        Text(
          '무게',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.gray50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                isDark: isDark,
                onTap: onDecrement,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    weightText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                isDark: isDark,
                onTap: onIncrement,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'kg',
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// 스텝퍼 +/- 버튼
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        height: 40,
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isDark ? AppColors.textSecondaryDark : AppColors.gray500,
          ),
        ),
      ),
    );
  }
}

/// 메모 섹션 (접히는 형태)
class _MemoSection extends StatelessWidget {
  final TextEditingController controller;
  final bool showMemo;
  final bool isDark;
  final VoidCallback onToggle;

  const _MemoSection({
    required this.controller,
    required this.showMemo,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메모 토글 버튼
          GestureDetector(
            onTap: () {
              HapticUtils.light();
              onToggle();
            },
            child: Row(
              children: [
                Icon(
                  showMemo
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '메모 추가',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 메모 입력 필드
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '오늘 운동에 대한 메모를 남겨보세요',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.compact),
                  ),
                ),
              ),
            ),
            crossFadeState:
                showMemo ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 공용 Primary 버튼
// =============================================================================

/// 프라이머리 버튼 (저장하기, 다음)
class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.isEnabled,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isEnabled
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.isEnabled
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isEnabled
          ? () {
              HapticUtils.medium();
              widget.onTap();
            }
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: widget.isEnabled
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
