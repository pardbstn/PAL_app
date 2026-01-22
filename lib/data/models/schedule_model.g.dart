// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ScheduleModel _$ScheduleModelFromJson(Map<String, dynamic> json) =>
    _ScheduleModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String?,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String?,
      scheduledAt: const ScheduleTimestampConverter().fromJson(
        json['scheduledAt'],
      ),
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      status:
          $enumDecodeNullable(_$ScheduleStatusEnumMap, json['status']) ??
          ScheduleStatus.scheduled,
      scheduleType:
          $enumDecodeNullable(_$ScheduleTypeEnumMap, json['scheduleType']) ??
          ScheduleType.pt,
      title: json['title'] as String?,
      note: json['note'] as String?,
      groupId: json['groupId'] as String?,
      createdAt: const ScheduleTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ScheduleModelToJson(
  _ScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainerId': instance.trainerId,
  'memberId': instance.memberId,
  'memberName': instance.memberName,
  'scheduledAt': const ScheduleTimestampConverter().toJson(
    instance.scheduledAt,
  ),
  'duration': instance.duration,
  'status': _$ScheduleStatusEnumMap[instance.status]!,
  'scheduleType': _$ScheduleTypeEnumMap[instance.scheduleType]!,
  'title': instance.title,
  'note': instance.note,
  'groupId': instance.groupId,
  'createdAt': const ScheduleTimestampConverter().toJson(instance.createdAt),
};

const _$ScheduleStatusEnumMap = {
  ScheduleStatus.scheduled: 'scheduled',
  ScheduleStatus.completed: 'completed',
  ScheduleStatus.cancelled: 'cancelled',
  ScheduleStatus.noShow: 'noShow',
};

const _$ScheduleTypeEnumMap = {
  ScheduleType.pt: 'pt',
  ScheduleType.personal: 'personal',
};
