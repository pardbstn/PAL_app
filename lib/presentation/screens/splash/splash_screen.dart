import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

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
    debugPrint('[Splash] 네비게이션 시작...');

    // 애니메이션을 위해 잠시 대기 (웹에서는 1초)
    await Future.delayed(Duration(seconds: kIsWeb ? 1 : 2));
    debugPrint('[Splash] 딜레이 완료');

    if (!mounted) {
      debugPrint('[Splash] mounted=false, 종료');
      return;
    }

    // 인증 상태가 로드될 때까지 최대 5초 대기
    AuthState authState = ref.read(authProvider);
    debugPrint('[Splash] 초기 authState: isLoading=${authState.isLoading}, isAuthenticated=${authState.isAuthenticated}');

    int waitCount = 0;
    const maxWait = 10; // 최대 5초 (0.5초 * 10)

    while (authState.isLoading && waitCount < maxWait) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      authState = ref.read(authProvider);
      waitCount++;
      debugPrint('[Splash] 대기 중... $waitCount/$maxWait');
    }

    if (!mounted) return;

    debugPrint('[Splash] 최종 authState: isAuthenticated=${authState.isAuthenticated}, role=${authState.userRole}');

    // 로그인 상태 확인
    if (!authState.isAuthenticated) {
      debugPrint('[Splash] 로그인 화면으로 이동');
      context.go(AppRoutes.login);
      return;
    }

    // 역할에 따라 홈으로 이동
    if (authState.userRole == UserRole.trainer) {
      debugPrint('[Splash] 트레이너 홈으로 이동');
      context.go(AppRoutes.trainerHome);
    } else {
      debugPrint('[Splash] 회원 홈으로 이동');
      context.go(AppRoutes.memberHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A2140), const Color(0xFF162035)]
                : [const Color(0xFFDBE1FE), const Color(0xFFD5F5E3)],
          ),
        ),
        child: Center(
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
            Text(
              'PAL',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF2563EB),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.8)
                    : const Color(0xFF64748B),
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
                  isDark
                      ? Colors.white.withValues(alpha: 0.7)
                      : const Color(0xFF2563EB).withValues(alpha: 0.5),
                ),
              ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(duration: 300.ms),
          ],
        ),
      ),
      ),
    );
  }
}
