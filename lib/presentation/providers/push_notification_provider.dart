import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_pal_app/data/models/notification_settings_model.dart';
import 'package:flutter_pal_app/data/repositories/notification_repository.dart';
import 'package:flutter_pal_app/data/repositories/notification_settings_repository.dart';
import 'package:flutter_pal_app/data/services/fcm_service.dart';

/// 알림 설정 실시간 감시 Provider
final notificationSettingsProvider =
    StreamProvider.family<NotificationSettingsModel?, String>((ref, userId) {
  final repository = ref.watch(notificationSettingsRepositoryProvider);
  return repository.watchSettings(userId);
});

/// 읽지 않은 알림 개수 실시간 감시 Provider
final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUnreadCount(userId);
});

/// 푸시 알림 상태
class PushNotificationState {
  final bool isInitialized;
  final String? fcmToken;
  final int badgeCount;
  final String? lastError;

  PushNotificationState({
    this.isInitialized = false,
    this.fcmToken,
    this.badgeCount = 0,
    this.lastError,
  });

  PushNotificationState copyWith({
    bool? isInitialized,
    String? fcmToken,
    int? badgeCount,
    String? lastError,
  }) {
    return PushNotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      badgeCount: badgeCount ?? this.badgeCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// 푸시 알림 관리 Notifier
class PushNotificationNotifier extends Notifier<PushNotificationState> {
  late final FCMService _fcmService;
  late final NotificationSettingsRepository _settingsRepository;
  @override
  PushNotificationState build() {
    _fcmService = ref.watch(fcmServiceProvider);
    _settingsRepository = ref.watch(notificationSettingsRepositoryProvider);
    return PushNotificationState();
  }

  /// FCM 초기화
  Future<void> initializeFcm(String userId) async {
    try {
      // 1. FCM 서비스 초기화 (이미 main.dart에서 호출됨)

      // 2. FCM 토큰 가져오기
      final token = await _fcmService.getToken();
      if (token == null) {
        state = state.copyWith(
          lastError: 'FCM 토큰을 가져올 수 없어요',
        );
        return;
      }

      // 3. Firestore에 토큰 저장
      final exists = await _settingsRepository.exists(userId);
      if (exists) {
        await _settingsRepository.updateFcmToken(userId, token);
      } else {
        await _settingsRepository.createDefaultSettings(userId, token);
      }

      // 4. 토큰 갱신 리스너 설정
      _fcmService.onTokenRefresh.listen((newToken) {
        _settingsRepository.updateFcmToken(userId, newToken);
        state = state.copyWith(fcmToken: newToken);
      });

      state = state.copyWith(
        isInitialized: true,
        fcmToken: token,
        lastError: null,
      );
    } catch (e) {
      state = state.copyWith(
        lastError: 'FCM 초기화 실패: $e',
      );
    }
  }

  /// 개별 알림 설정 업데이트
  Future<void> updateSetting(
    String userId,
    String settingName,
    bool value,
  ) async {
    try {
      await _settingsRepository.updateSetting(userId, settingName, value);
    } catch (e) {
      state = state.copyWith(
        lastError: '설정 업데이트 실패: $e',
      );
    }
  }

  /// 앱 아이콘 뱃지 카운트 업데이트
  Future<void> updateBadgeCount(int count) async {
    try {
      final isSupported = await FlutterAppBadger.isAppBadgeSupported();
      if (isSupported) {
        if (count > 0) {
          await FlutterAppBadger.updateBadgeCount(count);
        } else {
          await FlutterAppBadger.removeBadge();
        }
        state = state.copyWith(badgeCount: count);
      }
    } catch (e) {
      state = state.copyWith(
        lastError: '뱃지 업데이트 실패: $e',
      );
    }
  }

  /// 뱃지 제거
  Future<void> clearBadge() async {
    await updateBadgeCount(0);
  }

  /// 알림 탭 처리 (라우팅)
  void handleNotificationTap(Map<String, dynamic> data) {
    // 알림 타입에 따른 라우팅 처리
    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;

    if (type == null || targetId == null) return;

    // 여기서는 타입만 정의, 실제 라우팅은 앱 레벨에서 처리
    // 예시:
    // - 'dm' -> 채팅 화면으로 이동
    // - 'pt_reminder' -> 캘린더 화면으로 이동
    // - 'ai_insight' -> 인사이트 화면으로 이동
    // - 'trainer_transfer' -> 트레이너 전환 요청 화면으로 이동
    // - 'weekly_report' -> 주간 리포트 화면으로 이동
  }

  /// FCM 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcmService.subscribeToTopic(topic);
    } catch (e) {
      state = state.copyWith(
        lastError: '토픽 구독 실패: $e',
      );
    }
  }

  /// FCM 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcmService.unsubscribeFromTopic(topic);
    } catch (e) {
      state = state.copyWith(
        lastError: '토픽 구독 해제 실패: $e',
      );
    }
  }
}

final pushNotificationProvider =
    NotifierProvider<PushNotificationNotifier, PushNotificationState>(
  PushNotificationNotifier.new,
);
