/// 식단 분석 Provider
///
/// 식단 AI 분석 기능을 위한 Riverpod Provider 및 Service
/// 회원의 영양 섭취 추적 및 분석 결과 제공
library;

import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/diet_analysis_model.dart';
import '../../data/repositories/diet_analysis_repository.dart';

// ============================================================
// Repository-based Providers
// ============================================================

/// 오늘의 식단 기록 스트림 Provider (회원별)
final todayDietRecordsProvider =
    StreamProvider.family<List<DietAnalysisModel>, String>((ref, memberId) {
  final repository = ref.watch(dietAnalysisRepositoryProvider);
  return repository.watchTodayDietRecords(memberId);
});

/// 일일 영양 요약 스트림 Provider (회원별)
final dailyNutritionSummaryProvider =
    StreamProvider.family<DailyNutritionSummary, String>((ref, memberId) {
  final repository = ref.watch(dietAnalysisRepositoryProvider);
  return repository.watchTodaySummary(memberId);
});

/// 특정 날짜의 식단 기록 Future Provider
final dietRecordsByDateProvider =
    FutureProvider.family<List<DietAnalysisModel>, ({String memberId, DateTime date})>(
        (ref, params) {
  final repository = ref.watch(dietAnalysisRepositoryProvider);
  return repository.getDietRecordsByDate(params.memberId, params.date);
});

/// 특정 날짜의 영양 요약 Future Provider
final dailyNutritionSummaryByDateProvider =
    FutureProvider.family<DailyNutritionSummary, ({String memberId, DateTime date})>(
        (ref, params) {
  final repository = ref.watch(dietAnalysisRepositoryProvider);
  return repository.getDailySummary(params.memberId, params.date);
});

/// 최근 식단 기록 Future Provider
final recentDietRecordsProvider =
    FutureProvider.family<List<DietAnalysisModel>, String>((ref, memberId) {
  final repository = ref.watch(dietAnalysisRepositoryProvider);
  return repository.getRecentRecords(memberId, limit: 20);
});

// ============================================================
// Diet Analysis Service
// ============================================================

/// 식단 분석 서비스 Provider
final dietAnalysisServiceProvider = Provider<DietAnalysisService>((ref) {
  return DietAnalysisService(
    repository: ref.watch(dietAnalysisRepositoryProvider),
    functions: FirebaseFunctions.instanceFor(region: 'asia-northeast3'),
    supabase: Supabase.instance.client,
  );
});

/// 식단 분석 결과
class DietAnalysisResult {
  final bool success;
  final DietAnalysisModel? record;
  final String? errorMessage;
  final DietAnalysisUsage? usage;

  const DietAnalysisResult({
    required this.success,
    this.record,
    this.errorMessage,
    this.usage,
  });

  factory DietAnalysisResult.success(DietAnalysisModel record, DietAnalysisUsage usage) {
    return DietAnalysisResult(
      success: true,
      record: record,
      usage: usage,
    );
  }

