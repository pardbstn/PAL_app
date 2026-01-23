// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerStatsModel _$TrainerStatsModelFromJson(
  Map<String, dynamic> json,
) => _TrainerStatsModel(
  id: json['id'] as String? ?? '',
  avgResponseTimeMinutes:
      (json['avgResponseTimeMinutes'] as num?)?.toDouble() ?? 0.0,
  proactiveMessageCount: (json['proactiveMessageCount'] as num?)?.toInt() ?? 0,
  memberGoalAchievementRate:
      (json['memberGoalAchievementRate'] as num?)?.toDouble() ?? 0.0,
  avgMemberBodyFatChange:
      (json['avgMemberBodyFatChange'] as num?)?.toDouble() ?? 0.0,
  avgMemberAttendanceRate:
      (json['avgMemberAttendanceRate'] as num?)?.toDouble() ?? 0.0,
  reRegistrationRate: (json['reRegistrationRate'] as num?)?.toDouble() ?? 0.0,
  longTermMemberCount: (json['longTermMemberCount'] as num?)?.toInt() ?? 0,
  trainerNoShowRate: (json['trainerNoShowRate'] as num?)?.toDouble() ?? 0.0,
  aiInsightViewRate: (json['aiInsightViewRate'] as num?)?.toDouble() ?? 0.0,
  weeklyMemberDataViewCount:
      (json['weeklyMemberDataViewCount'] as num?)?.toInt() ?? 0,
  dietFeedbackCount: (json['dietFeedbackCount'] as num?)?.toInt() ?? 0,
  lastCalculated: const StatsTimestampConverter().fromJson(
    json['lastCalculated'],
  ),
);

Map<String, dynamic> _$TrainerStatsModelToJson(_TrainerStatsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'avgResponseTimeMinutes': instance.avgResponseTimeMinutes,
      'proactiveMessageCount': instance.proactiveMessageCount,
      'memberGoalAchievementRate': instance.memberGoalAchievementRate,
      'avgMemberBodyFatChange': instance.avgMemberBodyFatChange,
      'avgMemberAttendanceRate': instance.avgMemberAttendanceRate,
      'reRegistrationRate': instance.reRegistrationRate,
      'longTermMemberCount': instance.longTermMemberCount,
      'trainerNoShowRate': instance.trainerNoShowRate,
      'aiInsightViewRate': instance.aiInsightViewRate,
      'weeklyMemberDataViewCount': instance.weeklyMemberDataViewCount,
      'dietFeedbackCount': instance.dietFeedbackCount,
      'lastCalculated': const StatsTimestampConverter().toJson(
        instance.lastCalculated,
      ),
    };
