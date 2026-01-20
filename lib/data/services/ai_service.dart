import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/models/weight_prediction_model.dart';

/// AI 서비스 Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// AI 사용량 정보
class AIUsageInfo {
  final int curriculumCount;
  final int curriculumLimit;
  final int predictionCount;
  final int predictionLimit;
  final String subscriptionTier;
  final String model;
  final String provider;
  final String currentMonth;

  AIUsageInfo({
    required this.curriculumCount,
    required this.curriculumLimit,
    required this.predictionCount,
    required this.predictionLimit,
    required this.subscriptionTier,
    required this.model,
    required this.provider,
    required this.currentMonth,
  });

  factory AIUsageInfo.fromMap(Map<dynamic, dynamic> map) {
    return AIUsageInfo(
      curriculumCount: (map['curriculumCount'] as num?)?.toInt() ?? 0,
      curriculumLimit: (map['curriculumLimit'] as num?)?.toInt() ?? 3,
      predictionCount: (map['predictionCount'] as num?)?.toInt() ?? 0,
      predictionLimit: (map['predictionLimit'] as num?)?.toInt() ?? 3,
      subscriptionTier: map['subscriptionTier']?.toString() ?? 'free',
      model: map['model']?.toString() ?? 'gemini-2.0-flash-lite',
      provider: map['provider']?.toString() ?? 'google',
      currentMonth: map['currentMonth']?.toString() ?? '',
    );
  }

  /// 커리큘럼 남은 사용 횟수
  int get curriculumRemaining =>
      curriculumLimit == -1 ? 999999 : curriculumLimit - curriculumCount;

  /// 예측 남은 사용 횟수
  int get predictionRemaining =>
      predictionLimit == -1 ? 999999 : predictionLimit - predictionCount;

  /// 커리큘럼 사용 가능 여부
  bool get canUseCurriculum => curriculumLimit == -1 || curriculumRemaining > 0;

  /// 예측 사용 가능 여부
  bool get canUsePrediction => predictionLimit == -1 || predictionRemaining > 0;

  /// 커리큘럼 무제한 여부
  bool get isCurriculumUnlimited => curriculumLimit == -1;

  /// 예측 무제한 여부
  bool get isPredictionUnlimited => predictionLimit == -1;

  /// [deprecated] 기존 호환성
  int get remaining => curriculumRemaining;
  bool get canUse => canUseCurriculum;
  bool get isUnlimited => isCurriculumUnlimited;
}

/// AI 생성 커리큘럼 (아직 저장되지 않은 상태)
class GeneratedCurriculum {
  final int sessionNumber;
  final String title;
  final String? description;
  final List<GeneratedExercise> exercises;

  GeneratedCurriculum({
    required this.sessionNumber,
    required this.title,
    this.description,
    required this.exercises,
  });

  factory GeneratedCurriculum.fromMap(Map<dynamic, dynamic> map) {
    final exercisesList = map['exercises'] as List<dynamic>? ?? [];

    // sessionNumber는 숫자 또는 문자열로 올 수 있음
    int parseSessionNumber = 1;
    final sessionValue = map['sessionNumber'];
    if (sessionValue is num) {
      parseSessionNumber = sessionValue.toInt();
    } else if (sessionValue is String) {
      parseSessionNumber = int.tryParse(sessionValue) ?? 1;
    }

    return GeneratedCurriculum(
      sessionNumber: parseSessionNumber,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      exercises: exercisesList
          .map((e) => GeneratedExercise.fromMap(e as Map<dynamic, dynamic>))
          .toList(),
    );
  }

  /// CurriculumModel로 변환 (저장 시 사용)
  CurriculumModel toCurriculumModel({
    required String memberId,
    required String trainerId,
  }) {
    final now = DateTime.now();
    return CurriculumModel(
      id: '',
      memberId: memberId,
      trainerId: trainerId,
      sessionNumber: sessionNumber,
      title: title,
      exercises: exercises.map((e) => e.toExercise()).toList(),
      isAiGenerated: true,
      createdAt: now,
      updatedAt: now,
    );
  }
}

/// AI 생성 운동 항목
class GeneratedExercise {
  final String name;
  final int sets;
  final int reps;
  final String? weight;
  final String? rest;
  final String? notes;

  GeneratedExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.rest,
    this.notes,
  });

  factory GeneratedExercise.fromMap(Map<dynamic, dynamic> map) {
    // sets와 reps는 숫자 또는 문자열로 올 수 있음
    int parseSets = 3;
    int parseReps = 10;

    final setsValue = map['sets'];
    if (setsValue is num) {
      parseSets = setsValue.toInt();
    } else if (setsValue is String) {
      parseSets = int.tryParse(setsValue) ?? 3;
    }

    final repsValue = map['reps'];
    if (repsValue is num) {
      parseReps = repsValue.toInt();
    } else if (repsValue is String) {
      parseReps = int.tryParse(repsValue) ?? 10;
    }

    return GeneratedExercise(
      name: map['name']?.toString() ?? '',
      sets: parseSets,
      reps: parseReps,
      weight: map['weight']?.toString(),
      rest: map['rest']?.toString(),
      notes: map['notes']?.toString(),
    );
  }

  /// Exercise 모델로 변환
  Exercise toExercise() {
    // weight 문자열에서 숫자 추출 시도
    double? weightValue;
    if (weight != null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(weight!);
      if (match != null) {
        weightValue = double.tryParse(match.group(1) ?? '');
      }
    }

    // rest 문자열에서 초 추출
    int? restSeconds;
    if (rest != null) {
      final match = RegExp(r'(\d+)').firstMatch(rest!);
      if (match != null) {
        restSeconds = int.tryParse(match.group(1) ?? '');
      }
    }

    return Exercise(
      name: name,
      sets: sets,
      reps: reps,
      weight: weightValue,
      restSeconds: restSeconds,
      note: notes,
    );
  }
}

/// AI 서비스
class AIService {
  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast3', // 서울 리전
  );

  /// 동적 맵을 안전하게 변환
  Map<String, dynamic> _convertToStringDynamic(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }

  /// AI 커리큘럼 생성
  Future<List<GeneratedCurriculum>> generateCurriculum({
    required String memberId,
    required String goal,
    required String experience,
    required int sessionCount,
    String? restrictions,
  }) async {
    try {
      final callable = _functions.httpsCallable('generateCurriculum');
      final result = await callable.call({
        'memberId': memberId,
        'goal': goal,
        'experience': experience,
        'sessionCount': sessionCount,
        'restrictions': restrictions,
      });

      final data = _convertToStringDynamic(result.data);

      if (data['success'] != true) {
        throw Exception('커리큘럼 생성에 실패했습니다.');
      }

      final curriculumsList = data['curriculums'] as List<dynamic>? ?? [];
      final curriculums = curriculumsList
          .map((c) => GeneratedCurriculum.fromMap(c as Map<dynamic, dynamic>))
          .toList();

      return curriculums;
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// AI 사용량 조회
  Future<AIUsageInfo> getAIUsage() async {
    try {
      final callable = _functions.httpsCallable('getAIUsage');
      final result = await callable.call();
      return AIUsageInfo.fromMap(result.data as Map<dynamic, dynamic>);
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    }
  }

  /// AI 체중 예측
  ///
  /// [memberId] 예측 대상 회원 ID
  /// [weeksAhead] 예측할 주 수 (기본값: 8, 최대: 12)
  Future<WeightPredictionResult> predictWeight({
    required String memberId,
    int weeksAhead = 8,
  }) async {
    try {
      final callable = _functions.httpsCallable('predictWeight');
      final result = await callable.call({
        'memberId': memberId,
        'weeksAhead': weeksAhead,
      });

      final data = _convertToStringDynamic(result.data);

      if (data['success'] != true) {
        final error = data['error'] as Map<dynamic, dynamic>?;
        throw Exception(error?['message']?.toString() ?? '체중 예측에 실패했습니다.');
      }

      final predictionData = data['prediction'] as Map<dynamic, dynamic>;
      return WeightPredictionResult.fromMap(predictionData);
    } on FirebaseFunctionsException catch (e) {
      throw _handleFunctionsException(e);
    } catch (e) {
      rethrow;
    }
  }

  /// AI 인사이트 생성
  ///
  /// 트레이너의 회원 데이터를 분석하여 관리 인사이트 생성
  /// [memberId] 특정 회원만 분석 (optional)
  /// [forceRefresh] 캐시 무시하고 새로 생성 (기본값: false)
  /// [includeAI] AI 기반 추천 포함 여부 (기본값: true)
  ///
  /// 타임아웃: 60초
  Future<InsightsResult> generateInsights({
    String? memberId,
    bool forceRefresh = false,
    bool includeAI = true,
  }) async {
    try {
      final callable = _functions.httpsCallable(
        'generateInsights',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
      );

      final result = await callable.call({
        if (memberId != null) 'memberId': memberId,
        'forceRefresh': forceRefresh,
        'includeAI': includeAI,
      });

      final data = _convertToStringDynamic(result.data);
      return InsightsResult.fromMap(data);
    } on FirebaseFunctionsException catch (e) {
      return InsightsResult.error(
        errorCode: e.code,
        errorMessage: e.message ?? '인사이트 생성에 실패했습니다.',
      );
    } catch (e) {
      return InsightsResult.error(
        errorCode: 'unknown',
        errorMessage: e.toString(),
      );
    }
  }

  /// Firebase Functions 예외 처리
  Exception _handleFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return Exception('로그인이 필요합니다.');
      case 'permission-denied':
        return Exception('권한이 없습니다.');
      case 'invalid-argument':
        return Exception(e.message ?? '잘못된 입력입니다.');
      case 'resource-exhausted':
        return Exception(e.message ?? '사용량 한도를 초과했습니다.');
      case 'not-found':
        return Exception(e.message ?? '데이터를 찾을 수 없습니다.');
      default:
        return Exception(e.message ?? '오류가 발생했습니다.');
    }
  }
}

