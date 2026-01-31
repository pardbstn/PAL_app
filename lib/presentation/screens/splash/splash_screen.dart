import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // 배경색만 표시 (로고 없음)
        child: const SizedBox.shrink(),
      ),
    );
  }
}
