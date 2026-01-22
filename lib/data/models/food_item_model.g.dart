// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodItem _$FoodItemFromJson(Map<String, dynamic> json) => _FoodItem(
  id: json['id'] as String,
  name: json['name'] as String,
  servingSize: (json['servingSize'] as num).toDouble(),
  calories: (json['calories'] as num).toDouble(),
  carbs: (json['carbs'] as num).toDouble(),
  protein: (json['protein'] as num).toDouble(),
  fat: (json['fat'] as num).toDouble(),
  sugar: (json['sugar'] as num?)?.toDouble(),
  sodium: (json['sodium'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FoodItemToJson(_FoodItem instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'servingSize': instance.servingSize,
  'calories': instance.calories,
  'carbs': instance.carbs,
  'protein': instance.protein,
  'fat': instance.fat,
  'sugar': instance.sugar,
  'sodium': instance.sodium,
};
