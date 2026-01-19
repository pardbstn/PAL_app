import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

/// 채팅방 모델
@freezed
sealed class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    /// 채팅방 ID
    required String id,

    /// 트레이너 ID
    required String trainerId,

    /// 회원 ID
    required String memberId,

    /// 트레이너 이름
    required String trainerName,

    /// 회원 이름
    required String memberName,

    /// 트레이너 프로필 URL
    String? trainerProfileUrl,

    /// 회원 프로필 URL
    String? memberProfileUrl,

    /// 마지막 메시지
    String? lastMessage,

    /// 마지막 메시지 시간
    @NullableTimestampConverter() DateTime? lastMessageAt,

    /// 트레이너 안읽은 메시지 수
    @Default(0) int unreadCountTrainer,

    /// 회원 안읽은 메시지 수
    @Default(0) int unreadCountMember,

    /// 생성 시간
    @TimestampConverter() required DateTime createdAt,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel.fromJson({
      ...data,
      'id': doc.id,
      'unreadCountTrainer': data['unreadCountTrainer'] ?? 0,
      'unreadCountMember': data['unreadCountMember'] ?? 0,
    });
  }
}

/// ChatRoomModel 확장 메서드
extension ChatRoomModelX on ChatRoomModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'memberId': memberId,
      'trainerName': trainerName,
      'memberName': memberName,
      if (trainerProfileUrl != null) 'trainerProfileUrl': trainerProfileUrl,
      if (memberProfileUrl != null) 'memberProfileUrl': memberProfileUrl,
      if (lastMessage != null) 'lastMessage': lastMessage,
      if (lastMessageAt != null) 'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
      'unreadCountTrainer': unreadCountTrainer,
      'unreadCountMember': unreadCountMember,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 상대방 이름 가져오기
  String getOtherName(String odId) {
    return odId == trainerId ? memberName : trainerName;
  }

  /// 상대방 프로필 URL 가져오기
  String? getOtherProfileUrl(String odId) {
    return odId == trainerId ? memberProfileUrl : trainerProfileUrl;
  }

  /// 내 안읽은 메시지 수
  int getMyUnreadCount(String role) {
    return role == 'trainer' ? unreadCountTrainer : unreadCountMember;
  }
}
