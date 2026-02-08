import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/common/app_card.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../data/models/diet_analysis_model.dart';
import '../../../data/models/diet_record_model.dart' as diet_record;
import '../../../data/models/food_item_model.dart';
import '../../../data/repositories/diet_analysis_repository.dart';
import '../../../data/services/food_database_service.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/providers/diet_analysis_provider.dart';
import '../../../presentation/widgets/states/states.dart';
import '../../widgets/diet/food_search_bottom_sheet.dart';
import '../../widgets/common/glass_icon.dart';
import '../../widgets/common/mesh_gradient_background.dart';

/// 회원 식단 기록 화면 (AI 분석 기능 포함)
class MemberDietScreen extends ConsumerStatefulWidget {
  const MemberDietScreen({super.key});

  @override
  ConsumerState<MemberDietScreen> createState() => _MemberDietScreenState();
}

class _MemberDietScreenState extends ConsumerState<MemberDietScreen> {
  DateTime _selectedDate = DateTime.now();
  int _targetCalories = 2000;
  double _targetProtein = 60;
  double _targetCarbs = 300;
  double _targetFat = 65;

  @override
  void initState() {
    super.initState();
    // 음식 데이터베이스 초기화
    FoodDatabaseService.instance.init();
  }

  void _showTargetEditDialog() {
    final calorieController = TextEditingController(text: '$_targetCalories');
    final proteinController = TextEditingController(text: '${_targetProtein.toInt()}');
    final carbsController = TextEditingController(text: '${_targetCarbs.toInt()}');
    final fatController = TextEditingController(text: '${_targetFat.toInt()}');

    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final cs = theme.colorScheme;
        return AlertDialog(
          title: const Text('목표 영양소 설정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '목표 칼로리 (kcal)',
                    hintText: '2000',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.local_fire_department, color: cs.primary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: proteinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '단백질 (g)',
                    hintText: '60',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.egg_alt, color: const Color(0xFFFF8A00)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: carbsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '탄수화물 (g)',
                    hintText: '300',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.grain, color: const Color(0xFF5B8DEF)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: fatController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '지방 (g)',
                    hintText: '65',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.water_drop, color: const Color(0xFFFFB347)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _targetCalories = int.tryParse(calorieController.text) ?? 2000;
                  _targetProtein = double.tryParse(proteinController.text) ?? 60;
                  _targetCarbs = double.tryParse(carbsController.text) ?? 300;
                  _targetFat = double.tryParse(fatController.text) ?? 65;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('적용'),
            ),
          ],
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  void _changeDate(int days) {
    final member = ref.read(currentMemberProvider);
    final newDate = _selectedDate.add(Duration(days: days));
    setState(() => _selectedDate = newDate);
    // 날짜 변경 시 해당 날짜의 데이터를 다시 조회하도록 invalidate
    if (member != null) {
      ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: member.id, date: newDate)));
    }
  }

  /// 음식 검색 바텀시트 표시
  Future<void> _showFoodSearch(MealType mealType) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보를 찾을 수 없어요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // diet_analysis_model.MealType을 diet_record_model.MealType으로 변환
    final recordMealType = _convertToRecordMealType(mealType);

    await FoodSearchBottomSheet.show(
      context: context,
      mealType: recordMealType,
      date: _selectedDate,
      onFoodSelected: (food, multiplier) => _addFoodFromSearch(mealType, food, multiplier, member.id),
    );
  }

  /// MealType 변환 (diet_analysis_model -> diet_record_model)
  diet_record.MealType _convertToRecordMealType(MealType mealType) {
    return switch (mealType) {
      MealType.breakfast => diet_record.MealType.breakfast,
      MealType.lunch => diet_record.MealType.lunch,
      MealType.dinner => diet_record.MealType.dinner,
      MealType.snack => diet_record.MealType.snack,
    };
  }

  /// 검색에서 음식 추가
  Future<void> _addFoodFromSearch(MealType mealType, FoodItem food, double multiplier, String memberId) async {
    // FoodItem에 multiplier 적용
    final adjustedFood = food.multiply(multiplier);

    // DietAnalysisModel로 변환하여 저장
    final record = DietAnalysisModel(
      id: '', // Firestore가 생성
      memberId: memberId,
      mealType: mealType,
      imageUrl: '', // 검색으로 추가한 음식은 이미지 없음
      foodName: adjustedFood.name,
      calories: adjustedFood.calories.toInt(),
      protein: adjustedFood.protein,
      carbs: adjustedFood.carbs,
      fat: adjustedFood.fat,
      confidence: 1.0, // 데이터베이스 검색은 신뢰도 100%
      analyzedAt: _selectedDate,
      createdAt: DateTime.now(),
    );

    try {
      // Repository를 통해 저장
      final repository = ref.read(dietAnalysisRepositoryProvider);
      await repository.create(record);

      // 데이터 새로고침
      final isToday = _isToday(_selectedDate);
      if (isToday) {
        ref.invalidate(dailyNutritionSummaryProvider(memberId));
      } else {
        ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: memberId, date: _selectedDate)));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${adjustedFood.name} 추가 완료! (${adjustedFood.calories.toInt()} kcal)'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.secondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('음식 추가 실패: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// 식단 기록 삭제
  Future<void> _deleteDietRecord(DietAnalysisModel record) async {
    final member = ref.read(currentMemberProvider);
    if (member == null) return;

    try {
      final repository = ref.read(dietAnalysisRepositoryProvider);
      await repository.delete(record.id);

      // 데이터 새로고침
      final isToday = _isToday(_selectedDate);
      if (isToday) {
        ref.invalidate(dailyNutritionSummaryProvider(member.id));
      } else {
        ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: member.id, date: _selectedDate)));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.foodName} 삭제됨'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '실행 취소',
            onPressed: () async {
              // 삭제 취소 - 다시 생성
              await repository.create(record);
              if (isToday) {
                ref.invalidate(dailyNutritionSummaryProvider(member.id));
              } else {
                ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: member.id, date: _selectedDate)));
              }
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 실패: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// 촬영 가이드 다이얼로그 표시
  Future<void> _showPhotoGuideDialog() async {
    final cs = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Text('📸 '),
            Text('촬영 가이드'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정확한 분석을 위해:', style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
            const SizedBox(height: 12),
            _buildGuideItem('✓', '음식이 잘 보이도록 촬영해주세요', cs),
            const SizedBox(height: 6),
            _buildGuideItem('✓', '밝은 곳에서 촬영하면 좋아요', cs),
            const SizedBox(height: 6),
            _buildGuideItem('✓', '음식 전체가 화면에 들어오게 해주세요', cs),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8A00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                  Expanded(
                    child: Text(
                      '음식이 아닌 이미지는 분석이 어려워요',
                      style: TextStyle(
                        color: const Color(0xFFFF8A00),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 가이드 항목 위젯
  Widget _buildGuideItem(String icon, String text, ColorScheme cs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: TextStyle(fontSize: 16, color: cs.primary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.8))),
        ),
      ],
    );
  }

  /// AI 분석을 위한 이미지 소스 선택 다이얼로그
  Future<void> _showAnalyzeBottomSheet() async {
    final member = ref.read(currentMemberProvider);
    if (member == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보를 찾을 수 없어요'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    // 촬영 가이드 먼저 표시
    await _showPhotoGuideDialog();

    if (!mounted) return;

    final cs = Theme.of(context).colorScheme;

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('AI 식단 분석', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('음식 사진을 찍으면 AI가 영양 정보를 분석해드려요', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            // 식사 타입 선택
            Text('식사 유형을 선택해주세요', style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MealType.values.map((type) => _buildMealTypeChip(ctx, type, member.id)).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeChip(BuildContext ctx, MealType mealType, String memberId) {
    final cs = Theme.of(ctx).colorScheme;
    final labels = {
      MealType.breakfast: '아침',
      MealType.lunch: '점심',
      MealType.dinner: '저녁',
      MealType.snack: '간식',
    };

    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _selectImageAndAnalyze(memberId, mealType);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MealTypeIcon(mealType: mealType),
            const SizedBox(width: 8),
            Text(labels[mealType]!, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 및 분석 실행
  Future<void> _selectImageAndAnalyze(String memberId, MealType mealType) async {
    final cs = Theme.of(context).colorScheme;

    // 이미지 소스 선택
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.onSurface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text('사진 선택', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSourceOption(ctx, Icons.camera_alt_outlined, '카메라', () => Navigator.pop(ctx, ImageSource.camera)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSourceOption(ctx, Icons.photo_library_outlined, '갤러리', () => Navigator.pop(ctx, ImageSource.gallery)),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;

    // 분석 실행
    final notifier = ref.read(dietAnalysisNotifierProvider.notifier);
    await notifier.analyzeFromSource(
      memberId: memberId,
      mealType: mealType,
      source: source,
    );

    // 결과 처리
    if (!mounted) return;
    final state = ref.read(dietAnalysisNotifierProvider);
    if (state.status == AnalysisStatus.success) {
      if (!mounted) return;
      final result = state.result;

      // 음식 인식 실패 체크 (강화된 검증)
      // 1. 0kcal 또는 매우 낮은 칼로리 (10kcal 미만)
      // 2. 음식 이름이 비어있거나 일반적인 경우
      final bool isInvalidCalories = result != null && result.calories < 10;
      final bool isInvalidFoodName = result != null &&
          (result.foodName.isEmpty ||
           result.foodName == '알 수 없음' ||
           result.foodName == 'unknown' ||
           result.foodName.length < 2);

      if (isInvalidCalories || isInvalidFoodName) {
        _showLowQualityResultDialog(
          title: '음식 인식 실패',
          message: '음식을 인식하지 못했어요.\n\n'
              '📸 촬영 팁:\n'
              '• 음식이 잘 보이도록 가까이서 촬영해주세요\n'
              '• 밝은 곳에서 촬영하면 더 정확해요\n'
              '• 그릇 전체가 보이게 촬영해주세요',
          icon: '❌',
        );
        return;
      }

      // 낮은 신뢰도 체크 (0.6 미만으로 상향)
      if (result != null && result.confidence < 0.6) {
        _showLowQualityResultDialog(
          title: '분석 결과 확인 필요',
          message: '분석 결과가 정확하지 않을 수 있어요.\n'
              '아래 결과를 확인하고 사용하거나, 다시 촬영해주세요.',
          icon: '⚠️',
          showResult: true,
          result: result,
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.result?.foodName ?? "음식"} 분석 완료! (${state.result?.calories ?? 0} kcal)'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.secondary,
        ),
      );
    } else if (state.status == AnalysisStatus.failure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.errorMessage ?? '분석에 실패했어요'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  /// 낮은 품질 결과 다이얼로그 표시
  Future<void> _showLowQualityResultDialog({
    required String title,
    required String message,
    required String icon,
    bool showResult = false,
    DietAnalysisModel? result,
  }) async {
    final cs = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Text('$icon '),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (showResult && result != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('분석된 내용:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 8),
                    Text(result.foodName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${result.calories} kcal', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(result.nutritionSummary, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (showResult && result != null)
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // 결과를 그대로 사용
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${result.foodName} 추가됐어요'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppTheme.secondary,
                  ),
                );
              },
              child: const Text('그대로 사용'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // 결과 삭제
              if (result != null) {
                _deleteDietRecord(result);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: showResult ? cs.onSurface.withValues(alpha: 0.6) : cs.primary,
            ),
            child: Text(showResult ? '다시 촬영' : '확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceOption(BuildContext ctx, IconData icon, String label, VoidCallback onTap) {
    final cs = Theme.of(ctx).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: cs.primary),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final member = ref.watch(currentMemberProvider);
    final analysisState = ref.watch(dietAnalysisNotifierProvider);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('식단 기록'), centerTitle: true),
        body: const Center(child: Text('회원 정보를 찾을 수 없어요')),
      );
    }

    // 선택된 날짜의 영양 요약 조회 (오늘이면 스트림, 아니면 Future)
    final isToday = _isToday(_selectedDate);
    final summaryAsync = isToday
        ? ref.watch(dailyNutritionSummaryProvider(member.id))
        : ref.watch(dailyNutritionSummaryByDateProvider((memberId: member.id, date: _selectedDate)));

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '식단 기록',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF191F28),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: MeshGradientBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildDateSelector(cs, tt),
                  Expanded(
                    child: summaryAsync.when(
                      loading: () => _buildShimmerLoading(cs),
                      error: (error, _) => ErrorState.fromError(error, onRetry: () {
                        if (isToday) {
                          ref.invalidate(dailyNutritionSummaryProvider(member.id));
                        } else {
                          ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: member.id, date: _selectedDate)));
                        }
                      }),
                      data: (summary) => _buildContent(cs, tt, summary, isToday),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: AppNavGlass.fabBottomPadding,
              child: analysisState.isLoading
                  ? FloatingActionButton.extended(
                      onPressed: null,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      icon: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      label: const Text('분석 중...'),
                    )
                  : FloatingActionButton.extended(
                      onPressed: _showAnalyzeBottomSheet,
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('AI 촬영'),
                    )
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(
                        duration: 2000.ms,
                        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.3),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(ColorScheme cs, TextTheme tt) {
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outline.withValues(alpha: 0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filled(
            onPressed: () => _changeDate(-1),
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(backgroundColor: cs.surfaceContainerHighest, foregroundColor: cs.onSurface),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 7)),
              );
              if (picked != null) {
                final member = ref.read(currentMemberProvider);
                setState(() => _selectedDate = picked);
                // 날짜 변경 시 해당 날짜의 데이터를 다시 조회하도록 invalidate
                if (member != null) {
                  ref.invalidate(dailyNutritionSummaryByDateProvider((memberId: member.id, date: picked)));
                }
              }
            },
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(dateFormat.format(_selectedDate), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 20, color: cs.onSurface.withValues(alpha: 0.5)),
                  ],
                ),
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text('오늘', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
                  ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: () => _changeDate(1),
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(backgroundColor: cs.surfaceContainerHighest, foregroundColor: cs.onSurface),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildShimmerLoading(ColorScheme cs) {
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHighest,
      highlightColor: cs.surface,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => Container(
          height: i == 0 ? 120 : 100,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, TextTheme tt, DailyNutritionSummary summary, bool isToday) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 칼로리 요약 카드
          _buildCalorieSummaryCard(cs, tt, summary, isToday).animate().fadeIn(duration: 200.ms).slideY(begin: 0.02, end: 0),
          const SizedBox(height: 16),
          // 영양소 카드
          _buildNutrientCards(cs, tt, summary).animate(delay: 50.ms).fadeIn(duration: 200.ms),
          const SizedBox(height: 20),
          // 식사별 섹션
          ...MealType.values.asMap().entries.map((e) {
            final mealRecords = summary.recordsByMealType[e.value] ?? [];
            return _buildMealSection(e.value, mealRecords, cs, tt)
                .animate(delay: Duration(milliseconds: 75 + 50 * e.key))
                .fadeIn(duration: 200.ms)
                .slideX(begin: 0.02, end: 0);
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCalorieSummaryCard(ColorScheme cs, TextTheme tt, DailyNutritionSummary summary, bool isToday) {
    final progress = summary.calorieProgress(_targetCalories);
    final isOver = summary.totalCalories > _targetCalories;
    final fmt = NumberFormat('#,###');
    final summaryLabel = isToday ? '오늘 총 섭취' : '해당일 총 섭취';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(summaryLabel, style: tt.bodyMedium?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmt.format(summary.totalCalories), style: tt.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('kcal', style: tt.bodyLarge?.copyWith(color: Colors.white70))),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showTargetEditDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('목표', style: tt.bodySmall?.copyWith(color: Colors.white70)),
                          const SizedBox(width: 4),
                          Icon(Icons.edit, size: 12, color: Colors.white70),
                        ],
                      ),
                      Text('${fmt.format(_targetCalories)} kcal', style: tt.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(isOver ? AppTheme.error : Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toInt()}% 달성', style: tt.bodySmall?.copyWith(color: Colors.white70)),
              Text(
                isOver ? '${fmt.format(summary.totalCalories - _targetCalories)} kcal 초과' : '${fmt.format(_targetCalories - summary.totalCalories)} kcal 남음',
                style: tt.bodySmall?.copyWith(color: isOver ? const Color(0xFFFFCDD2) : Colors.white70, fontWeight: isOver ? FontWeight.w600 : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientCards(ColorScheme cs, TextTheme tt, DailyNutritionSummary summary) {
    return Row(
      children: [
        Expanded(child: _buildNutrientCard('탄수화물', summary.totalCarbs, _targetCarbs, 'g', const Color(0xFF5B8DEF), cs, tt)),
        const SizedBox(width: 8),
        Expanded(child: _buildNutrientCard('단백질', summary.totalProtein, _targetProtein, 'g', const Color(0xFF10B981), cs, tt)),
        const SizedBox(width: 8),
        Expanded(child: _buildNutrientCard('지방', summary.totalFat, _targetFat, 'g', const Color(0xFFF59E0B), cs, tt)),
      ],
    );
  }

  Widget _buildNutrientCard(String label, double current, double target, String unit, Color color, ColorScheme cs, TextTheme tt) {
    final progress = (current / target).clamp(0.0, 1.0);

    return AppCard(
      variant: AppCardVariant.standard,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.75))),
          const SizedBox(height: 8),
          Text('${current.toStringAsFixed(0)}$unit', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text('/ ${target.toStringAsFixed(0)}$unit', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildMealSection(MealType mealType, List<DietAnalysisModel> items, ColorScheme cs, TextTheme tt) {
    final sectionCal = items.fold<int>(0, (s, i) => s + i.calories);
    final labels = {MealType.breakfast: '아침', MealType.lunch: '점심', MealType.dinner: '저녁', MealType.snack: '간식'};
    final colors = {
      MealType.breakfast: const Color(0xFFFFB347),
      MealType.lunch: const Color(0xFFFFD700),
      MealType.dinner: const Color(0xFF9370DB),
      MealType.snack: const Color(0xFF90EE90),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        variant: AppCardVariant.standard,
        padding: EdgeInsets.zero,
        child: Column(
        children: [
          // 헤더 (탭하여 음식 검색 추가)
          InkWell(
            onTap: () => _showFoodSearch(mealType),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  _MealTypeIcon(mealType: mealType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(labels[mealType]!, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (items.isNotEmpty)
                          Text('${NumberFormat('#,###').format(sectionCal)} kcal', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)))
                        else
                          Text('탭하여 음식 추가', style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
                      ],
                    ),
                  ),
                  // 추가 버튼
                  IconButton(
                    onPressed: () => _showFoodSearch(mealType),
                    icon: Icon(Icons.add_circle_outline, color: colors[mealType]),
                    tooltip: '음식 추가',
                  ),
                ],
              ),
            ),
          ),
          // 아이템 목록 또는 빈 상태
          if (items.isEmpty)
            InkWell(
              onTap: () => _showFoodSearch(mealType),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.add_circle_outline, size: 32, color: cs.onSurface.withValues(alpha: 0.2)),
                    const SizedBox(height: 8),
                    Text('음식을 추가해보세요', style: tt.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              ),
            )
          else
            ...items.asMap().entries.map((entry) =>
              _buildDietItemTile(entry.value, cs, tt)
                  .animate(delay: Duration(milliseconds: 50 * entry.key))
                  .fadeIn(duration: 200.ms)
                  .slideX(begin: 0.02, end: 0)
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildDietItemTile(DietAnalysisModel item, ColorScheme cs, TextTheme tt) {
    // 검색으로 추가한 음식인지 확인 (imageUrl이 비어있으면 검색 추가)
    final isFromSearch = item.imageUrl.isEmpty;

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteDietRecord(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withValues(alpha: 0.1),
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.1))),
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('음식 삭제'),
            content: Text('${item.foodName}을(를) 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ?? false;
      },
      child: InkWell(
        onTap: () => _showDietItemDetail(item, cs, tt),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.1)))),
          child: Row(
            children: [
              // 썸네일
              GestureDetector(
                onTap: item.imageUrl.isNotEmpty
                    ? () => _showFullImage(context, item.imageUrl, item.foodName)
                    : null,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    image: item.imageUrl.isNotEmpty
                        ? DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: item.imageUrl.isEmpty
                      ? Icon(Icons.restaurant, color: cs.onSurface.withValues(alpha: 0.3))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.foodName, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        // 입력 타입 표시 (AI 분석 or 검색)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isFromSearch
                                ? AppTheme.primary.withValues(alpha: 0.1)
                                : item.confidenceColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isFromSearch ? '검색' : 'AI ${item.confidenceLabel}',
                            style: TextStyle(
                              fontSize: 10,
                              color: isFromSearch ? AppTheme.primary : item.confidenceColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(item.caloriesFormatted, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.nutritionSummary, style: tt.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5)), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 상세보기 화살표
              Icon(Icons.chevron_right, size: 20, color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  /// 식단 아이템 상세 바텀시트
  void _showDietItemDetail(DietAnalysisModel item, ColorScheme cs, TextTheme tt) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 핸들바
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // 사진 (있을 경우)
                if (item.imageUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => _showFullImage(sheetContext, item.imageUrl, item.foodName),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fullscreen, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text('원본 보기', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // 음식 이름 + 칼로리
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.foodName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${item.calories} kcal', style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 영양소 상세
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildNutrientRow('탄수화물', '${item.carbs.toStringAsFixed(1)}g', const Color(0xFF5B8DEF), colorScheme),
                        const SizedBox(height: 12),
                        _buildNutrientRow('단백질', '${item.protein.toStringAsFixed(1)}g', const Color(0xFF10B981), colorScheme),
                        const SizedBox(height: 12),
                        _buildNutrientRow('지방', '${item.fat.toStringAsFixed(1)}g', const Color(0xFFF59E0B), colorScheme),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrientRow(String label, String value, Color color, ColorScheme cs) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface)),
      ],
    );
  }

  /// 전체 화면 이미지 뷰어
  void _showFullImage(BuildContext ctx, String imageUrl, String title) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 식사 유형별 아이콘 위젯 (Frosted Glass Gradient)
class _MealTypeIcon extends StatelessWidget {
  final MealType mealType;

  const _MealTypeIcon({required this.mealType});

  @override
  Widget build(BuildContext context) {
    // 식사 유형별 색상
    final colors = {
      MealType.breakfast: const Color(0xFFFF8A00),
      MealType.lunch: const Color(0xFFFFD700),
      MealType.dinner: const Color(0xFF5C6BC0),
      MealType.snack: const Color(0xFF66BB6A),
    };

    // 식사 유형별 아이콘
    final icons = {
      MealType.breakfast: Icons.wb_sunny_rounded,
      MealType.lunch: Icons.light_mode_rounded,
      MealType.dinner: Icons.dark_mode_rounded,
      MealType.snack: Icons.eco_rounded,
    };

    return GlassIcon(
      icon: icons[mealType] ?? Icons.restaurant,
      size: 40,
      iconSize: 22,
      color: colors[mealType],
      iconColor: Colors.white,
      blurSigma: 6,
    );
  }
}
