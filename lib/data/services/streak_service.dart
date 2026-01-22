import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/streak_model.dart';
import '../models/badge_model.dart';
import '../models/notification_model.dart';
import '../repositories/streak_repository.dart';
import '../repositories/notification_repository.dart';

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService(
    streakRepository: ref.watch(streakRepositoryProvider),
    notificationRepository: ref.watch(notificationRepositoryProvider),
  );
});

/// 스트릭 업데이트 결과
class StreakUpdateResult {
  final StreakModel streak;
  final bool isNewRecord;
  final List<String> newBadges;
  final int? milestone;

  StreakUpdateResult({
    required this.streak,
    this.isNewRecord = false,
    this.newBadges = const [],
    this.milestone,
  });
}

class StreakService {
  final StreakRepository streakRepository;
  final NotificationRepository notificationRepository;

  StreakService({
    required this.streakRepository,
    required this.notificationRepository,
  });

  /// 체중 기록 시 스트릭 업데이트
  Future<StreakUpdateResult> recordWeight(String memberId) async {
    final updatedStreak = await streakRepository.updateWeightStreak(
      memberId,
      DateTime.now(),
    );

    return await _processStreakUpdate(
      memberId,
      updatedStreak,
      StreakType.weight,
    );
  }

  /// 식단 기록 시 스트릭 업데이트
  Future<StreakUpdateResult> recordDiet(String memberId) async {
    final updatedStreak = await streakRepository.updateDietStreak(
      memberId,
      DateTime.now(),
    );

    return await _processStreakUpdate(
      memberId,
      updatedStreak,
      StreakType.diet,
    );
  }

  /// 스트릭 업데이트 후 처리 (배지 체크, 마일스톤 확인)
  Future<StreakUpdateResult> _processStreakUpdate(
    String memberId,
    StreakModel streak,
    StreakType type,
  ) async {
    final currentStreak = type == StreakType.weight
        ? streak.weightStreak
        : streak.dietStreak;
    final longestStreak = type == StreakType.weight
        ? streak.longestWeightStreak
        : streak.longestDietStreak;

    // 신기록 여부
    final isNewRecord = currentStreak == longestStreak && currentStreak > 1;

    // 마일스톤 체크 (7, 14, 30, 60, 100일)
    int? milestone;
    if ([7, 14, 30, 60, 100].contains(currentStreak)) {
      milestone = currentStreak;
    }

    // 배지 체크
    final newBadges = await _checkAndAwardBadges(memberId, streak, type);

    // 마일스톤 달성 시 알림
    if (milestone != null) {
      await _sendMilestoneNotification(memberId, milestone, type);
    }

    return StreakUpdateResult(
      streak: streak,
      isNewRecord: isNewRecord,
      newBadges: newBadges,
      milestone: milestone,
    );
  }

  /// 배지 획득 체크 및 부여
  Future<List<String>> _checkAndAwardBadges(
    String memberId,
    StreakModel streak,
    StreakType type,
  ) async {
    final List<String> newBadges = [];
    final currentStreak = type == StreakType.weight
        ? streak.weightStreak
        : streak.dietStreak;

    // 기본 배지 목록에서 확인
    for (final badgeData in DefaultBadges.badges) {
      final badgeStreakType = badgeData['streakType'] == 'weight'
          ? StreakType.weight
          : StreakType.diet;

      if (badgeStreakType != type) continue;

      final requiredStreak = badgeData['requiredStreak'] as int;
      final badgeCode = badgeData['code'] as String;

      // 조건 충족 & 아직 미획득
      if (currentStreak >= requiredStreak && !streak.badges.contains(badgeCode)) {
        await streakRepository.addBadge(memberId, badgeCode);
        newBadges.add(badgeCode);

        // 배지 획득 알림
        await _sendBadgeNotification(
          memberId,
          badgeData['name'] as String,
          badgeData['description'] as String,
        );
      }
    }

    return newBadges;
  }

  /// 마일스톤 알림 발송
  Future<void> _sendMilestoneNotification(
    String memberId,
    int days,
    StreakType type,
  ) async {
    final typeLabel = type == StreakType.weight ? '체중' : '식단';

    final notification = NotificationModel(
      id: '',
      userId: memberId,
      type: NotificationType.streakReminder,
      title: '🔥 $days일 연속 $typeLabel 기록 달성!',
      body: '대단해요! $days일 동안 꾸준히 기록했어요. 이 습관을 계속 유지해보세요!',
      data: {
        'type': 'milestone',
        'days': days,
        'streakType': type.name,
      },
      createdAt: DateTime.now(),
    );

    await notificationRepository.create(notification);
  }

  /// 배지 획득 알림 발송
  Future<void> _sendBadgeNotification(
    String memberId,
    String badgeName,
    String description,
  ) async {
    final notification = NotificationModel(
      id: '',
      userId: memberId,
      type: NotificationType.streakReminder,
      title: '🏆 새 배지 획득!',
      body: '$badgeName - $description',
      data: {
        'type': 'badge',
        'badgeName': badgeName,
      },
      createdAt: DateTime.now(),
    );

    await notificationRepository.create(notification);
  }

  /// 현재 스트릭 상태 조회
  Future<StreakModel?> getStreakStatus(String memberId) async {
    return await streakRepository.get(memberId);
  }

  /// 모든 사용자의 stale 스트릭 리셋 (자정 배치)
  Future<void> resetAllStaleStreaks() async {
    await streakRepository.resetStaleStreaks();
  }
}
