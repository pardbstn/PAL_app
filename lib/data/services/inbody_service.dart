import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inbody_record_model.dart';
import '../repositories/inbody_repository.dart';

/// InbodyService Provider
final inbodyServiceProvider = Provider<InbodyService>((ref) {
  return InbodyService(repository: ref.watch(inbodyRepositoryProvider));
});

/// 인바디 서비스
/// 인바디 데이터 파싱 및 저장 로직 담당
class InbodyService {
  final InbodyRepository repository;

  InbodyService({required this.repository});

  /// 인바디 앱/API에서 받은 raw 데이터 파싱
  /// rawData는 인바디 기기에서 전송되는 JSON 형식 데이터
  InbodyRecordModel? parseInbodyData(
    String memberId,
    Map<String, dynamic> rawData,
  ) {
    try {
      // 인바디 API 응답 형식에 맞게 파싱
      // 실제 인바디 API 연동 시 필드명 조정 필요
      final measuredAt = rawData['measuredAt'] != null
          ? DateTime.parse(rawData['measuredAt'].toString())
          : DateTime.now();

      return InbodyRecordModel(
        id: '',
        memberId: memberId,
        measuredAt: measuredAt,
        weight: _parseDouble(rawData['weight']) ?? 0,
        skeletalMuscleMass: _parseDouble(rawData['skeletalMuscleMass']) ??
            _parseDouble(rawData['SMM']) ??
            0,
        bodyFatMass: _parseDouble(rawData['bodyFatMass']) ??
            _parseDouble(rawData['BFM']),
        bodyFatPercent: _parseDouble(rawData['bodyFatPercent']) ??
            _parseDouble(rawData['PBF']) ??
            0,
        bmi: _parseDouble(rawData['bmi']) ?? _parseDouble(rawData['BMI']),
        basalMetabolicRate: _parseDouble(rawData['basalMetabolicRate']) ??
            _parseDouble(rawData['BMR']),
        totalBodyWater: _parseDouble(rawData['totalBodyWater']) ??
            _parseDouble(rawData['TBW']),
        protein:
            _parseDouble(rawData['protein']) ?? _parseDouble(rawData['Protein']),
        minerals: _parseDouble(rawData['minerals']) ??
            _parseDouble(rawData['Minerals']),
        visceralFatLevel: _parseInt(rawData['visceralFatLevel']) ??
            _parseInt(rawData['VFL']),
        inbodyScore: _parseInt(rawData['inbodyScore']) ??
            _parseInt(rawData['InBodyScore']),
        source: InbodySource.inbodyApi,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // 파싱 실패 시 null 반환
      return null;
    }
  }

  /// 수동 입력 데이터 저장
  Future<String> saveManualEntry(
    String memberId, {
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
    final record = InbodyRecordModel(
      id: '',
      memberId: memberId,
      measuredAt: measuredAt ?? DateTime.now(),
      weight: weight,
      skeletalMuscleMass: skeletalMuscleMass,
      bodyFatMass: bodyFatMass,
      bodyFatPercent: bodyFatPercent,
      bmi: bmi,
      basalMetabolicRate: basalMetabolicRate,
      totalBodyWater: totalBodyWater,
      protein: protein,
      minerals: minerals,
      visceralFatLevel: visceralFatLevel,
      inbodyScore: inbodyScore,
      source: InbodySource.manual,
      memo: memo,
      createdAt: DateTime.now(),
    );

    return await repository.save(record);
  }

  /// 파싱된 인바디 데이터 저장
  Future<String?> saveFromRawData(
    String memberId,
    Map<String, dynamic> rawData,
  ) async {
    final record = parseInbodyData(memberId, rawData);
    if (record == null) return null;
    return await repository.save(record);
  }

  /// 체성분 분석 요약 생성
  Future<InbodyAnalysisSummary?> getAnalysisSummary(String memberId) async {
    final latest = await repository.getLatest(memberId);
    if (latest == null) return null;

    final weightChange = await repository.getWeightChange(memberId);
    final muscleChange = await repository.getMuscleMassChange(memberId);
    final fatPercentChange = await repository.getBodyFatPercentChange(memberId);

    return InbodyAnalysisSummary(
      latestRecord: latest,
      weightChange: weightChange,
      muscleChange: muscleChange,
      fatPercentChange: fatPercentChange,
    );
  }

  /// double 파싱 헬퍼
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// int 파싱 헬퍼
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// 인바디 분석 요약 클래스
class InbodyAnalysisSummary {
  final InbodyRecordModel latestRecord;
  final double? weightChange;
  final double? muscleChange;
  final double? fatPercentChange;

  InbodyAnalysisSummary({
    required this.latestRecord,
    this.weightChange,
    this.muscleChange,
    this.fatPercentChange,
  });

  /// 전체적인 진행 상태 (개선/유지/악화)
  String get progressStatus {
    int positiveChanges = 0;
    int negativeChanges = 0;

    // 골격근량 증가는 긍정적
    if (muscleChange != null && muscleChange! > 0.1) positiveChanges++;
    if (muscleChange != null && muscleChange! < -0.1) negativeChanges++;

    // 체지방률 감소는 긍정적
    if (fatPercentChange != null && fatPercentChange! < -0.5) positiveChanges++;
    if (fatPercentChange != null && fatPercentChange! > 0.5) negativeChanges++;

    if (positiveChanges > negativeChanges) return '개선';
    if (negativeChanges > positiveChanges) return '주의';
    return '유지';
  }

  /// 변화 요약 텍스트
  String get changeSummary {
    final parts = <String>[];

    if (weightChange != null) {
      final sign = weightChange! >= 0 ? '+' : '';
      parts.add('체중 $sign${weightChange!.toStringAsFixed(1)}kg');
    }

    if (muscleChange != null) {
      final sign = muscleChange! >= 0 ? '+' : '';
      parts.add('근육량 $sign${muscleChange!.toStringAsFixed(1)}kg');
    }

    if (fatPercentChange != null) {
      final sign = fatPercentChange! >= 0 ? '+' : '';
      parts.add('체지방률 $sign${fatPercentChange!.toStringAsFixed(1)}%');
    }

    return parts.isEmpty ? '변화 데이터 없음' : parts.join(', ');
  }
}