/// AI 인사이트 생성 결과 (새 버전)
///
/// Cloud Function 응답을 파싱하여 상태 정보와 함께 반환
class InsightsResult {
  /// 요청 성공 여부
  final bool success;

  /// 생성된 인사이트 목록
  final List<GeneratedInsightSummary> insights;

  /// 캐시된 결과인지 여부
  final bool cached;

  /// 생성 시각
  final DateTime? generatedAt;

  /// 에러 코드 (실패 시)
  final String? errorCode;

  /// 에러 메시지 (실패 시)
  final String? errorMessage;

  /// 통계 정보
  final InsightStats? stats;

  InsightsResult({
    required this.success,
    required this.insights,
    this.cached = false,
    this.generatedAt,
    this.errorCode,
    this.errorMessage,
    this.stats,
  });

  /// 성공 응답 생성
  factory InsightsResult.fromMap(Map<dynamic, dynamic> map) {
    final insightsList = map['insights'] as List<dynamic>? ?? [];
    final statsMap = map['stats'] as Map<dynamic, dynamic>?;

    return InsightsResult(
      success: map['success'] as bool? ?? true,
      insights: insightsList
          .map((i) => GeneratedInsightSummary.fromMap(i as Map<dynamic, dynamic>))
          .toList(),
      cached: map['cached'] as bool? ?? false,
      generatedAt: map['generatedAt'] != null
          ? DateTime.tryParse(map['generatedAt'].toString())
          : DateTime.now(),
      stats: statsMap != null ? InsightStats.fromMap(statsMap) : null,
    );
  }

