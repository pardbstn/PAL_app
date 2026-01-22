import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_model.dart';

part 'body_composition_prediction_model.freezed.dart';
part 'body_composition_prediction_model.g.dart';

/// 개별 지표 예측 결과
@freezed
sealed class MetricPrediction with _$MetricPrediction {
  const factory MetricPrediction({
    /// 현재 값
    required double current,

    /// 4주 후 예측 값
    required double predicted,

    /// 주간 변화 추세
    required double weeklyTrend,

    /// 예측 신뢰도 (0.0 ~ 1.0)
    required double confidence,

    /// 목표 값 (nullable)
    double? targetValue,

    /// 목표 도달 예상 주 수 (nullable)
    int? estimatedWeeksToTarget,
  }) = _MetricPrediction;

  factory MetricPrediction.fromJson(Map<String, dynamic> json) =>
      _$MetricPredictionFromJson(json);
}

/// 체성분 종합 예측 모델
@freezed
sealed class BodyCompositionPredictionModel with _$BodyCompositionPredictionModel {
  const BodyCompositionPredictionModel._();

  const factory BodyCompositionPredictionModel({
    /// 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 트레이너 ID
    required String trainerId,

    /// 체중 예측 (nullable)
    MetricPrediction? weightPrediction,

    /// 골격근량 예측 (nullable)
    MetricPrediction? musclePrediction,

    /// 체지방률 예측 (nullable)
    MetricPrediction? bodyFatPrediction,

    /// AI 분석 메시지
    required String analysisMessage,

    /// 각 지표별 사용된 데이터 포인트 수
    required Map<String, int> dataPointsUsed,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,
  }) = _BodyCompositionPredictionModel;

  factory BodyCompositionPredictionModel.fromJson(Map<String, dynamic> json) =>
      _$BodyCompositionPredictionModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory BodyCompositionPredictionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BodyCompositionPredictionModel.fromJson({...data, 'id': doc.id});
  }
}

/// BodyCompositionPredictionModel 확장 메서드
extension BodyCompositionPredictionModelX on BodyCompositionPredictionModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }

  /// 체중 예측 존재 여부
  bool get hasWeightPrediction => weightPrediction != null;

  /// 골격근량 예측 존재 여부
  bool get hasMusclePrediction => musclePrediction != null;

  /// 체지방률 예측 존재 여부
  bool get hasBodyFatPrediction => bodyFatPrediction != null;

  /// 체중 감량 중 여부
  bool get isLosingWeight =>
      weightPrediction != null && weightPrediction!.weeklyTrend < -0.1;

  /// 근육 증가 중 여부
  bool get isGainingMuscle =>
      musclePrediction != null && musclePrediction!.weeklyTrend > 0.05;

  /// 체지방 감소 중 여부
  bool get isLosingFat =>
      bodyFatPrediction != null && bodyFatPrediction!.weeklyTrend < -0.1;

  /// 전체 신뢰도 (평균)
  double get overallConfidence {
    final predictions = [weightPrediction, musclePrediction, bodyFatPrediction]
        .whereType<MetricPrediction>()
        .toList();
    if (predictions.isEmpty) return 0;
    return predictions.map((p) => p.confidence).reduce((a, b) => a + b) /
        predictions.length;
  }

  /// 신뢰도 레벨 텍스트
  String get confidenceLevel {
    final conf = overallConfidence;
    if (conf >= 0.7) return 'high';
    if (conf >= 0.4) return 'medium';
    return 'low';
  }

  /// 데이터 충분 여부 (최소 4개 이상의 데이터 포인트가 있는 지표가 있는지)
  bool get hasEnoughData {
    return dataPointsUsed.values.any((n) => n >= 4);
  }

  /// 사용 가능한 예측 지표 수
  int get availablePredictionCount {
    int n = 0;
    if (hasWeightPrediction) n++;
    if (hasMusclePrediction) n++;
    if (hasBodyFatPrediction) n++;
    return n;
  }
}

/// MetricPrediction 확장 메서드
extension MetricPredictionX on MetricPrediction {
  /// 변화량 (predicted - current)
  double get change => predicted - current;

  /// 변화 방향 아이콘
  String get changeIcon {
    if (weeklyTrend > 0.05) return '▲';
    if (weeklyTrend < -0.05) return '▼';
    return '→';
  }

  /// 포맷된 변화량
  String get formattedChange {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}';
  }

  /// 목표 설정 여부
  bool get hasTarget => targetValue != null;

  /// 목표까지 남은 양
  double? get remainingToTarget {
    if (targetValue == null) return null;
    return (targetValue! - current).abs();
  }

  /// 목표 도달 가능 여부 (예상 주 수가 있고, 합리적인 범위 내)
  bool get isTargetAchievable =>
      estimatedWeeksToTarget != null && estimatedWeeksToTarget! > 0;

  /// 신뢰도 레벨 텍스트
  String get confidenceLevel {
    if (confidence >= 0.7) return 'high';
    if (confidence >= 0.4) return 'medium';
    return 'low';
  }
}
