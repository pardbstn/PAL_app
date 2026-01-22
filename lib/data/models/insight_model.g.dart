// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_InsightModel _$InsightModelFromJson(Map<String, dynamic> json) =>
    _InsightModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String?,
      memberName: json['memberName'] as String?,
      type: $enumDecode(_$InsightTypeEnumMap, json['type']),
      priority: $enumDecode(_$InsightPriorityEnumMap, json['priority']),
      title: json['title'] as String,
      message: json['message'] as String,
      actionSuggestion: json['actionSuggestion'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      graphData: (json['graphData'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      graphType: json['graphType'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      isActionTaken: json['isActionTaken'] as bool? ?? false,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      expiresAt: const NullableTimestampConverter().fromJson(json['expiresAt']),
    );

Map<String, dynamic> _$InsightModelToJson(
  _InsightModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainerId': instance.trainerId,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'type': _$InsightTypeEnumMap[instance.type]!,
  'priority': _$InsightPriorityEnumMap[instance.priority]!,
  'title': instance.title,
  'message': instance.message,
  'actionSuggestion': instance.actionSuggestion,
  'data': instance.data,
  'graphData': instance.graphData,
  'graphType': instance.graphType,
  'isRead': instance.isRead,
  'isActionTaken': instance.isActionTaken,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'expiresAt': const NullableTimestampConverter().toJson(instance.expiresAt),
};

const _$InsightTypeEnumMap = {
  InsightType.attendanceAlert: 'attendanceAlert',
  InsightType.ptExpiry: 'ptExpiry',
  InsightType.performance: 'performance',
  InsightType.recommendation: 'recommendation',
  InsightType.weightProgress: 'weightProgress',
  InsightType.workoutVolume: 'workoutVolume',
  InsightType.churnRisk: 'churnRisk',
  InsightType.renewalLikelihood: 'renewalLikelihood',
  InsightType.plateauDetection: 'plateauDetection',
  InsightType.workoutRecommendation: 'workoutRecommendation',
  InsightType.noshowPattern: 'noshowPattern',
  InsightType.performanceRanking: 'performanceRanking',
  InsightType.bodyPrediction: 'bodyPrediction',
  InsightType.workoutAchievement: 'workoutAchievement',
  InsightType.attendanceHabit: 'attendanceHabit',
  InsightType.nutritionBalance: 'nutritionBalance',
  InsightType.bodyChangeReport: 'bodyChangeReport',
  InsightType.conditionPattern: 'conditionPattern',
  InsightType.goalProgress: 'goalProgress',
};

const _$InsightPriorityEnumMap = {
  InsightPriority.high: 'high',
  InsightPriority.medium: 'medium',
  InsightPriority.low: 'low',
};
