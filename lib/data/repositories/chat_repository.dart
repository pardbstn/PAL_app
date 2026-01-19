import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../models/chat_room_model.dart';
import 'base_repository.dart';

/// ChatRepository Provider
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(firestore: ref.watch(firestoreProvider));
});

/// 채팅 Repository
class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _chatRooms =>
      _firestore.collection('chat_rooms');

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  /// 채팅방 생성 또는 가져오기
  Future<ChatRoomModel> getOrCreateChatRoom({
    required String trainerId,
    required String memberId,
    required String trainerName,
    required String memberName,
    String? trainerProfileUrl,
    String? memberProfileUrl,
  }) async {
    try {
      // 기존 채팅방 찾기
      final existing = await _chatRooms
          .where('trainerId', isEqualTo: trainerId)
          .where('memberId', isEqualTo: memberId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return ChatRoomModel.fromFirestore(existing.docs.first);
      }

      // 새 채팅방 생성
      final chatRoom = ChatRoomModel(
        id: '',
        trainerId: trainerId,
        memberId: memberId,
        trainerName: trainerName,
        memberName: memberName,
        trainerProfileUrl: trainerProfileUrl,
        memberProfileUrl: memberProfileUrl,
        createdAt: DateTime.now(),
      );

      final docRef = await _chatRooms.add(chatRoom.toFirestore());
      final doc = await docRef.get();
      return ChatRoomModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('채팅방 생성/조회 실패: $e');
    }
  }

  /// 내 채팅방 목록 (실시간)
  Stream<List<ChatRoomModel>> watchMyChatRooms(String odId, String role) {
    final field = role == 'trainer' ? 'trainerId' : 'memberId';

    return _chatRooms
        .where(field, isEqualTo: odId)
        .snapshots()
        .map((snapshot) {
      final rooms = snapshot.docs
          .map((doc) => ChatRoomModel.fromFirestore(doc))
          .toList();
      // 클라이언트 측 정렬 (마지막 메시지 시간순)
      rooms.sort((a, b) {
        final aTime = a.lastMessageAt ?? a.createdAt;
        final bTime = b.lastMessageAt ?? b.createdAt;
        return bTime.compareTo(aTime);
      });
      return rooms;
    });
  }

  /// 특정 채팅방 메시지 (실시간)
  /// 인덱스 없이 작동하도록 클라이언트 사이드 정렬 사용
  Stream<List<MessageModel>> watchMessages(String chatRoomId, {int limit = 50}) {
    return _messages
        .where('chatRoomId', isEqualTo: chatRoomId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      // 클라이언트 사이드 정렬 (시간순, 오래된 것이 먼저)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      // limit 적용
      if (messages.length > limit) {
        return messages.sublist(messages.length - limit);
      }
      return messages;
    });
  }

  /// 메시지 전송
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String senderRole,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final message = MessageModel(
        id: '',
        chatRoomId: chatRoomId,
        senderId: senderId,
        senderRole: senderRole,
        content: content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        isRead: false,
      );

      // 메시지 추가
      await _messages.add(message.toFirestore());

      // 채팅방 업데이트
      final unreadField = senderRole == 'trainer'
          ? 'unreadCountMember'
          : 'unreadCountTrainer';

      await _chatRooms.doc(chatRoomId).update({
        'lastMessage': imageUrl != null ? '사진' : content,
        'lastMessageAt': Timestamp.now(),
        unreadField: FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('메시지 전송 실패: $e');
    }
  }

  /// 읽음 처리
  Future<void> markAsRead(String chatRoomId, String odId, String role) async {
    try {
      final unreadField = role == 'trainer'
          ? 'unreadCountTrainer'
          : 'unreadCountMember';

      await _chatRooms.doc(chatRoomId).update({
        unreadField: 0,
      });

      // 상대방이 보낸 메시지 읽음 처리
      final otherRole = role == 'trainer' ? 'member' : 'trainer';
      final unreadMessages = await _messages
          .where('chatRoomId', isEqualTo: chatRoomId)
          .where('senderRole', isEqualTo: otherRole)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('읽음 처리 실패: $e');
    }
  }

  /// 안읽은 메시지 총 수 (실시간)
  Stream<int> watchUnreadCount(String odId, String role) {
    final field = role == 'trainer' ? 'trainerId' : 'memberId';
    final unreadField = role == 'trainer'
        ? 'unreadCountTrainer'
        : 'unreadCountMember';

    return _chatRooms
        .where(field, isEqualTo: odId)
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += (data[unreadField] as num?)?.toInt() ?? 0;
      }
      return total;
    });
  }

  /// 채팅방 정보 가져오기
  Future<ChatRoomModel?> getChatRoom(String chatRoomId) async {
    try {
      final doc = await _chatRooms.doc(chatRoomId).get();
      if (!doc.exists) return null;
      return ChatRoomModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('채팅방 조회 실패: $e');
    }
  }

  /// 채팅방 실시간 감시
  Stream<ChatRoomModel?> watchChatRoom(String chatRoomId) {
    return _chatRooms.doc(chatRoomId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatRoomModel.fromFirestore(doc);
    });
  }

  /// 채팅방 삭제
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      // 채팅방의 모든 메시지 삭제
      final messages = await _messages
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_chatRooms.doc(chatRoomId));
      await batch.commit();
    } catch (e) {
      throw Exception('채팅방 삭제 실패: $e');
    }
  }

  /// 이전 메시지 더 불러오기 (페이지네이션)
  /// 인덱스 없이 작동하도록 클라이언트 사이드 필터링/정렬
  Future<List<MessageModel>> loadMoreMessages(
    String chatRoomId, {
    required DateTime beforeTime,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _messages
          .where('chatRoomId', isEqualTo: chatRoomId)
          .get();

      var messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .where((msg) => msg.createdAt.isBefore(beforeTime))
          .toList();

      // 클라이언트 사이드 정렬 (시간순, 오래된 것이 먼저)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      // limit 적용 (최근 N개)
      if (messages.length > limit) {
        return messages.sublist(messages.length - limit);
      }
      return messages;
    } catch (e) {
      throw Exception('메시지 불러오기 실패: $e');
    }
  }
}
