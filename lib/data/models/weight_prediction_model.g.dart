// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_prediction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PredictedWeightPoint _$PredictedWeightPointFromJson(
  Map<String, dynamic> json,
) => _PredictedWeightPoint(
  date: const TimestampConverter().fromJson(json['date']),
  weight: (json['weight'] as num).toDouble(),
  upperBound: (json['upperBound'] as num).toDouble(),
  lowerBound: (json['lowerBound'] as num).toDouble(),
);

Map<String, dynamic> _$PredictedWeightPointToJson(
  _PredictedWeightPoint instance,
) => <String, dynamic>{
  'date': const TimestampConverter().toJson(instance.date),
  'weight': instance.weight,
  'upperBound': instance.upperBound,
  'lowerBound': instance.lowerBound,
};

_DataSummary _$DataSummaryFromJson(Map<String, dynamic> json) => _DataSummary(
  recentWeekChange: (json['recentWeekChange'] as num?)?.toDouble() ?? 0,
  recentMonthChange: (json['recentMonthChange'] as num?)?.toDouble() ?? 0,
  totalChange: (json['totalChange'] as num?)?.toDouble() ?? 0,
  minWeight: (json['minWeight'] as num?)?.toDouble() ?? 0,
  maxWeight: (json['maxWeight'] as num?)?.toDouble() ?? 0,
  avgWeight: (json['avgWeight'] as num?)?.toDouble() ?? 0,
  weightRange: (json['weightRange'] as num?)?.toDouble() ?? 0,
  recordDays: (json['recordDays'] as num?)?.toInt() ?? 0,
  consistencyScore: (json['consistencyScore'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DataSummaryToJson(_DataSummary instance) =>
    <String, dynamic>{
      'recentWeekChange': instance.recentWeekChange,
      'recentMonthChange': instance.recentMonthChange,
      'totalChange': instance.totalChange,
      'minWeight': instance.minWeight,
      'maxWeight': instance.maxWeight,
      'avgWeight': instance.avgWeight,
      'weightRange': instance.weightRange,
      'recordDays': instance.recordDays,
      'consistencyScore': instance.consistencyScore,
    };

_GoalScenario _$GoalScenarioFromJson(Map<String, dynamic> json) =>
    _GoalScenario(
      name: json['name'] as String,
      weeklyChange: (json['weeklyChange'] as num).toDouble(),
      weeksNeeded: (json['weeksNeeded'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$GoalScenarioToJson(_GoalScenario instance) =>
    <String, dynamic>{
      'name': instance.name,
      'weeklyChange': instance.weeklyChange,
      'weeksNeeded': instance.weeksNeeded,
      'difficulty': instance.difficulty,
      'description': instance.description,
    };

_CoachingMessage _$CoachingMessageFromJson(Map<String, dynamic> json) =>
    _CoachingMessage(
      type: json['type'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$CoachingMessageToJson(_CoachingMessage instance) =>
    <String, dynamic>{
      'type': instance.type,
      'title': instance.title,
      'content': instance.content,
    };

_GeminiAnalysis _$GeminiAnalysisFromJson(Map<String, dynamic> json) =>
    _GeminiAnalysis(
      aiInsight: json['aiInsight'] as String? ?? '',
      actionItems:
          (json['actionItems'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      motivationalMessage: json['motivationalMessage'] as String? ?? '',
    );

Map<String, dynamic> _$GeminiAnalysisToJson(_GeminiAnalysis instance) =>
    <String, dynamic>{
      'aiInsight': instance.aiInsight,
      'actionItems': instance.actionItems,
      'motivationalMessage': instance.motivationalMessage,
    };

_WeightPredictionModel _$WeightPredictionModelFromJson(
  Map<String, dynamic> json,
) => _WeightPredictionModel(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  trainerId: json['trainerId'] as String,
  currentWeight: (json['currentWeight'] as num).toDouble(),
  targetWeight: (json['targetWeight'] as num?)?.toDouble(),
  predictedWeights:
      (json['predictedWeights'] as List<dynamic>?)
          ?.map((e) => PredictedWeightPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  weeklyTrend: (json['weeklyTrend'] as num).toDouble(),
  estimatedWeeksToTarget: (json['estimatedWeeksToTarget'] as num?)?.toInt(),
  confidence: (json['confidence'] as num).toDouble(),
  dataPointsUsed: (json['dataPointsUsed'] as num).toInt(),
  analysisMessage: json['analysisMessage'] as String?,
  dataSummary: json['dataSummary'] == null
      ? null
      : DataSummary.fromJson(json['dataSummary'] as Map<String, dynamic>),
  goalScenarios:
      (json['goalScenarios'] as List<dynamic>?)
          ?.map((e) => GoalScenario.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  coachingMessages:
      (json['coachingMessages'] as List<dynamic>?)
          ?.map((e) => CoachingMessage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  geminiAnalysis: json['geminiAnalysis'] == null
      ? null
      : GeminiAnalysis.fromJson(json['geminiAnalysis'] as Map<String, dynamic>),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$WeightPredictionModelToJson(
  _WeightPredictionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'trainerId': instance.trainerId,
  'currentWeight': instance.currentWeight,
  'targetWeight': instance.targetWeight,
  'predictedWeights': instance.predictedWeights,
  'weeklyTrend': instance.weeklyTrend,
  'estimatedWeeksToTarget': instance.estimatedWeeksToTarget,
  'confidence': instance.confidence,
  'dataPointsUsed': instance.dataPointsUsed,
  'analysisMessage': instance.analysisMessage,
  'dataSummary': instance.dataSummary,
  'goalScenarios': instance.goalScenarios,
  'coachingMessages': instance.coachingMessages,
  'geminiAnalysis': instance.geminiAnalysis,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
};
