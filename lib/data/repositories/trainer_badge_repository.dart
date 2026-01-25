import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../models/trainer_badge_model.dart';
import '../models/trainer_stats_model.dart';

/// 트레이너 배지 레포지토리
class TrainerBadgeRepository {
  final FirebaseFirestore _firestore;

  TrainerBadgeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 배지 조회
  Future<TrainerBadgeModel?> getBadges(String trainerId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.badges)
        .doc('current')
        .get();
    if (!doc.exists) return null;
    return TrainerBadgeModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// 배지 업데이트
  Future<void> updateBadges(String trainerId, TrainerBadgeModel badges) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.badges)
        .doc('current')
        .set(badges.toJson());
  }

  /// 배지 조건 체크 및 업데이트
  Future<List<BadgeItem>> checkAndUpdateBadges(String trainerId, TrainerStatsModel stats) async {
    final existing = await getBadges(trainerId);
    final currentBadges = existing?.activeBadges ?? [];
    final history = existing?.badgeHistory ?? [];

    final newActiveBadges = <BadgeItem>[];
    final now = DateTime.now();

    // 각 배지 조건 체크
    for (final badgeType in TrainerBadgeType.values) {
      final isEarned = _checkBadgeCondition(badgeType, stats);
      final existingBadge = currentBadges.where((b) => b.type == badgeType.name).firstOrNull;

      if (isEarned) {
        if (existingBadge != null) {
          newActiveBadges.add(existingBadge);
        } else {
          final newBadge = BadgeItem(
            type: badgeType.name,
            name: badgeType.displayName,
            icon: badgeType.icon,
            earnedAt: now,
          );
          newActiveBadges.add(newBadge);
          history.add(newBadge);
        }
      } else if (existingBadge != null) {
        // 배지 해제
        history.add(BadgeItem(
          type: existingBadge.type,
          name: existingBadge.name,
          icon: existingBadge.icon,
          earnedAt: existingBadge.earnedAt,
          revokedAt: now,
        ));
      }
    }

    await updateBadges(trainerId, TrainerBadgeModel(
      activeBadges: newActiveBadges,
      badgeHistory: history,
    ));

    return newActiveBadges;
  }

  /// 배지 조건 체크
  bool _checkBadgeCondition(TrainerBadgeType type, TrainerStatsModel stats) {
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

  /// 배지 스트림 (실시간)
  Stream<TrainerBadgeModel?> watchBadges(String trainerId) {
    return _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.badges)
        .doc('current')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return TrainerBadgeModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }
}
