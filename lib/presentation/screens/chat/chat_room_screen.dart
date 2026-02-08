import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/data/models/message_model.dart';
import 'package:flutter_pal_app/data/models/chat_room_model.dart';
import 'package:flutter_pal_app/data/repositories/chat_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/chat/message_input.dart';

/// 채팅방 화면
class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatRoomId;

  const ChatRoomScreen({super.key, required this.chatRoomId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    final role = authState.userRole;
    if (userId == null || role == null) return;

    final roleStr = role == UserRole.trainer ? 'trainer' : 'member';
    await ref.read(chatRepositoryProvider).markAsRead(
          widget.chatRoomId,
          userId,
          roleStr,
        );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage(String content, String? imageUrl) async {
    final authState = ref.read(authProvider);
    final userId = authState.userId;
    final role = authState.userRole;
    if (userId == null || role == null) return;

    final roleStr = role == UserRole.trainer ? 'trainer' : 'member';

    await ref.read(chatRepositoryProvider).sendMessage(
          chatRoomId: widget.chatRoomId,
          senderId: userId,
          senderRole: roleStr,
          content: content,
          imageUrl: imageUrl,
        );

    // 전송 후 스크롤
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomAsync = ref.watch(chatRoomProvider(widget.chatRoomId));
    final messagesAsync = ref.watch(messagesProvider(widget.chatRoomId));
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? '';

    // 메시지 수신 시 스크롤
    ref.listen(messagesProvider(widget.chatRoomId), (prev, next) {
      next.whenData((messages) {
        if (_isFirstLoad) {
          _isFirstLoad = false;
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        } else if (prev?.value?.length != messages.length) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: chatRoomAsync.when(
          data: (room) {
            if (room == null) return const Text('채팅');
            final otherName = room.getOtherName(userId);
            final otherProfileUrl = room.getOtherProfileUrl(userId);

            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: otherProfileUrl != null
                      ? NetworkImage(otherProfileUrl)
                      : null,
                  child: otherProfileUrl == null
                      ? Text(
                          otherName.isNotEmpty ? otherName[0] : '?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(otherName),
              ],
            );
          },
          loading: () => const Text('로딩 중...'),
          error: (_, _) => const Text('채팅'),
        ),
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '대화를 시작해보세요!',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == userId;
                    final showDate = index == 0 ||
                        !_isSameDay(
                          messages[index - 1].createdAt,
                          message.createdAt,
                        );

                    return Column(
                      children: [
                        if (showDate) _DateDivider(date: message.createdAt),
                        _MessageBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Text('메시지를 불러올 수 없어요: $error'),
              ),
            ),
          ),

          // 메시지 입력
          MessageInput(
            chatRoomId: widget.chatRoomId,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// 날짜 구분선
class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return '오늘';
    } else if (messageDate == yesterday) {
      return '어제';
    } else if (date.year == now.year) {
      return DateFormat('M월 d일 EEEE', 'ko_KR').format(date);
    } else {
      return DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(date);
    }
  }
}

/// 메시지 버블
class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) ...[
            Text(
              DateFormat('a h:mm', 'ko_KR').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: message.imageUrl != null
                  ? const EdgeInsets.all(4)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: message.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        message.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 200,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 100,
                            color: colorScheme.errorContainer,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Text(
                      message.content,
                      style: TextStyle(
                        color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          if (!isMe) ...[
            const SizedBox(width: 8),
            Text(
              DateFormat('a h:mm', 'ko_KR').format(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .slideX(begin: isMe ? 0.1 : -0.1, end: 0, duration: 200.ms);
  }
}
