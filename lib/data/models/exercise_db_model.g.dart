// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_db_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExerciseDbModel _$ExerciseDbModelFromJson(Map<String, dynamic> json) =>
    _ExerciseDbModel(
      id: json['id'] as String,
      nameKo: json['nameKo'] as String,
      nameEn: json['nameEn'] as String? ?? '',
      equipment: json['equipment'] as String,
      equipmentEn: json['equipmentEn'] as String? ?? '',
      primaryMuscle: json['primaryMuscle'] as String,
      secondaryMuscles:
          (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      level: json['level'] as String? ?? '초급',
      force: json['force'] as String?,
      mechanic: json['mechanic'] as String?,
      instructions:
          (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$ExerciseDbModelToJson(_ExerciseDbModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameKo': instance.nameKo,
      'nameEn': instance.nameEn,
      'equipment': instance.equipment,
      'equipmentEn': instance.equipmentEn,
      'primaryMuscle': instance.primaryMuscle,
      'secondaryMuscles': instance.secondaryMuscles,
      'level': instance.level,
      'force': instance.force,
      'mechanic': instance.mechanic,
      'instructions': instance.instructions,
      'imageUrl': instance.imageUrl,
      'tags': instance.tags,
    };
