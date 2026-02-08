import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
        _selectedExercises.add(_SelectedExercise(
          id: '${exercise.name}_${exercise.category.name}',
          nameKo: exercise.name,
          equipment: '',
          primaryMuscle: categoryLabel,
          sets: exercise.sets,
          reps: exercise.reps,
          weight: exercise.weight,
        ));
      }

    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
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

  /// 운동 추가 바텀시트 표시
  void _showExercisePickerSheet() {
    final sheetSearchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        String sheetSearchQuery = '';
        String? sheetSelectedMuscle;

        return StatefulBuilder(
          builder: (sheetCtx, setSheetState) {
            // 필터링
            var list = ExerciseConstants.exercises;
            if (sheetSelectedMuscle != null) {
              list = list
                  .where((e) => e['primaryMuscle'] == sheetSelectedMuscle)
                  .toList();
            }
            if (sheetSearchQuery.isNotEmpty) {
              final query = sheetSearchQuery.toLowerCase();
              list = list
                  .where((e) =>
                      (e['nameKo'] as String).toLowerCase().contains(query))
                  .toList();
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.appBackgroundDark
                    : AppColors.appBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // 핸들바
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.gray500 : AppColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // 타이틀
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '운동 추가',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 16,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: AppSpacing.sm,
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: TextField(
                        controller: sheetSearchController,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            sheetSearchQuery = value.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: '운동을 검색해보세요',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 20,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 14,
                          ),
                        ),
                      ),
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
                      itemCount: _muscleGroups.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (_, index) {
                        final group = _muscleGroups[index];
                        final isActive =
                            sheetSelectedMuscle == group.filterKey;
                        return _FilterChip(
                          label: group.label,
                          icon: group.icon,
                          isActive: isActive,
                          isDark: isDark,
                          onTap: () {
                            HapticUtils.selection();
                            setSheetState(() {
                              sheetSelectedMuscle =
                                  sheetSelectedMuscle == group.filterKey
                                      ? null
                                      : group.filterKey;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // 운동 목록
                  Expanded(
                    child: list.isEmpty
                        ? _EmptySearchResult(isDark: isDark)
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                            ),
                            itemCount: list.length,
                            itemBuilder: (_, index) {
                              final exercise = list[index];
                              final id = exercise['id'] as String;
                              final isSelected = _isExerciseSelected(id);
                              return _ExercisePickerTile(
                                exercise: exercise,
                                isSelected: isSelected,
                                isDark: isDark,
                                onTap: () {
                                  _toggleExercise(exercise);
                                  setSheetState(() {});
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      sheetSearchController.dispose();
    });
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

// =============================================================================
// 공용 서브 위젯
// =============================================================================

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
                  onValueTap: () async {
                    final result = await _showNumberEditDialog(
                      context: context,
                      title: '세트 수 입력',
                      unit: '세트',
                      currentValue: exercise.sets.toDouble(),
                      min: 1,
                      max: 20,
                      isDark: isDark,
                    );
                    if (result != null) {
                      exercise.sets = result.toInt();
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
                  onValueTap: () async {
                    final result = await _showNumberEditDialog(
                      context: context,
                      title: '반복 횟수 입력',
                      unit: '회',
                      currentValue: exercise.reps.toDouble(),
                      min: 1,
                      max: 100,
                      isDark: isDark,
                    );
                    if (result != null) {
                      exercise.reps = result.toInt();
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
                  onValueTap: () async {
                    final result = await _showNumberEditDialog(
                      context: context,
                      title: '무게 입력',
                      unit: 'kg',
                      currentValue: exercise.weight,
                      min: 0,
                      max: 500,
                      isDark: isDark,
                      isInteger: false,
                    );
                    if (result != null) {
                      exercise.weight = result;
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

/// 스텝퍼 컨트롤 (세트, 반복)
class _StepperControl extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final bool isDark;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback? onValueTap;

  const _StepperControl({
    required this.label,
    required this.value,
    required this.unit,
    required this.isDark,
    required this.onDecrement,
    required this.onIncrement,
    this.onValueTap,
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
              // 값 표시 (탭하면 직접 입력)
              Expanded(
                child: GestureDetector(
                  onTap: onValueTap,
                  behavior: HitTestBehavior.opaque,
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
  final VoidCallback? onValueTap;

  const _WeightControl({
    required this.weight,
    required this.isDark,
    required this.onDecrement,
    required this.onIncrement,
    this.onValueTap,
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
                child: GestureDetector(
                  onTap: onValueTap,
                  behavior: HitTestBehavior.opaque,
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
