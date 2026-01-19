import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';
import 'package:flutter_pal_app/presentation/providers/onboarding_provider.dart';

/// 스플래시 화면
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    // 애니메이션을 위해 2초 대기
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 첫 실행 여부 확인
    final isFirstRun = await ref.read(isFirstRunProvider.future);

    if (!mounted) return;

    if (isFirstRun) {
      context.go(AppRoutes.onboarding);
      return;
    }

    // 로그인 상태 확인
    final authState = ref.read(authProvider);

    if (!authState.isAuthenticated) {
      context.go(AppRoutes.login);
      return;
    }

    // 역할에 따라 홈으로 이동
    if (authState.userRole == UserRole.trainer) {
      context.go(AppRoutes.trainerHome);
    } else {
      context.go(AppRoutes.memberHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : const Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 60,
                color: Color(0xFF2563EB),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 32),

            // 앱 이름
            const Text(
              'PAL',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 8,
              ),
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut),

            const SizedBox(height: 12),

            // 슬로건
            Text(
              'Progress, Analyze, Level-up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 1,
              ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 80),

            // 로딩 인디케이터
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.7),
                ),
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
