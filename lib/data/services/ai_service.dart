import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';

/// AI 서비스 Provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// AI 사용량 정보
class AIUsageInfo {
  final int curriculumCount;
  final int curriculumLimit;
  final String subscriptionTier;
  final String model;
  final String provider;
  final String currentMonth;

  AIUsageInfo({
    required this.curriculumCount,
    required this.curriculumLimit,
    required this.subscriptionTier,
    required this.model,
    required this.provider,
    required this.currentMonth,
  });

  factory AIUsageInfo.fromMap(Map<dynamic, dynamic> map) {
    return AIUsageInfo(
      curriculumCount: (map['curriculumCount'] as num?)?.toInt() ?? 0,
      curriculumLimit: (map['curriculumLimit'] as num?)?.toInt() ?? 3,
      subscriptionTier: map['subscriptionTier']?.toString() ?? 'free',
      model: map['model']?.toString() ?? 'gemini-2.0-flash-lite',
      provider: map['provider']?.toString() ?? 'google',
      currentMonth: map['currentMonth']?.toString() ?? '',
    );
  }

  /// 남은 사용 횟수
  int get remaining => curriculumLimit == -1 ? 999999 : curriculumLimit - curriculumCount;

  /// 사용 가능 여부
  bool get canUse => curriculumLimit == -1 || remaining > 0;

  /// 무제한 여부
  bool get isUnlimited => curriculumLimit == -1;
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
