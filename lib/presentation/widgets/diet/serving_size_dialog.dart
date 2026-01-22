import 'package:flutter/material.dart';
import '../../../data/models/food_item_model.dart';

/// 수량 선택 다이얼로그
/// 음식 선택 후 수량(배수) 선택
class ServingSizeDialog extends StatefulWidget {
  final FoodItem food;

  const ServingSizeDialog({
    super.key,
    required this.food,
  });

  /// 다이얼로그 표시 및 결과 반환
  /// 반환값: 선택한 배수 (null이면 취소)
  static Future<double?> show({
    required BuildContext context,
    required FoodItem food,
  }) {
    return showDialog<double>(
      context: context,
      builder: (context) => ServingSizeDialog(food: food),
    );
  }

  @override
  State<ServingSizeDialog> createState() => _ServingSizeDialogState();
}

class _ServingSizeDialogState extends State<ServingSizeDialog> {
  double _multiplier = 1.0;
  final _customController = TextEditingController(text: '1.0');
  bool _isCustom = false;

  final List<double> _presetMultipliers = [0.5, 1.0, 1.5, 2.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  FoodItem get _calculatedFood => widget.food.multiply(_multiplier);

  void _selectPreset(double value) {
    setState(() {
      _multiplier = value;
      _isCustom = false;
      _customController.text = value.toString();
    });
  }

  void _onCustomChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0 && parsed <= 10) {
      setState(() {
        _multiplier = parsed;
        _isCustom = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculated = _calculatedFood;

    return AlertDialog(
      title: Text(
        widget.food.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 기본 영양정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '1회 제공량: ${widget.food.servingSizeText}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.food.calories.toInt()} kcal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 수량 선택
            Text(
              '수량 선택',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 프리셋 버튼들
            Wrap(
              spacing: 8,
              children: _presetMultipliers.map((value) {
                final isSelected = !_isCustom && _multiplier == value;
                return ChoiceChip(
                  label: Text('$value인분'),
                  selected: isSelected,
                  onSelected: (_) => _selectPreset(value),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // 직접 입력
            Row(
              children: [
                ChoiceChip(
                  label: const Text('직접입력'),
                  selected: _isCustom,
                  onSelected: (_) {
                    setState(() => _isCustom = true);
                  },
                ),
                const SizedBox(width: 12),
                if (_isCustom)
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _customController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: _onCustomChanged,
                      decoration: const InputDecoration(
                        isDense: true,
                        suffix: Text('인분'),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 계산된 영양정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '$_multiplier인분 (${calculated.servingSize.toInt()}g)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${calculated.calories.toInt()} kcal',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '탄 ${calculated.carbs.toInt()}g | 단 ${calculated.protein.toInt()}g | 지 ${calculated.fat.toInt()}g',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_multiplier),
          child: const Text('추가'),
        ),
      ],
    );
  }
}