  factory DietAnalysisResult.failure(String message) {
    return DietAnalysisResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// 식단 분석 사용량
class DietAnalysisUsage {
  final int current;
  final int limit;
  final String tier;

  const DietAnalysisUsage({
    required this.current,
    required this.limit,
    required this.tier,
  });

  bool get isUnlimited => limit == -1;
  int get remaining => isUnlimited ? -1 : limit - current;
  double get usagePercent => isUnlimited ? 0 : (current / limit).clamp(0.0, 1.0);
}

/// 식단 분석 서비스
class DietAnalysisService {
  final DietAnalysisRepository _repository;
  final FirebaseFunctions _functions;
  final SupabaseClient _supabase;

  DietAnalysisService({
    required DietAnalysisRepository repository,
    required FirebaseFunctions functions,
    required SupabaseClient supabase,
  })  : _repository = repository,
        _functions = functions,
        _supabase = supabase;

  /// 이미지로 음식 분석
  ///
  /// [memberId] 회원 ID
  /// [imageFile] 분석할 이미지 파일
  /// [mealType] 식사 유형
  Future<DietAnalysisResult> analyzeFood({
    required String memberId,
    required File imageFile,
    required MealType mealType,
  }) async {
    try {
      // 1. Supabase Storage에 이미지 업로드
      final fileName =
          'diet/$memberId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('images')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('images')
          .getPublicUrl(fileName);

      // 2. Cloud Function 호출
      final callable = _functions.httpsCallable('analyzeDiet');
      final response = await callable.call<Map<String, dynamic>>({
        'memberId': memberId,
        'imageUrl': imageUrl,
        'mealType': mealType.name,
      });

      final data = response.data;

      if (data['success'] != true) {
        return DietAnalysisResult.failure(
          data['error'] ?? '분석에 실패했습니다.',
        );
      }

      // 3. 결과 파싱
      final record = DietAnalysisModel(
        id: data['id'] as String,
        memberId: memberId,
        mealType: mealType,
        imageUrl: imageUrl,
        foodName: data['foodName'] as String,
        calories: (data['calories'] as num).toInt(),
        protein: (data['protein'] as num).toDouble(),
        carbs: (data['carbs'] as num).toDouble(),
        fat: (data['fat'] as num).toDouble(),
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        analyzedAt: DateTime.parse(data['analyzedAt'] as String),
        createdAt: DateTime.parse(data['createdAt'] as String),
      );

      final usageData = data['usage'] as Map<String, dynamic>;
      final usage = DietAnalysisUsage(
        current: usageData['current'] as int,
        limit: usageData['limit'] as int,
        tier: usageData['tier'] as String,
      );

      return DietAnalysisResult.success(record, usage);
    } on FirebaseFunctionsException catch (e) {
      return DietAnalysisResult.failure(e.message ?? '분석 중 오류가 발생했습니다.');
    } catch (e) {
      return DietAnalysisResult.failure('분석 중 오류가 발생했습니다: $e');
    }
  }

  /// 갤러리 또는 카메라에서 이미지 선택 후 분석
  ///
  /// [memberId] 회원 ID
  /// [mealType] 식사 유형
  /// [source] 이미지 소스 (카메라 또는 갤러리)
  Future<DietAnalysisResult> pickAndAnalyze({
    required String memberId,
    required MealType mealType,
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        return DietAnalysisResult.failure('이미지를 선택하지 않았습니다.');
      }

      final imageFile = File(pickedFile.path);
      return analyzeFood(
        memberId: memberId,
        imageFile: imageFile,
        mealType: mealType,
      );
    } catch (e) {
      return DietAnalysisResult.failure('이미지 선택 중 오류가 발생했습니다: $e');
    }
  }

  /// 식단 기록 삭제
  ///
  /// [recordId] 삭제할 기록 ID
  Future<void> deleteDietRecord(String recordId) async {
    await _repository.deleteDietRecord(recordId);
  }
}

// ============================================================
// Analysis State Notifier
// ============================================================

/// 분석 상태
enum AnalysisStatus {
  initial,
  selectingImage,
  uploading,
  analyzing,
  success,
  failure,
}

/// 식단 분석 상태
class DietAnalysisState {
  final AnalysisStatus status;
  final DietAnalysisModel? result;
  final DietAnalysisUsage? usage;
  final String? errorMessage;
  final double uploadProgress;

  const DietAnalysisState({
    this.status = AnalysisStatus.initial,
    this.result,
    this.usage,
    this.errorMessage,
    this.uploadProgress = 0,
  });

  DietAnalysisState copyWith({
    AnalysisStatus? status,
    DietAnalysisModel? result,
    DietAnalysisUsage? usage,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return DietAnalysisState(
      status: status ?? this.status,
      result: result ?? this.result,
      usage: usage ?? this.usage,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  bool get isLoading =>
      status == AnalysisStatus.selectingImage ||
      status == AnalysisStatus.uploading ||
      status == AnalysisStatus.analyzing;
}

/// 식단 분석 상태 Notifier
class DietAnalysisNotifier extends Notifier<DietAnalysisState> {
  @override
  DietAnalysisState build() => const DietAnalysisState();

  /// 상태 초기화
  void reset() {
    state = const DietAnalysisState();
  }

  /// 이미지 선택 및 분석 시작
  Future<void> analyzeFromSource({
    required String memberId,
    required MealType mealType,
    required ImageSource source,
  }) async {
    state = state.copyWith(status: AnalysisStatus.selectingImage);

    try {
      final service = ref.read(dietAnalysisServiceProvider);

      state = state.copyWith(status: AnalysisStatus.uploading);

      final result = await service.pickAndAnalyze(
        memberId: memberId,
        mealType: mealType,
        source: source,
      );

      if (result.success) {
        state = state.copyWith(
          status: AnalysisStatus.success,
          result: result.record,
          usage: result.usage,
        );
      } else {
        state = state.copyWith(
          status: AnalysisStatus.failure,
          errorMessage: result.errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.failure,
        errorMessage: '분석 중 오류가 발생했습니다: $e',
      );
    }
  }
}

/// 식단 분석 상태 Provider
final dietAnalysisNotifierProvider =
    NotifierProvider<DietAnalysisNotifier, DietAnalysisState>(
        DietAnalysisNotifier.new);
