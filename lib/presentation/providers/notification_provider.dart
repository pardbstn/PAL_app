import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

/// 현재 사용자의 알림 목록 실시간 감시
final notificationsProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchByUserId(userId);
});

/// 읽지 않은 알림 개수 실시간 감시
final unreadNotificationCountProvider = StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUnreadCount(userId);
});

/// 알림 관리 Notifier
class NotificationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAsRead(notificationId);
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.markAllAsRead(userId);
  }

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.delete(notificationId);
  }

  /// 오래된 알림 삭제
  Future<void> deleteOldNotifications(String userId) async {
    final repository = ref.read(notificationRepositoryProvider);
    await repository.deleteOldNotifications(userId);
  }
}

final notificationNotifierProvider = AsyncNotifierProvider<NotificationNotifier, void>(() {
  return NotificationNotifier();
});
