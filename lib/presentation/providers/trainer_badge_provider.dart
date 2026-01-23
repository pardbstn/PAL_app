import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_badge_model.dart';
import 'package:flutter_pal_app/data/models/trainer_stats_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_badge_repository.dart';

/// 트레이너 배지 레포지토리 프로바이더
final trainerBadgeRepositoryProvider = Provider<TrainerBadgeRepository>((ref) {
  return TrainerBadgeRepository();
});

/// 트레이너 배지 스트림 프로바이더
final trainerBadgesProvider = StreamProvider.family<TrainerBadgeModel?, String>((ref, trainerId) {
  final repo = ref.watch(trainerBadgeRepositoryProvider);
  return repo.watchBadges(trainerId);
});

/// 배지 진행률 정보
class BadgeProgress {
  final TrainerBadgeType badgeType;
  final double currentValue;
  final double targetValue;
  final bool isEarned;

  const BadgeProgress({
    required this.badgeType,
    required this.currentValue,
    required this.targetValue,
    required this.isEarned,
  });

  /// 진행률 (0.0 ~ 1.0)
  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);

  /// 퍼센트 (0 ~ 100)
  int get percentComplete => (progress * 100).round();
}

/// 배지 진행률 프로바이더 (현재 stats 기반)
final badgeProgressProvider = Provider.family<List<BadgeProgress>, TrainerStatsModel?>((ref, stats) {
  if (stats == null) return [];

  return TrainerBadgeType.values.map((type) {
    final target = _getTargetValue(type);
    final current = _getCurrentValue(type, stats);
    return BadgeProgress(
      badgeType: type,
      currentValue: current,
      targetValue: target,
      isEarned: _checkCondition(type, stats),
    );
  }).toList();
});

/// 배지별 목표값
double _getTargetValue(TrainerBadgeType type) {
  switch (type) {
    case TrainerBadgeType.lightningResponse:
      return 30; // 30분 이내
    case TrainerBadgeType.fastResponse:
      return 60; // 60분 이내
    case TrainerBadgeType.consistentCommunication:
      return 3; // 주 3회
    case TrainerBadgeType.goalAchiever:
      return 80; // 80%
    case TrainerBadgeType.bodyTransformExpert:
      return 3; // -3%
    case TrainerBadgeType.consistencyPower:
      return 90; // 90%
    case TrainerBadgeType.reRegistrationMaster:
      return 70; // 70%
    case TrainerBadgeType.longTermMemberHolder:
      return 3; // 3명
    case TrainerBadgeType.zeroNoShow:
      return 0; // 0%
    case TrainerBadgeType.aiInsightPro:
      return 90; // 90%
    case TrainerBadgeType.dataBasedCoaching:
      return 3; // 주 3회
    case TrainerBadgeType.dietFeedbackExpert:
      return 50; // 50회
  }
}

/// 배지별 현재값 (stats에서 추출)
double _getCurrentValue(TrainerBadgeType type, TrainerStatsModel stats) {
  switch (type) {
    case TrainerBadgeType.lightningResponse:
    case TrainerBadgeType.fastResponse:
      return stats.avgResponseTimeMinutes;
    case TrainerBadgeType.consistentCommunication:
      return stats.proactiveMessageCount.toDouble();
    case TrainerBadgeType.goalAchiever:
      return stats.memberGoalAchievementRate;
    case TrainerBadgeType.bodyTransformExpert:
      return stats.avgMemberBodyFatChange.abs();
    case TrainerBadgeType.consistencyPower:
      return stats.avgMemberAttendanceRate;
    case TrainerBadgeType.reRegistrationMaster:
      return stats.reRegistrationRate;
    case TrainerBadgeType.longTermMemberHolder:
      return stats.longTermMemberCount.toDouble();
    case TrainerBadgeType.zeroNoShow:
      return stats.trainerNoShowRate;
    case TrainerBadgeType.aiInsightPro:
      return stats.aiInsightViewRate;
    case TrainerBadgeType.dataBasedCoaching:
      return stats.weeklyMemberDataViewCount.toDouble();
    case TrainerBadgeType.dietFeedbackExpert:
      return stats.dietFeedbackCount.toDouble();
  }
}

/// 배지 조건 충족 여부
bool _checkCondition(TrainerBadgeType type, TrainerStatsModel stats) {
  switch (type) {
    case TrainerBadgeType.lightningResponse:
      return stats.avgResponseTimeMinutes > 0 && stats.avgResponseTimeMinutes <= 30;
    case TrainerBadgeType.fastResponse:
      return stats.avgResponseTimeMinutes > 0 && stats.avgResponseTimeMinutes <= 60;
    case TrainerBadgeType.consistentCommunication:
      return stats.proactiveMessageCount >= 3;
    case TrainerBadgeType.goalAchiever:
      return stats.memberGoalAchievementRate >= 80;
    case TrainerBadgeType.bodyTransformExpert:
      return stats.avgMemberBodyFatChange <= -3;
    case TrainerBadgeType.consistencyPower:
      return stats.avgMemberAttendanceRate >= 90;
    case TrainerBadgeType.reRegistrationMaster:
      return stats.reRegistrationRate >= 70;
    case TrainerBadgeType.longTermMemberHolder:
      return stats.longTermMemberCount >= 3;
    case TrainerBadgeType.zeroNoShow:
      return stats.trainerNoShowRate == 0;
    case TrainerBadgeType.aiInsightPro:
      return stats.aiInsightViewRate >= 90;
    case TrainerBadgeType.dataBasedCoaching:
      return stats.weeklyMemberDataViewCount >= 3;
    case TrainerBadgeType.dietFeedbackExpert:
      return stats.dietFeedbackCount >= 50;
  }
}
