import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/services/ai_service.dart';
import 'package:flutter_pal_app/data/repositories/weight_prediction_repository.dart';
import 'package:flutter_pal_app/data/models/weight_prediction_model.dart';

/// 최신 예측 결과 Provider (Firestore에서 조회 - 실시간 스트림)
final latestPredictionProvider =
    StreamProvider.family<WeightPredictionModel?, String>((ref, memberId) {
  final repository = ref.watch(weightPredictionRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value(null);
  }

  return repository.watchLatestPrediction(memberId);
});

/// 예측 히스토리 Provider
final predictionHistoryProvider =
    StreamProvider.family<List<WeightPredictionModel>, String>((ref, memberId) {
  final repository = ref.watch(weightPredictionRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchPredictionHistory(memberId, limit: 10);
});

/// 예측 존재 여부 Provider
final hasPredictionProvider =
    FutureProvider.family<bool, String>((ref, memberId) async {
  final repository = ref.watch(weightPredictionRepositoryProvider);

  if (memberId.isEmpty) {
    return false;
  }

  return repository.hasPrediction(memberId);
});

/// 체중 예측 서비스 클래스 (UI에서 직접 사용)
class WeightPredictionService {
  final AIService _aiService;

  WeightPredictionService(this._aiService);

  /// 체중 예측 실행
  Future<WeightPredictionResult> predict({
    required String memberId,
    int weeksAhead = 8,
  }) async {
    return _aiService.predictWeight(
      memberId: memberId,
      weeksAhead: weeksAhead,
    );
  }
}

/// 체중 예측 서비스 Provider
final weightPredictionServiceProvider = Provider<WeightPredictionService>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return WeightPredictionService(aiService);
});
