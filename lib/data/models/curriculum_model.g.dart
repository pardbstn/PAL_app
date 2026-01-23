// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Exercise _$ExerciseFromJson(Map<String, dynamic> json) => _Exercise(
  name: json['name'] as String,
  sets: (json['sets'] as num).toInt(),
  reps: (json['reps'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  restSeconds: (json['restSeconds'] as num?)?.toInt(),
  note: json['note'] as String?,
  exerciseId: json['exerciseId'] as String?,
  isModifiedByTrainer: json['isModifiedByTrainer'] as bool? ?? false,
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'name': instance.name,
  'sets': instance.sets,
  'reps': instance.reps,
  'weight': instance.weight,
  'restSeconds': instance.restSeconds,
  'note': instance.note,
  'exerciseId': instance.exerciseId,
  'isModifiedByTrainer': instance.isModifiedByTrainer,
};

_CurriculumSettings _$CurriculumSettingsFromJson(Map<String, dynamic> json) =>
    _CurriculumSettings(
      exerciseCount: (json['exerciseCount'] as num?)?.toInt() ?? 5,
      setCount: (json['setCount'] as num?)?.toInt() ?? 3,
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 1,
      focusParts:
          (json['focusParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedParts:
          (json['excludedParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      additionalNotes: json['additionalNotes'] as String?,
    );

Map<String, dynamic> _$CurriculumSettingsToJson(_CurriculumSettings instance) =>
    <String, dynamic>{
      'exerciseCount': instance.exerciseCount,
      'setCount': instance.setCount,
      'sessionCount': instance.sessionCount,
      'focusParts': instance.focusParts,
      'styles': instance.styles,
      'excludedParts': instance.excludedParts,
      'additionalNotes': instance.additionalNotes,
    };

_CurriculumModel _$CurriculumModelFromJson(Map<String, dynamic> json) =>
    _CurriculumModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      sessionNumber: (json['sessionNumber'] as num).toInt(),
      title: json['title'] as String,
      exercises:
          (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isCompleted: json['isCompleted'] as bool? ?? false,
      scheduledDate: const NullableTimestampConverter().fromJson(
        json['scheduledDate'],
      ),
      completedDate: const NullableTimestampConverter().fromJson(
        json['completedDate'],
      ),
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      settings: json['settings'] == null
          ? null
          : CurriculumSettings.fromJson(
              json['settings'] as Map<String, dynamic>,
            ),
      aiNotes: json['aiNotes'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$CurriculumModelToJson(_CurriculumModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'trainerId': instance.trainerId,
      'sessionNumber': instance.sessionNumber,
      'title': instance.title,
      'exercises': instance.exercises,
      'isCompleted': instance.isCompleted,
      'scheduledDate': const NullableTimestampConverter().toJson(
        instance.scheduledDate,
      ),
      'completedDate': const NullableTimestampConverter().toJson(
        instance.completedDate,
      ),
      'isAiGenerated': instance.isAiGenerated,
      'settings': instance.settings,
      'aiNotes': instance.aiNotes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
