// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerReviewModel _$TrainerReviewModelFromJson(Map<String, dynamic> json) =>
    _TrainerReviewModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String,
      professionalism: (json['professionalism'] as num).toInt(),
      communication: (json['communication'] as num).toInt(),
      punctuality: (json['punctuality'] as num).toInt(),
      satisfaction: (json['satisfaction'] as num).toInt(),
      reregistrationIntent: (json['reregistrationIntent'] as num).toInt(),
      comment: json['comment'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
      createdAt: const ReviewTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$TrainerReviewModelToJson(_TrainerReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'memberId': instance.memberId,
      'professionalism': instance.professionalism,
      'communication': instance.communication,
      'punctuality': instance.punctuality,
      'satisfaction': instance.satisfaction,
      'reregistrationIntent': instance.reregistrationIntent,
      'comment': instance.comment,
      'isPublic': instance.isPublic,
      'createdAt': const ReviewTimestampConverter().toJson(instance.createdAt),
    };
