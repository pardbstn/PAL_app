// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_composition_prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MetricPrediction _$MetricPredictionFromJson(Map<String, dynamic> json) =>
    _MetricPrediction(
      current: (json['current'] as num).toDouble(),
      predicted: (json['predicted'] as num).toDouble(),
      weeklyTrend: (json['weeklyTrend'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      targetValue: (json['targetValue'] as num?)?.toDouble(),
      estimatedWeeksToTarget: (json['estimatedWeeksToTarget'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MetricPredictionToJson(_MetricPrediction instance) =>
    <String, dynamic>{
      'current': instance.current,
      'predicted': instance.predicted,
      'weeklyTrend': instance.weeklyTrend,
      'confidence': instance.confidence,
      'targetValue': instance.targetValue,
      'estimatedWeeksToTarget': instance.estimatedWeeksToTarget,
    };

_BodyCompositionPredictionModel _$BodyCompositionPredictionModelFromJson(
  Map<String, dynamic> json,
) => _BodyCompositionPredictionModel(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  trainerId: json['trainerId'] as String,
  weightPrediction: json['weightPrediction'] == null
      ? null
      : MetricPrediction.fromJson(
          json['weightPrediction'] as Map<String, dynamic>,
        ),
  musclePrediction: json['musclePrediction'] == null
      ? null
      : MetricPrediction.fromJson(
          json['musclePrediction'] as Map<String, dynamic>,
        ),
  bodyFatPrediction: json['bodyFatPrediction'] == null
      ? null
      : MetricPrediction.fromJson(
          json['bodyFatPrediction'] as Map<String, dynamic>,
        ),
  analysisMessage: json['analysisMessage'] as String,
  dataPointsUsed: Map<String, int>.from(json['dataPointsUsed'] as Map),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$BodyCompositionPredictionModelToJson(
  _BodyCompositionPredictionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'trainerId': instance.trainerId,
  'weightPrediction': instance.weightPrediction,
  'musclePrediction': instance.musclePrediction,
  'bodyFatPrediction': instance.bodyFatPrediction,
  'analysisMessage': instance.analysisMessage,
  'dataPointsUsed': instance.dataPointsUsed,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
