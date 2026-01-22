import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import 'base_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(firestore: ref.watch(firestoreProvider));
});

class NotificationRepository extends BaseRepository<NotificationModel> {
  NotificationRepository({required super.firestore})
      : super(collectionPath: 'notifications');

  @override
  Future<NotificationModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return NotificationModel.fromFirestore(doc);
  }

  @override
  Future<List<NotificationModel>> getAll() async {
    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
  }

  /// 알림 생성
  @override
  Future<String> create(NotificationModel notification) async {
    final docRef = await collection.add(notification.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  /// 알림 삭제
  @override
  Future<void> delete(String notificationId) async {
    await collection.doc(notificationId).delete();
  }

  @override
  Stream<NotificationModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return NotificationModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<NotificationModel>> watchAll() {
    return collection.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  /// 사용자별 알림 목록 조회
  Future<List<NotificationModel>> getByUserId(String userId) async {
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// 사용자별 알림 실시간 감시
  Stream<List<NotificationModel>> watchByUserId(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  /// 읽지 않은 알림 개수 실시간 감시
  Stream<int> watchUnreadCount(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    await collection.doc(notificationId).update({'isRead': true});
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    final batch = firestore.batch();
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// 오래된 알림 삭제 (30일 이상)
  Future<void> deleteOldNotifications(String userId) async {
    final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
    final batch = firestore.batch();
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoffDate))
        .get();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
