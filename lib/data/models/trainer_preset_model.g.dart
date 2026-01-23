// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_preset_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerPresetModel _$TrainerPresetModelFromJson(Map<String, dynamic> json) =>
    _TrainerPresetModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      gymName: json['gymName'] as String?,
      excludedExerciseIds:
          (json['excludedExerciseIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      defaultExerciseCount:
          (json['defaultExerciseCount'] as num?)?.toInt() ?? 5,
      defaultSetCount: (json['defaultSetCount'] as num?)?.toInt() ?? 3,
      preferredStyles:
          (json['preferredStyles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedBodyParts:
          (json['excludedBodyParts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$TrainerPresetModelToJson(_TrainerPresetModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'gymName': instance.gymName,
      'excludedExerciseIds': instance.excludedExerciseIds,
      'defaultExerciseCount': instance.defaultExerciseCount,
      'defaultSetCount': instance.defaultSetCount,
      'preferredStyles': instance.preferredStyles,
      'excludedBodyParts': instance.excludedBodyParts,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
