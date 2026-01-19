import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

// Screens
import 'package:flutter_pal_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_shell.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_home_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_members_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_member_detail_screen.dart';
// 웹 전용 화면
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_web_shell.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_dashboard_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_members_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_member_detail_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/ai_curriculum_generator_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_calendar_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/add_schedule_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_messages_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_settings_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_shell.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_home_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_records_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_diet_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_messages_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_settings_screen.dart';

// ============================================================================
// 페이지 전환 애니메이션
// ============================================================================

/// 페이드 전환 페이지 (기본 페이지용)
CustomTransitionPage<void> buildFadeTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// 슬라이드 전환 페이지 (상세 페이지용)
CustomTransitionPage<void> buildSlideTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,

    // 리다이렉트 가드
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginPage = state.matchedLocation == AppRoutes.login;
      final userRole = authState.userRole;

      // 로그인 안 했으면 로그인 페이지로
      if (!isLoggedIn && !isLoginPage) {
        return AppRoutes.login;
      }

      // 로그인 했는데 로그인 페이지면 역할에 따라 홈으로
      if (isLoggedIn && isLoginPage) {
        if (userRole == UserRole.trainer) {
          return AppRoutes.trainerHome;
        } else if (userRole == UserRole.member) {
          return AppRoutes.memberHome;
        }
      }

      // 트레이너가 회원 경로 접근 시도시 트레이너 홈으로
      if (isLoggedIn &&
          userRole == UserRole.trainer &&
          state.matchedLocation.startsWith('/member')) {
        return AppRoutes.trainerHome;
      }

      // 회원이 트레이너 경로 접근 시도시 회원 홈으로
      if (isLoggedIn &&
          userRole == UserRole.member &&
          state.matchedLocation.startsWith('/trainer')) {
        return AppRoutes.memberHome;
      }

      return null; // 리다이렉트 없음
    },

    // 라우트 정의
    routes: [
      // 로그인
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // 트레이너 라우트 (ShellRoute로 Bottom Navigation 유지)
      // 웹에서는 TrainerWebShell(사이드바), 모바일에서는 TrainerShell(바텀 네비) 사용
      ShellRoute(
        builder: (context, state, child) => kIsWeb
            ? TrainerWebShell(child: child)
            : TrainerShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.trainerHome,
            name: RouteNames.trainerHome,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: kIsWeb
                  ? const TrainerDashboardWebScreen()
                  : const TrainerHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerMembers,
            name: RouteNames.trainerMembers,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: kIsWeb
                  ? const TrainerMembersWebScreen()
                  : const TrainerMembersScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerCalendar,
            name: RouteNames.trainerCalendar,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const TrainerCalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerMessages,
            name: RouteNames.trainerMessages,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const TrainerMessagesScreen(),
            ),
          ),
        ],
      ),

      // 트레이너 - Shell 외부 라우트 (상세 페이지 등)
      // 웹에서는 TrainerMemberDetailWebScreen, 모바일에서는 TrainerMemberDetailScreen 사용
      GoRoute(
        path: AppRoutes.trainerMemberDetail,
        name: RouteNames.trainerMemberDetail,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: kIsWeb
              ? const TrainerMemberDetailWebScreen()
              : const TrainerMemberDetailScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.trainerCurriculumCreate,
        name: RouteNames.trainerCurriculumCreate,
        pageBuilder: (context, state) {
          final memberId = state.uri.queryParameters['memberId'];
          final memberName = state.uri.queryParameters['memberName'];
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: AiCurriculumGeneratorScreen(
              memberId: memberId,
              memberName: memberName,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trainerSettings,
        name: RouteNames.trainerSettings,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const TrainerSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.trainerScheduleAdd,
        name: RouteNames.trainerScheduleAdd,
        pageBuilder: (context, state) {
          final dateStr = state.uri.queryParameters['date'];
          DateTime? initialDate;
          if (dateStr != null) {
            initialDate = DateTime.tryParse(dateStr);
          }
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: AddScheduleScreen(initialDate: initialDate),
          );
        },
      ),

      // 회원 라우트 (ShellRoute로 Bottom Navigation 유지)
      ShellRoute(
        builder: (context, state, child) => MemberShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.memberHome,
            name: RouteNames.memberHome,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const MemberHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberRecords,
            name: RouteNames.memberRecords,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const MemberRecordsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberDiet,
            name: RouteNames.memberDiet,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const MemberDietScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberMessages,
            name: RouteNames.memberMessages,
            pageBuilder: (context, state) => buildFadeTransitionPage(
              key: state.pageKey,
              child: const MemberMessagesScreen(),
            ),
          ),
        ],
      ),

      // 회원 - Shell 외부 라우트 (설정 페이지)
      GoRoute(
        path: AppRoutes.memberSettings,
        name: RouteNames.memberSettings,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const MemberSettingsScreen(),
        ),
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('페이지를 찾을 수 없습니다: ${state.error}'),
      ),
    ),
  );
});
