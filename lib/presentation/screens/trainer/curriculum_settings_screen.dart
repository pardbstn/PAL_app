import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/exercise_db_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_template_model.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_template_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/wheel_picker_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/chip_button_widget.dart';
import 'package:flutter_pal_app/presentation/widgets/curriculum/exercise_search_widget.dart';

/// AI 커리큘럼 V2 설정 화면
class CurriculumSettingsScreen extends ConsumerStatefulWidget {
  final String? memberId;
  final String? memberName;
  /// 추가 생성 모드일 때 추가할 회차 수
  final int? additionalSessions;
  /// 추가 생성 모드일 때 시작 회차 번호
  final int? startSession;

  const CurriculumSettingsScreen({
    super.key,
    this.memberId,
    this.memberName,
    this.additionalSessions,
    this.startSession,
  });

  /// 추가 생성 모드인지 여부
  bool get isAdditionalMode => additionalSessions != null && startSession != null;

  @override
  ConsumerState<CurriculumSettingsScreen> createState() =>
      _CurriculumSettingsScreenState();
}

class _CurriculumSettingsScreenState
    extends ConsumerState<CurriculumSettingsScreen> {
  int _exerciseCount = 5;
  int _setCount = 3;
  late int _sessionCount;
  final List<String> _focusParts = [];
  final List<String> _excludedBodyParts = [];
  final List<String> _styles = [];
  final List<ExerciseDbModel> _excludedExercises = [];
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 추가 생성 모드면 additionalSessions 사용, 아니면 기본값 1
    _sessionCount = widget.additionalSessions ?? 1;
  }

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
        // 추가 생성 모드 정보
        'isAdditionalMode': widget.isAdditionalMode,
        'startSession': widget.startSession,
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

            // 부위 사이클
            _buildSectionCard(
              theme: theme,
              icon: Icons.sports_martial_arts,
              title: '부위 사이클',
              subtitle: _focusParts.isNotEmpty
                  ? '선택 순서대로 회차별로 사이클됩니다'
                  : null,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _focusPartOptions.map((part) {
                  final index = _focusParts.indexOf(part);
                  return ChipButtonWidget(
                    label: part,
                    isSelected: index >= 0,
                    orderNumber: index >= 0 ? index + 1 : null,
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
            const SizedBox(height: 16),

            // 저장된 템플릿 가져오기
            _buildSectionCard(
              theme: theme,
              icon: Icons.folder_open,
              title: '저장된 템플릿',
              subtitle: '이전에 저장한 커리큘럼 템플릿을 불러옵니다',
              child: _TemplateLoadSection(
                memberId: widget.memberId,
                memberName: widget.memberName,
                isAdditionalMode: widget.isAdditionalMode,
                startSession: widget.startSession,
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
    String? subtitle,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                  ],
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

/// 트레이너별 템플릿 스트림 프로바이더
final _trainerTemplatesProvider = StreamProvider.family<List<CurriculumTemplateModel>, String>((ref, trainerId) {
  final repo = ref.watch(curriculumTemplateRepositoryProvider);
  return repo.watchByTrainerId(trainerId);
});

/// 템플릿 불러오기 섹션
class _TemplateLoadSection extends ConsumerWidget {
  final String? memberId;
  final String? memberName;
  final bool isAdditionalMode;
  final int? startSession;

  const _TemplateLoadSection({
    required this.memberId,
    required this.memberName,
    required this.isAdditionalMode,
    required this.startSession,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final trainerId = authState.trainerModel?.id ?? authState.userId;

    if (trainerId == null || trainerId.isEmpty) {
      return Text(
        '로그인이 필요합니다',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
      );
    }

    final templatesAsync = ref.watch(_trainerTemplatesProvider(trainerId));

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.folder_off_outlined,
                    size: 32,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '저장된 템플릿이 없습니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '커리큘럼 생성 후 템플릿으로 저장할 수 있습니다',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            ...templates.take(5).map((template) => _TemplateListTile(
              template: template,
              memberId: memberId,
              memberName: memberName,
              isAdditionalMode: isAdditionalMode,
              startSession: startSession,
              isDark: isDark,
            )),
            if (templates.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => _showAllTemplates(context, ref, templates, isDark),
                  child: Text(
                    '전체 ${templates.length}개 템플릿 보기',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Column(
          children: List.generate(3, (index) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ),
      ),
      error: (error, _) => Text(
        '템플릿 로드 실패: $error',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  void _showAllTemplates(
    BuildContext context,
    WidgetRef ref,
    List<CurriculumTemplateModel> templates,
    bool isDark,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들바
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 제목
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '저장된 템플릿 (${templates.length}개)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // 템플릿 목록
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: templates.length,
                  itemBuilder: (context, index) => _TemplateListTile(
                    template: templates[index],
                    memberId: memberId,
                    memberName: memberName,
                    isAdditionalMode: isAdditionalMode,
                    startSession: startSession,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 템플릿 리스트 타일
class _TemplateListTile extends ConsumerWidget {
  final CurriculumTemplateModel template;
  final String? memberId;
  final String? memberName;
  final bool isAdditionalMode;
  final int? startSession;
  final bool isDark;

  const _TemplateListTile({
    required this.template,
    required this.memberId,
    required this.memberName,
    required this.isAdditionalMode,
    required this.startSession,
    required this.isDark,
  });

  String _getGoalLabel(FitnessGoal goal) {
    return switch (goal) {
      FitnessGoal.diet => '다이어트',
      FitnessGoal.bulk => '벌크업',
      FitnessGoal.fitness => '체력향상',
      FitnessGoal.rehab => '재활',
    };
  }

  String _getExperienceLabel(ExperienceLevel exp) {
    return switch (exp) {
      ExperienceLevel.beginner => '초급',
      ExperienceLevel.intermediate => '중급',
      ExperienceLevel.advanced => '고급',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description_outlined,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          template.name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            _buildTag(context, _getGoalLabel(template.goal), theme.colorScheme.primary),
            const SizedBox(width: 4),
            _buildTag(context, _getExperienceLabel(template.experience), theme.colorScheme.secondary),
            const SizedBox(width: 4),
            Text(
              '${template.sessionCount}회차',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            if (template.usageCount > 0) ...[
              const SizedBox(width: 8),
              Text(
                '사용 ${template.usageCount}회',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => _applyTemplate(context, ref),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _applyTemplate(BuildContext context, WidgetRef ref) {
    if (memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원 정보가 없습니다.')),
      );
      return;
    }

    // 템플릿 사용 카운트 증가
    final repo = ref.read(curriculumTemplateRepositoryProvider);
    repo.incrementUsageCount(template.id);

    // 템플릿에서 직접 커리큘럼 설정으로 결과 화면으로 이동
    // 템플릿의 세션을 CurriculumSettings와 함께 전달
    final settings = CurriculumSettings(
      sessionCount: template.sessionCount,
      exerciseCount: template.sessions.isNotEmpty
          ? template.sessions.first.exercises.length
          : 5,
    );

    context.push(
      '/trainer/curriculum/result',
      extra: {
        'memberId': memberId,
        'memberName': memberName,
        'settings': settings,
        'templateSessions': template.sessions,
        'isFromTemplate': true,
        'templateName': template.name,
        'isAdditionalMode': isAdditionalMode,
        'startSession': startSession,
      },
    );
  }
}
