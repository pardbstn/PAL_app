import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_pal_app/core/constants/routes.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/curriculum_template_model.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

// Screens
import 'package:flutter_pal_app/presentation/screens/auth/login_screen.dart';
import 'package:flutter_pal_app/presentation/screens/auth/role_selection_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_shell.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_home_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_members_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_member_detail_screen.dart';
// 웹 전용 화면
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_web_shell.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_dashboard_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_members_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_member_detail_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_schedule_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/web/trainer_revenue_web_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/curriculum_settings_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/curriculum_result_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_calendar_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/add_schedule_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_settings_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_insights_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_shell.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_home_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_records_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_calendar_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_diet_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_settings_screen.dart';
import 'package:flutter_pal_app/presentation/screens/splash/splash_screen.dart';
import 'package:flutter_pal_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:flutter_pal_app/presentation/screens/chat/chat_list_screen.dart';
import 'package:flutter_pal_app/presentation/screens/chat/chat_room_screen.dart';
import 'package:flutter_pal_app/presentation/screens/common/notifications_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/member_review_trainer_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/subscription_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/self_training_home_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/monthly_report_screen.dart';
import 'package:flutter_pal_app/presentation/screens/member/trainer_question_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_requests_screen.dart';
import 'package:flutter_pal_app/presentation/screens/trainer/trainer_rating_detail_screen.dart';

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
    opaque: true,
    maintainState: false, // 이전 페이지 상태 유지 안함
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
    opaque: true,
    maintainState: false, // 이전 페이지 상태 유지 안함
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      // 배경색으로 이전 페이지 잔상 방지
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// 즉시 전환 페이지 (Shell 내부 탭 전환용 - AnimatedSwitcher가 처리)
CustomTransitionPage<void> buildInstantTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    opaque: true,
    maintainState: false,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
  );
}

