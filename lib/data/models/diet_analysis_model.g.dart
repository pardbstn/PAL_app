// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DietAnalysisModel _$DietAnalysisModelFromJson(Map<String, dynamic> json) =>
    _DietAnalysisModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      imageUrl: json['imageUrl'] as String,
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toInt(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      analyzedAt: const TimestampConverter().fromJson(json['analyzedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$DietAnalysisModelToJson(_DietAnalysisModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'imageUrl': instance.imageUrl,
      'foodName': instance.foodName,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'confidence': instance.confidence,
      'analyzedAt': const TimestampConverter().toJson(instance.analyzedAt),
      'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.createdAt,
        const TimestampConverter().toJson,
      ),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
