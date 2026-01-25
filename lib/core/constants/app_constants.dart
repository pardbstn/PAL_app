/// 앱 공통 상수
class AppConstants {
  AppConstants._();

  // 표시 제한
  static const int badgeDisplayCap = 99;
  static const String badgeOverflowText = '99+';

  // 목록 제한
  static const int defaultListLimit = 20;
  static const int messageListLimit = 50;
  static const int predictionDisplayLimit = 10;

  // 구독 티어별 회원 한도
  static const int freeTierMemberLimit = 5;
  static const int basicTierMemberLimit = 30;
  static const int proTierMemberLimit = 999999;

  // 체성분 입력 유효성 검사
  static const double maxWeight = 300.0;
  static const double maxBodyFat = 80.0;
  static const double maxMuscleMass = 100.0;

  // 배지 기준
  static const double goalAchievementThreshold = 80.0;
  static const double attendanceRateThreshold = 90.0;
  static const double reRegistrationRateThreshold = 70.0;
  static const double insightViewRateThreshold = 90.0;
  static const int dietFeedbackCountThreshold = 50;
  static const int fastResponseTimeMinutes = 30;
  static const int superFastResponseTimeMinutes = 60;

  // 요청 만료
  static const int requestExpiryHours = 48;
}
