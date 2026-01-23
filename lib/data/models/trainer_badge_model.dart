import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trainer_badge_model.freezed.dart';
part 'trainer_badge_model.g.dart';

/// 트레이너 배지 유형
enum TrainerBadgeType {
  lightningResponse('번개응답', '⚡', '최근 30일 평균 응답시간 30분 이내'),
  fastResponse('빠른응답', '💬', '최근 30일 평균 응답시간 1시간 이내'),
  consistentCommunication('꾸준한소통', '📱', '주 3회 이상 회원에게 먼저 메시지'),
  goalAchiever('목표달성왕', '🎯', '회원 목표달성률 80% 이상'),
  bodyTransformExpert('체형변화전문가', '💪', '회원 평균 체지방 -3% 이상'),
  consistencyPower('꾸준함의힘', '📅', '회원 평균 출석률 90% 이상'),
  reRegistrationMaster('재등록마스터', '🔄', '재등록률 70% 이상'),
  longTermMemberHolder('장기회원보유', '🤝', '6개월 이상 회원 3명 이상'),
  zeroNoShow('노쇼제로', '✅', '최근 3개월 트레이너 노쇼율 0%'),
  aiInsightPro('AI인사이트활용왕', '🤖', 'AI 인사이트 확인율 90% 이상'),
  dataBasedCoaching('데이터기반코칭', '📈', '회원 데이터 주 3회 이상 확인'),
  dietFeedbackExpert('식단피드백전문가', '🥗', '식단 분석 피드백 누적 50회 이상');

  const TrainerBadgeType(this.displayName, this.icon, this.description);
  final String displayName;
  final String icon;
  final String description;
}

class BadgeTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const BadgeTimestampConverter();
  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

class NullableBadgeTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableBadgeTimestampConverter();
  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }
  @override
  dynamic toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}

@freezed
sealed class BadgeItem with _$BadgeItem {
  const factory BadgeItem({
    required String type,
    required String name,
    required String icon,
    @BadgeTimestampConverter() required DateTime earnedAt,
    @NullableBadgeTimestampConverter() DateTime? revokedAt,
  }) = _BadgeItem;

  factory BadgeItem.fromJson(Map<String, dynamic> json) =>
      _$BadgeItemFromJson(json);
}

@freezed
sealed class TrainerBadgeModel with _$TrainerBadgeModel {
  const factory TrainerBadgeModel({
    @Default('') String id,
    @Default([]) List<BadgeItem> activeBadges,
    @Default([]) List<BadgeItem> badgeHistory,
  }) = _TrainerBadgeModel;

  factory TrainerBadgeModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerBadgeModelFromJson(json);
}
