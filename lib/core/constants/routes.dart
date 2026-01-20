/// PAL 앱 라우트 경로 상수
abstract class AppRoutes {
  // 스플래시 & 온보딩
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // 인증
  static const String login = '/login';

  // 트레이너 경로
  static const String trainerHome = '/trainer/home';
  static const String trainerMembers = '/trainer/members';
  static const String trainerMemberDetail = '/trainer/members/:id';
  static const String trainerCalendar = '/trainer/calendar';
  static const String trainerScheduleAdd = '/trainer/schedule/add';
  static const String trainerCurriculumCreate = '/trainer/curriculum/create';
  static const String trainerMessages = '/trainer/messages';
  static const String trainerChatRoom = '/trainer/messages/:chatRoomId';
  static const String trainerSettings = '/trainer/settings';
  static const String trainerInsights = '/trainer/insights';

  // 회원 경로
  static const String memberHome = '/member/home';
  static const String memberRecords = '/member/records';
  static const String memberCalendar = '/member/calendar';
  static const String memberDiet = '/member/diet';
  static const String memberMessages = '/member/messages';
  static const String memberChatRoom = '/member/messages/:chatRoomId';
  static const String memberSettings = '/member/settings';
}

/// 라우트 이름 상수
abstract class RouteNames {
  // 스플래시 & 온보딩
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  static const String login = 'login';

  // 트레이너
  static const String trainerHome = 'trainer-home';
  static const String trainerMembers = 'trainer-members';
  static const String trainerMemberDetail = 'trainer-member-detail';
  static const String trainerCalendar = 'trainer-calendar';
  static const String trainerScheduleAdd = 'trainer-schedule-add';
  static const String trainerCurriculumCreate = 'trainer-curriculum-create';
  static const String trainerMessages = 'trainer-messages';
  static const String trainerChatRoom = 'trainer-chat-room';
  static const String trainerSettings = 'trainer-settings';
  static const String trainerInsights = 'trainer-insights';

  // 회원
  static const String memberHome = 'member-home';
  static const String memberRecords = 'member-records';
  static const String memberCalendar = 'member-calendar';
  static const String memberDiet = 'member-diet';
  static const String memberMessages = 'member-messages';
  static const String memberChatRoom = 'member-chat-room';
  static const String memberSettings = 'member-settings';
}
