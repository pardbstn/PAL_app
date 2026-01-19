import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';
import 'member_model.dart';
import 'curriculum_model.dart';

part 'curriculum_template_model.freezed.dart';
part 'curriculum_template_model.g.dart';

/// 템플릿 세션 (회차별 운동 계획)
@freezed
sealed class TemplateSession with _$TemplateSession {
  const factory TemplateSession({
    /// 회차 번호 (1, 2, 3...)
    required int sessionNumber,

    /// 제목 (예: '상체 운동')
    required String title,

    /// 설명
    String? description,

    /// 운동 목록
    @Default([]) List<Exercise> exercises,
  }) = _TemplateSession;

  factory TemplateSession.fromJson(Map<String, dynamic> json) =>
      _$TemplateSessionFromJson(json);
}

/// 커리큘럼 템플릿 모델
/// AI로 생성한 커리큘럼을 템플릿으로 저장하여 재사용
@freezed
sealed class CurriculumTemplateModel with _$CurriculumTemplateModel {
  const factory CurriculumTemplateModel({
    /// 템플릿 문서 ID
    required String id,

    /// 생성한 트레이너 ID
    required String trainerId,

    /// 템플릿 이름 (예: '초보자 다이어트 12주')
    required String name,

    /// 대상 운동 목표
    required FitnessGoal goal,

    /// 대상 경험 수준
    required ExperienceLevel experience,

    /// 총 회차 수
    required int sessionCount,

    /// 회차별 운동 계획
    @Default([]) List<TemplateSession> sessions,

    /// 사용 횟수
    @Default(0) int usageCount,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,

    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _CurriculumTemplateModel;

  factory CurriculumTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$CurriculumTemplateModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory CurriculumTemplateModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // sessions 안전하게 처리
    List<Map<String, dynamic>> sanitizedSessions = [];
    final rawSessions = data['sessions'];
    if (rawSessions is List) {
      sanitizedSessions = rawSessions
          .whereType<Map<String, dynamic>>()
          .map((session) {
        // exercises 안전하게 처리
        final rawExercises = session['exercises'];
        List<Map<String, dynamic>> sanitizedExercises = [];
        if (rawExercises is List) {
          sanitizedExercises = rawExercises
              .whereType<Map<String, dynamic>>()
              .map((e) => {
                    'name': e['name']?.toString() ?? '',
                    'sets': e['sets'] is num ? e['sets'] : 3,
                    'reps': e['reps'] is num ? e['reps'] : 10,
                    'weight': e['weight'] is num ? e['weight'] : null,
                    'restSeconds': e['restSeconds'] is num ? e['restSeconds'] : null,
                    'note': e['note']?.toString(),
                  })
              .toList();
        }
        return {
          'sessionNumber': session['sessionNumber'] is num ? session['sessionNumber'] : 1,
          'title': session['title']?.toString() ?? '',
          'description': session['description']?.toString(),
          'exercises': sanitizedExercises,
        };
      }).toList();
    }

    return CurriculumTemplateModel.fromJson({
      ...data,
      'id': doc.id,
      'sessions': sanitizedSessions,
    });
  }
}

/// CurriculumTemplateModel 확장 메서드
extension CurriculumTemplateModelX on CurriculumTemplateModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'name': name,
      'goal': goal.name,
      'experience': experience.name,
      'sessionCount': sessionCount,
      'sessions': sessions.map((s) => {
        'sessionNumber': s.sessionNumber,
        'title': s.title,
        'description': s.description,
        'exercises': s.exercises.map((e) => e.toJson()).toList(),
      }).toList(),
      'usageCount': usageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 목표 라벨
  String get goalLabel => switch (goal) {
        FitnessGoal.diet => '다이어트',
        FitnessGoal.bulk => '벌크업',
        FitnessGoal.fitness => '체력 향상',
        FitnessGoal.rehab => '재활',
      };

  /// 경험 수준 라벨
  String get experienceLabel => switch (experience) {
        ExperienceLevel.beginner => '초급',
        ExperienceLevel.intermediate => '중급',
        ExperienceLevel.advanced => '고급',
      };

  /// 총 운동 수
  int get totalExerciseCount =>
      sessions.fold(0, (total, session) => total + session.exercises.length);
}
