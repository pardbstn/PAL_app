// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BodyRecordModel _$BodyRecordModelFromJson(Map<String, dynamic> json) =>
    _BodyRecordModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      recordDate: const TimestampConverter().fromJson(json['recordDate']),
      weight: (json['weight'] as num).toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      muscleMass: (json['muscleMass'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmr: (json['bmr'] as num?)?.toDouble(),
      source:
          $enumDecodeNullable(_$RecordSourceEnumMap, json['source']) ??
          RecordSource.manual,
      note: json['note'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$BodyRecordModelToJson(_BodyRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'recordDate': const TimestampConverter().toJson(instance.recordDate),
      'weight': instance.weight,
      'bodyFatPercent': instance.bodyFatPercent,
      'muscleMass': instance.muscleMass,
      'bmi': instance.bmi,
      'bmr': instance.bmr,
      'source': _$RecordSourceEnumMap[instance.source]!,
      'note': instance.note,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$RecordSourceEnumMap = {
  RecordSource.manual: 'manual',
  RecordSource.inbodyApi: 'inbody_api',
};
