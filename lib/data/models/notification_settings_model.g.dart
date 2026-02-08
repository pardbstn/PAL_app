// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationSettingsModel _$NotificationSettingsModelFromJson(
  Map<String, dynamic> json,
) => _NotificationSettingsModel(
  userId: json['userId'] as String,
  fcmToken: json['fcmToken'] as String? ?? '',
  dmMessages: json['dmMessages'] as bool? ?? true,
  ptReminders: json['ptReminders'] as bool? ?? true,
  aiInsights: json['aiInsights'] as bool? ?? true,
  trainerTransfer: json['trainerTransfer'] as bool? ?? true,
  weeklyReport: json['weeklyReport'] as bool? ?? true,
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$NotificationSettingsModelToJson(
  _NotificationSettingsModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'fcmToken': instance.fcmToken,
  'dmMessages': instance.dmMessages,
  'ptReminders': instance.ptReminders,
  'aiInsights': instance.aiInsights,
  'trainerTransfer': instance.trainerTransfer,
  'weeklyReport': instance.weeklyReport,
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
