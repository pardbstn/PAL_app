import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 인바디 입력 폼 위젯
/// FAB 클릭 시 BottomSheet로 표시
class InbodyInputForm extends StatefulWidget {
  final String memberId;
  final Function(InbodyFormData data) onSubmit;
  final VoidCallback? onCancel;

  const InbodyInputForm({
    super.key,
    required this.memberId,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<InbodyInputForm> createState() => _InbodyInputFormState();

  /// BottomSheet로 표시
  static Future<InbodyFormData?> showAsBottomSheet(
    BuildContext context, {
    required String memberId,
  }) async {
    return showModalBottomSheet<InbodyFormData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: InbodyInputForm(
            memberId: memberId,
            onSubmit: (data) => Navigator.of(context).pop(data),
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}

class _InbodyInputFormState extends State<InbodyInputForm> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;
  DateTime _measuredAt = DateTime.now();

  // 필수 필드
  final _weightController = TextEditingController();
  final _skeletalMuscleMassController = TextEditingController();
  final _bodyFatPercentController = TextEditingController();

  // 선택 필드
  final _bodyFatMassController = TextEditingController();
  final _bmiController = TextEditingController();
  final _basalMetabolicRateController = TextEditingController();
  final _totalBodyWaterController = TextEditingController();
  final _proteinController = TextEditingController();
  final _mineralsController = TextEditingController();
  final _visceralFatLevelController = TextEditingController();
  final _inbodyScoreController = TextEditingController();
  final _memoController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _skeletalMuscleMassController.dispose();
    _bodyFatPercentController.dispose();
    _bodyFatMassController.dispose();
    _bmiController.dispose();
    _basalMetabolicRateController.dispose();
    _totalBodyWaterController.dispose();
    _proteinController.dispose();
    _mineralsController.dispose();
    _visceralFatLevelController.dispose();
    _inbodyScoreController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '인바디 기록 입력',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(),

          // 폼 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 측정 일시
                  _buildDatePicker(context, colorScheme),
                  const SizedBox(height: 24),

                  // 필수 필드 섹션
                  Text(
                    '필수 정보',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRequiredFields(colorScheme),
                  const SizedBox(height: 24),

                  // 선택 필드 토글
                  _buildOptionalFieldsToggle(colorScheme),

                  // 선택 필드 섹션 (확장)
                  if (_showOptionalFields) ...[
                    const SizedBox(height: 16),
                    _buildOptionalFields(colorScheme)
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .slideY(begin: -0.1, end: 0),
                  ],

                  const SizedBox(height: 24),

                  // 메모
                  TextFormField(
                    controller: _memoController,
                    decoration: InputDecoration(
                      labelText: '메모 (선택)',
                      hintText: '측정 관련 메모를 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.note_outlined),
                    ),
                    maxLines: 2,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // 제출 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _handleSubmit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDatePicker(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _measuredAt,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null && context.mounted) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_measuredAt),
          );
          if (!mounted) return;
          setState(() {
            _measuredAt = DateTime(
              date.year,
              date.month,
              date.day,
              time?.hour ?? _measuredAt.hour,
              time?.minute ?? _measuredAt.minute,
            );
          });
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: colorScheme.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '측정 일시',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  _formatDateTime(_measuredAt),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredFields(ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _weightController,
                label: '체중',
                suffix: 'kg',
                icon: Icons.monitor_weight_outlined,
                validator: _validateRequired,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _skeletalMuscleMassController,
                label: '골격근량',
                suffix: 'kg',
                icon: Icons.fitness_center,
                validator: _validateRequired,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _bodyFatPercentController,
                label: '체지방률',
                suffix: '%',
                icon: Icons.water_drop_outlined,
                validator: _validateRequired,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionalFieldsToggle(ColorScheme colorScheme) {
    return InkWell(
      onTap: () {
        setState(() {
          _showOptionalFields = !_showOptionalFields;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              _showOptionalFields
                  ? Icons.expand_less
                  : Icons.expand_more,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _showOptionalFields ? '선택 정보 접기' : '선택 정보 더보기',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalFields(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선택 정보',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _bodyFatMassController,
                label: '체지방량',
                suffix: 'kg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _bmiController,
                label: 'BMI',
                suffix: '',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _basalMetabolicRateController,
                label: '기초대사량',
                suffix: 'kcal',
                isInteger: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _totalBodyWaterController,
                label: '체수분량',
                suffix: 'L',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _proteinController,
                label: '단백질',
                suffix: 'kg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _mineralsController,
                label: '무기질',
                suffix: 'kg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: _visceralFatLevelController,
                label: '내장지방 레벨',
                suffix: '',
                isInteger: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: _inbodyScoreController,
                label: '인바디 점수',
                suffix: '점',
                isInteger: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    IconData? icon,
    String? Function(String?)? validator,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix.isNotEmpty ? suffix : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: icon != null ? Icon(icon) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          isInteger ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
        ),
      ],
      validator: validator,
    );
  }

  String? _validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 입력';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return '올바른 값 입력';
    }
    return null;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = InbodyFormData(
        memberId: widget.memberId,
        measuredAt: _measuredAt,
        weight: double.parse(_weightController.text),
        skeletalMuscleMass: double.parse(_skeletalMuscleMassController.text),
        bodyFatPercent: double.parse(_bodyFatPercentController.text),
        bodyFatMass: _parseDouble(_bodyFatMassController.text),
        bmi: _parseDouble(_bmiController.text),
        basalMetabolicRate: _parseDouble(_basalMetabolicRateController.text),
        totalBodyWater: _parseDouble(_totalBodyWaterController.text),
        protein: _parseDouble(_proteinController.text),
        minerals: _parseDouble(_mineralsController.text),
        visceralFatLevel: _parseInt(_visceralFatLevelController.text),
        inbodyScore: _parseInt(_inbodyScoreController.text),
        memo: _memoController.text.isEmpty ? null : _memoController.text,
      );
      widget.onSubmit(data);
    }
  }

  double? _parseDouble(String text) {
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  int? _parseInt(String text) {
    if (text.isEmpty) return null;
    return int.tryParse(text);
  }
}

/// 인바디 폼 데이터 클래스
class InbodyFormData {
  final String memberId;
  final DateTime measuredAt;
  final double weight;
  final double skeletalMuscleMass;
  final double bodyFatPercent;
  final double? bodyFatMass;
  final double? bmi;
  final double? basalMetabolicRate;
  final double? totalBodyWater;
  final double? protein;
  final double? minerals;
  final int? visceralFatLevel;
  final int? inbodyScore;
  final String? memo;

  InbodyFormData({
    required this.memberId,
    required this.measuredAt,
    required this.weight,
    required this.skeletalMuscleMass,
    required this.bodyFatPercent,
    this.bodyFatMass,
    this.bmi,
    this.basalMetabolicRate,
    this.totalBodyWater,
    this.protein,
    this.minerals,
    this.visceralFatLevel,
    this.inbodyScore,
    this.memo,
  });
}
