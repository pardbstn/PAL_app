import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/curriculum_template_model.dart';
import 'package:flutter_pal_app/data/models/member_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_template_repository.dart';
import 'package:flutter_pal_app/data/services/ai_service.dart';

/// 커리큘럼 템플릿 상태
class CurriculumTemplateState {
  final List<CurriculumTemplateModel> templates;
  final bool isLoading;
  final String? error;

  const CurriculumTemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
  });

  CurriculumTemplateState copyWith({
    List<CurriculumTemplateModel>? templates,
    bool? isLoading,
    String? error,
  }) {
    return CurriculumTemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 커리큘럼 템플릿 노티파이어
class CurriculumTemplateNotifier extends Notifier<CurriculumTemplateState> {
  CurriculumTemplateRepository get _repository =>
      ref.read(curriculumTemplateRepositoryProvider);

  @override
  CurriculumTemplateState build() {
    return const CurriculumTemplateState();
  }

  /// 트레이너별 템플릿 로드
  Future<void> loadTemplates(String trainerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final templates = await _repository.getByTrainerId(trainerId);
      state = state.copyWith(templates: templates, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// AI 생성 커리큘럼을 템플릿으로 저장
  Future<String> saveAsTemplate({
    required String trainerId,
    required String name,
    required FitnessGoal goal,
    required ExperienceLevel experience,
    required List<GeneratedCurriculum> curriculums,
  }) async {
    final now = DateTime.now();

    // GeneratedCurriculum을 TemplateSession으로 변환
    final sessions = curriculums.map((c) {
      return TemplateSession(
        sessionNumber: c.sessionNumber,
        title: c.title,
        description: c.description,
        exercises: c.exercises.map((e) => e.toExercise()).toList(),
      );
    }).toList();

    final template = CurriculumTemplateModel(
      id: '',
      trainerId: trainerId,
      name: name,
      goal: goal,
      experience: experience,
      sessionCount: curriculums.length,
      sessions: sessions,
      usageCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    final templateId = await _repository.create(template);

    // 상태 갱신
    await loadTemplates(trainerId);

    return templateId;
  }

  /// 목표/경험에 맞는 템플릿 필터링 (클라이언트 측 필터링)
  Future<List<CurriculumTemplateModel>> getMatchingTemplates({
    required String trainerId,
    required FitnessGoal goal,
    required ExperienceLevel experience,
  }) async {
    // 복합 인덱스 문제를 피하기 위해 클라이언트 측 필터링 사용
    final allTemplates = await _repository.getByTrainerId(trainerId);
    return allTemplates
        .where((t) => t.goal == goal && t.experience == experience)
        .toList()
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
  }

  /// 템플릿 사용 횟수 증가
  Future<void> incrementUsage(String templateId) async {
    await _repository.incrementUsageCount(templateId);
  }

  /// 템플릿 삭제
  Future<void> deleteTemplate(String templateId, String trainerId) async {
    await _repository.delete(templateId);
    await loadTemplates(trainerId);
  }

  /// 템플릿 이름 수정
  Future<void> updateTemplateName(
      String templateId, String name, String trainerId) async {
    await _repository.updateName(templateId, name);
    await loadTemplates(trainerId);
  }
}

/// 커리큘럼 템플릿 Provider
final curriculumTemplateProvider =
    NotifierProvider<CurriculumTemplateNotifier, CurriculumTemplateState>(() {
  return CurriculumTemplateNotifier();
});

/// 특정 목표/경험에 맞는 템플릿 Provider (클라이언트 측 필터링)
final matchingTemplatesProvider = FutureProvider.family<
    List<CurriculumTemplateModel>,
    ({String trainerId, FitnessGoal goal, ExperienceLevel experience})>(
        (ref, params) async {
  final repository = ref.watch(curriculumTemplateRepositoryProvider);
  // 복합 인덱스 문제를 피하기 위해 클라이언트 측 필터링 사용
  final allTemplates = await repository.getByTrainerId(params.trainerId);
  return allTemplates
      .where((t) => t.goal == params.goal && t.experience == params.experience)
      .toList()
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
});
