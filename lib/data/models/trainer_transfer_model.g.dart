// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerTransferModel _$TrainerTransferModelFromJson(
  Map<String, dynamic> json,
) => _TrainerTransferModel(
  id: json['id'] as String? ?? '',
  memberId: json['memberId'] as String,
  memberName: json['memberName'] as String,
  fromTrainerId: json['fromTrainerId'] as String,
  fromTrainerName: json['fromTrainerName'] as String,
  toTrainerId: json['toTrainerId'] as String,
  toTrainerName: json['toTrainerName'] as String,
  status:
      $enumDecodeNullable(_$TransferStatusEnumMap, json['status']) ??
      TransferStatus.pending,
  reason: json['reason'] as String? ?? '',
  requestedAt: const TimestampConverter().fromJson(json['requestedAt']),
  respondedAt: const NullableTimestampConverter().fromJson(json['respondedAt']),
);

Map<String, dynamic> _$TrainerTransferModelToJson(
  _TrainerTransferModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'fromTrainerId': instance.fromTrainerId,
  'fromTrainerName': instance.fromTrainerName,
  'toTrainerId': instance.toTrainerId,
  'toTrainerName': instance.toTrainerName,
  'status': _$TransferStatusEnumMap[instance.status]!,
  'reason': instance.reason,
  'requestedAt': const TimestampConverter().toJson(instance.requestedAt),
  'respondedAt': const NullableTimestampConverter().toJson(
    instance.respondedAt,
  ),
};

const _$TransferStatusEnumMap = {
  TransferStatus.pending: 'pending',
  TransferStatus.accepted: 'accepted',
  TransferStatus.rejected: 'rejected',
  TransferStatus.cancelled: 'cancelled',
};
