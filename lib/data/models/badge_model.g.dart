// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BadgeModel _$BadgeModelFromJson(Map<String, dynamic> json) => _BadgeModel(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  iconUrl: json['iconUrl'] as String,
  requiredStreak: (json['requiredStreak'] as num).toInt(),
  streakType: $enumDecode(_$StreakTypeEnumMap, json['streakType']),
  badgeType:
      $enumDecodeNullable(_$BadgeTypeEnumMap, json['badgeType']) ??
      BadgeType.streak,
);

Map<String, dynamic> _$BadgeModelToJson(_BadgeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'requiredStreak': instance.requiredStreak,
      'streakType': _$StreakTypeEnumMap[instance.streakType]!,
      'badgeType': _$BadgeTypeEnumMap[instance.badgeType]!,
    };

const _$StreakTypeEnumMap = {
  StreakType.weight: 'weight',
  StreakType.diet: 'diet',
};

const _$BadgeTypeEnumMap = {
  BadgeType.streak: 'streak',
  BadgeType.achievement: 'achievement',
  BadgeType.milestone: 'milestone',
};
