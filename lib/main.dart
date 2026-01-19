import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_pal_app/firebase_options.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/router/app_router.dart';
import 'package:flutter_pal_app/presentation/providers/theme_provider.dart';
import 'package:flutter_pal_app/data/services/fcm_service.dart';

/// FCM 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('[FCM] 백그라운드 메시지 수신: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FCM 서비스 초기화
  final fcmService = FCMService();
  await fcmService.initialize();

  // Supabase 초기화
  await Supabase.initialize(
    url: 'https://bfakxuixdebjvwjbasto.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJmYWt4dWl4ZGVianZ3amJhc3RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0Nzc1NTQsImV4cCI6MjA4NDA1MzU1NH0.q8rb2oY8QimxmCDlLhRncMp-00TriKAOjBNckM-u8SM',
  );

  runApp(const ProviderScope(child: MyApp()));
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
