// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) =>
    _ChatRoomModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String,
      trainerName: json['trainerName'] as String,
      memberName: json['memberName'] as String,
      trainerProfileUrl: json['trainerProfileUrl'] as String?,
      memberProfileUrl: json['memberProfileUrl'] as String?,
      lastMessage: json['lastMessage'] as String?,
      lastMessageAt: const NullableTimestampConverter().fromJson(
        json['lastMessageAt'],
      ),
      unreadCountTrainer: (json['unreadCountTrainer'] as num?)?.toInt() ?? 0,
      unreadCountMember: (json['unreadCountMember'] as num?)?.toInt() ?? 0,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$ChatRoomModelToJson(_ChatRoomModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'memberId': instance.memberId,
      'trainerName': instance.trainerName,
      'memberName': instance.memberName,
      'trainerProfileUrl': instance.trainerProfileUrl,
      'memberProfileUrl': instance.memberProfileUrl,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': const NullableTimestampConverter().toJson(
        instance.lastMessageAt,
      ),
      'unreadCountTrainer': instance.unreadCountTrainer,
      'unreadCountMember': instance.unreadCountMember,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