/// GoRouter Provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final refreshListenable = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,

    // 리다이렉트 가드
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isPendingRoleSelection = authState.isPendingRoleSelection;
      final currentPath = state.matchedLocation;
      final userRole = authState.userRole;

      // 스플래시와 온보딩은 리다이렉트 없음
      if (currentPath == AppRoutes.splash || currentPath == AppRoutes.onboarding) {
        return null;
      }

      final isLoginPage = currentPath == AppRoutes.login;
      final isRoleSelectionPage = currentPath == AppRoutes.roleSelection;

      // 역할 선택 대기 중이면 역할 선택 페이지로
      if (isLoggedIn && isPendingRoleSelection && !isRoleSelectionPage) {
        return AppRoutes.roleSelection;
      }

      // 역할 선택 완료 후 역할 선택 페이지 접근 시 홈으로
      if (isLoggedIn && !isPendingRoleSelection && isRoleSelectionPage) {
        if (userRole == UserRole.trainer) {
          return AppRoutes.trainerHome;
        } else if (userRole == UserRole.member) {
          return AppRoutes.memberHome;
        }
      }

      // 로그인 안 했으면 로그인 페이지로
      if (!isLoggedIn && !isLoginPage) {
        return AppRoutes.login;
      }

      // 로그인 했는데 로그인 페이지면 역할에 따라 홈으로
      if (isLoggedIn && !isPendingRoleSelection && isLoginPage) {
        if (userRole == UserRole.trainer) {
          return AppRoutes.trainerHome;
        } else if (userRole == UserRole.member) {
          return AppRoutes.memberHome;
        }
        // userRole이 아직 로드되지 않은 경우 (null) 로그인 페이지 유지
        // authStateChanges 리스너가 _loadUserData 완료 후 다시 리다이렉트됨
      }

      // 트레이너가 회원 경로 접근 시도시 트레이너 홈으로
      if (isLoggedIn &&
          !isPendingRoleSelection &&
          userRole == UserRole.trainer &&
          currentPath.startsWith('/member')) {
        return AppRoutes.trainerHome;
      }

      // 회원이 트레이너 경로 접근 시도시 회원 홈으로
      if (isLoggedIn &&
          !isPendingRoleSelection &&
          userRole == UserRole.member &&
          currentPath.startsWith('/trainer')) {
        return AppRoutes.memberHome;
      }

      return null;
    },

    // 라우트 정의
    routes: [
      // 스플래시
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),

      // 온보딩
      GoRoute(
        path: AppRoutes.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),

      // 로그인
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // 역할 선택 (소셜 로그인 후 신규 사용자)
      GoRoute(
        path: AppRoutes.roleSelection,
        name: RouteNames.roleSelection,
        pageBuilder: (context, state) => buildFadeTransitionPage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
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
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: kIsWeb
                  ? const TrainerDashboardWebScreen()
                  : const TrainerHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerMembers,
            name: RouteNames.trainerMembers,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: kIsWeb
                  ? const TrainerMembersWebScreen()
                  : const TrainerMembersScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerCalendar,
            name: RouteNames.trainerCalendar,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: kIsWeb
                  ? const TrainerScheduleWebScreen()
                  : const TrainerCalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerMessages,
            name: RouteNames.trainerMessages,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const ChatListScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.trainerRevenue,
            name: RouteNames.trainerRevenue,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const TrainerRevenueWebScreen(),
            ),
          ),
        ],
      ),

      // 트레이너 채팅방
      GoRoute(
        path: AppRoutes.trainerChatRoom,
        name: RouteNames.trainerChatRoom,
        pageBuilder: (context, state) {
          final chatRoomId = state.pathParameters['chatRoomId']!;
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: ChatRoomScreen(chatRoomId: chatRoomId),
          );
        },
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
          final additionalSessions = int.tryParse(state.uri.queryParameters['additionalSessions'] ?? '');
          final startSession = int.tryParse(state.uri.queryParameters['startSession'] ?? '');
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: CurriculumSettingsScreen(
              memberId: memberId,
              memberName: memberName,
              additionalSessions: additionalSessions,
              startSession: startSession,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trainerCurriculumResult,
        name: RouteNames.trainerCurriculumResult,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: CurriculumResultScreen(
              memberId: extra['memberId'] as String?,
              memberName: extra['memberName'] as String?,
              settings: extra['settings'] as CurriculumSettings?,
              excludedExerciseIds: (extra['excludedExerciseIds'] as List<String>?) ?? [],
              isAdditionalMode: extra['isAdditionalMode'] as bool? ?? false,
              startSession: extra['startSession'] as int?,
              templateSessions: extra['templateSessions'] as List<TemplateSession>?,
              isFromTemplate: extra['isFromTemplate'] as bool? ?? false,
              templateName: extra['templateName'] as String?,
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
      GoRoute(
        path: AppRoutes.trainerInsights,
        name: RouteNames.trainerInsights,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const TrainerInsightsScreen(),
        ),
      ),
      // 트레이너 요청 관리 (트레이너용)
      GoRoute(
        path: AppRoutes.trainerRequests,
        name: RouteNames.trainerRequests,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const TrainerRequestsScreen(),
        ),
      ),
      // 트레이너 평점 상세
      GoRoute(
        path: AppRoutes.trainerRatingDetail,
        name: RouteNames.trainerRatingDetail,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const TrainerRatingDetailScreen(),
        ),
      ),

      // 회원 라우트 (ShellRoute로 Bottom Navigation 유지)
      ShellRoute(
        builder: (context, state, child) => MemberShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.memberHome,
            name: RouteNames.memberHome,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const MemberHomeScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberRecords,
            name: RouteNames.memberRecords,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const MemberRecordsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberCalendar,
            name: RouteNames.memberCalendar,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const MemberCalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberDiet,
            name: RouteNames.memberDiet,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const MemberDietScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.memberMessages,
            name: RouteNames.memberMessages,
            pageBuilder: (context, state) => buildInstantTransitionPage(
              key: state.pageKey,
              child: const ChatListScreen(),
            ),
          ),
        ],
      ),

      // 회원 채팅방
      GoRoute(
        path: AppRoutes.memberChatRoom,
        name: RouteNames.memberChatRoom,
        pageBuilder: (context, state) {
          final chatRoomId = state.pathParameters['chatRoomId']!;
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: ChatRoomScreen(chatRoomId: chatRoomId),
          );
        },
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
      // 트레이너 리뷰 작성 (회원)
      GoRoute(
        path: AppRoutes.memberReviewTrainer,
        name: RouteNames.memberReviewTrainer,
        pageBuilder: (context, state) {
          final trainerId = state.pathParameters['trainerId']!;
          final memberId = state.uri.queryParameters['memberId'] ?? '';
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: MemberReviewTrainerScreen(
              trainerId: trainerId,
              memberId: memberId,
            ),
          );
        },
      ),
      // 구독 관리
      GoRoute(
        path: AppRoutes.memberSubscription,
        name: RouteNames.memberSubscription,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const SubscriptionScreen(),
        ),
      ),
      // 셀프 트레이닝 홈
      GoRoute(
        path: AppRoutes.memberSelfTraining,
        name: RouteNames.memberSelfTraining,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const SelfTrainingHomeScreen(),
        ),
      ),
      // 월간 리포트
      GoRoute(
        path: AppRoutes.memberMonthlyReport,
        name: RouteNames.memberMonthlyReport,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const MonthlyReportScreen(),
        ),
      ),
      // 트레이너 질문
      GoRoute(
        path: AppRoutes.memberTrainerQuestion,
        name: RouteNames.memberTrainerQuestion,
        pageBuilder: (context, state) => buildSlideTransitionPage(
          key: state.pageKey,
          child: const TrainerQuestionScreen(),
        ),
      ),

      // 공통 라우트 (회원/트레이너 모두 접근 가능)
      // 알림
      GoRoute(
        path: AppRoutes.notifications,
        name: RouteNames.notifications,
        pageBuilder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          return buildSlideTransitionPage(
            key: state.pageKey,
            child: NotificationsScreen(userId: userId),
          );
        },
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
