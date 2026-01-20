import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics 서비스
///
/// Firebase Analytics를 래핑하여 이벤트 트래킹을 쉽게 사용할 수 있게 합니다.
/// 개발 모드에서는 콘솔에 로그만 출력합니다.
///
/// 사용 예시:
/// ```dart
/// AnalyticsService.instance.logLogin(method: 'google');
/// AnalyticsService.instance.logScreenView(screenName: 'home');
/// AnalyticsService.instance.logEvent(name: 'button_click', parameters: {'button_id': 'submit'});
/// ```
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Firebase Analytics Observer (GoRouter에서 사용)
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
        nameExtractor: (settings) => settings.name ?? 'unknown',
      );

  /// 사용자 ID 설정
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    _logDebug('setUserId', {'userId': userId ?? 'null'});
  }

  /// 사용자 속성 설정
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
    _logDebug('setUserProperty', {'name': name, 'value': value ?? 'null'});
  }

  /// 화면 조회 이벤트
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    _logDebug('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass ?? 'null',
    });
  }

  /// 로그인 이벤트
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
    _logDebug('login', {'method': method});
  }

  /// 회원가입 이벤트
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
    _logDebug('sign_up', {'method': method});
  }

  /// 로그아웃 이벤트
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
  }

  /// 검색 이벤트
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    _logDebug('search', {'search_term': searchTerm});
  }

  /// 공유 이벤트
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
    _logDebug('share', {
      'content_type': contentType,
      'item_id': itemId,
      'method': method,
    });
  }

  /// 커스텀 이벤트
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    _logDebug(name, parameters);
  }

  // ========== PAL 앱 전용 이벤트 ==========

  /// 회원 추가 이벤트
  Future<void> logMemberAdded({
    required String trainerId,
    required String memberId,
  }) async {
    await logEvent(
      name: 'member_added',
      parameters: {
        'trainer_id': trainerId,
        'member_id': memberId,
      },
    );
  }

  /// 운동 기록 추가 이벤트
  Future<void> logWorkoutRecorded({
    required String memberId,
    required String workoutType,
    required int duration,
  }) async {
    await logEvent(
      name: 'workout_recorded',
      parameters: {
        'member_id': memberId,
        'workout_type': workoutType,
        'duration_minutes': duration,
      },
    );
  }

  /// 식단 기록 추가 이벤트
  Future<void> logDietRecorded({
    required String memberId,
    required String mealType,
  }) async {
    await logEvent(
      name: 'diet_recorded',
      parameters: {
        'member_id': memberId,
        'meal_type': mealType,
      },
    );
  }

  /// AI 분석 요청 이벤트
  Future<void> logAIAnalysisRequested({
    required String analysisType,
    required String memberId,
  }) async {
    await logEvent(
      name: 'ai_analysis_requested',
      parameters: {
        'analysis_type': analysisType,
        'member_id': memberId,
      },
    );
  }

  /// AI 분석 완료 이벤트
  Future<void> logAIAnalysisCompleted({
    required String analysisType,
    required String memberId,
    required bool success,
    int? durationMs,
  }) async {
    final params = <String, Object>{
      'analysis_type': analysisType,
      'member_id': memberId,
      'success': success,
    };
    if (durationMs != null) {
      params['duration_ms'] = durationMs;
    }
    await logEvent(
      name: 'ai_analysis_completed',
      parameters: params,
    );
  }

  /// 체중 예측 조회 이벤트
  Future<void> logWeightPredictionViewed({
    required String memberId,
  }) async {
    await logEvent(
      name: 'weight_prediction_viewed',
      parameters: {
        'member_id': memberId,
      },
    );
  }

  /// 인바디 기록 추가 이벤트
  Future<void> logInbodyRecorded({
    required String memberId,
  }) async {
    await logEvent(
      name: 'inbody_recorded',
      parameters: {
        'member_id': memberId,
      },
    );
  }

  /// 채팅 메시지 전송 이벤트
  Future<void> logChatMessageSent({
    required String senderId,
    required String roomId,
    required String messageType,
  }) async {
    await logEvent(
      name: 'chat_message_sent',
      parameters: {
        'sender_id': senderId,
        'room_id': roomId,
        'message_type': messageType,
      },
    );
  }

  /// PT 세션 예약 이벤트
  Future<void> logPTSessionScheduled({
    required String trainerId,
    required String memberId,
    required String sessionDate,
  }) async {
    await logEvent(
      name: 'pt_session_scheduled',
      parameters: {
        'trainer_id': trainerId,
        'member_id': memberId,
        'session_date': sessionDate,
      },
    );
  }

  /// PT 세션 완료 이벤트
  Future<void> logPTSessionCompleted({
    required String trainerId,
    required String memberId,
  }) async {
    await logEvent(
      name: 'pt_session_completed',
      parameters: {
        'trainer_id': trainerId,
        'member_id': memberId,
      },
    );
  }

  /// 에러 이벤트 로깅
  Future<void> logError({
    required String errorCode,
    required String errorMessage,
    String? screenName,
    Map<String, Object>? additionalParams,
  }) async {
    final params = <String, Object>{
      'error_code': errorCode,
      'error_message': errorMessage.length > 100
          ? errorMessage.substring(0, 100)
          : errorMessage,
    };
    if (screenName != null) {
      params['screen_name'] = screenName;
    }
    if (additionalParams != null) {
      params.addAll(additionalParams);
    }
    await logEvent(
      name: 'app_error',
      parameters: params,
    );
  }

  /// 기능 사용 이벤트
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, Object>? parameters,
  }) async {
    final params = <String, Object>{
      'feature_name': featureName,
    };
    if (parameters != null) {
      params.addAll(parameters);
    }
    await logEvent(
      name: 'feature_used',
      parameters: params,
    );
  }

  /// 디버그 로그 출력
  void _logDebug(String eventName, Map<String, Object>? parameters) {
    if (kDebugMode) {
      debugPrint('[Analytics] $eventName: $parameters');
    }
  }
}

/// 편의 접근자
AnalyticsService get analytics => AnalyticsService.instance;
