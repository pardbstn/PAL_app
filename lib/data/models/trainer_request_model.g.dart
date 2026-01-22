// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerRequestModel _$TrainerRequestModelFromJson(Map<String, dynamic> json) =>
    _TrainerRequestModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      requestType: $enumDecode(_$RequestTypeEnumMap, json['requestType']),
      content: json['content'] as String,
      attachmentUrls:
          (json['attachmentUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      response: json['response'] as String?,
      status:
          $enumDecodeNullable(_$RequestStatusEnumMap, json['status']) ??
          RequestStatus.pending,
      price: (json['price'] as num).toInt(),
      createdAt: const RequestTimestampConverter().fromJson(json['createdAt']),
      answeredAt: const RequestNullableTimestampConverter().fromJson(
        json['answeredAt'],
      ),
    );

Map<String, dynamic> _$TrainerRequestModelToJson(
  _TrainerRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'trainerId': instance.trainerId,
  'requestType': _$RequestTypeEnumMap[instance.requestType]!,
  'content': instance.content,
  'attachmentUrls': instance.attachmentUrls,
  'response': instance.response,
  'status': _$RequestStatusEnumMap[instance.status]!,
  'price': instance.price,
  'createdAt': const RequestTimestampConverter().toJson(instance.createdAt),
  'answeredAt': const RequestNullableTimestampConverter().toJson(
    instance.answeredAt,
  ),
};

const _$RequestTypeEnumMap = {
  RequestType.question: 'question',
  RequestType.formCheck: 'formCheck',
  RequestType.monthlyCoaching: 'monthlyCoaching',
};

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.answered: 'answered',
  RequestStatus.expired: 'expired',
};
