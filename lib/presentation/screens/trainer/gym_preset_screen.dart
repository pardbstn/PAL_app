import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/data/models/exercise_db_model.dart';
import 'package:flutter_pal_app/data/models/trainer_preset_model.dart';
import 'package:flutter_pal_app/presentation/providers/trainer_preset_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/wheel_picker_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/chip_button_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/exercise_search_widget.dart';

/// 체육관 프리셋 설정 화면
class GymPresetScreen extends ConsumerStatefulWidget {
  final String? trainerId;

  const GymPresetScreen({super.key, this.trainerId});

  @override
  ConsumerState<GymPresetScreen> createState() => _GymPresetScreenState();
}

class _GymPresetScreenState extends ConsumerState<GymPresetScreen> {
  final _gymNameController = TextEditingController();
  int _exerciseCount = 5;
  int _setCount = 3;
  final List<String> _preferredStyles = [];
  final List<String> _excludedBodyParts = [];
  final List<ExerciseDbModel> _excludedExercises = [];
  bool _isLoading = false;
  bool _isSaving = false;

  static const List<String> _styleOptions = [
    '고중량', '저중량', '고반복', '저반복',
    '서킷', '슈퍼세트', '드롭세트', '피라미드', '자이언트세트',
    '컴파운드 위주', '고립 위주',
    '스트렝스', '근비대', '근지구력',
  ];

  static const List<String> _injuryPartOptions = [
    '어깨', '허리', '무릎', '손목', '발목', '목', '팔꿈치', '고관절',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreset();
  }

  @override
  void dispose() {
    _gymNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreset() async {
    if (widget.trainerId == null) return;
    setState(() => _isLoading = true);

    try {
      final presetAsync = await ref.read(
        trainerPresetProvider(widget.trainerId!).future,
      );
      if (presetAsync != null && mounted) {
        setState(() {
          _gymNameController.text = presetAsync.gymName ?? '';
          _exerciseCount = presetAsync.defaultExerciseCount;
          _setCount = presetAsync.defaultSetCount;
          _preferredStyles.addAll(presetAsync.preferredStyles);
          _excludedBodyParts.addAll(presetAsync.excludedBodyParts);
        });
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleItem(List<String> list, String item) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  Future<void> _save() async {
    if (widget.trainerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('트레이너 정보가 없습니다.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final preset = TrainerPresetModel(
      id: widget.trainerId!,
      trainerId: widget.trainerId!,
      gymName: _gymNameController.text.isNotEmpty
          ? _gymNameController.text
          : null,
      excludedExerciseIds: _excludedExercises.map((e) => e.id).toList(),
      defaultExerciseCount: _exerciseCount,
      defaultSetCount: _setCount,
      preferredStyles: List.from(_preferredStyles),
      excludedBodyParts: List.from(_excludedBodyParts),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(trainerPresetNotifierProvider.notifier);
    final success = await notifier.savePreset(preset);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프리셋이 저장되었습니다!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('체육관 프리셋')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('체육관 프리셋')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 체육관 이름
            _buildSectionCard(
              theme: theme,
              icon: Icons.store,
              title: '체육관 이름',
              child: TextField(
                controller: _gymNameController,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: '체육관 이름 (선택)',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 기본 설정
            _buildSectionCard(
              theme: theme,
              icon: Icons.fitness_center,
              title: '기본 설정',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WheelPickerWidget(
                    label: '기본 종목 수',
                    value: _exerciseCount,
                    min: 1,
                    max: 10,
                    onChanged: (v) => setState(() => _exerciseCount = v),
                  ),
                  WheelPickerWidget(
                    label: '기본 세트 수',
                    value: _setCount,
                    min: 1,
                    max: 10,
                    onChanged: (v) => setState(() => _setCount = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 선호 스타일
            _buildSectionCard(
              theme: theme,
              icon: Icons.bolt,
              title: '선호 운동 스타일',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _styleOptions.map((style) {
                  return ChipButtonWidget(
                    label: style,
                    isSelected: _preferredStyles.contains(style),
                    onTap: () => _toggleItem(_preferredStyles, style),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 제외 부위
            _buildSectionCard(
              theme: theme,
              icon: Icons.healing,
              title: '기본 제외 부위',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _injuryPartOptions.map((part) {
                  return ChipButtonWidget(
                    label: part,
                    isSelected: _excludedBodyParts.contains(part),
                    onTap: () => _toggleItem(_excludedBodyParts, part),
                    variant: ChipButtonVariant.danger,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 제외 운동
            _buildSectionCard(
              theme: theme,
              icon: Icons.block,
              title: '기본 제외 운동',
              child: ExerciseSearchWidget(
                excludedExercises: _excludedExercises,
                onExclude: (ex) => setState(() => _excludedExercises.add(ex)),
                onRemove: (ex) => setState(() => _excludedExercises.remove(ex)),
              ),
            ),
            const SizedBox(height: 24),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, size: 20),
                label: Text(_isSaving ? '저장 중...' : '프리셋 저장'),
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
