import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_pal_app/core/constants/api_constants.dart';
import 'package:flutter_pal_app/core/constants/firestore_constants.dart';
import 'package:flutter_pal_app/data/models/body_composition_prediction_model.dart';

/// 체성분 예측 상태
class BodyCompositionPredictionState {
  final bool isLoading;
  final BodyCompositionPredictionModel? prediction;
  final String? error;
  final bool isDemo; // 데모 데이터 여부

  const BodyCompositionPredictionState({
    this.isLoading = false,
    this.prediction,
    this.error,
    this.isDemo = false,
  });

  BodyCompositionPredictionState copyWith({
    bool? isLoading,
    BodyCompositionPredictionModel? prediction,
    String? error,
    bool? isDemo,
  }) {
    return BodyCompositionPredictionState(
      isLoading: isLoading ?? this.isLoading,
      prediction: prediction ?? this.prediction,
      error: error,
      isDemo: isDemo ?? this.isDemo,
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
    state = state.copyWith(isLoading: true, error: null, isDemo: false);

    try {
      final functions = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      );
      final callable = functions.httpsCallable(
        CloudFunctions.predictBodyComposition,
      );
      final result = await callable.call({'memberId': memberId});
      final data = Map<String, dynamic>.from(result.data as Map);

      if (data['success'] == true) {
        final predictions = Map<String, dynamic>.from(
          data['predictions'] as Map,
        );

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
          id: data['predictionId']?.toString() ?? '',
          memberId: memberId,
          trainerId: '',
          weightPrediction: weightPred,
          musclePrediction: musclePred,
          bodyFatPrediction: bodyFatPred,
          analysisMessage: data['analysisMessage']?.toString() ?? '',
          dataPointsUsed: Map<String, int>.from(
            data['dataPointsUsed'] as Map? ?? {},
          ),
          createdAt: DateTime.now(),
        );

        state = state.copyWith(isLoading: false, prediction: model);
      } else {
        // Cloud Function 실패 시 로컬 폴백 시도
        await _tryLocalFallback(memberId, data['error']?.toString());
      }
    } on FirebaseFunctionsException catch (e) {
      // Firebase Functions 에러 시 로컬 폴백 시도
      await _tryLocalFallback(memberId, e.message);
    } catch (e) {
      // 기타 에러 시 로컬 폴백 시도
      await _tryLocalFallback(memberId, e.toString());
    }
  }

  /// Cloud Function 실패 시 로컬 데이터로 간단한 예측 생성
  Future<void> _tryLocalFallback(String memberId, String? originalError) async {
    try {
      // 체중 기록 가져오기 시도 (인덱스 없이 단순 쿼리)
      final firestore = FirebaseFirestore.instance;
      final bodyRecords = await firestore
          .collection(FirestoreCollections.bodyRecords)
          .where('memberId', isEqualTo: memberId)
          .limit(20)
          .get();

      if (bodyRecords.docs.length < 2) {
        state = state.copyWith(
          isLoading: false,
          error: bodyRecords.docs.isEmpty
              ? '체성분 기록이 없어요.\n먼저 체중을 기록해주세요'
              : '예측을 위해 최소 2개 이상의 기록이 필요합니다.\n체중을 한 번 더 기록해주세요',
        );
        return;
      }

      // 날짜순 정렬 (클라이언트에서)
      final sortedDocs = bodyRecords.docs.toList()
        ..sort((a, b) {
          final aDate = a.data()['recordDate'] as Timestamp?;
          final bDate = b.data()['recordDate'] as Timestamp?;
          if (aDate == null || bDate == null) return 0;
          return bDate.compareTo(aDate); // 최신순
        });

      // 최신 기록 가져오기
      final latestData = sortedDocs.first.data();
      final latestWeight = (latestData['weight'] as num?)?.toDouble();
      final latestMuscle = (latestData['muscleMass'] as num?)?.toDouble();
      final latestBodyFat = (latestData['bodyFatPercent'] as num?)?.toDouble();

      if (latestWeight == null) {
        state = state.copyWith(isLoading: false, error: '체중 데이터가 없어요');
        return;
      }

      // 간단한 트렌드 계산 (있는 데이터로)
      double? weightWeeklyTrend;
      double? muscleWeeklyTrend;
      double? bodyFatWeeklyTrend;

      if (sortedDocs.length >= 2) {
        final oldestData = sortedDocs.last.data();
        final oldestWeight = (oldestData['weight'] as num?)?.toDouble();
        final oldestMuscle = (oldestData['muscleMass'] as num?)?.toDouble();
        final oldestBodyFat = (oldestData['bodyFatPercent'] as num?)?.toDouble();

        final weeks = sortedDocs.length / 2; // 대략적인 주 수
        final weeksNonZero = weeks > 0 ? weeks : 1;

        if (oldestWeight != null) {
          final weightChange = latestWeight - oldestWeight;
          weightWeeklyTrend = weightChange / weeksNonZero;
        }

        if (latestMuscle != null && oldestMuscle != null) {
          final muscleChange = latestMuscle - oldestMuscle;
          muscleWeeklyTrend = muscleChange / weeksNonZero;
        }

        if (latestBodyFat != null && oldestBodyFat != null) {
          final bodyFatChange = latestBodyFat - oldestBodyFat;
          bodyFatWeeklyTrend = bodyFatChange / weeksNonZero;
        }
      }

      // 로컬 예측 모델 생성
      final now = DateTime.now();
      final confidence = sortedDocs.length >= 5 ? 0.6 : 0.3;

      // 4주 후 예측 계산
      final predicted4WeeksWeight = latestWeight + (weightWeeklyTrend ?? 0) * 4;

      final weightPrediction = MetricPrediction(
        current: latestWeight,
        predicted: predicted4WeeksWeight,
        weeklyTrend: weightWeeklyTrend ?? 0,
        confidence: confidence,
        targetValue: null,
        estimatedWeeksToTarget: null,
      );

      // 골격근량 예측 (데이터가 있는 경우)
      MetricPrediction? musclePrediction;
      if (latestMuscle != null) {
        final predicted4WeeksMuscle = latestMuscle + (muscleWeeklyTrend ?? 0) * 4;
        musclePrediction = MetricPrediction(
          current: latestMuscle,
          predicted: predicted4WeeksMuscle,
          weeklyTrend: muscleWeeklyTrend ?? 0,
          confidence: confidence,
          targetValue: null,
          estimatedWeeksToTarget: null,
        );
      }

      // 체지방률 예측 (데이터가 있는 경우)
      MetricPrediction? bodyFatPrediction;
      if (latestBodyFat != null) {
        final predicted4WeeksBodyFat = latestBodyFat + (bodyFatWeeklyTrend ?? 0) * 4;
        bodyFatPrediction = MetricPrediction(
          current: latestBodyFat,
          predicted: predicted4WeeksBodyFat,
          weeklyTrend: bodyFatWeeklyTrend ?? 0,
          confidence: confidence,
          targetValue: null,
          estimatedWeeksToTarget: null,
        );
      }

      // dataPointsUsed 계산 (각 메트릭별 유효한 데이터 개수)
      final muscleCount = sortedDocs.where((doc) =>
        (doc.data()['muscleMass'] as num?) != null
      ).length;
      final bodyFatCount = sortedDocs.where((doc) =>
        (doc.data()['bodyFatPercent'] as num?) != null
      ).length;

      final dataPointsUsed = {
        'weight': sortedDocs.length,
        if (muscleCount > 0) 'muscleMass': muscleCount,
        if (bodyFatCount > 0) 'bodyFatPercent': bodyFatCount,
      };

      final model = BodyCompositionPredictionModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        memberId: memberId,
        trainerId: '',
        weightPrediction: weightPrediction,
        musclePrediction: musclePrediction,
        bodyFatPrediction: bodyFatPrediction,
        analysisMessage: _generateLocalAnalysisMessage(
          latestWeight,
          weightWeeklyTrend,
          sortedDocs.length,
          latestMuscle,
          muscleWeeklyTrend,
          latestBodyFat,
          bodyFatWeeklyTrend,
        ),
        dataPointsUsed: dataPointsUsed,
        createdAt: now,
      );

      state = state.copyWith(
        isLoading: false,
        prediction: model,
        isDemo: true, // 데모 데이터임을 표시
      );
    } catch (e) {
      // 폴백도 실패하면 원래 에러 표시
      state = state.copyWith(
        isLoading: false,
        error: '예측 서비스를 사용할 수 없어요.\n잠시 후 다시 시도해주세요',
      );
    }
  }

  /// 로컬 분석 메시지 생성
  String _generateLocalAnalysisMessage(
    double currentWeight,
    double? weightWeeklyTrend,
    int dataPoints,
    double? currentMuscle,
    double? muscleWeeklyTrend,
    double? currentBodyFat,
    double? bodyFatWeeklyTrend,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('📊 현재 체성분');
    buffer.writeln('체중: ${currentWeight.toStringAsFixed(1)}kg');
    if (currentMuscle != null) {
      buffer.writeln('골격근량: ${currentMuscle.toStringAsFixed(1)}kg');
    }
    if (currentBodyFat != null) {
      buffer.writeln('체지방률: ${currentBodyFat.toStringAsFixed(1)}%');
    }
    buffer.writeln();

    // 체중 트렌드
    if (weightWeeklyTrend != null) {
      if (weightWeeklyTrend < -0.1) {
        buffer.writeln(
          '📉 체중: 주간 ${weightWeeklyTrend.abs().toStringAsFixed(2)}kg 감량 추세',
        );
      } else if (weightWeeklyTrend > 0.1) {
        buffer.writeln('📈 체중: 주간 ${weightWeeklyTrend.toStringAsFixed(2)}kg 증가 추세');
      } else {
        buffer.writeln('➡️ 체중: 안정적으로 유지');
      }
    }

    // 골격근량 트렌드
    if (currentMuscle != null && muscleWeeklyTrend != null) {
      if (muscleWeeklyTrend < -0.05) {
        buffer.writeln(
          '📉 골격근량: 주간 ${muscleWeeklyTrend.abs().toStringAsFixed(2)}kg 감소 추세',
        );
      } else if (muscleWeeklyTrend > 0.05) {
        buffer.writeln('💪 골격근량: 주간 ${muscleWeeklyTrend.toStringAsFixed(2)}kg 증가 추세');
      } else {
        buffer.writeln('➡️ 골격근량: 안정적으로 유지');
      }
    }

    // 체지방률 트렌드
    if (currentBodyFat != null && bodyFatWeeklyTrend != null) {
      if (bodyFatWeeklyTrend < -0.1) {
        buffer.writeln(
          '📉 체지방률: 주간 ${bodyFatWeeklyTrend.abs().toStringAsFixed(2)}% 감소 추세',
        );
      } else if (bodyFatWeeklyTrend > 0.1) {
        buffer.writeln('📈 체지방률: 주간 ${bodyFatWeeklyTrend.toStringAsFixed(2)}% 증가 추세');
      } else {
        buffer.writeln('➡️ 체지방률: 안정적으로 유지');
      }
    }

    buffer.writeln();

    if (dataPoints < 5) {
      buffer.writeln('💡 더 정확한 예측을 위해 체성분을 꾸준히 기록해주세요.');
      buffer.writeln('   (현재 $dataPoints개 기록, 권장 10개 이상)');
    }

    return buffer.toString();
  }

  /// 상태 초기화
  void reset() {
    state = const BodyCompositionPredictionState();
  }
}

/// Provider
final bodyCompositionPredictionProvider =
    NotifierProvider<
      BodyCompositionPredictionNotifier,
      BodyCompositionPredictionState
    >(BodyCompositionPredictionNotifier.new);
