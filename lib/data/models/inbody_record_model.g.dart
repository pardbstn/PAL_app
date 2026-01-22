// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbody_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InbodyRecordModel _$InbodyRecordModelFromJson(Map<String, dynamic> json) =>
    _InbodyRecordModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      measuredAt: const TimestampConverter().fromJson(json['measuredAt']),
      weight: (json['weight'] as num).toDouble(),
      skeletalMuscleMass: (json['skeletalMuscleMass'] as num).toDouble(),
      bodyFatMass: (json['bodyFatMass'] as num?)?.toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num).toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      basalMetabolicRate: (json['basalMetabolicRate'] as num?)?.toDouble(),
      totalBodyWater: (json['totalBodyWater'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      minerals: (json['minerals'] as num?)?.toDouble(),
      visceralFatLevel: (json['visceralFatLevel'] as num?)?.toInt(),
      inbodyScore: (json['inbodyScore'] as num?)?.toInt(),
      source:
          $enumDecodeNullable(_$InbodySourceEnumMap, json['source']) ??
          InbodySource.manual,
      memo: json['memo'] as String?,
      imageUrl: json['imageUrl'] as String?,
      analyzedAt: const TimestampConverter().fromJson(json['analyzedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$InbodyRecordModelToJson(_InbodyRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'memberId': instance.memberId,
      'measuredAt': const TimestampConverter().toJson(instance.measuredAt),
      'weight': instance.weight,
      'skeletalMuscleMass': instance.skeletalMuscleMass,
      'bodyFatMass': instance.bodyFatMass,
      'bodyFatPercent': instance.bodyFatPercent,
      'bmi': instance.bmi,
      'basalMetabolicRate': instance.basalMetabolicRate,
      'totalBodyWater': instance.totalBodyWater,
      'protein': instance.protein,
      'minerals': instance.minerals,
      'visceralFatLevel': instance.visceralFatLevel,
      'inbodyScore': instance.inbodyScore,
      'source': _$InbodySourceEnumMap[instance.source]!,
      'memo': instance.memo,
      'imageUrl': instance.imageUrl,
      'analyzedAt': _$JsonConverterToJson<dynamic, DateTime>(
        instance.analyzedAt,
        const TimestampConverter().toJson,
      ),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$InbodySourceEnumMap = {
  InbodySource.manual: 'manual',
  InbodySource.inbodyApi: 'inbody_api',
  InbodySource.inbodyApp: 'inbody_app',
  InbodySource.aiAnalysis: 'ai_analysis',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
