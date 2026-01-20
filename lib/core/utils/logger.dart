import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 앱 로거
///
/// 개발 모드: 콘솔에 컬러 로그 출력
/// 프로덕션 모드: Firebase Crashlytics 연동 준비 (현재는 로그 무시)
///
/// 사용 예시:
/// ```dart
/// AppLogger.debug('디버그 메시지');
/// AppLogger.info('정보 메시지');
/// AppLogger.warning('경고 메시지');
/// AppLogger.error('에러 메시지', error, stackTrace);
/// ```
class AppLogger {
  AppLogger._();

  static const String _name = 'PAL';

  // ANSI 색상 코드 (터미널 출력용)
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _blue = '\x1B[34m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';

  /// 로그 레벨
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.warning;

  /// 최소 로그 레벨 설정
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 디버그 로그 (개발용 상세 정보)
  static void debug(
    String message, {
    String? tag,
    dynamic data,
  }) {
    _log(
      level: LogLevel.debug,
      message: message,
      tag: tag,
      data: data,
      color: _cyan,
      emoji: '🔍',
    );
  }

  /// 정보 로그 (일반 정보)
  static void info(
    String message, {
    String? tag,
    dynamic data,
  }) {
    _log(
      level: LogLevel.info,
      message: message,
      tag: tag,
      data: data,
      color: _green,
      emoji: '✅',
    );
  }

  /// 경고 로그 (주의 필요)
  static void warning(
    String message, {
    String? tag,
    dynamic data,
  }) {
    _log(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      data: data,
      color: _yellow,
      emoji: '⚠️',
    );
  }

  /// 에러 로그 (오류 발생)
  static void error(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      color: _red,
      emoji: '❌',
    );

    // 프로덕션에서 Crashlytics에 에러 기록
    if (!kDebugMode && error != null) {
      _recordToCrashlytics(message, error, stackTrace);
    }
  }

  /// 치명적 에러 로그 (앱 크래시 수준)
  static void fatal(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _log(
      level: LogLevel.fatal,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      color: _magenta,
      emoji: '💥',
    );

    // 프로덕션에서 Crashlytics에 치명적 에러 기록
    if (!kDebugMode && error != null) {
      _recordToCrashlytics(message, error, stackTrace, fatal: true);
    }
  }

  /// 네트워크 요청/응답 로그
  static void network(
    String message, {
    String? method,
    String? url,
    int? statusCode,
    dynamic data,
  }) {
    final buffer = StringBuffer(message);
    if (method != null) buffer.write(' [$method]');
    if (url != null) buffer.write(' $url');
    if (statusCode != null) buffer.write(' ($statusCode)');

    _log(
      level: LogLevel.debug,
      message: buffer.toString(),
      tag: 'Network',
      data: data,
      color: _blue,
      emoji: '🌐',
    );
  }

  /// 내부 로그 처리
  static void _log({
    required LogLevel level,
    required String message,
    String? tag,
    dynamic data,
    dynamic error,
    StackTrace? stackTrace,
    required String color,
    required String emoji,
  }) {
    // 최소 레벨 미만이면 무시
    if (level.index < _minLevel.index) {
      return;
    }

    // 릴리즈 모드에서는 debug, info 로그 무시
    if (!kDebugMode && (level == LogLevel.debug || level == LogLevel.info)) {
      return;
    }

    final tagStr = tag != null ? '[$tag] ' : '';

    // 콘솔 출력 (개발 모드)
    if (kDebugMode) {
      // dart:developer log 사용 (디버그 도구 연동)
      developer.log(
        '$color$emoji $tagStr$message$_reset',
        time: DateTime.now(),
        level: _getLevelValue(level),
        name: _name,
        error: error,
        stackTrace: stackTrace,
      );

      // 추가 데이터 출력
      if (data != null) {
        debugPrint('$color  └─ Data: $data$_reset');
      }

      // 에러 및 스택트레이스 출력
      if (error != null) {
        debugPrint('$color  └─ Error: $error$_reset');
      }
      if (stackTrace != null) {
        debugPrint('$color  └─ StackTrace:\n$stackTrace$_reset');
      }
    }
  }

  /// 로그 레벨을 정수값으로 변환 (dart:developer용)
  static int _getLevelValue(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
      LogLevel.fatal => 1200,
    };
  }

  /// Firebase Crashlytics에 에러 기록 (프로덕션용)
  static void _recordToCrashlytics(
    String message,
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {
    // TODO: Firebase Crashlytics 연동
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: message,
    //   fatal: fatal,
    // );
  }

  /// Crashlytics에 사용자 정보 설정 (프로덕션용)
  static void setUserId(String userId) {
    if (!kDebugMode) {
      // TODO: Firebase Crashlytics 연동
      // FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
  }

  /// Crashlytics에 커스텀 키 설정 (프로덕션용)
  static void setCustomKey(String key, dynamic value) {
    if (!kDebugMode) {
      // TODO: Firebase Crashlytics 연동
      // FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    }
  }

  /// 로그 메시지 기록 (Crashlytics 브레드크럼)
  static void logMessage(String message) {
    if (!kDebugMode) {
      // TODO: Firebase Crashlytics 연동
      // FirebaseCrashlytics.instance.log(message);
    }
  }
}

/// 로그 레벨
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// 편의 함수들 - 글로벌 접근용
void logDebug(String message, {String? tag, dynamic data}) {
  AppLogger.debug(message, tag: tag, data: data);
}

void logInfo(String message, {String? tag, dynamic data}) {
  AppLogger.info(message, tag: tag, data: data);
}

void logWarning(String message, {String? tag, dynamic data}) {
  AppLogger.warning(message, tag: tag, data: data);
}

void logError(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
  AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);
}

void logFatal(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
  AppLogger.fatal(message, tag: tag, error: error, stackTrace: stackTrace);
}

void logNetwork(String message, {String? method, String? url, int? statusCode, dynamic data}) {
  AppLogger.network(message, method: method, url: url, statusCode: statusCode, data: data);
}
