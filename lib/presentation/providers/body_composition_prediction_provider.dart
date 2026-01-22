import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_pal_app/data/models/body_composition_prediction_model.dart';

/// 체성분 예측 상태
class BodyCompositionPredictionState {
  final bool isLoading;
  final BodyCompositionPredictionModel? prediction;
  final String? error;

  const BodyCompositionPredictionState({
    this.isLoading = false,
    this.prediction,
    this.error,
  });

  BodyCompositionPredictionState copyWith({
    bool? isLoading,
    BodyCompositionPredictionModel? prediction,
    String? error,
  }) {
    return BodyCompositionPredictionState(
      isLoading: isLoading ?? this.isLoading,
      prediction: prediction ?? this.prediction,
      error: error,
    );
  }
}

/// 체성분 예측 Notifier
class BodyCompositionPredictionNotifier
    extends Notifier<BodyCompositionPredictionState> {
  @override
  BodyCompositionPredictionState build() =>
      const BodyCompositionPredictionState();

  /// 체성분 예측 요청 (체중 + 골격근량 + 체지방률)
  Future<void> predictBodyComposition(String memberId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final functions =
          FirebaseFunctions.instanceFor(region: 'asia-northeast3');
      final callable = functions.httpsCallable('predictBodyComposition');
      final result = await callable.call({'memberId': memberId});

      if (result.data['success'] == true) {
        final predictions = result.data['predictions'] as Map<String, dynamic>;

        // Parse each metric prediction
        MetricPrediction? weightPred;
        MetricPrediction? musclePred;
        MetricPrediction? bodyFatPred;

        if (predictions['weight'] != null) {
          weightPred = MetricPrediction.fromJson(
            Map<String, dynamic>.from(predictions['weight']),
          );
        }
        if (predictions['skeletalMuscleMass'] != null) {
          musclePred = MetricPrediction.fromJson(
            Map<String, dynamic>.from(predictions['skeletalMuscleMass']),
          );
        }
        if (predictions['bodyFatPercent'] != null) {
          bodyFatPred = MetricPrediction.fromJson(
            Map<String, dynamic>.from(predictions['bodyFatPercent']),
          );
        }

        final model = BodyCompositionPredictionModel(
          id: result.data['predictionId'] ?? '',
          memberId: memberId,
          trainerId: '',
          weightPrediction: weightPred,
          musclePrediction: musclePred,
          bodyFatPrediction: bodyFatPred,
          analysisMessage: result.data['analysisMessage'] ?? '',
          dataPointsUsed:
              Map<String, int>.from(result.data['dataPointsUsed'] ?? {}),
          createdAt: DateTime.now(),
        );

        state = state.copyWith(isLoading: false, prediction: model);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.data['error'] ?? '예측에 실패했습니다.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: '예측 중 오류가 발생했습니다: ${e.toString()}',
      );
    }
  }

  /// 상태 초기화
  void reset() {
    state = const BodyCompositionPredictionState();
  }
}

/// Provider
final bodyCompositionPredictionProvider = NotifierProvider<
    BodyCompositionPredictionNotifier, BodyCompositionPredictionState>(
  BodyCompositionPredictionNotifier.new,
);
