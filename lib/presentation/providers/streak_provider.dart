import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/streak_model.dart';
import '../../data/models/badge_model.dart';
import '../../data/repositories/streak_repository.dart';
import '../../data/services/streak_service.dart';

/// 특정 회원의 스트릭 실시간 감시
final memberStreakProvider = StreamProvider.family<StreakModel?, String>((ref, memberId) {
  final repository = ref.watch(streakRepositoryProvider);
  return repository.watch(memberId);
});

/// 현재 로그인 회원의 스트릭 (authProvider와 연동 필요)
// final currentMemberStreakProvider = StreamProvider<StreakModel?>((ref) {
//   final currentUser = ref.watch(currentUserProvider);
//   if (currentUser == null) return Stream.value(null);
//   final repository = ref.watch(streakRepositoryProvider);
//   return repository.watch(currentUser.id);
// });

/// 스트릭 관리 Notifier
class StreakNotifier extends AsyncNotifier<StreakUpdateResult?> {
  @override
  Future<StreakUpdateResult?> build() async => null;

  /// 체중 기록 시 스트릭 업데이트
  Future<StreakUpdateResult> recordWeight(String memberId) async {
    final service = ref.read(streakServiceProvider);
    final result = await service.recordWeight(memberId);
    state = AsyncData(result);
    return result;
  }

  /// 식단 기록 시 스트릭 업데이트
  Future<StreakUpdateResult> recordDiet(String memberId) async {
    final service = ref.read(streakServiceProvider);
    final result = await service.recordDiet(memberId);
    state = AsyncData(result);
    return result;
  }

  /// 스트릭 상태 리셋
  void resetState() {
    state = const AsyncData(null);
  }
}

final streakNotifierProvider = AsyncNotifierProvider<StreakNotifier, StreakUpdateResult?>(() {
  return StreakNotifier();
});

/// 회원이 획득한 배지 목록 (스트릭 기반)
final earnedBadgesProvider = Provider.family<List<BadgeModel>, StreakModel?>((ref, streak) {
  if (streak == null) return [];

  final List<BadgeModel> earnedBadges = [];

  for (final badgeData in DefaultBadges.badges) {
    final badgeCode = badgeData['code'] as String;

    if (streak.badges.contains(badgeCode)) {
      earnedBadges.add(BadgeModel(
        id: badgeCode,
        code: badgeCode,
        name: badgeData['name'] as String,
        description: badgeData['description'] as String,
        iconUrl: badgeData['iconUrl'] as String,
        requiredStreak: badgeData['requiredStreak'] as int,
        streakType: badgeData['streakType'] == 'weight'
            ? StreakType.weight
            : StreakType.diet,
      ));
    }
  }

  return earnedBadges;
});

/// 다음 획득 가능한 배지 목록
final nextBadgesProvider = Provider.family<List<BadgeModel>, StreakModel?>((ref, streak) {
  if (streak == null) return [];

  final List<BadgeModel> nextBadges = [];

  for (final badgeData in DefaultBadges.badges) {
    final badgeCode = badgeData['code'] as String;

    // 아직 획득하지 않은 배지만
    if (!streak.badges.contains(badgeCode)) {
      final streakType = badgeData['streakType'] == 'weight'
          ? StreakType.weight
          : StreakType.diet;
      final currentStreak = streakType == StreakType.weight
          ? streak.weightStreak
          : streak.dietStreak;
      final requiredStreak = badgeData['requiredStreak'] as int;

      // 현재 스트릭보다 높은 목표만
      if (requiredStreak > currentStreak) {
        nextBadges.add(BadgeModel(
          id: badgeCode,
          code: badgeCode,
          name: badgeData['name'] as String,
          description: badgeData['description'] as String,
          iconUrl: badgeData['iconUrl'] as String,
          requiredStreak: requiredStreak,
          streakType: streakType,
        ));
      }
    }
  }

  // 필요 스트릭 기준 정렬
  nextBadges.sort((a, b) => a.requiredStreak.compareTo(b.requiredStreak));

  return nextBadges;
});
