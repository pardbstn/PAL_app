// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbody_ocr_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InbodyOcrResult _$InbodyOcrResultFromJson(Map<String, dynamic> json) =>
    _InbodyOcrResult(
      weight: (json['weight'] as num?)?.toDouble(),
      skeletalMuscle: (json['skeletalMuscleMass'] as num?)?.toDouble(),
      bodyFat: (json['bodyFatMass'] as num?)?.toDouble(),
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      bmi: (json['bmi'] as num?)?.toDouble(),
      basalMetabolicRate: (json['basalMetabolicRate'] as num?)?.toDouble(),
      measureDate: json['measureDate'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      rawText: json['rawText'] as String? ?? '',
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$InbodyOcrResultToJson(_InbodyOcrResult instance) =>
    <String, dynamic>{
      'weight': instance.weight,
      'skeletalMuscleMass': instance.skeletalMuscle,
      'bodyFatMass': instance.bodyFat,
      'bodyFatPercent': instance.bodyFatPercent,
      'bmi': instance.bmi,
      'basalMetabolicRate': instance.basalMetabolicRate,
      'measureDate': instance.measureDate,
      'confidence': instance.confidence,
      'rawText': instance.rawText,
      'errorMessage': instance.errorMessage,
    };
