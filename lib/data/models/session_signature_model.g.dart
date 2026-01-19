// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_signature_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionSignatureModel _$SessionSignatureModelFromJson(
  Map<String, dynamic> json,
) => _SessionSignatureModel(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  trainerId: json['trainerId'] as String,
  curriculumId: json['curriculumId'] as String,
  sessionNumber: (json['sessionNumber'] as num).toInt(),
  signatureImageUrl: json['signatureImageUrl'] as String,
  signedAt: const TimestampConverter().fromJson(json['signedAt']),
  memo: json['memo'] as String?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$SessionSignatureModelToJson(
  _SessionSignatureModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'trainerId': instance.trainerId,
  'curriculumId': instance.curriculumId,
  'sessionNumber': instance.sessionNumber,
  'signatureImageUrl': instance.signatureImageUrl,
  'signedAt': const TimestampConverter().toJson(instance.signedAt),
  'memo': instance.memo,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
