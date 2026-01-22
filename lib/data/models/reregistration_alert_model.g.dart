// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reregistration_alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReregistrationAlertModel _$ReregistrationAlertModelFromJson(
  Map<String, dynamic> json,
) => _ReregistrationAlertModel(
  id: json['id'] as String,
  memberId: json['memberId'] as String,
  trainerId: json['trainerId'] as String,
  totalSessions: (json['totalSessions'] as num).toInt(),
  completedSessions: (json['completedSessions'] as num).toInt(),
  progressRate: (json['progressRate'] as num).toDouble(),
  alertSentAt: const ReregistrationTimestampConverter().fromJson(
    json['alertSentAt'],
  ),
  reregistered: json['reregistered'] as bool? ?? false,
  createdAt: const ReregistrationRequiredTimestampConverter().fromJson(
    json['createdAt'],
  ),
);

Map<String, dynamic> _$ReregistrationAlertModelToJson(
  _ReregistrationAlertModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'memberId': instance.memberId,
  'trainerId': instance.trainerId,
  'totalSessions': instance.totalSessions,
  'completedSessions': instance.completedSessions,
  'progressRate': instance.progressRate,
  'alertSentAt': const ReregistrationTimestampConverter().toJson(
    instance.alertSentAt,
  ),
  'reregistered': instance.reregistered,
  'createdAt': const ReregistrationRequiredTimestampConverter().toJson(
    instance.createdAt,
  ),
};
