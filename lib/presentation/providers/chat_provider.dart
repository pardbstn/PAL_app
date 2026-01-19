import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/chat_room_model.dart';
import 'package:flutter_pal_app/data/models/message_model.dart';
import 'package:flutter_pal_app/data/repositories/chat_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

/// 내 채팅방 목록 Provider
final myChatRoomsProvider = StreamProvider<List<ChatRoomModel>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId;
  final role = authState.userRole;

  if (userId == null || role == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(chatRepositoryProvider);
  final roleStr = role == UserRole.trainer ? 'trainer' : 'member';
  return repository.watchMyChatRooms(userId, roleStr);
});

/// 특정 채팅방 메시지 Provider
final messagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(chatRoomId);
});

/// 특정 채팅방 정보 Provider
final chatRoomProvider = StreamProvider.family<ChatRoomModel?, String>((ref, chatRoomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchChatRoom(chatRoomId);
});

/// 전체 안읽은 메시지 수 Provider
final totalUnreadCountProvider = StreamProvider<int>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.userId;
  final role = authState.userRole;

  if (userId == null || role == null) {
    return Stream.value(0);
  }

  final repository = ref.watch(chatRepositoryProvider);
  final roleStr = role == UserRole.trainer ? 'trainer' : 'member';
  return repository.watchUnreadCount(userId, roleStr);
});

/// 채팅방 생성/가져오기 Provider
final getOrCreateChatRoomProvider = FutureProvider.family<ChatRoomModel, ChatRoomParams>((ref, params) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getOrCreateChatRoom(
    trainerId: params.trainerId,
    memberId: params.memberId,
    trainerName: params.trainerName,
    memberName: params.memberName,
    trainerProfileUrl: params.trainerProfileUrl,
    memberProfileUrl: params.memberProfileUrl,
  );
});

/// 채팅방 생성 파라미터
class ChatRoomParams {
  final String trainerId;
  final String memberId;
  final String trainerName;
  final String memberName;
  final String? trainerProfileUrl;
  final String? memberProfileUrl;

  const ChatRoomParams({
    required this.trainerId,
    required this.memberId,
    required this.trainerName,
    required this.memberName,
    this.trainerProfileUrl,
    this.memberProfileUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatRoomParams &&
          runtimeType == other.runtimeType &&
          trainerId == other.trainerId &&
          memberId == other.memberId;

  @override
  int get hashCode => trainerId.hashCode ^ memberId.hashCode;
}
