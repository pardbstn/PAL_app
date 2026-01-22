// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionModel _$SubscriptionModelFromJson(
  Map<String, dynamic> json,
) => _SubscriptionModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  plan:
      $enumDecodeNullable(_$SubscriptionPlanEnumMap, json['plan']) ??
      SubscriptionPlan.free,
  startDate: const SubscriptionTimestampConverter().fromJson(json['startDate']),
  endDate: const SubscriptionNullableTimestampConverter().fromJson(
    json['endDate'],
  ),
  isActive: json['isActive'] as bool? ?? true,
  features:
      (json['features'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  monthlyQuestionCount: (json['monthlyQuestionCount'] as num?)?.toInt() ?? 0,
  createdAt: const SubscriptionTimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$SubscriptionModelToJson(_SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plan': _$SubscriptionPlanEnumMap[instance.plan]!,
      'startDate': const SubscriptionTimestampConverter().toJson(
        instance.startDate,
      ),
      'endDate': const SubscriptionNullableTimestampConverter().toJson(
        instance.endDate,
      ),
      'isActive': instance.isActive,
      'features': instance.features,
      'monthlyQuestionCount': instance.monthlyQuestionCount,
      'createdAt': const SubscriptionTimestampConverter().toJson(
        instance.createdAt,
      ),
    };

const _$SubscriptionPlanEnumMap = {
  SubscriptionPlan.free: 'free',
  SubscriptionPlan.premium: 'premium',
};
