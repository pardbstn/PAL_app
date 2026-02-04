import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pal_app/core/constants/routes.dart';

/// 스플래시 화면
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // 최소 대기 후 로그인 화면으로 이동 (라우터 redirect가 처리)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_navigated) {
        _navigated = true;
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 네이티브 스플래시와 동일한 배경색 사용으로 전환 시 깜빡임 방지
    // 네이티브 스플래시 이미지와 일치하는 단색 배경
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A2140)  // 다크모드: 네이티브 darkbackground.png와 일치
          : const Color(0xFFDBE1FE), // 라이트모드: 네이티브 background.png와 일치
      body: const SizedBox.shrink(), // 배경색만 표시 (로고 없음)
    );
  }
}
