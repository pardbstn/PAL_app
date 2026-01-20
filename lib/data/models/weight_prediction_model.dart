import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'weight_prediction_model.freezed.dart';
part 'weight_prediction_model.g.dart';

/// 예측된 체중 데이터 포인트
@freezed
sealed class PredictedWeightPoint with _$PredictedWeightPoint {
  const factory PredictedWeightPoint({
    /// 예측 날짜
    @TimestampConverter() required DateTime date,

    /// 예측 체중 (kg)
    required double weight,

    /// 신뢰구간 상한 (kg)
    required double upperBound,

    /// 신뢰구간 하한 (kg)
    required double lowerBound,
  }) = _PredictedWeightPoint;

  factory PredictedWeightPoint.fromJson(Map<String, dynamic> json) =>
      _$PredictedWeightPointFromJson(json);
}

/// PredictedWeightPoint 확장 메서드
extension PredictedWeightPointX on PredictedWeightPoint {
  /// 신뢰구간 범위 (kg)
  double get confidenceRange => upperBound - lowerBound;

  /// 신뢰구간 퍼센트 (예측값 대비)
  double get confidenceRangePercent => (confidenceRange / weight) * 100;
}

/// 데이터 요약 모델
@freezed
sealed class DataSummary with _$DataSummary {
  const factory DataSummary({
    /// 최근 1주 변화량 (kg)
    @Default(0) double recentWeekChange,

    /// 최근 1개월 변화량 (kg)
    @Default(0) double recentMonthChange,

    /// 전체 기간 변화량 (kg)
    @Default(0) double totalChange,

    /// 최저 체중 (kg)
    @Default(0) double minWeight,

    /// 최고 체중 (kg)
    @Default(0) double maxWeight,

    /// 평균 체중 (kg)
    @Default(0) double avgWeight,

    /// 체중 변동폭 (kg)
    @Default(0) double weightRange,

    /// 기록 기간 (일)
    @Default(0) int recordDays,

    /// 일관성 점수 (0~100)
    @Default(0) int consistencyScore,
  }) = _DataSummary;

  factory DataSummary.fromJson(Map<String, dynamic> json) =>
      _$DataSummaryFromJson(json);
}

/// 목표 달성 시나리오 모델
@freezed
sealed class GoalScenario with _$GoalScenario {
  const factory GoalScenario({
    /// 시나리오 이름
    required String name,

    /// 주당 필요 변화량 (kg)
    required double weeklyChange,

    /// 예상 소요 주 수
    required int weeksNeeded,

    /// 난이도 (easy/moderate/hard/achieved)
    required String difficulty,

    /// 설명
    required String description,
  }) = _GoalScenario;

  factory GoalScenario.fromJson(Map<String, dynamic> json) =>
      _$GoalScenarioFromJson(json);
}

/// AI 코칭 메시지 모델
@freezed
sealed class CoachingMessage with _$CoachingMessage {
  const factory CoachingMessage({
    /// 메시지 유형 (success/warning/info/tip)
    required String type,

    /// 제목
    required String title,

    /// 내용
    required String content,
  }) = _CoachingMessage;

  factory CoachingMessage.fromJson(Map<String, dynamic> json) =>
      _$CoachingMessageFromJson(json);
}

/// Gemini AI 심층 분석 모델 (Pro 전용)
@freezed
sealed class GeminiAnalysis with _$GeminiAnalysis {
  const factory GeminiAnalysis({
    /// AI 생성 심층 분석 메시지
    @Default('') String aiInsight,

    /// AI 추천 액션 아이템
    @Default([]) List<String> actionItems,

    /// AI 생성 동기부여 메시지
    @Default('') String motivationalMessage,
  }) = _GeminiAnalysis;

  factory GeminiAnalysis.fromJson(Map<String, dynamic> json) =>
      _$GeminiAnalysisFromJson(json);
}

