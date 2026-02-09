// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AnalyzedFoodItem _$AnalyzedFoodItemFromJson(Map<String, dynamic> json) =>
    _AnalyzedFoodItem(
      foodName: json['foodName'] as String,
      estimatedWeight: (json['estimatedWeight'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      portionNote: json['portionNote'] as String? ?? '',
      dbCorrected: json['dbCorrected'] as bool? ?? false,
    );

Map<String, dynamic> _$AnalyzedFoodItemToJson(_AnalyzedFoodItem instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'estimatedWeight': instance.estimatedWeight,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'portionNote': instance.portionNote,
      'dbCorrected': instance.dbCorrected,
    };

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
      foods:
          (json['foods'] as List<dynamic>?)
              ?.map((e) => AnalyzedFoodItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'foods': instance.foods,
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
