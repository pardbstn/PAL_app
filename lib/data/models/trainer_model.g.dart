// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AiUsage _$AiUsageFromJson(Map<String, dynamic> json) => _AiUsage(
  curriculumCount: (json['curriculumCount'] as num?)?.toInt() ?? 0,
  predictionCount: (json['predictionCount'] as num?)?.toInt() ?? 0,
  resetDate: const TimestampConverter().fromJson(json['resetDate']),
);

Map<String, dynamic> _$AiUsageToJson(_AiUsage instance) => <String, dynamic>{
  'curriculumCount': instance.curriculumCount,
  'predictionCount': instance.predictionCount,
  'resetDate': const TimestampConverter().toJson(instance.resetDate),
};

_TrainerModel _$TrainerModelFromJson(Map<String, dynamic> json) =>
    _TrainerModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      subscriptionTier:
          $enumDecodeNullable(
            _$SubscriptionTierEnumMap,
            json['subscriptionTier'],
          ) ??
          SubscriptionTier.free,
      memberIds:
          (json['memberIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      aiUsage: AiUsage.fromJson(json['aiUsage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TrainerModelToJson(_TrainerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'subscriptionTier': _$SubscriptionTierEnumMap[instance.subscriptionTier]!,
      'memberIds': instance.memberIds,
      'aiUsage': instance.aiUsage,
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.basic: 'basic',
  SubscriptionTier.pro: 'pro',
};