  /// 에러 응답 생성
  factory InsightsResult.error({
    required String errorCode,
    required String errorMessage,
  }) {
    return InsightsResult(
      success: false,
      insights: [],
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  /// 결과가 에러인지 확인
  bool get hasError => !success || errorCode != null;

  /// 인사이트 개수
  int get count => insights.length;
}

/// 인사이트 생성 통계
class InsightStats {
  final int totalMembers;
  final int totalGenerated;
  final int newSaved;
  final int skippedDuplicates;

  InsightStats({
    required this.totalMembers,
    required this.totalGenerated,
    required this.newSaved,
    required this.skippedDuplicates,
  });

  factory InsightStats.fromMap(Map<dynamic, dynamic> map) {
    return InsightStats(
      totalMembers: (map['totalMembers'] as num?)?.toInt() ?? 0,
      totalGenerated: (map['totalGenerated'] as num?)?.toInt() ?? 0,
      newSaved: (map['newSaved'] as num?)?.toInt() ?? 0,
      skippedDuplicates: (map['skippedDuplicates'] as num?)?.toInt() ?? 0,
    );
  }
}

/// AI 체중 예측 결과
class WeightPredictionResult {
  final String id;
  final String memberId;
  final String trainerId;
  final double currentWeight;
  final double? targetWeight;
  final List<PredictedWeightPoint> predictedWeights;
  final double weeklyTrend;
  final int? estimatedWeeksToTarget;
  final double confidence;
  final int dataPointsUsed;
  final String analysisMessage;

  WeightPredictionResult({
    required this.id,
    required this.memberId,
    required this.trainerId,
    required this.currentWeight,
    this.targetWeight,
    required this.predictedWeights,
    required this.weeklyTrend,
    this.estimatedWeeksToTarget,
    required this.confidence,
    required this.dataPointsUsed,
    required this.analysisMessage,
  });

  factory WeightPredictionResult.fromMap(Map<dynamic, dynamic> map) {
    final predictedList = map['predictedWeights'] as List<dynamic>? ?? [];

    return WeightPredictionResult(
      id: map['id']?.toString() ?? '',
      memberId: map['memberId']?.toString() ?? '',
      trainerId: map['trainerId']?.toString() ?? '',
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 0,
      targetWeight: (map['targetWeight'] as num?)?.toDouble(),
      predictedWeights: predictedList
          .map((p) => PredictedWeightPoint(
                date: DateTime.parse(p['date'] as String),
                weight: (p['weight'] as num).toDouble(),
                upperBound: (p['upperBound'] as num).toDouble(),
                lowerBound: (p['lowerBound'] as num).toDouble(),
              ))
          .toList(),
      weeklyTrend: (map['weeklyTrend'] as num?)?.toDouble() ?? 0,
      estimatedWeeksToTarget: (map['estimatedWeeksToTarget'] as num?)?.toInt(),
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0,
      dataPointsUsed: (map['dataPointsUsed'] as num?)?.toInt() ?? 0,
      analysisMessage: map['analysisMessage']?.toString() ?? '',
    );
  }

  /// 감량 중인지 여부
  bool get isLosingWeight => weeklyTrend < 0;

  /// 증량 중인지 여부
  bool get isGainingWeight => weeklyTrend > 0;

  /// 유지 중인지 여부 (주간 변화 ±0.1kg 이내)
  bool get isMaintaining => weeklyTrend.abs() < 0.1;

  /// 신뢰도 등급 (high/medium/low)
  String get confidenceLevel {
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.5) return 'medium';
    return 'low';
  }

  /// 신뢰도 한글 등급
  String get confidenceLevelKorean {
    if (confidence >= 0.8) return '높음';
    if (confidence >= 0.5) return '보통';
    return '낮음';
  }

  /// 마지막 예측 체중
  double? get finalPredictedWeight =>
      predictedWeights.isNotEmpty ? predictedWeights.last.weight : null;
}

/// AI 인사이트 생성 결과
class InsightGenerationResult {
  final int totalMembers;
  final int totalGenerated;
  final int newSaved;
  final int skippedDuplicates;
  final List<GeneratedInsightSummary> insights;

  InsightGenerationResult({
    required this.totalMembers,
    required this.totalGenerated,
    required this.newSaved,
    required this.skippedDuplicates,
    required this.insights,
  });

  factory InsightGenerationResult.fromMap(Map<dynamic, dynamic> map) {
    final stats = map['stats'] as Map<dynamic, dynamic>? ?? {};
    final insightsList = map['insights'] as List<dynamic>? ?? [];

    return InsightGenerationResult(
      totalMembers: (stats['totalMembers'] as num?)?.toInt() ?? 0,
      totalGenerated: (stats['totalGenerated'] as num?)?.toInt() ?? 0,
      newSaved: (stats['newSaved'] as num?)?.toInt() ?? 0,
      skippedDuplicates: (stats['skippedDuplicates'] as num?)?.toInt() ?? 0,
      insights: insightsList
          .map((i) => GeneratedInsightSummary.fromMap(i as Map<dynamic, dynamic>))
          .toList(),
    );
  }
}

/// 생성된 인사이트 요약
class GeneratedInsightSummary {
  final String type;
  final String priority;
  final String title;
  final String message;
  final String? memberName;
  final String? actionSuggestion;

  GeneratedInsightSummary({
    required this.type,
    required this.priority,
    required this.title,
    required this.message,
    this.memberName,
    this.actionSuggestion,
  });

  factory GeneratedInsightSummary.fromMap(Map<dynamic, dynamic> map) {
    return GeneratedInsightSummary(
      type: map['type']?.toString() ?? '',
      priority: map['priority']?.toString() ?? 'low',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      memberName: map['memberName']?.toString(),
      actionSuggestion: map['actionSuggestion']?.toString(),
    );
  }
}
