import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/core/theme/app_tokens.dart';
import 'package:flutter_pal_app/core/utils/haptic_utils.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/workout_log_provider.dart';
import 'package:flutter_pal_app/presentation/providers/exercise_search_provider.dart';
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

/// 세트별 상태 (UI 편집용)
class _SetDetailState {
  int reps;
  double weight;
  _SetDetailState({this.reps = 10, this.weight = 0.0});
}

/// 선택된 운동 정보 (내부 편집용, 최종 저장 시 WorkoutExercise로 변환)
class _SelectedExercise {
  final String id;
  final String nameKo;
  final String equipment;
  final String primaryMuscle;
  List<_SetDetailState> setDetailList;

  _SelectedExercise({
    required this.id,
    required this.nameKo,
    required this.equipment,
    required this.primaryMuscle,
    int sets = 3,
    int reps = 10,
    double weight = 0.0,
  }) : setDetailList = List.generate(
          sets,
          (_) => _SetDetailState(reps: reps, weight: weight),
        );

  int get sets => setDetailList.length;

  /// 세트 추가 (마지막 세트 값 복사)
  void addSet() {
    if (setDetailList.length >= 20) return;
    final last = setDetailList.isNotEmpty
        ? setDetailList.last
        : _SetDetailState();
    setDetailList.add(_SetDetailState(reps: last.reps, weight: last.weight));
  }

  /// 마지막 세트 제거
  void removeLastSet() {
    if (setDetailList.length > 1) {
      setDetailList.removeLast();
    }
  }

  /// WorkoutExercise로 변환
  WorkoutExercise toWorkoutExercise() {
    final details = setDetailList
        .map((s) => SetDetail(reps: s.reps, weight: s.weight))
        .toList();
    final maxWeight = setDetailList
        .map((s) => s.weight)
        .reduce((a, b) => a > b ? a : b);
    return WorkoutExercise(
      name: nameKo,
      category: _muscleToCategory(primaryMuscle),
      sets: setDetailList.length,
      reps: setDetailList.first.reps,
      weight: maxWeight,
      restSeconds: 60,
      setDetails: details,
    );
  }
}

// ---------------------------------------------------------------------------
// 메인 화면
// ---------------------------------------------------------------------------

/// 운동 추가/수정 화면 (Toss 스타일 2단계 UX)
class AddWorkoutScreen extends ConsumerStatefulWidget {
  /// 수정 모드일 때 기존 운동 기록
  final WorkoutLogModel? existingWorkout;

