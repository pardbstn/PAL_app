// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_badge_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BadgeItem _$BadgeItemFromJson(Map<String, dynamic> json) => _BadgeItem(
  type: json['type'] as String,
  name: json['name'] as String,
  icon: json['icon'] as String,
  earnedAt: const BadgeTimestampConverter().fromJson(json['earnedAt']),
  revokedAt: const NullableBadgeTimestampConverter().fromJson(
    json['revokedAt'],
  ),
);

Map<String, dynamic> _$BadgeItemToJson(_BadgeItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'icon': instance.icon,
      'earnedAt': const BadgeTimestampConverter().toJson(instance.earnedAt),
      'revokedAt': const NullableBadgeTimestampConverter().toJson(
        instance.revokedAt,
      ),
    };

_TrainerBadgeModel _$TrainerBadgeModelFromJson(Map<String, dynamic> json) =>
    _TrainerBadgeModel(
      id: json['id'] as String? ?? '',
      activeBadges:
          (json['activeBadges'] as List<dynamic>?)
              ?.map((e) => BadgeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      badgeHistory:
          (json['badgeHistory'] as List<dynamic>?)
              ?.map((e) => BadgeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TrainerBadgeModelToJson(_TrainerBadgeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activeBadges': instance.activeBadges,
      'badgeHistory': instance.badgeHistory,
    };
