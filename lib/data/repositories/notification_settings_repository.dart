import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/notification_settings_model.dart';
import 'package:flutter_pal_app/data/repositories/base_repository.dart';

/// 알림 설정 Repository (notification_settings 컬렉션)
/// Note: NOT extending BaseRepository because doc ID = userId
class NotificationSettingsRepository {
  final FirebaseFirestore firestore;

  NotificationSettingsRepository({required this.firestore});

  /// 컬렉션 레퍼런스
  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection('notification_settings');

  /// 알림 설정 가져오기
  Future<NotificationSettingsModel?> getSettings(String userId) async {
    try {
      final doc = await collection.doc(userId).get();
      if (!doc.exists) return null;
      return NotificationSettingsModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }

  /// 알림 설정 실시간 감시
  Stream<NotificationSettingsModel?> watchSettings(String userId) {
    return collection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return NotificationSettingsModel.fromFirestore(doc);
    });
  }

  /// 알림 설정 저장 (생성 또는 업데이트)
  Future<void> saveSettings(NotificationSettingsModel settings) async {
    await collection.doc(settings.userId).set(
      {
        'fcmToken': settings.fcmToken,
        'dmMessages': settings.dmMessages,
        'ptReminders': settings.ptReminders,
        'aiInsights': settings.aiInsights,
        'trainerTransfer': settings.trainerTransfer,
        'weeklyReport': settings.weeklyReport,
        'updatedAt': Timestamp.fromDate(settings.updatedAt),
      },
      SetOptions(merge: true),
    );
  }

  /// FCM 토큰만 업데이트
  Future<void> updateFcmToken(String userId, String token) async {
    await collection.doc(userId).set(
      {
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// 개별 설정 업데이트
  Future<void> updateSetting(
    String userId,
    String field,
    bool value,
  ) async {
    await collection.doc(userId).update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 알림 설정 삭제
  Future<void> deleteSettings(String userId) async {
    await collection.doc(userId).delete();
  }

  /// 알림 설정 존재 여부 확인
  Future<bool> exists(String userId) async {
    final doc = await collection.doc(userId).get();
    return doc.exists;
  }

  /// 기본 설정으로 초기화
  Future<void> createDefaultSettings(String userId, String fcmToken) async {
    final defaultSettings = NotificationSettingsModel(
      userId: userId,
      fcmToken: fcmToken,
      dmMessages: true,
      ptReminders: true,
      aiInsights: true,
      trainerTransfer: true,
      weeklyReport: true,
      updatedAt: DateTime.now(),
    );
    await saveSettings(defaultSettings);
  }
}

final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>((ref) {
  return NotificationSettingsRepository(
    firestore: ref.watch(firestoreProvider),
  );
});
