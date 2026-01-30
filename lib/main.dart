import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_pal_app/firebase_options.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/router/app_router.dart';
import 'package:flutter_pal_app/core/utils/logger.dart';
import 'package:flutter_pal_app/presentation/providers/theme_provider.dart';
import 'package:flutter_pal_app/data/services/fcm_service.dart';

/// FCM 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] 백그라운드 메시지 수신: ${message.notification?.title}');
}

/// FCM 초기화 (비동기, 앱 시작을 막지 않음)
Future<void> _initializeFCM() async {
  try {
    debugPrint('[Main] FCM 초기화 시작...');

    // FCM 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // FCM 서비스 초기화 (타임아웃 5초)
    final fcmService = FCMService();
    await fcmService.initialize().timeout(const Duration(seconds: 5));
    debugPrint('[Main] FCM 초기화 완료');
  } catch (e) {
    debugPrint('[Main] FCM 초기화 실패 (무시됨): $e');
    // FCM 실패해도 앱은 계속 실행 (푸시 알림만 비활성화)
  }
}

void main() async {
  // runZonedGuarded로 비동기 에러 캐치
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Flutter 프레임워크 에러 핸들러 등록
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        AppLogger.error(
          'Flutter Error',
          tag: 'FlutterError',
          error: details.exception,
          stackTrace: details.stack,
        );
      };

      // 플랫폼 에러 핸들러 등록 (네이티브 레이어 에러)
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.fatal(
          'Platform Error',
          tag: 'PlatformDispatcher',
          error: error,
          stackTrace: stack,
        );
        return true;
      };

      debugPrint('[Main] 앱 초기화 시작...');

      // 한국어 로케일 초기화
      await initializeDateFormatting('ko_KR', null);
      debugPrint('[Main] 로케일 초기화 완료');

      // Firebase 초기화
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 10));
        debugPrint('[Main] Firebase 초기화 완료');
      } catch (e, st) {
        debugPrint('[Main] Firebase 초기화 실패: $e');
        // Firebase 없이는 앱 실행 불가 - 에러 화면 표시 후 종료 필요
        rethrow;
      }

      // Kakao SDK 초기화
      try {
        KakaoSdk.init(nativeAppKey: '493a529a0143eee0e513d3bec3eaa6fa');
        debugPrint('[Main] Kakao SDK 초기화 완료');
      } catch (e, st) {
        debugPrint('[Main] Kakao SDK 초기화 실패: $e');
        // 카카오 로그인 불가하지만 앱은 계속 실행
      }

      // FCM 초기화 (웹에서는 지원하지 않음) - 백그라운드에서 비동기 처리
      if (!kIsWeb) {
        // FCM은 앱 시작을 막지 않도록 비동기로 처리
        _initializeFCM();
      }

      // Supabase 초기화
      try {
        await Supabase.initialize(
          url: 'https://bfakxuixdebjvwjbasto.supabase.co',
          anonKey:
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmYWt4dWl4ZGVianZ3amJhc3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0Nzc1NTQsImV4cCI6MjA4NDA1MzU1NH0.q8rb2oY8QimxmCDlLhRncMp-00TriKAOjBNckM-u8SM',
        ).timeout(const Duration(seconds: 10));
        debugPrint('[Main] Supabase 초기화 완료');
      } catch (e, st) {
        debugPrint('[Main] Supabase 초기화 실패: $e');
        // Supabase 실패해도 앱은 계속 실행 (이미지 저장만 불가)
      }

      debugPrint('[Main] 앱 초기화 완료, UI 시작');

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      // Zone 내 캐치되지 않은 비동기 에러 처리
      AppLogger.fatal(
        'Uncaught async error',
        tag: 'ZoneGuard',
        error: error,
        stackTrace: stackTrace,
      );
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'PAL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
