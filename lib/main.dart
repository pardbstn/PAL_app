import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_pal_app/firebase_options.dart';
import 'package:flutter_pal_app/core/theme/app_theme.dart';
import 'package:flutter_pal_app/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

    return MaterialApp.router(
      title: 'PAL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
