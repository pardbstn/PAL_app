import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/data/models/body_record_model.dart';
import 'package:flutter_pal_app/data/repositories/body_record_repository.dart';
import 'package:flutter_pal_app/presentation/providers/body_records_provider.dart';

/// 체성분 기록 추가 바텀시트
class AddBodyRecordSheet extends ConsumerStatefulWidget {
  final String memberId;

  const AddBodyRecordSheet({super.key, required this.memberId});

  /// 바텀시트 열기
  static Future<bool?> show(BuildContext context, String memberId) {
    return showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBodyRecordSheet(memberId: memberId),
    );
  }

  @override
  ConsumerState<AddBodyRecordSheet> createState() => _AddBodyRecordSheetState();
}

class _AddBodyRecordSheetState extends ConsumerState<AddBodyRecordSheet> {
  final _formKey = GlobalKey<FormState>();

  // 입력 컨트롤러
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _muscleMassController = TextEditingController();

  // 상태
  DateTime _selectedDate = DateTime.now();
  RecordSource _recordSource = RecordSource.manual;
  bool _isLoading = false;
  String? _dateWarning; // 같은 날짜 경고 메시지

  @override
  void initState() {
    super.initState();
    // 초기 날짜(오늘)에 기록이 있는지 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingRecord(_selectedDate);
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  _buildHeader(colorScheme),
                  const SizedBox(height: 24),

                  // 기록 날짜
                  _buildDatePicker(colorScheme),
                  const SizedBox(height: 20),

                  // 체중 (필수)
                  _buildWeightField(colorScheme),
                  const SizedBox(height: 16),

                  // 체지방률 (선택)
                  _buildBodyFatField(colorScheme),
                  const SizedBox(height: 16),

                  // 골격근량 (선택)
                  _buildMuscleMassField(colorScheme),
                  const SizedBox(height: 20),

                  // 데이터 소스
                  _buildDataSourceSelector(colorScheme),
                  const SizedBox(height: 32),

                  // 저장 버튼
                  _buildSaveButton(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '체성분 기록 추가',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '기록 날짜',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _dateWarning != null ? AppTheme.error : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _dateWarning != null ? AppTheme.error : AppTheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('yyyy년 M월 d일').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
        // 같은 날짜 경고 메시지
        if (_dateWarning != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _dateWarning!,
                    style: const TextStyle(
                      color: AppTheme.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _checkExistingRecord(picked);
    }
  }

  /// 같은 날짜에 기록이 있는지 확인
  Future<void> _checkExistingRecord(DateTime date) async {
    final repository = ref.read(bodyRecordRepositoryProvider);
    final existingRecord = await repository.getByDate(widget.memberId, date);
    setState(() {
      _dateWarning = existingRecord != null
          ? '이 날짜에 이미 기록이 있어요. 저장 시 기존 기록을 삭제한 후 다시 시도해주세요'
          : null;
    });
  }

  Widget _buildWeightField(ColorScheme colorScheme) {
    return _buildNumberField(
      colorScheme: colorScheme,
      label: '체중',
      hint: '예: 72.5',
      suffix: 'kg',
      controller: _weightController,
      isRequired: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '체중을 입력해주세요';
        }
        final weight = double.tryParse(value);
        if (weight == null || weight <= 0 || weight > 300) {
          return '올바른 체중을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildBodyFatField(ColorScheme colorScheme) {
    return _buildNumberField(
      colorScheme: colorScheme,
      label: '체지방률',
      hint: '예: 18.5',
      suffix: '%',
      controller: _bodyFatController,
      isRequired: false,
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final bodyFat = double.tryParse(value);
        if (bodyFat == null || bodyFat < 0 || bodyFat > 80) {
          return '올바른 체지방률을 입력해주세요 (0-80%)';
        }
        return null;
      },
    );
  }

  Widget _buildMuscleMassField(ColorScheme colorScheme) {
    return _buildNumberField(
      colorScheme: colorScheme,
      label: '골격근량',
      hint: '예: 32.0',
      suffix: 'kg',
      controller: _muscleMassController,
      isRequired: false,
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final muscleMass = double.tryParse(value);
        if (muscleMass == null || muscleMass < 0 || muscleMass > 100) {
          return '올바른 골격근량을 입력해주세요 (0-100kg)';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField({
    required ColorScheme colorScheme,
    required String label,
    required String hint,
    required String suffix,
    required TextEditingController controller,
    required bool isRequired,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.error),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDataSourceSelector(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '데이터 소스',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDataSourceChip(
                label: '직접 입력',
                icon: Icons.edit_outlined,
                source: RecordSource.manual,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDataSourceChip(
                label: 'AI 인바디 분석',
                icon: Icons.camera_alt_outlined,
                source: RecordSource.inbodyApi,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataSourceChip({
    required String label,
    required IconData icon,
    required RecordSource source,
  }) {
    final isSelected = _recordSource == source;
    return InkWell(
      onTap: () => setState(() => _recordSource = source),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppTheme.primary : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primary : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveRecord,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                '저장',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _saveRecord() async {
    if (!_formKey.currentState!.validate()) return;

    // 같은 날짜 경고가 있으면 저장 불가
    if (_dateWarning != null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(bodyRecordRepositoryProvider);

      // 같은 날짜에 기록이 이미 있는지 다시 확인 (동시성 방지)
      final existingRecord = await repository.getByDate(widget.memberId, _selectedDate);
      if (existingRecord != null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _dateWarning = '이 날짜에 이미 기록이 있어요. 다른 날짜를 선택해주세요';
          });
        }
        return;
      }

      final weight = double.parse(_weightController.text);
      final bodyFatPercent = _bodyFatController.text.isNotEmpty
          ? double.parse(_bodyFatController.text)
          : null;
      final muscleMass = _muscleMassController.text.isNotEmpty
          ? double.parse(_muscleMassController.text)
          : null;

      final record = BodyRecordModel(
        id: '',
        memberId: widget.memberId,
        recordDate: _selectedDate,
        weight: weight,
        bodyFatPercent: bodyFatPercent,
        muscleMass: muscleMass,
        source: _recordSource,
        createdAt: DateTime.now(),
      );

      await repository.create(record);

      // Provider 무효화
      ref.invalidate(bodyRecordsProvider(widget.memberId));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('체성분 기록이 저장됐어요'),
            backgroundColor: AppTheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
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
