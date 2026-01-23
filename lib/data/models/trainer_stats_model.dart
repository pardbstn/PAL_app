import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trainer_stats_model.freezed.dart';
part 'trainer_stats_model.g.dart';

class StatsTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const StatsTimestampConverter();
  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
sealed class TrainerStatsModel with _$TrainerStatsModel {
  const factory TrainerStatsModel({
    @Default('') String id,
    @Default(0.0) double avgResponseTimeMinutes,
    @Default(0) int proactiveMessageCount,
    @Default(0.0) double memberGoalAchievementRate,
    @Default(0.0) double avgMemberBodyFatChange,
    @Default(0.0) double avgMemberAttendanceRate,
    @Default(0.0) double reRegistrationRate,
    @Default(0) int longTermMemberCount,
    @Default(0.0) double trainerNoShowRate,
    @Default(0.0) double aiInsightViewRate,
    @Default(0) int weeklyMemberDataViewCount,
    @Default(0) int dietFeedbackCount,
    @StatsTimestampConverter() required DateTime lastCalculated,
  }) = _TrainerStatsModel;

  factory TrainerStatsModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerStatsModelFromJson(json);
}
