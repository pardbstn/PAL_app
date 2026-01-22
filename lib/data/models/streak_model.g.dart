// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakModel _$StreakModelFromJson(Map<String, dynamic> json) => _StreakModel(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  weightStreak: (json['weightStreak'] as num?)?.toInt() ?? 0,
  dietStreak: (json['dietStreak'] as num?)?.toInt() ?? 0,
  longestWeightStreak: (json['longestWeightStreak'] as num?)?.toInt() ?? 0,
  longestDietStreak: (json['longestDietStreak'] as num?)?.toInt() ?? 0,
  lastWeightRecordDate: const StreakTimestampConverter().fromJson(
    json['lastWeightRecordDate'],
  ),
  lastDietRecordDate: const StreakTimestampConverter().fromJson(
    json['lastDietRecordDate'],
  ),
  badges:
      (json['badges'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  updatedAt: const StreakRequiredTimestampConverter().fromJson(
    json['updatedAt'],
  ),
);

Map<String, dynamic> _$StreakModelToJson(_StreakModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'weightStreak': instance.weightStreak,
      'dietStreak': instance.dietStreak,
      'longestWeightStreak': instance.longestWeightStreak,
      'longestDietStreak': instance.longestDietStreak,
      'lastWeightRecordDate': const StreakTimestampConverter().toJson(
        instance.lastWeightRecordDate,
      ),
      'lastDietRecordDate': const StreakTimestampConverter().toJson(
        instance.lastDietRecordDate,
      ),
      'badges': instance.badges,
      'updatedAt': const StreakRequiredTimestampConverter().toJson(
        instance.updatedAt,
      ),
    };
