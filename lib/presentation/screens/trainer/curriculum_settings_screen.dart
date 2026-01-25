import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/exercise_db_model.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/wheel_picker_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/chip_button_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/exercise_search_widget.dart';

/// AI 커리큘럼 V2 설정 화면
class CurriculumSettingsScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? memberName;

  const CurriculumSettingsScreen({
    super.key,
    this.memberId,
    this.memberName,
  });

  @override
  ConsumerState<CurriculumSettingsScreen> createState() =>
      _CurriculumSettingsScreenState();
}

class _CurriculumSettingsScreenState
    extends ConsumerState<CurriculumSettingsScreen> {
  int _exerciseCount = 5;
  int _setCount = 3;
  int _sessionCount = 1;
  final List<String> _focusParts = [];
  final List<String> _excludedBodyParts = [];
  final List<String> _styles = [];
  final List<ExerciseDbModel> _excludedExercises = [];
  final _notesController = TextEditingController();

  // 선택 옵션들
  static const List<String> _focusPartOptions = [
    '가슴', '등', '하체', '어깨', '팔', '복근', '전신',
  ];

  static const List<String> _injuryPartOptions = [
    '어깨', '허리', '무릎', '손목', '발목', '목', '팔꿈치', '고관절',
  ];

  static const List<String> _styleOptions = [
    '고중량', '저중량', '고반복', '저반복',
    '서킷', '슈퍼세트', '드롭세트', '피라미드', '자이언트세트',
    '컴파운드 위주', '고립 위주',
    '스트렝스', '근비대', '근지구력',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

  CurriculumSettings _buildSettings() {
    return CurriculumSettings(
      exerciseCount: _exerciseCount,
      setCount: _setCount,
      sessionCount: _sessionCount,
      focusParts: List.from(_focusParts),
      styles: List.from(_styles),
      excludedParts: List.from(_excludedBodyParts),
      additionalNotes: _notesController.text.isNotEmpty
          ? _notesController.text
          : null,
    );
  }

  Future<void> _generate() async {
    if (widget.memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 없습니다.')),
      );
      return;
    }

    final settings = _buildSettings();

    // Navigate to result screen
    context.push(
      '/trainer/curriculum/result',
      extra: {
        'memberId': widget.memberId,
        'memberName': widget.memberName,
        'settings': settings,
        'excludedExerciseIds': _excludedExercises.map((e) => e.id).toList(),
      },
    );
  }

  Future<void> _generateWithDefaults() async {
    if (widget.memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 없습니다.')),
      );
      return;
    }

    // 기본 설정으로 바로 생성
    const settings = CurriculumSettings();

    context.push(
      '/trainer/curriculum/result',
      extra: {
        'memberId': widget.memberId,
        'memberName': widget.memberName,
        'settings': settings,
        'excludedExerciseIds': <String>[],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const emerald = Color(0xFF10B981);

    // 프리셋 로드 (최초 1회)
    // Note: In real usage, trainerId would come from auth state
    // For now, we'll skip preset loading if not available

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else if (widget.memberId != null && widget.memberId!.isNotEmpty) {
              context.go('/trainer/members/${widget.memberId}');
            } else {
              context.go('/trainer');
            }
          },
        ),
        title: Text(
          widget.memberName != null
              ? '${widget.memberName} 커리큘럼 설정'
              : '커리큘럼 설정',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본 설정
            _buildSectionCard(
              theme: theme,
              icon: Icons.fitness_center,
              title: '기본 설정',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WheelPickerWidget(
                    label: 'PT 횟수',
                    value: _sessionCount,
                    min: 1,
                    max: 50,
                    onChanged: (v) => setState(() => _sessionCount = v),
                  ),
                  WheelPickerWidget(
                    label: '종목 수',
                    value: _exerciseCount,
                    min: 1,
                    max: 10,
                    onChanged: (v) => setState(() => _exerciseCount = v),
                  ),
                  WheelPickerWidget(
                    label: '세트 수',
                    value: _setCount,
                    min: 1,
                    max: 10,
                    onChanged: (v) => setState(() => _setCount = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 집중 부위
            _buildSectionCard(
              theme: theme,
              icon: Icons.sports_martial_arts,
              title: '집중 부위',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _focusPartOptions.map((part) {
                  return ChipButtonWidget(
                    label: part,
                    isSelected: _focusParts.contains(part),
                    onTap: () => _toggleItem(_focusParts, part),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 운동 스타일
            _buildSectionCard(
              theme: theme,
              icon: Icons.bolt,
              title: '운동 스타일',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _styleOptions.map((style) {
                  return ChipButtonWidget(
                    label: style,
                    isSelected: _styles.contains(style),
                    onTap: () => _toggleItem(_styles, style),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 제외 운동
            _buildSectionCard(
              theme: theme,
              icon: Icons.block,
              title: '제외 운동',
              child: ExerciseSearchWidget(
                excludedExercises: _excludedExercises,
                onExclude: (ex) => setState(() => _excludedExercises.add(ex)),
                onRemove: (ex) => setState(() => _excludedExercises.remove(ex)),
              ),
            ),
            const SizedBox(height: 16),

            // 부상/통증 부위
            _buildSectionCard(
              theme: theme,
              icon: Icons.healing,
              title: '제외 부위 (부상/통증)',
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

            // 기타 요청
            _buildSectionCard(
              theme: theme,
              icon: Icons.notes,
              title: '기타 요청',
              child: TextField(
                controller: _notesController,
                maxLines: 2,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: '추가 요청사항을 입력하세요...',
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
            const SizedBox(height: 24),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _generateWithDefaults,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '스킵하고 바로 생성',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('설정 적용 후 생성'),
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
              ],
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
