// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutExercise _$WorkoutExerciseFromJson(Map<String, dynamic> json) =>
    _WorkoutExercise(
      name: json['name'] as String,
      category: $enumDecode(_$WorkoutCategoryEnumMap, json['category']),
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      restSeconds: (json['restSeconds'] as num?)?.toInt() ?? 60,
      note: json['note'] as String? ?? '',
    );

Map<String, dynamic> _$WorkoutExerciseToJson(_WorkoutExercise instance) =>
    <String, dynamic>{
      'name': instance.name,
      'category': _$WorkoutCategoryEnumMap[instance.category]!,
      'sets': instance.sets,
      'reps': instance.reps,
      'weight': instance.weight,
      'restSeconds': instance.restSeconds,
      'note': instance.note,
    };

const _$WorkoutCategoryEnumMap = {
  WorkoutCategory.chest: 'chest',
  WorkoutCategory.back: 'back',
  WorkoutCategory.shoulder: 'shoulder',
  WorkoutCategory.arm: 'arm',
  WorkoutCategory.leg: 'leg',
  WorkoutCategory.core: 'core',
  WorkoutCategory.cardio: 'cardio',
  WorkoutCategory.other: 'other',
};

_WorkoutLogModel _$WorkoutLogModelFromJson(Map<String, dynamic> json) =>
    _WorkoutLogModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String,
      trainerId: json['trainerId'] as String? ?? '',
      workoutDate: const TimestampConverter().fromJson(json['workoutDate']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      memo: json['memo'] as String? ?? '',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$WorkoutLogModelToJson(_WorkoutLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'trainerId': instance.trainerId,
      'workoutDate': const TimestampConverter().toJson(instance.workoutDate),
      'exercises': instance.exercises,
      'durationMinutes': instance.durationMinutes,
      'memo': instance.memo,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