  const AddWorkoutScreen({super.key, this.existingWorkout});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen> {
  // 선택된 운동 목록
  final List<_SelectedExercise> _selectedExercises = [];

  // 제목
  final _titleController = TextEditingController();

  // 메모
  final _memoController = TextEditingController();
  bool _showMemo = false;

  // 운동 시간 (분) - 수동 입력
  int _durationMinutes = 0;

  // 저장 중 상태
  bool _isSaving = false;

  // 오운완 사진
  Uint8List? _imageBytes;

  // 수정 모드 여부
  bool get _isEditMode => widget.existingWorkout != null;

  // 근육 그룹 필터 목록
  @override
  void initState() {
    super.initState();

    // 수정 모드: 기존 데이터 로드
    if (_isEditMode) {
      final workout = widget.existingWorkout!;
      _titleController.text = workout.title;
      _memoController.text = workout.memo;
      _durationMinutes = workout.durationMinutes;
      _showMemo = workout.memo.isNotEmpty;

      // 기존 운동 목록 복원
      for (final exercise in workout.exercises) {
        final categoryLabel = _categoryLabel(exercise.category);
        final selected = _SelectedExercise(
          id: '${exercise.name}_${exercise.category.name}',
          nameKo: exercise.name,
          equipment: '',
          primaryMuscle: categoryLabel,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: exercise.weight,
        );
        // 세트별 상세가 있으면 로드
        if (exercise.setDetails != null &&
            exercise.setDetails!.isNotEmpty) {
          selected.setDetailList = exercise.setDetails!
              .map((d) =>
                  _SetDetailState(reps: d.reps, weight: d.weight))
              .toList();
        }
        _selectedExercises.add(selected);
      }

    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  /// 운동 추가 바텀시트 표시
  void _showExercisePickerSheet() async {
    // 로컬 JSON 800개 운동 로드 (캐시됨, 실패 시 ExerciseConstants fallback)
    List<Map<String, dynamic>> loadedExercises;
    try {
      loadedExercises = await ref.read(allExercisesProvider.future);
    } catch (_) {
      loadedExercises = ExerciseConstants.exercises;
    }
    if (!mounted) return;

    // 현재 선택 상태 스냅샷
    final initialSelectedIds = <String>{
      ..._selectedExercises.map((e) => e.id),
    };
    final initialSelectedData = <String, Map<String, dynamic>>{
      for (final e in _selectedExercises)
        e.id: {
          'id': e.id,
          'nameKo': e.nameKo,
          'equipment': e.equipment,
          'primaryMuscle': e.primaryMuscle,
        },
    };

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExercisePickerSheetWidget(
        exercises: List<Map<String, dynamic>>.from(loadedExercises),
        initialSelectedIds: initialSelectedIds,
        initialSelectedData: initialSelectedData,
        onConfirm: (selectedIds, selectedData) {
          if (!mounted) return;
          setState(() {
            _selectedExercises
                .removeWhere((e) => !selectedIds.contains(e.id));
            for (final id in selectedIds) {
              if (!_selectedExercises.any((e) => e.id == id)) {
                final exercise = selectedData[id]!;
                _selectedExercises.add(_SelectedExercise(
                  id: id,
                  nameKo: exercise['nameKo'] as String,
                  equipment: exercise['equipment'] as String,
                  primaryMuscle: exercise['primaryMuscle'] as String,
                ));
              }
            }
          });
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 사진
  // ---------------------------------------------------------------------------

  /// 오운완 사진 선택 (카메라/갤러리)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile == null) return;
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 선택 실패: $e')),
      );
    }
  }

  /// 사진 제거
  void _removeImage() {
    setState(() => _imageBytes = null);
  }

  /// 사진 선택 바텀시트
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Supabase에 이미지 업로드 후 URL 반환
  Future<String?> _uploadImage(String userId) async {
    if (_imageBytes == null) return null;
    final fileName =
        'workout/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final supabase = Supabase.instance.client;
    await supabase.storage.from('pal-storage').uploadBinary(
          fileName,
          _imageBytes!,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return supabase.storage.from('pal-storage').getPublicUrl(fileName);
  }

  // ---------------------------------------------------------------------------
  // 저장
  // ---------------------------------------------------------------------------

  Future<void> _saveWorkout() async {
    if (_selectedExercises.isEmpty) return;

    // 회원 ID 우선 사용 (캘린더 조회와 통일), 없으면 Firebase UID 폴백
    final member = ref.read(currentMemberProvider);
    final userId = member?.id ?? ref.read(authProvider).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요해요')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 사진이 있으면 먼저 업로드
      final imageUrl = await _uploadImage(userId);

      final exercises =
          _selectedExercises.map((e) => e.toWorkoutExercise()).toList();

      if (_isEditMode) {
        // 수정 모드
        final existingWorkout = widget.existingWorkout!;
        final updateData = <String, dynamic>{
          'title': _titleController.text.trim(),
          'exercises': exercises.map((e) => e.toJson()).toList(),
          'durationMinutes': _durationMinutes,
          'memo': _memoController.text.trim(),
        };
        if (imageUrl != null) {
          updateData['imageUrl'] = imageUrl;
        }

        await ref
            .read(workoutLogNotifierProvider.notifier)
            .updateWorkoutLog(existingWorkout.id, updateData);

        if (!mounted) return;
        HapticUtils.success();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동 기록을 수정했어요')),
        );
      } else {
        // 새로 추가
        final workoutLog = WorkoutLogModel(
          userId: userId,
          title: _titleController.text.trim(),
          workoutDate: DateTime.now(),
          exercises: exercises,
          durationMinutes: _durationMinutes,
          memo: _memoController.text.trim(),
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
        );

        await ref
            .read(workoutLogNotifierProvider.notifier)
            .addWorkoutLog(workoutLog);

        if (!mounted) return;
        HapticUtils.success();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동을 저장했어요')),
        );
      }

      context.pop(true); // true를 반환하여 캘린더에서 새로고침 트리거
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
      body: _StepSetDetails(
        selectedExercises: _selectedExercises,
        titleController: _titleController,
        memoController: _memoController,
        showMemo: _showMemo,
        isSaving: _isSaving,
        isEditMode: _isEditMode,
        imageBytes: _imageBytes,
        durationMinutes: _durationMinutes,
        onDurationChanged: (value) {
          setState(() => _durationMinutes = value);
        },
        onToggleMemo: () {
          setState(() => _showMemo = !_showMemo);
        },
        onExerciseChanged: () => setState(() {}),
        onRemoveExercise: (index) {
          HapticUtils.light();
          setState(() {
            _selectedExercises.removeAt(index);
          });
        },
        onSave: _saveWorkout,
        onPickImage: _showImagePickerSheet,
        onRemoveImage: _removeImage,
        onAddExercise: _showExercisePickerSheet,
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
          Icons.close,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        onPressed: () => context.pop(),
      ),
      title: Text(
        _isEditMode ? '운동 수정' : '운동 추가',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }
}

// =============================================================================
// 세부 설정 화면
// =============================================================================

class _StepSetDetails extends StatelessWidget {
  final List<_SelectedExercise> selectedExercises;
  final TextEditingController titleController;
  final TextEditingController memoController;
  final bool showMemo;
  final bool isSaving;
  final bool isEditMode;
  final Uint8List? imageBytes;
  final int durationMinutes;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onToggleMemo;
  final VoidCallback onExerciseChanged;
  final ValueChanged<int> onRemoveExercise;
  final VoidCallback onSave;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;
  final VoidCallback onAddExercise;

  const _StepSetDetails({
    super.key,
    required this.selectedExercises,
    required this.titleController,
    required this.memoController,
    required this.showMemo,
    required this.isSaving,
    required this.isEditMode,
    this.imageBytes,
    required this.durationMinutes,
    required this.onDurationChanged,
    required this.onToggleMemo,
    required this.onExerciseChanged,
    required this.onRemoveExercise,
    required this.onSave,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 리스트 항목: 제목+운동시간 + 운동들 + 운동추가버튼 + 메모 + 사진
    final extraItems = 4; // 제목+운동시간, 운동추가버튼, 메모, 사진

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
            itemCount: selectedExercises.length + extraItems,
            itemBuilder: (context, index) {
              // 제목 + 운동 시간 입력
              if (index == 0) {
                return _TitleAndDurationSection(
                  titleController: titleController,
                  durationMinutes: durationMinutes,
                  isDark: isDark,
                  onDurationChanged: onDurationChanged,
                );
              }
              final exerciseIndex = index - 1;
              if (exerciseIndex < selectedExercises.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.compact),
                  child: _ExerciseDetailCard(
                    exercise: selectedExercises[exerciseIndex],
                    isDark: isDark,
                    onChanged: onExerciseChanged,
                    onRemove: () => onRemoveExercise(exerciseIndex),
                  )
                      .animate()
                      .fadeIn(duration: 200.ms, delay: (exerciseIndex * 50).ms)
                      .slideY(
                        begin: 0.03,
                        end: 0,
                        duration: 200.ms,
                        delay: (exerciseIndex * 50).ms,
                      ),
                );
              }
              // 운동 추가 버튼
              if (exerciseIndex == selectedExercises.length) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.compact),
                  child: GestureDetector(
                    onTap: onAddExercise,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.gray200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '운동 추가',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (exerciseIndex == selectedExercises.length + 1) {
                // 메모 영역
                return _MemoSection(
                  controller: memoController,
                  showMemo: showMemo,
                  isDark: isDark,
                  onToggle: onToggleMemo,
                );
              }
              // 오운완 사진 영역
              return _PhotoSection(
                imageBytes: imageBytes,
                isDark: isDark,
                onPickImage: onPickImage,
                onRemoveImage: onRemoveImage,
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
              label: isSaving
                  ? '저장 중...'
                  : isEditMode
                      ? '수정하기'
                      : '저장하기',
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

// =============================================================================
// Step 2 서브 위젯
// =============================================================================

/// 운동 세부 설정 카드 (세트별 무게/횟수 입력)
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
          const SizedBox(height: AppSpacing.compact),

          // 세트 수 컨트롤
          Row(
            children: [
              Text(
                '세트 수',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.gray50,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperButton(
                      icon: Icons.remove,
                      isDark: isDark,
                      onTap: () {
                        exercise.removeLastSet();
                        HapticUtils.light();
                        onChanged();
                      },
                    ),
                    SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          '${exercise.sets}',
                          style: TextStyle(
                            fontSize: 15,
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
                      onTap: () {
                        exercise.addSet();
                        HapticUtils.light();
                        onChanged();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 세트별 헤더
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    '',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '횟수',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Center(
                    child: Text(
                      '무게(kg)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 세트별 행
          ...exercise.setDetailList.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final setDetail = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  // 세트 번호
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${setIndex + 1}세트',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  // 횟수 스텝퍼
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            isDark: isDark,
                            onTap: () {
                              if (setDetail.reps > 1) {
                                setDetail.reps--;
                                HapticUtils.light();
                                onChanged();
                              }
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await _showNumberEditDialog(
                                  context: context,
                                  title: '${setIndex + 1}세트 횟수',
                                  unit: '회',
                                  currentValue: setDetail.reps.toDouble(),
                                  min: 1,
                                  max: 100,
                                  isDark: isDark,
                                );
                                if (result != null) {
                                  setDetail.reps = result.toInt();
                                  HapticUtils.light();
                                  onChanged();
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  '${setDetail.reps}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            isDark: isDark,
                            onTap: () {
                              if (setDetail.reps < 100) {
                                setDetail.reps++;
                                HapticUtils.light();
                                onChanged();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 무게 스텝퍼
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkBackground
                            : AppColors.gray50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove,
                            isDark: isDark,
                            onTap: () {
                              if (setDetail.weight >= 2.5) {
                                setDetail.weight -= 2.5;
                                HapticUtils.light();
                                onChanged();
                              }
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                final result = await _showNumberEditDialog(
                                  context: context,
                                  title: '${setIndex + 1}세트 무게',
                                  unit: 'kg',
                                  currentValue: setDetail.weight,
                                  min: 0,
                                  max: 500,
                                  isDark: isDark,
                                  isInteger: false,
                                );
                                if (result != null) {
                                  setDetail.weight = result;
                                  HapticUtils.light();
                                  onChanged();
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  setDetail.weight == setDetail.weight.roundToDouble() &&
                                          setDetail.weight % 1 == 0
                                      ? setDetail.weight.toInt().toString()
                                      : setDetail.weight.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          _StepperButton(
                            icon: Icons.add,
                            isDark: isDark,
                            onTap: () {
                              if (setDetail.weight < 500) {
                                setDetail.weight += 2.5;
                                HapticUtils.light();
                                onChanged();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 숫자 직접 입력 다이얼로그
Future<double?> _showNumberEditDialog({
  required BuildContext context,
  required String title,
  required String unit,
  required double currentValue,
  required double min,
  required double max,
  required bool isDark,
  bool isInteger = true,
}) async {
  final controller = TextEditingController(
    text: isInteger
        ? currentValue.toInt().toString()
        : (currentValue % 1 == 0
            ? currentValue.toInt().toString()
            : currentValue.toStringAsFixed(1)),
  );

  return showDialog<double>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: isInteger
              ? TextInputType.number
              : const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onSubmitted: (value) {
            final parsed = double.tryParse(value);
            if (parsed != null) {
              Navigator.of(ctx).pop(parsed.clamp(min, max));
            } else {
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text);
              if (parsed != null) {
                Navigator.of(ctx).pop(parsed.clamp(min, max));
              } else {
                Navigator.of(ctx).pop();
              }
            },
            child: const Text(
              '확인',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
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

/// 제목 + 운동 시간 입력 섹션
class _TitleAndDurationSection extends StatelessWidget {
  final TextEditingController titleController;
  final int durationMinutes;
  final bool isDark;
  final ValueChanged<int> onDurationChanged;

  const _TitleAndDurationSection({
    required this.titleController,
    required this.durationMinutes,
    required this.isDark,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 입력
          Container(
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
            child: TextField(
              controller: titleController,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '운동 제목 (예: 상체 운동, 등 데이)',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.compact),

          // 운동 시간 입력
          Container(
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
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '운동 시간',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // 시간 스텝퍼
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : AppColors.gray50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StepperButton(
                        icon: Icons.remove,
                        isDark: isDark,
                        onTap: () {
                          if (durationMinutes >= 5) {
                            HapticUtils.light();
                            onDurationChanged(durationMinutes - 5);
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await _showNumberEditDialog(
                            context: context,
                            title: '운동 시간 입력',
                            unit: '분',
                            currentValue: durationMinutes.toDouble(),
                            min: 0,
                            max: 300,
                            isDark: isDark,
                          );
                          if (result != null) {
                            HapticUtils.light();
                            onDurationChanged(result.toInt());
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 56,
                          child: Center(
                            child: Text(
                              '$durationMinutes분',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _StepperButton(
                        icon: Icons.add,
                        isDark: isDark,
                        onTap: () {
                          if (durationMinutes < 300) {
                            HapticUtils.light();
                            onDurationChanged(durationMinutes + 5);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
// 오운완 사진 섹션
// =============================================================================

class _PhotoSection extends StatelessWidget {
  final Uint8List? imageBytes;
  final bool isDark;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _PhotoSection({
    required this.imageBytes,
    required this.isDark,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오운완 사진',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (imageBytes != null)
            // 사진 미리보기
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Image.memory(
                    imageBytes!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemoveImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            // 사진 추가 버튼
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.border,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_rounded,
                      size: 32,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '오늘의 운동 사진을 남겨보세요',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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

// ---------------------------------------------------------------------------
// 운동 선택 바텀시트 (독립 StatefulWidget – InheritedElement 충돌 방지)
// ---------------------------------------------------------------------------

class _ExercisePickerSheetWidget extends StatefulWidget {
  final List<Map<String, dynamic>> exercises;
  final Set<String> initialSelectedIds;
  final Map<String, Map<String, dynamic>> initialSelectedData;
  final void Function(
    Set<String> selectedIds,
    Map<String, Map<String, dynamic>> selectedData,
  ) onConfirm;

  const _ExercisePickerSheetWidget({
    required this.exercises,
    required this.initialSelectedIds,
    required this.initialSelectedData,
    required this.onConfirm,
  });

  @override
  State<_ExercisePickerSheetWidget> createState() =>
      _ExercisePickerSheetWidgetState();
}

class _ExercisePickerSheetWidgetState
    extends State<_ExercisePickerSheetWidget> {
  static const List<_MuscleGroup> _muscleGroups = [
    _MuscleGroup(label: '가슴', filterKey: '가슴', icon: Icons.fitness_center),
    _MuscleGroup(label: '등', filterKey: '등', icon: Icons.accessibility_new),
    _MuscleGroup(label: '하체', filterKey: '하체', icon: Icons.directions_run),
    _MuscleGroup(
        label: '어깨', filterKey: '어깨', icon: Icons.sports_martial_arts),
    _MuscleGroup(label: '팔', filterKey: '팔', icon: Icons.front_hand),
    _MuscleGroup(label: '복근', filterKey: '복근', icon: Icons.star_outline),
    _MuscleGroup(label: '유산소', filterKey: '유산소', icon: Icons.directions_bike),
    _MuscleGroup(label: '종아리', filterKey: '종아리', icon: Icons.hiking),
  ];

  late Set<String> _selectedIds;
  late Map<String, Map<String, dynamic>> _selectedData;
  int _selectedMuscleIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds);
    _selectedData =
        Map<String, Map<String, dynamic>>.from(widget.initialSelectedData);
  }

  List<Map<String, dynamic>> get _filteredExercises {
    final muscle = _muscleGroups[_selectedMuscleIndex].filterKey;
    final all = widget.exercises
        .where((e) => e['primaryMuscle'] == muscle)
        .toList();

    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all
        .where((e) =>
            (e['nameKo'] as String).toLowerCase().contains(q))
        .toList();
  }

  void _toggle(Map<String, dynamic> exercise) {
    HapticUtils.light();
    final id = exercise['id'] as String;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        _selectedData.remove(id);
      } else {
        _selectedIds.add(id);
        _selectedData[id] = exercise;
      }
    });
  }

  void _confirm() {
    // 선택 데이터 캡처
    final ids = Set<String>.from(_selectedIds);
    final data = Map<String, Map<String, dynamic>>.from(_selectedData);
    // 먼저 모달 닫기 → 다음 프레임에서 콜백 실행 (PopScope GlobalKey 충돌 방지)
    Navigator.of(context).pop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onConfirm(ids, data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercises = _filteredExercises;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '운동 선택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_selectedIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedIds.length}개 선택',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 검색바
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '운동 검색',
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                prefixIcon: Icon(Icons.search,
                    color: isDark ? Colors.grey[400] : Colors.grey),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          // 근육 그룹 탭
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _muscleGroups.length,
              itemBuilder: (_, i) {
                final g = _muscleGroups[i];
                final selected = i == _selectedMuscleIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    avatar: Icon(g.icon, size: 16),
                    label: Text(g.label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedMuscleIndex = i),
                    selectedColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      color: selected
                          ? AppColors.primary
                          : isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!,
                    ),
                    backgroundColor:
                        isDark ? AppColors.darkBackground : Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // 운동 목록
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (_, i) {
                      final ex = exercises[i];
                      final id = ex['id'] as String;
                      final isSelected = _selectedIds.contains(id);
                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : isDark
                                  ? Colors.grey[500]
                                  : Colors.grey[400],
                          size: 22,
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                ex['nameKo'] as String,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          ex['equipment'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        onTap: () => _toggle(ex),
                      );
                    },
                  ),
          ),
          // 하단 버튼
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    _selectedIds.isEmpty
                        ? '확인'
                        : '${_selectedIds.length}개 선택 완료',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
