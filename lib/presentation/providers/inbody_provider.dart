import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/constants/api_constants.dart';
import '../../data/models/inbody_record_model.dart';
import '../../data/repositories/inbody_repository.dart';
import '../../data/services/inbody_service.dart';
import '../../data/services/ai_service.dart';

/// 회원의 최신 인바디 기록 Provider (실시간)
final latestInbodyProvider =
    StreamProvider.family<InbodyRecordModel?, String>((ref, memberId) {
  final repository = ref.watch(inbodyRepositoryProvider);
  return repository.watchLatest(memberId);
});

/// 회원의 인바디 기록 히스토리 Provider (실시간)
final inbodyHistoryProvider =
    StreamProvider.family<List<InbodyRecordModel>, String>((ref, memberId) {
  final repository = ref.watch(inbodyRepositoryProvider);
  return repository.watchByMemberId(memberId);
});

/// 회원의 인바디 기록 히스토리 (제한된 개수)
final inbodyHistoryLimitedProvider = StreamProvider.family<
    List<InbodyRecordModel>, ({String memberId, int limit})>((ref, params) {
  final repository = ref.watch(inbodyRepositoryProvider);
  return repository.watchByMemberId(params.memberId, limit: params.limit);
});

/// 인바디 분석 요약 Provider
final inbodyAnalysisSummaryProvider =
    FutureProvider.family<InbodyAnalysisSummary?, String>((ref, memberId) async {
  final service = ref.watch(inbodyServiceProvider);
  return await service.getAnalysisSummary(memberId);
});

/// 날짜 범위 인바디 기록 Provider
final inbodyByRangeProvider = FutureProvider.family<List<InbodyRecordModel>,
    ({String memberId, DateTime startDate, DateTime endDate})>(
  (ref, params) async {
    final repository = ref.watch(inbodyRepositoryProvider);
    return await repository.getByRange(
      params.memberId,
      params.startDate,
      params.endDate,
    );
  },
);

