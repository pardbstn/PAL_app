// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_rating_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerRatingModel _$TrainerRatingModelFromJson(Map<String, dynamic> json) =>
    _TrainerRatingModel(
      id: json['id'] as String? ?? '',
      overall: (json['overall'] as num?)?.toDouble() ?? 0.0,
      memberRating: (json['memberRating'] as num?)?.toDouble() ?? 0.0,
      aiRating: (json['aiRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lastUpdated: const RatingTimestampConverter().fromJson(
        json['lastUpdated'],
      ),
    );

Map<String, dynamic> _$TrainerRatingModelToJson(
  _TrainerRatingModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'overall': instance.overall,
  'memberRating': instance.memberRating,
  'aiRating': instance.aiRating,
  'reviewCount': instance.reviewCount,
  'lastUpdated': const RatingTimestampConverter().toJson(instance.lastUpdated),
};
