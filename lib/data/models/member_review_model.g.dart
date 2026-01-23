// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberReviewModel _$MemberReviewModelFromJson(Map<String, dynamic> json) =>
    _MemberReviewModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      coachingSatisfaction:
          (json['coachingSatisfaction'] as num?)?.toInt() ?? 5,
      communication: (json['communication'] as num?)?.toInt() ?? 5,
      kindness: (json['kindness'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String? ?? '',
      createdAt: const ReviewTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$MemberReviewModelToJson(_MemberReviewModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'coachingSatisfaction': instance.coachingSatisfaction,
      'communication': instance.communication,
      'kindness': instance.kindness,
      'comment': instance.comment,
      'createdAt': const ReviewTimestampConverter().toJson(instance.createdAt),
    };
