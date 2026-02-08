import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pal_app/presentation/providers/notification_provider.dart';

/// 읽지 않은 알림 개수를 표시하는 배지 위젯
///
/// 아이콘 위에 겹쳐서 사용할 수 있습니다.
/// 알림 개수가 0이면 아무것도 표시하지 않습니다.
///
/// 사용 예시:
/// ```dart
/// Stack(
///   clipBehavior: Clip.none,
///   children: [
///     Icon(Icons.notifications_outlined),
///     Positioned(
///       right: -6,
///       top: -6,
///       child: NotificationBadge(userId: userId),
///     ),
///   ],
/// )
/// ```
class NotificationBadge extends ConsumerWidget {
  final String userId;
  final double size;
  final double fontSize;

  const NotificationBadge({
    super.key,
    required this.userId,
    this.size = 18,
    this.fontSize = 10,
  });

  // 디자인 시스템 색상
  static const Color _badgeColor = Color(0xFFF04452);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadNotificationCountProvider(userId));

    return countAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (count) {
        if (count == 0) return const SizedBox.shrink();

        // 99개 초과시 99+로 표시
        final displayText = count > 99 ? '99+' : count.toString();

        return Container(
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: count > 9 ? 4 : 0,
          ),
          decoration: const BoxDecoration(
            color: _badgeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 아이콘과 배지를 함께 표시하는 편의 위젯
///
/// 사용 예시:
/// ```dart
/// NotificationIconWithBadge(
///   userId: userId,
///   onTap: () => context.push('/notifications'),
/// )
/// ```
class NotificationIconWithBadge extends StatelessWidget {
  final String userId;
  final VoidCallback? onTap;
  final double iconSize;
  final Color? iconColor;

  const NotificationIconWithBadge({
    super.key,
    required this.userId,
    this.onTap,
    this.iconSize = 24,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = iconColor ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: iconSize,
              color: effectiveColor,
            ),
            Positioned(
              right: -4,
              top: -4,
              child: NotificationBadge(
                userId: userId,
                size: 16,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar의 actions에서 사용하기 편한 위젯
///
/// 사용 예시:
/// ```dart
/// AppBar(
///   title: Text('홈'),
///   actions: [
///     NotificationActionButton(
///       userId: userId,
///       onTap: () => context.push('/notifications'),
///     ),
///   ],
/// )
/// ```
class NotificationActionButton extends StatelessWidget {
  final String userId;
  final VoidCallback? onTap;

  const NotificationActionButton({
    super.key,
    required this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          Positioned(
            right: -6,
            top: -6,
            child: NotificationBadge(
              userId: userId,
              size: 16,
              fontSize: 9,
            ),
          ),
        ],
      ),
      tooltip: '알림',
    );
  }
}
