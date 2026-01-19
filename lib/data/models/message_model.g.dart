// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chatRoomId'] as String,
      senderId: json['senderId'] as String,
      senderRole: json['senderRole'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatRoomId': instance.chatRoomId,
      'senderId': instance.senderId,
      'senderRole': instance.senderRole,
      'content': instance.content,
      'imageUrl': instance.imageUrl,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'isRead': instance.isRead,
    };