/// AI 체중 예측 모델
/// 회원의 체중 변화를 예측한 결과를 저장
@freezed
sealed class WeightPredictionModel with _$WeightPredictionModel {
  const factory WeightPredictionModel({
    /// 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 트레이너 ID
    required String trainerId,

    /// 현재 체중 (kg)
    required double currentWeight,

    /// 목표 체중 (kg, nullable)
    double? targetWeight,

    /// 예측 데이터 포인트들
    @Default([]) List<PredictedWeightPoint> predictedWeights,

    /// 주간 변화량 (kg/week, 음수면 감량 중)
    required double weeklyTrend,

    /// 목표 도달 예상 주 수 (nullable)
    int? estimatedWeeksToTarget,

    /// 예측 신뢰도 (0.0 ~ 1.0)
    required double confidence,

    /// 예측에 사용된 데이터 포인트 수
    required int dataPointsUsed,

    /// AI 분석 메시지
    String? analysisMessage,

    /// 데이터 요약
    DataSummary? dataSummary,

    /// 목표 달성 시나리오들
    @Default([]) List<GoalScenario> goalScenarios,

    /// AI 코칭 메시지들
    @Default([]) List<CoachingMessage> coachingMessages,

    /// Gemini AI 심층 분석 (Pro 전용)
    GeminiAnalysis? geminiAnalysis,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,
  }) = _WeightPredictionModel;

  factory WeightPredictionModel.fromJson(Map<String, dynamic> json) =>
      _$WeightPredictionModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory WeightPredictionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeightPredictionModel.fromJson({...data, 'id': doc.id});
  }
}

/// WeightPredictionModel 확장 메서드
extension WeightPredictionModelX on WeightPredictionModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }

  /// 목표 체중 설정 여부
  bool get hasTargetWeight => targetWeight != null;

  /// 감량 중인지 여부
  bool get isLosingWeight => weeklyTrend < 0;

  /// 증량 중인지 여부
  bool get isGainingWeight => weeklyTrend > 0;

  /// 유지 중인지 여부 (주간 변화 ±0.1kg 이내)
  bool get isMaintaining => weeklyTrend.abs() < 0.1;

  /// 목표 도달 가능 여부 (예상 주 수가 있고, 합리적인 범위 내)
  bool get isTargetAchievable =>
      estimatedWeeksToTarget != null && estimatedWeeksToTarget! > 0;

  /// 목표까지 남은 체중 (kg)
  double? get weightToTarget {
    if (targetWeight == null) return null;
    return (targetWeight! - currentWeight).abs();
  }

  /// 예측 신뢰도 등급 (high/medium/low)
  String get confidenceLevel {
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.5) return 'medium';
    return 'low';
  }

  /// 데이터 충분 여부 (최소 4개 이상의 데이터 포인트)
  bool get hasEnoughData => dataPointsUsed >= 4;

  /// 예측 기간 (일)
  int get predictionDays {
    if (predictedWeights.isEmpty) return 0;
    final firstDate = predictedWeights.first.date;
    final lastDate = predictedWeights.last.date;
    return lastDate.difference(firstDate).inDays;
  }

  /// 예측 기간 (주)
  int get predictionWeeks => (predictionDays / 7).ceil();

  /// 특정 날짜의 예측 체중 가져오기
  PredictedWeightPoint? getPredictionForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    try {
      return predictedWeights.firstWhere((p) {
        final predDate = DateTime(p.date.year, p.date.month, p.date.day);
        return predDate == targetDate;
      });
    } catch (_) {
      return null;
    }
  }

  /// 마지막 예측 포인트
  PredictedWeightPoint? get lastPrediction =>
      predictedWeights.isNotEmpty ? predictedWeights.last : null;

  /// 예측 종료 날짜
  DateTime? get predictionEndDate => lastPrediction?.date;

  /// 예측 종료 시점의 체중
  double? get finalPredictedWeight => lastPrediction?.weight;

  /// Gemini AI 분석 가용 여부 (Pro 전용)
  bool get hasGeminiAnalysis =>
      geminiAnalysis != null && geminiAnalysis!.aiInsight.isNotEmpty;

  /// Gemini AI 인사이트 (없으면 기본 분석 메시지)
  String get aiInsightOrDefault =>
      hasGeminiAnalysis ? geminiAnalysis!.aiInsight : (analysisMessage ?? '');
}
