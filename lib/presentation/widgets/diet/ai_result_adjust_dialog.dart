import 'package:flutter/material.dart';
import '../../../data/models/diet_analysis_model.dart';

/// AI 분석 결과 확인 및 배수 조정 다이얼로그
///
/// 개별 음식 항목별로 배수를 +/- 0.5 단위로 조정하고 영양소를 재계산
class AiResultAdjustDialog extends StatefulWidget {
  final DietAnalysisModel result;

  const AiResultAdjustDialog({super.key, required this.result});

  /// 다이얼로그 표시
  /// 반환: 조정된 foods 리스트 + 총합 (null이면 취소)
  static Future<AdjustedResult?> show({
    required BuildContext context,
    required DietAnalysisModel result,
  }) {
    return showDialog<AdjustedResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AiResultAdjustDialog(result: result),
    );
  }

  @override
  State<AiResultAdjustDialog> createState() => _AiResultAdjustDialogState();
}

class _AiResultAdjustDialogState extends State<AiResultAdjustDialog> {
  late List<double> _multipliers;
  static const _step = 0.5;
  static const _min = 0.5;
  static const _max = 6.0;

  @override
  void initState() {
    super.initState();
    _multipliers = List.filled(
      widget.result.foods.isEmpty ? 1 : widget.result.foods.length,
      1.0,
    );
  }

  int get _totalCalories {
    if (widget.result.foods.isEmpty) {
      return (widget.result.calories * _multipliers[0]).toInt();
    }
    double total = 0;
    for (var i = 0; i < widget.result.foods.length; i++) {
      total += widget.result.foods[i].calories * _multipliers[i];
    }
    return total.toInt();
  }

  double get _totalProtein {
    if (widget.result.foods.isEmpty) {
      return widget.result.protein * _multipliers[0];
    }
    double total = 0;
    for (var i = 0; i < widget.result.foods.length; i++) {
      total += widget.result.foods[i].protein * _multipliers[i];
    }
    return total;
  }

  double get _totalCarbs {
    if (widget.result.foods.isEmpty) {
      return widget.result.carbs * _multipliers[0];
    }
    double total = 0;
    for (var i = 0; i < widget.result.foods.length; i++) {
      total += widget.result.foods[i].carbs * _multipliers[i];
    }
    return total;
  }

  double get _totalFat {
    if (widget.result.foods.isEmpty) {
      return widget.result.fat * _multipliers[0];
    }
    double total = 0;
    for (var i = 0; i < widget.result.foods.length; i++) {
      total += widget.result.foods[i].fat * _multipliers[i];
    }
    return total;
  }

  List<AnalyzedFoodItem> get _adjustedFoods {
    if (widget.result.foods.isEmpty) return [];
    return List.generate(widget.result.foods.length, (i) {
      final food = widget.result.foods[i];
      final m = _multipliers[i];
      return AnalyzedFoodItem(
        foodName: food.foodName,
        estimatedWeight: food.estimatedWeight * m,
        calories: (food.calories * m * 10).roundToDouble() / 10,
        protein: (food.protein * m * 10).roundToDouble() / 10,
        carbs: (food.carbs * m * 10).roundToDouble() / 10,
        fat: (food.fat * m * 10).roundToDouble() / 10,
        portionNote: food.portionNote,
        dbCorrected: food.dbCorrected,
      );
    });
  }

  /// +/- 배수 조절 위젯
  Widget _buildMultiplierStepper(int index, ColorScheme cs, TextTheme tt) {
    final m = _multipliers[index];
    final canDecrease = m > _min;
    final canIncrease = m < _max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // - 버튼
        _StepperButton(
          icon: Icons.remove,
          enabled: canDecrease,
          cs: cs,
          onTap: () => setState(() {
            _multipliers[index] = ((m - _step) * 10).round() / 10;
          }),
        ),
        // 배수 표시
        Container(
          width: 52,
          alignment: Alignment.center,
          child: Text(
            '${m % 1 == 0 ? m.toInt() : m}x',
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: m == 1.0 ? cs.onSurface : cs.primary,
            ),
          ),
        ),
        // + 버튼
        _StepperButton(
          icon: Icons.add,
          enabled: canIncrease,
          cs: cs,
          onTap: () => setState(() {
            _multipliers[index] = ((m + _step) * 10).round() / 10;
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasFoods = widget.result.foods.isNotEmpty;

    return AlertDialog(
      title: const Text('분석 결과 확인'),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 안내 메시지
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tune, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '실제 드신 양에 맞게 배수를 조절해주세요',
                        style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 개별 음식 항목
              if (hasFoods)
                ...List.generate(widget.result.foods.length, (i) =>
                  _buildFoodItem(i, widget.result.foods[i], cs, tt),
                )
              else
                _buildSingleItem(cs, tt),

              const SizedBox(height: 12),

              // 총합 영양소
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('총 영양소', style: tt.labelSmall?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                    )),
                    const SizedBox(height: 4),
                    Text(
                      '$_totalCalories kcal',
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '탄 ${_totalCarbs.toStringAsFixed(0)}g | '
                      '단 ${_totalProtein.toStringAsFixed(0)}g | '
                      '지 ${_totalFat.toStringAsFixed(0)}g',
                      style: tt.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, AdjustedResult(
              calories: _totalCalories,
              protein: _totalProtein,
              carbs: _totalCarbs,
              fat: _totalFat,
              foods: _adjustedFoods,
            ));
          },
          child: const Text('확인'),
        ),
      ],
    );
  }

  /// 개별 음식 항목 위젯
  Widget _buildFoodItem(int index, AnalyzedFoodItem food, ColorScheme cs, TextTheme tt) {
    final m = _multipliers[index];
    final adjustedCal = (food.calories * m).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: food.dbCorrected
            ? Border.all(color: cs.primary.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 음식명 + 칼로리
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            food.foodName,
                            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (food.dbCorrected) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 14, color: cs.primary),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(food.estimatedWeight * m).toInt()}g | $adjustedCal kcal',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // +/- 배수 조절
              _buildMultiplierStepper(index, cs, tt),
            ],
          ),
        ],
      ),
    );
  }

  /// foods 배열이 없는 경우 (이전 버전 호환)
  Widget _buildSingleItem(ColorScheme cs, TextTheme tt) {
    final m = _multipliers[0];
    final adjustedCal = (widget.result.calories * m).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.result.foodName,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text('$adjustedCal kcal',
                  style: tt.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          _buildMultiplierStepper(0, cs, tt),
        ],
      ),
    );
  }
}

/// +/- 원형 버튼
class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final ColorScheme cs;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? cs.primary : cs.outline.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? cs.onPrimary : cs.outline,
        ),
      ),
    );
  }
}

/// 배수 조정 결과
class AdjustedResult {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<AnalyzedFoodItem> foods;

  const AdjustedResult({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.foods,
  });
}
