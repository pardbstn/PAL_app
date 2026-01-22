// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiAnalysis _$AiAnalysisFromJson(Map<String, dynamic> json) => _AiAnalysis(
  foodName: json['foodName'] as String?,
  calories: (json['calories'] as num?)?.toDouble(),
  protein: (json['protein'] as num?)?.toDouble(),
  carbs: (json['carbs'] as num?)?.toDouble(),
  fat: (json['fat'] as num?)?.toDouble(),
  confidence: (json['confidence'] as num?)?.toDouble(),
  feedback: json['feedback'] as String?,
);

Map<String, dynamic> _$AiAnalysisToJson(_AiAnalysis instance) =>
    <String, dynamic>{
      'foodName': instance.foodName,
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'confidence': instance.confidence,
      'feedback': instance.feedback,
    };

_DietRecordModel _$DietRecordModelFromJson(Map<String, dynamic> json) =>
    _DietRecordModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      recordDate: const TimestampConverter().fromJson(json['recordDate']),
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      aiAnalysis: json['aiAnalysis'] == null
          ? null
          : AiAnalysis.fromJson(json['aiAnalysis'] as Map<String, dynamic>),
      note: json['note'] as String?,
      foodId: json['foodId'] as String?,
      servingMultiplier: (json['servingMultiplier'] as num?)?.toDouble() ?? 1.0,
      inputType: json['inputType'] as String? ?? 'manual',
      foodName: json['foodName'] as String?,
      calories: (json['calories'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$DietRecordModelToJson(_DietRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'recordDate': const TimestampConverter().toJson(instance.recordDate),
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'imageUrl': instance.imageUrl,
      'description': instance.description,
      'aiAnalysis': instance.aiAnalysis,
      'note': instance.note,
      'foodId': instance.foodId,
      'servingMultiplier': instance.servingMultiplier,
      'inputType': instance.inputType,
      'foodName': instance.foodName,
      'calories': instance.calories,
      'carbs': instance.carbs,
      'protein': instance.protein,
      'fat': instance.fat,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
