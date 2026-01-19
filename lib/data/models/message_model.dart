import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

/// 채팅 메시지 모델
@freezed
sealed class MessageModel with _$MessageModel {
  const factory MessageModel({
    /// 메시지 ID
    required String id,

    /// 채팅방 ID
    required String chatRoomId,

    /// 보낸 사람 ID
    required String senderId,

    /// 보낸 사람 역할 ('trainer' | 'member')
    required String senderRole,

    /// 메시지 내용
    required String content,

    /// 이미지 URL (선택)
    String? imageUrl,

    /// 생성 시간
    @TimestampConverter() required DateTime createdAt,

    /// 읽음 여부
    required bool isRead,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson({...data, 'id': doc.id});
  }
}

/// MessageModel 확장 메서드
extension MessageModelX on MessageModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'senderRole': senderRole,
      'content': content,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  /// 내 메시지인지 확인
  bool isMyMessage(String odId) => senderId == odId;
}
