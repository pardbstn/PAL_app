import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:flutter_pal_app/data/models/chat_room_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/chat_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/states/empty_state.dart';

/// 채팅 목록 화면
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatRoomsAsync = ref.watch(myChatRoomsProvider);
    final authState = ref.watch(authProvider);
    final userId = authState.userId ?? '';
    final role = authState.userRole == UserRole.trainer ? 'trainer' : 'member';

    return Scaffold(
      appBar: AppBar(
        title: const Text('메시지'),
        centerTitle: true,
      ),
      body: chatRoomsAsync.when(
        data: (chatRooms) {
          if (chatRooms.isEmpty) {
            return const EmptyState(type: EmptyStateType.messages);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final room = chatRooms[index];
              return _ChatRoomTile(
                room: room,
                userId: userId,
                role: role,
              ).animate().fadeIn(
                    duration: 300.ms,
                    delay: Duration(milliseconds: 50 * index.clamp(0, 10)),
                  );
            },
          );
        },
        loading: () => const _ChatListSkeleton(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('채팅 목록을 불러올 수 없어요'),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => ref.invalidate(myChatRoomsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 채팅방 타일
class _ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final String userId;
  final String role;

  const _ChatRoomTile({
    required this.room,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final otherName = room.getOtherName(userId);
    final otherProfileUrl = room.getOtherProfileUrl(userId);
    final unreadCount = room.getMyUnreadCount(role);
    final hasUnread = unreadCount > 0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: otherProfileUrl != null
            ? NetworkImage(otherProfileUrl)
            : null,
        child: otherProfileUrl == null
            ? Text(
                otherName.isNotEmpty ? otherName[0] : '?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: TextStyle(
                fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatTime(room.lastMessageAt),
            style: TextStyle(
              fontSize: 12,
              color: hasUnread
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              room.lastMessage ?? '새로운 대화를 시작해보세요',
              style: TextStyle(
                fontSize: 14,
                color: hasUnread
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        final basePath = role == 'trainer' ? '/trainer' : '/member';
        context.push('$basePath/messages/${room.id}');
      },
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('a h:mm', 'ko_KR').format(dateTime);
    } else if (messageDate == yesterday) {
      return '어제';
    } else if (dateTime.year == now.year) {
      return DateFormat('M월 d일').format(dateTime);
    } else {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }
}

/// 채팅 목록 스켈레톤
class _ChatListSkeleton extends StatelessWidget {
  const _ChatListSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
          title: Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Container(
            height: 14,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: 1200.ms, color: colorScheme.surface);
      },
    );
  }
}
