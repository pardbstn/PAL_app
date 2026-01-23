import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_stats_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_stats_repository.dart';

/// 트레이너 통계 레포지토리 프로바이더
final trainerStatsRepositoryProvider = Provider<TrainerStatsRepository>((ref) {
  return TrainerStatsRepository();
});

/// 트레이너 통계 스트림 프로바이더
final trainerStatsProvider = StreamProvider.family<TrainerStatsModel?, String>((ref, trainerId) {
  final repo = ref.watch(trainerStatsRepositoryProvider);
  return repo.watchStats(trainerId);
});

/// 통계 이벤트 타입
enum StatsEventType {
  messageSent,        // 메시지 발송
  proactiveMessage,   // 능동적 메시지 (트레이너가 먼저)
  dietFeedback,       // 식단 피드백 작성
  memberDataView,     // 회원 데이터 조회
  aiInsightView,      // AI 인사이트 확인
}

/// 통계 업데이트 노티파이어 (이벤트 기반 stats 수집)
class TrainerStatsNotifier extends Notifier<void> {
  @override
  void build() {}

  /// 이벤트 발생 시 통계 업데이트
  Future<void> trackEvent(String trainerId, StatsEventType event) async {
    final repo = ref.read(trainerStatsRepositoryProvider);

    switch (event) {
      case StatsEventType.proactiveMessage:
        await repo.incrementProactiveMessage(trainerId);
        break;
      case StatsEventType.dietFeedback:
        await repo.incrementDietFeedback(trainerId);
        break;
      case StatsEventType.memberDataView:
        await repo.incrementDataView(trainerId);
        break;
      case StatsEventType.messageSent:
      case StatsEventType.aiInsightView:
        // Cloud Functions에서 처리
        break;
    }
  }

  /// 응답 시간 업데이트
  Future<void> updateResponseTime(String trainerId, double avgMinutes) async {
    final repo = ref.read(trainerStatsRepositoryProvider);
    await repo.updateResponseTime(trainerId, avgMinutes);
  }
}

/// 통계 업데이트 프로바이더
final trainerStatsNotifierProvider = NotifierProvider<TrainerStatsNotifier, void>(() {
  return TrainerStatsNotifier();
});
