import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/inbody_record_model.dart';
import '../../data/repositories/inbody_repository.dart';
import '../../data/services/inbody_service.dart';

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
