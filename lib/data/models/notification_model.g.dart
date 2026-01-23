// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: const NotificationTimestampConverter().fromJson(
        json['createdAt'],
      ),
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'data': instance.data,
      'isRead': instance.isRead,
      'createdAt': const NotificationTimestampConverter().toJson(
        instance.createdAt,
      ),
    };

const _$NotificationTypeEnumMap = {
  NotificationType.reregistration: 'reregistration',
  NotificationType.sessionReminder: 'sessionReminder',
  NotificationType.streakReminder: 'streakReminder',
  NotificationType.reviewRequest: 'reviewRequest',
  NotificationType.trainerRequest: 'trainerRequest',
  NotificationType.badgeEarned: 'badgeEarned',
  NotificationType.badgeAtRisk: 'badgeAtRisk',
  NotificationType.badgeRevoked: 'badgeRevoked',
  NotificationType.general: 'general',
};
