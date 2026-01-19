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
);

Map<String, dynamic> _$ExerciseToJson(_Exercise instance) => <String, dynamic>{
  'name': instance.name,
  'sets': instance.sets,
  'reps': instance.reps,
  'weight': instance.weight,
  'restSeconds': instance.restSeconds,
  'note': instance.note,
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
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
