// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_template_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TemplateSession _$TemplateSessionFromJson(Map<String, dynamic> json) =>
    _TemplateSession(
      sessionNumber: (json['sessionNumber'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TemplateSessionToJson(_TemplateSession instance) =>
    <String, dynamic>{
      'sessionNumber': instance.sessionNumber,
      'title': instance.title,
      'description': instance.description,
      'exercises': instance.exercises,
    };

_CurriculumTemplateModel _$CurriculumTemplateModelFromJson(
  Map<String, dynamic> json,
) => _CurriculumTemplateModel(
  id: json['id'] as String,
  trainerId: json['trainerId'] as String,
  name: json['name'] as String,
  goal: $enumDecode(_$FitnessGoalEnumMap, json['goal']),
  experience: $enumDecode(_$ExperienceLevelEnumMap, json['experience']),
  sessionCount: (json['sessionCount'] as num).toInt(),
  sessions:
      (json['sessions'] as List<dynamic>?)
          ?.map((e) => TemplateSession.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$CurriculumTemplateModelToJson(
  _CurriculumTemplateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainerId': instance.trainerId,
  'name': instance.name,
  'goal': _$FitnessGoalEnumMap[instance.goal]!,
  'experience': _$ExperienceLevelEnumMap[instance.experience]!,
  'sessionCount': instance.sessionCount,
  'sessions': instance.sessions,
  'usageCount': instance.usageCount,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};

const _$FitnessGoalEnumMap = {
  FitnessGoal.diet: 'diet',
  FitnessGoal.bulk: 'bulk',
  FitnessGoal.fitness: 'fitness',
  FitnessGoal.rehab: 'rehab',
};

const _$ExperienceLevelEnumMap = {
  ExperienceLevel.beginner: 'beginner',
  ExperienceLevel.intermediate: 'intermediate',
  ExperienceLevel.advanced: 'advanced',
};
