// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trainer_performance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrainerPerformanceModel _$TrainerPerformanceModelFromJson(
  Map<String, dynamic> json,
) => _TrainerPerformanceModel(
  id: json['id'] as String,
  trainerId: json['trainerId'] as String,
  reregistrationRate: (json['reregistrationRate'] as num?)?.toDouble() ?? 0.0,
  goalAchievementRate: (json['goalAchievementRate'] as num?)?.toDouble() ?? 0.0,
  avgBodyCompositionChange:
      (json['avgBodyCompositionChange'] as num?)?.toDouble() ?? 0.0,
  attendanceManagementRate:
      (json['attendanceManagementRate'] as num?)?.toDouble() ?? 0.0,
  totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  totalMembers: (json['totalMembers'] as num?)?.toInt() ?? 0,
  activeMembers: (json['activeMembers'] as num?)?.toInt() ?? 0,
  updatedAt: const PerformanceTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$TrainerPerformanceModelToJson(
  _TrainerPerformanceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainerId': instance.trainerId,
  'reregistrationRate': instance.reregistrationRate,
  'goalAchievementRate': instance.goalAchievementRate,
  'avgBodyCompositionChange': instance.avgBodyCompositionChange,
  'attendanceManagementRate': instance.attendanceManagementRate,
  'totalReviews': instance.totalReviews,
  'averageRating': instance.averageRating,
  'totalMembers': instance.totalMembers,
  'activeMembers': instance.activeMembers,
  'updatedAt': const PerformanceTimestampConverter().toJson(instance.updatedAt),
};