/// 인바디 기록 CRUD 관리 Notifier
class InbodyNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 수동 입력으로 인바디 기록 저장
  Future<String?> saveManualEntry({
    required String memberId,
    required double weight,
    required double skeletalMuscleMass,
    required double bodyFatPercent,
    double? bodyFatMass,
    double? bmi,
    double? basalMetabolicRate,
    double? totalBodyWater,
    double? protein,
    double? minerals,
    int? visceralFatLevel,
    int? inbodyScore,
    String? memo,
    DateTime? measuredAt,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(inbodyServiceProvider);
      final id = await service.saveManualEntry(
        memberId,
        weight: weight,
        skeletalMuscleMass: skeletalMuscleMass,
        bodyFatPercent: bodyFatPercent,
        bodyFatMass: bodyFatMass,
        bmi: bmi,
        basalMetabolicRate: basalMetabolicRate,
        totalBodyWater: totalBodyWater,
        protein: protein,
        minerals: minerals,
        visceralFatLevel: visceralFatLevel,
        inbodyScore: inbodyScore,
        memo: memo,
        measuredAt: measuredAt,
      );
      state = const AsyncData(null);

      // 관련 provider들 갱신
      ref.invalidate(latestInbodyProvider(memberId));
      ref.invalidate(inbodyHistoryProvider(memberId));
      ref.invalidate(inbodyAnalysisSummaryProvider(memberId));

      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 인바디 기록 삭제
  Future<bool> deleteRecord(String memberId, String recordId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(inbodyRepositoryProvider);
      await repository.delete(recordId);
      state = const AsyncData(null);

      // 관련 provider들 갱신
      ref.invalidate(latestInbodyProvider(memberId));
      ref.invalidate(inbodyHistoryProvider(memberId));
      ref.invalidate(inbodyAnalysisSummaryProvider(memberId));

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 인바디 기록 업데이트
  Future<bool> updateRecord(
    String memberId,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(inbodyRepositoryProvider);
      await repository.update(recordId, data);
      state = const AsyncData(null);

      // 관련 provider들 갱신
      ref.invalidate(latestInbodyProvider(memberId));
      ref.invalidate(inbodyHistoryProvider(memberId));
      ref.invalidate(inbodyAnalysisSummaryProvider(memberId));

      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  /// 룩인바디에서 전화번호로 인바디 기록 조회 및 저장
  ///
  /// Cloud Function을 호출하여 룩인바디 API에서 데이터를 가져옵니다.
  /// Cloud Function이 직접 Firestore에 저장하므로 여기서는 결과만 반환합니다.
  ///
  /// 반환값: 성공 시 저장된 기록 수, 실패 시 에러 메시지
  Future<({int count, String? error})> fetchFromLookinBody(
    String memberId,
    String phoneNumber,
  ) async {
    state = const AsyncLoading();
    try {
      // Cloud Function 호출
      final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
      final callable = functions.httpsCallable(CloudFunctions.fetchInbodyByPhone);

      final result = await callable.call<Map<String, dynamic>>({
        'phone': phoneNumber, // Cloud Function은 'phone' 파라미터를 기대
        'memberId': memberId,
        'saveToFirestore': true,
      });

      final data = result.data;
      final success = data['success'] as bool? ?? false;
      final savedCount = data['savedCount'] as int? ?? 0;
      final message = data['message'] as String?;

      state = const AsyncData(null);

      // 관련 provider들 갱신
      ref.invalidate(latestInbodyProvider(memberId));
      ref.invalidate(inbodyHistoryProvider(memberId));
      ref.invalidate(inbodyAnalysisSummaryProvider(memberId));

      if (!success) {
        return (count: 0, error: message ?? '인바디 데이터를 가져오는 중 문제가 생겼어요');
      }

      return (count: savedCount, error: null);
    } on FirebaseFunctionsException catch (e) {
      state = AsyncError(e, StackTrace.current);

      // Cloud Function 에러 메시지 처리
      String errorMessage;
      switch (e.code) {
        case 'not-found':
          errorMessage = '해당 전화번호로 등록된 인바디 기록이 없어요';
          break;
        case 'permission-denied':
          errorMessage = '룩인바디 서비스 접근 권한이 없어요';
          break;
        case 'unavailable':
          errorMessage = '룩인바디 서비스에 연결할 수 없어요. 잠시 후 다시 시도해주세요';
          break;
        case 'invalid-argument':
          errorMessage = '올바른 전화번호 형식을 입력해주세요.';
          break;
        case 'failed-precondition':
          errorMessage = '룩인바디 API 설정이 완료되지 않았어요. 관리자에게 문의해주세요';
          break;
        default:
          errorMessage = e.message ?? '인바디 데이터를 가져오는 중 문제가 생겼어요';
      }

      return (count: 0, error: errorMessage);
    } catch (e, st) {
      state = AsyncError(e, st);
      return (count: 0, error: '인바디 데이터를 가져오는 중 문제가 생겼어요: $e');
    }
  }
}

/// InbodyNotifier Provider
final inbodyNotifierProvider =
    AsyncNotifierProvider<InbodyNotifier, void>(InbodyNotifier.new);

/// 체성분 변화 데이터 클래스 (차트용)
class InbodyChartData {
  final DateTime date;
  final double weight;
  final double skeletalMuscleMass;
  final double bodyFatPercent;
  final double? bodyFatMass;

  InbodyChartData({
    required this.date,
    required this.weight,
    required this.skeletalMuscleMass,
    required this.bodyFatPercent,
    this.bodyFatMass,
  });

  factory InbodyChartData.fromRecord(InbodyRecordModel record) {
    return InbodyChartData(
      date: record.measuredAt,
      weight: record.weight,
      skeletalMuscleMass: record.skeletalMuscleMass,
      bodyFatPercent: record.bodyFatPercent,
      bodyFatMass: record.bodyFatMass,
    );
  }
}

/// 차트용 인바디 데이터 Provider
final inbodyChartDataProvider =
    Provider.family<List<InbodyChartData>, List<InbodyRecordModel>>(
        (ref, records) {
  return records.reversed // 오래된 것부터 정렬 (차트용)
      .map((r) => InbodyChartData.fromRecord(r))
      .toList();
});

// ============================================
// 인바디 AI 분석 관련 Provider
// ============================================

/// 인바디 AI 분석 상태
class InbodyAnalysisState {
  final bool isAnalyzing;
  final InbodyAnalysisResult? result;
  final String? error;

  const InbodyAnalysisState({
    this.isAnalyzing = false,
    this.result,
    this.error,
  });

  InbodyAnalysisState copyWith({
    bool? isAnalyzing,
    InbodyAnalysisResult? result,
    String? error,
  }) {
    return InbodyAnalysisState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      result: result ?? this.result,
      error: error,
    );
  }

  static const initial = InbodyAnalysisState();
}

/// 인바디 AI 분석 Notifier
class InbodyAnalysisNotifier extends Notifier<InbodyAnalysisState> {
  @override
  InbodyAnalysisState build() => InbodyAnalysisState.initial;

  /// 인바디 결과지 이미지 AI 분석
  ///
  /// [memberId] 회원 ID
  /// [imageUrl] Supabase Storage에 업로드된 이미지 URL
  Future<InbodyAnalysisResult> analyzeInbodyImage({
    required String memberId,
    required String imageUrl,
  }) async {
    state = state.copyWith(isAnalyzing: true, error: null);

    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.analyzeInbody(
        memberId: memberId,
        imageUrl: imageUrl,
      );

      if (result.success) {
        state = state.copyWith(isAnalyzing: false, result: result);

        // 관련 provider들 갱신
        ref.invalidate(latestInbodyProvider(memberId));
        ref.invalidate(inbodyHistoryProvider(memberId));
        ref.invalidate(inbodyAnalysisSummaryProvider(memberId));
      } else {
        state = state.copyWith(
          isAnalyzing: false,
          error: result.error ?? '분석에 실패했어요',
        );
      }

      return result;
    } catch (e) {
      final errorMessage = e.toString();
      state = state.copyWith(isAnalyzing: false, error: errorMessage);
      return InbodyAnalysisResult(success: false, error: errorMessage);
    }
  }

  /// 상태 초기화
  void reset() {
    state = InbodyAnalysisState.initial;
  }
}

/// 인바디 AI 분석 Provider
final inbodyAnalysisProvider =
    NotifierProvider<InbodyAnalysisNotifier, InbodyAnalysisState>(
  InbodyAnalysisNotifier.new,
);
