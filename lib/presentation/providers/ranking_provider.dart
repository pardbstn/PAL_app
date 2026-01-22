import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_performance_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_performance_repository.dart';

/// 랭킹 타입 열거형
enum RankingType {
  /// 평점 기준 랭킹 (리뷰 5개 이상인 트레이너만)
  rating,

  /// 재등록률 기준 랭킹
  reregistration,
}

/// 랭킹 조회 파라미터
class RankingParams {
  final RankingType type;
  final int limit;

  const RankingParams({
    required this.type,
    this.limit = 10,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          limit == other.limit;

  @override
  int get hashCode => type.hashCode ^ limit.hashCode;
}

/// 평점 기준 트레이너 랭킹 (상위 10명)
/// 리뷰 5개 이상인 트레이너만 포함
final ratingRankingProvider =
    FutureProvider<List<TrainerPerformanceModel>>((ref) async {
  final repository = ref.watch(trainerPerformanceRepositoryProvider);
  return repository.getRankingByRating(limit: 10);
});

/// 재등록률 기준 트레이너 랭킹 (상위 10명)
final reregistrationRankingProvider =
    FutureProvider<List<TrainerPerformanceModel>>((ref) async {
  final repository = ref.watch(trainerPerformanceRepositoryProvider);
  return repository.getRankingByReregistration(limit: 10);
});

/// 유연한 랭킹 조회 (타입과 개수 지정 가능)
/// 사용 예: ref.watch(rankingProvider(RankingParams(type: RankingType.rating, limit: 20)))
final rankingProvider = FutureProvider.family<List<TrainerPerformanceModel>,
    RankingParams>((ref, params) async {
  final repository = ref.watch(trainerPerformanceRepositoryProvider);

  switch (params.type) {
    case RankingType.rating:
      return repository.getRankingByRating(limit: params.limit);
    case RankingType.reregistration:
      return repository.getRankingByReregistration(limit: params.limit);
  }
});
