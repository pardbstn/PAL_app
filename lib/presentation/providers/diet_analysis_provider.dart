/// 식단 분석 Provider
///
/// 식단 AI 분석 기능을 위한 Riverpod Provider 및 Service
/// 회원의 영양 섭취 추적 및 분석 결과 제공
library;

import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/constants/api_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/diet_analysis_model.dart';
import '../../data/models/food_item_model.dart';
import '../../data/repositories/diet_analysis_repository.dart';
import '../../data/services/food_database_service.dart';

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

  factory DietAnalysisResult.success(DietAnalysisModel record, [DietAnalysisUsage? usage]) {
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
  /// [imageBytes] 분석할 이미지 바이트 (iPad 호환성을 위해 바이트 사용)
  /// [mealType] 식사 유형
  Future<DietAnalysisResult> analyzeFood({
    required String memberId,
    required Uint8List imageBytes,
    required MealType mealType,
  }) async {
    try {
      // 1. Supabase Storage에 이미지 업로드
      // iPad 호환성을 위해 uploadBinary 사용
      final fileName =
          'diet/$memberId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('pal-storage')
          .uploadBinary(fileName, imageBytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));

      final imageUrl = _supabase.storage
          .from('pal-storage')
          .getPublicUrl(fileName);

      // 2. Cloud Function 호출
      final callable = _functions.httpsCallable(CloudFunctions.analyzeDiet);
      final response = await callable.call({
        'memberId': memberId,
        'imageUrl': imageUrl,
        'mealType': mealType.name,
      });

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['success'] != true) {
        return DietAnalysisResult.failure(
          data['error']?.toString() ?? '분석에 실패했어요',
        );
      }

      // 3. 개별 음식 파싱 + 로컬 DB 매칭 보정
      final rawFoods = ((data['foods'] as List<dynamic>?) ?? [])
          .map((f) => Map<String, dynamic>.from(f as Map))
          .toList();
      final correctedFoods = _correctWithLocalDb(rawFoods);

      // 보정된 값으로 총합 재계산
      final totalCalories = correctedFoods.isEmpty
          ? (data['calories'] as num).toInt()
          : correctedFoods.fold<double>(0, (sum, f) => sum + f.calories).toInt();
      final totalProtein = correctedFoods.isEmpty
          ? (data['protein'] as num).toDouble()
          : correctedFoods.fold<double>(0, (sum, f) => sum + f.protein);
      final totalCarbs = correctedFoods.isEmpty
          ? (data['carbs'] as num).toDouble()
          : correctedFoods.fold<double>(0, (sum, f) => sum + f.carbs);
      final totalFat = correctedFoods.isEmpty
          ? (data['fat'] as num).toDouble()
          : correctedFoods.fold<double>(0, (sum, f) => sum + f.fat);

      final record = DietAnalysisModel(
        id: data['id'] as String,
        memberId: memberId,
        mealType: mealType,
        imageUrl: imageUrl,
        foodName: data['foodName'] as String,
        calories: totalCalories,
        protein: totalProtein,
        carbs: totalCarbs,
        fat: totalFat,
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
        foods: correctedFoods,
        analyzedAt: DateTime.parse(data['analyzedAt'] as String),
        createdAt: DateTime.parse(data['createdAt'] as String),
      );

      // usage 데이터가 없을 수 있으므로 null 안전 처리
      final usageRaw = data['usage'];
      final usageData = usageRaw != null ? Map<String, dynamic>.from(usageRaw as Map) : null;
      final usage = usageData != null
          ? DietAnalysisUsage(
              current: (usageData['current'] as num?)?.toInt() ?? 0,
              limit: (usageData['limit'] as num?)?.toInt() ?? 10,
              tier: usageData['tier'] as String? ?? 'free',
            )
          : null;

      return DietAnalysisResult.success(record, usage);
    } on FirebaseFunctionsException catch (e) {
      return DietAnalysisResult.failure(e.message ?? '분석 중 문제가 생겼어요');
    } catch (e) {
      return DietAnalysisResult.failure('분석 중 문제가 생겼어요: $e');
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
        return DietAnalysisResult.failure('이미지를 선택하지 않았어요');
      }

      // iPad 호환성을 위해 XFile에서 바이트로 직접 읽기
      final imageBytes = await pickedFile.readAsBytes();
      return analyzeFood(
        memberId: memberId,
        imageBytes: imageBytes,
        mealType: mealType,
      );
    } catch (e) {
      return DietAnalysisResult.failure('이미지 선택 중 문제가 생겼어요: $e');
    }
  }

  /// 식단 기록 삭제
  ///
  /// [recordId] 삭제할 기록 ID
  Future<void> deleteDietRecord(String recordId) async {
    await _repository.deleteDietRecord(recordId);
  }

  /// AI 분석 결과를 로컬 음식 DB와 매칭하여 영양소 보정
  ///
  /// AI가 추정한 음식명으로 로컬 DB를 검색하고,
  /// 매칭되면 DB의 100g당 영양소 × 추정 중량으로 재계산
  List<AnalyzedFoodItem> _correctWithLocalDb(List<dynamic> rawFoods) {
    final db = FoodDatabaseService.instance;
    if (!db.isInitialized || rawFoods.isEmpty) {
      return rawFoods
          .map((f) => AnalyzedFoodItem(
                foodName: f['foodName'] as String? ?? '알 수 없는 음식',
                estimatedWeight: (f['estimatedWeight'] as num?)?.toDouble() ?? 0,
                calories: (f['calories'] as num?)?.toDouble() ?? 0,
                protein: (f['protein'] as num?)?.toDouble() ?? 0,
                carbs: (f['carbs'] as num?)?.toDouble() ?? 0,
                fat: (f['fat'] as num?)?.toDouble() ?? 0,
                portionNote: f['portionNote'] as String? ?? '',
              ))
          .toList();
    }

    return rawFoods.map((f) {
      final foodName = f['foodName'] as String? ?? '알 수 없는 음식';
      final weight = (f['estimatedWeight'] as num?)?.toDouble() ?? 0;
      final portionNote = f['portionNote'] as String? ?? '';

      // 로컬 DB에서 매칭 시도
      final match = _findBestMatch(db, foodName);

      if (match != null && weight > 0) {
        // DB 영양소는 100g 기준 → 추정 중량 비율로 재계산
        final ratio = weight / match.servingSize;
        return AnalyzedFoodItem(
          foodName: match.name,
          estimatedWeight: weight,
          calories: (match.calories * ratio * 10).roundToDouble() / 10,
          protein: (match.protein * ratio * 10).roundToDouble() / 10,
          carbs: (match.carbs * ratio * 10).roundToDouble() / 10,
          fat: (match.fat * ratio * 10).roundToDouble() / 10,
          portionNote: portionNote,
          dbCorrected: true,
        );
      }

      // 매칭 실패 시 AI 추정값 그대로 사용
      return AnalyzedFoodItem(
        foodName: foodName,
        estimatedWeight: weight,
        calories: (f['calories'] as num?)?.toDouble() ?? 0,
        protein: (f['protein'] as num?)?.toDouble() ?? 0,
        carbs: (f['carbs'] as num?)?.toDouble() ?? 0,
        fat: (f['fat'] as num?)?.toDouble() ?? 0,
        portionNote: portionNote,
      );
    }).toList();
  }

  /// 로컬 DB에서 가장 유사한 음식 찾기
  ///
  /// 1순위: 정확한 이름 일치
  /// 2순위: 정규화 후 일치 (공백/특수문자 제거)
  /// 3순위: 검색 결과 중 첫 번째 (부분 일치)
  FoodItem? _findBestMatch(FoodDatabaseService db, String foodName) {
    final results = db.searchFood(foodName, limit: 5);
    if (results.isEmpty) return null;

    final normalized = foodName.toLowerCase().replaceAll(' ', '').replaceAll('/', '');

    // 정확한 이름 일치 우선
    for (final item in results) {
      final itemNorm = item.name.toLowerCase().replaceAll(' ', '').replaceAll('/', '');
      if (itemNorm == normalized) return item;
    }

    // 이름이 검색어로 시작하는 항목
    for (final item in results) {
      final itemNorm = item.name.toLowerCase().replaceAll(' ', '').replaceAll('/', '');
      if (itemNorm.startsWith(normalized) || normalized.startsWith(itemNorm)) {
        return item;
      }
    }

    // 부분 일치도 없으면 null (AI 추정값 사용)
    return null;
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
        errorMessage: '분석 중 문제가 생겼어요: $e',
      );
    }
  }
}

/// 식단 분석 상태 Provider
final dietAnalysisNotifierProvider =
    NotifierProvider<DietAnalysisNotifier, DietAnalysisState>(
        DietAnalysisNotifier.new);
