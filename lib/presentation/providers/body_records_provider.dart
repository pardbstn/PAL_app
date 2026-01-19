import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/body_record_model.dart';
import 'package:flutter_pal_app/data/repositories/body_record_repository.dart';

/// 회원의 체성분 기록 목록 (실시간 스트림)
final bodyRecordsProvider =
    StreamProvider.family<List<BodyRecordModel>, String>((ref, memberId) {
  final repository = ref.watch(bodyRecordRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchByMemberId(memberId, limit: 30);
});

/// 회원의 최신 체성분 기록 1개
final latestBodyRecordProvider =
    Provider.family<AsyncValue<BodyRecordModel?>, String>((ref, memberId) {
  final recordsAsync = ref.watch(bodyRecordsProvider(memberId));

  return recordsAsync.whenData((records) {
    if (records.isEmpty) return null;
    return records.first; // 이미 최신순 정렬됨
  });
});

/// 차트용 체중 히스토리 데이터
final weightHistoryProvider =
    Provider.family<AsyncValue<List<WeightHistoryData>>, String>(
        (ref, memberId) {
  final recordsAsync = ref.watch(bodyRecordsProvider(memberId));

  return recordsAsync.whenData((records) {
    // 오래된 순으로 정렬 (차트용)
    final sorted = records.reversed.toList();

    return sorted.map((record) {
      return WeightHistoryData(
        date: record.recordDate,
        weight: record.weight,
        bodyFatPercent: record.bodyFatPercent,
        muscleMass: record.muscleMass,
      );
    }).toList();
  });
});

/// 체중 히스토리 데이터 클래스
class WeightHistoryData {
  final DateTime date;
  final double weight;
  final double? bodyFatPercent;
  final double? muscleMass;

  const WeightHistoryData({
    required this.date,
    required this.weight,
    this.bodyFatPercent,
    this.muscleMass,
  });
}

/// 체중 변화량 (첫 기록 대비)
final weightChangeProvider =
    Provider.family<AsyncValue<WeightChange?>, String>((ref, memberId) {
  final historyAsync = ref.watch(weightHistoryProvider(memberId));

  return historyAsync.whenData((history) {
    if (history.length < 2) return null;

    final firstWeight = history.first.weight;
    final lastWeight = history.last.weight;
    final change = lastWeight - firstWeight;

    return WeightChange(
      startWeight: firstWeight,
      currentWeight: lastWeight,
      change: change,
      changePercent: (change / firstWeight) * 100,
    );
  });
});

/// 체중 변화 데이터 클래스
class WeightChange {
  final double startWeight;
  final double currentWeight;
  final double change;
  final double changePercent;

  const WeightChange({
    required this.startWeight,
    required this.currentWeight,
    required this.change,
    required this.changePercent,
  });

  bool get isLoss => change < 0;
  bool get isGain => change > 0;
}
