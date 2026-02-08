import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_pal_app/data/models/notification_model.dart';
import 'package:flutter_pal_app/presentation/providers/notification_provider.dart';
import 'package:flutter_pal_app/presentation/widgets/notification/notification_card.dart';
import 'package:flutter_pal_app/presentation/widgets/skeleton/skeleton_base.dart';
import 'package:flutter_pal_app/presentation/widgets/states/empty_state.dart';

/// 알림 목록 전체 화면
///
/// 사용자의 모든 알림을 날짜별로 그룹화하여 표시합니다.
/// 모두 읽음 처리, 당겨서 새로고침을 지원합니다.
class NotificationsScreen extends ConsumerWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider(userId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          // 모두 읽음 버튼
          notificationsAsync.whenOrNull(
                data: (notifications) {
                  final hasUnread = notifications.any((n) => !n.isRead);
                  if (!hasUnread) return const SizedBox.shrink();

                  return TextButton(
                    onPressed: () => _markAllAsRead(ref),
                    child: Text(
                      '모두 읽음',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const _NotificationListSkeleton(),
        error: (error, stack) => _ErrorState(
          error: error,
          onRetry: () => ref.invalidate(notificationsProvider(userId)),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(
              customIcon: Icon(
                Icons.notifications_none_outlined,
                size: 80,
                color: Colors.grey,
              ),
              customTitle: '새로운 알림이 없어요',
              customMessage: '새로운 알림이 오면 여기에 표시됩니다',
            );
          }

          // 날짜별 그룹화
          final grouped = _groupByDate(notifications);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider(userId));
              // 스트림 새로고침을 위해 잠시 대기
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: colorScheme.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final group = grouped[index];
                return _NotificationGroup(
                  title: group.title,
                  notifications: group.notifications,
                  onNotificationTap: (notification) =>
                      _handleNotificationTap(context, ref, notification),
                  onNotificationDismiss: (notification) =>
                      _handleNotificationDismiss(ref, notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 모든 알림 읽음 처리
  Future<void> _markAllAsRead(WidgetRef ref) async {
    await ref.read(notificationNotifierProvider.notifier).markAllAsRead(userId);
  }

  /// 알림 탭 처리
  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    // 읽지 않은 알림이면 읽음 처리
    if (!notification.isRead) {
      await ref
          .read(notificationNotifierProvider.notifier)
          .markAsRead(notification.id);
    }

    // 알림 타입에 따라 해당 화면으로 네비게이션
    // TODO: go_router를 사용한 네비게이션 구현
    if (!context.mounted) return;
    _navigateByNotificationType(context, notification);
  }

  /// 알림 타입에 따른 네비게이션
  void _navigateByNotificationType(
    BuildContext context,
    NotificationModel notification,
  ) {
    // 알림 데이터에서 네비게이션 정보 추출
    final data = notification.data;
    if (data == null) return;

    // 예시: data에 따른 네비게이션 분기
    // context.push('/members/${data['memberId']}');
  }

  /// 알림 삭제 처리
  Future<void> _handleNotificationDismiss(
    WidgetRef ref,
    NotificationModel notification,
  ) async {
    await ref
        .read(notificationNotifierProvider.notifier)
        .deleteNotification(notification.id);
  }

  /// 알림을 날짜별로 그룹화
  List<_NotificationDateGroup> _groupByDate(List<NotificationModel> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final todayList = <NotificationModel>[];
    final yesterdayList = <NotificationModel>[];
    final thisWeekList = <NotificationModel>[];
    final olderList = <NotificationModel>[];

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate == today) {
        todayList.add(notification);
      } else if (notificationDate == yesterday) {
        yesterdayList.add(notification);
      } else if (notificationDate.isAfter(weekAgo)) {
        thisWeekList.add(notification);
      } else {
        olderList.add(notification);
      }
    }

    final groups = <_NotificationDateGroup>[];
    if (todayList.isNotEmpty) {
      groups.add(_NotificationDateGroup(title: '오늘', notifications: todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(_NotificationDateGroup(title: '어제', notifications: yesterdayList));
    }
    if (thisWeekList.isNotEmpty) {
      groups.add(_NotificationDateGroup(title: '이번 주', notifications: thisWeekList));
    }
    if (olderList.isNotEmpty) {
      groups.add(_NotificationDateGroup(title: '이전', notifications: olderList));
    }

    return groups;
  }
}

/// 날짜별 알림 그룹 데이터
class _NotificationDateGroup {
  final String title;
  final List<NotificationModel> notifications;

  _NotificationDateGroup({
    required this.title,
    required this.notifications,
  });
}

/// 날짜별 알림 그룹 위젯
class _NotificationGroup extends StatelessWidget {
  final String title;
  final List<NotificationModel> notifications;
  final void Function(NotificationModel) onNotificationTap;
  final void Function(NotificationModel) onNotificationDismiss;

  const _NotificationGroup({
    required this.title,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 그룹 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 알림 카드 목록
        ...notifications.map(
          (notification) => Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: const Color(0xFFF04452), // Error color
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) => onNotificationDismiss(notification),
            child: NotificationCard(
              notification: notification,
              onTap: () => onNotificationTap(notification),
            ),
          ),
        ),
      ],
    );
  }
}

/// 알림 목록 스켈레톤 로딩
class _NotificationListSkeleton extends StatelessWidget {
  const _NotificationListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) {
          return const _NotificationCardSkeleton();
        },
      ),
    );
  }
}

/// 단일 알림 카드 스켈레톤
class _NotificationCardSkeleton extends StatelessWidget {
  const _NotificationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 스켈레톤
          const SkeletonCircle(size: 44),
          const SizedBox(width: 12),
          // 텍스트 스켈레톤
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 120, height: 14),
                const SizedBox(height: 8),
                SkeletonLine(width: MediaQuery.of(context).size.width * 0.6, height: 12),
                const SizedBox(height: 4),
                const SkeletonLine(width: 80, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 상태 위젯
class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '알림을 불러오지 못했어요',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
