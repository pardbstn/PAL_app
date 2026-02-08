import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inbody_record_model.dart';
import '../repositories/inbody_repository.dart';

/// InBody 데이터 임포트 서비스 Provider
final inbodyImportServiceProvider = Provider<InbodyImportService>((ref) {
  return InbodyImportService(
    repository: ref.watch(inbodyRepositoryProvider),
  );
});

/// InBody CSV 임포트 결과
class InbodyImportResult {
  final int totalRows;
  final int successCount;
  final int failCount;
  final List<String> errors;

  const InbodyImportResult({
    required this.totalRows,
    required this.successCount,
    required this.failCount,
    required this.errors,
  });

  bool get isSuccess => failCount == 0;
  bool get hasPartialSuccess => successCount > 0 && failCount > 0;
}

/// InBody 파싱된 데이터
class ParsedInbodyData {
  final DateTime? measuredAt;
  final double? weight;
  final double? skeletalMuscleMass;
  final double? bodyFatPercent;
  final double? bodyFatMass;
  final double? bmi;
  final double? basalMetabolicRate;
  final double? totalBodyWater;
  final double? protein;
  final double? minerals;
  final int? visceralFatLevel;
  final int? inbodyScore;
  final String? error;

  const ParsedInbodyData({
    this.measuredAt,
    this.weight,
    this.skeletalMuscleMass,
    this.bodyFatPercent,
    this.bodyFatMass,
    this.bmi,
    this.basalMetabolicRate,
    this.totalBodyWater,
    this.protein,
    this.minerals,
    this.visceralFatLevel,
    this.inbodyScore,
    this.error,
  });

  bool get isValid =>
      measuredAt != null &&
      weight != null &&
      skeletalMuscleMass != null &&
      bodyFatPercent != null &&
      error == null;
}

/// InBody 데이터 임포트 서비스
/// CSV 파일에서 InBody 측정 데이터를 파싱하고 저장
class InbodyImportService {
  final InbodyRepository repository;

  InbodyImportService({required this.repository});

  /// CSV 파일 선택 및 파싱
  Future<List<ParsedInbodyData>?> pickAndParseCSV() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'CSV'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    String csvContent;

    if (file.bytes != null) {
      // 웹 환경
      csvContent = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      // 모바일/데스크톱 환경
      csvContent = await File(file.path!).readAsString();
    } else {
      return null;
    }

    return parseCSV(csvContent);
  }

  /// CSV 문자열 파싱
  List<ParsedInbodyData> parseCSV(String csvContent) {
    final List<List<dynamic>> rows =
        const CsvToListConverter().convert(csvContent);

    if (rows.isEmpty) {
      return [];
    }

    // 헤더 행 찾기 (첫 번째 행 또는 특정 키워드 포함 행)
    int headerIndex = _findHeaderRow(rows);
    if (headerIndex == -1) {
      // 헤더가 없으면 기본 순서로 파싱 시도
      return _parseWithoutHeader(rows);
    }

    final headers = rows[headerIndex].map((e) => e.toString().trim()).toList();
    final columnMap = _mapColumns(headers);

    final List<ParsedInbodyData> results = [];
    for (int i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
        continue; // 빈 행 건너뛰기
      }
      results.add(_parseRow(row, columnMap, i + 1));
    }

    return results;
  }

  /// 헤더 행 찾기
  int _findHeaderRow(List<List<dynamic>> rows) {
    final headerKeywords = [
      '체중',
      'weight',
      '골격근',
      'muscle',
      '체지방',
      'fat',
      '측정일',
      'date',
      'kg',
    ];

    for (int i = 0; i < rows.length && i < 5; i++) {
      final row = rows[i].map((e) => e.toString().toLowerCase()).join(' ');
      final matchCount =
          headerKeywords.where((keyword) => row.contains(keyword)).length;
      if (matchCount >= 2) {
        return i;
      }
    }
    return -1;
  }

  /// 컬럼 매핑
  Map<String, int> _mapColumns(List<String> headers) {
    final Map<String, int> columnMap = {};

    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase();

      // 측정일
      if (_matchesAny(header, ['측정일', '날짜', 'date', 'measured', '검사일'])) {
        columnMap['measuredAt'] = i;
      }
      // 체중
      else if (_matchesAny(header, ['체중', 'weight', '몸무게']) &&
          !header.contains('지방')) {
        columnMap['weight'] = i;
      }
      // 골격근량
      else if (_matchesAny(header, ['골격근', 'skeletal', 'smm', '근육량'])) {
        columnMap['skeletalMuscleMass'] = i;
      }
      // 체지방률
      else if (_matchesAny(header, ['체지방률', '체지방율', 'fat%', 'pbf', 'percent']) &&
          header.contains('%') || header.contains('율') || header.contains('률')) {
        columnMap['bodyFatPercent'] = i;
      }
      // 체지방량
      else if (_matchesAny(header, ['체지방량', 'body fat mass', 'bfm', '지방량']) &&
          !header.contains('%') && !header.contains('율')) {
        columnMap['bodyFatMass'] = i;
      }
      // BMI
      else if (_matchesAny(header, ['bmi', '체질량', '체질량지수'])) {
        columnMap['bmi'] = i;
      }
      // 기초대사량
      else if (_matchesAny(header, ['기초대사', 'bmr', 'basal', 'kcal'])) {
        columnMap['basalMetabolicRate'] = i;
      }
      // 체수분량
      else if (_matchesAny(header, ['체수분', 'water', 'tbw', '수분'])) {
        columnMap['totalBodyWater'] = i;
      }
      // 단백질
      else if (_matchesAny(header, ['단백질', 'protein'])) {
        columnMap['protein'] = i;
      }
      // 무기질
      else if (_matchesAny(header, ['무기질', 'mineral'])) {
        columnMap['minerals'] = i;
      }
      // 내장지방
      else if (_matchesAny(header, ['내장지방', 'visceral', 'vfl'])) {
        columnMap['visceralFatLevel'] = i;
      }
      // 인바디 점수
      else if (_matchesAny(header, ['점수', 'score', '인바디점수'])) {
        columnMap['inbodyScore'] = i;
      }
    }

    return columnMap;
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// 단일 행 파싱
  ParsedInbodyData _parseRow(
      List<dynamic> row, Map<String, int> columnMap, int rowNumber) {
    try {
      DateTime? measuredAt;
      if (columnMap.containsKey('measuredAt')) {
        measuredAt = _parseDate(row[columnMap['measuredAt']!]);
      }
      measuredAt ??= DateTime.now();

      final weight = _parseDouble(columnMap['weight'], row);
      final skeletalMuscleMass =
          _parseDouble(columnMap['skeletalMuscleMass'], row);
      final bodyFatPercent = _parseDouble(columnMap['bodyFatPercent'], row);

      // 필수 필드 검증
      if (weight == null || skeletalMuscleMass == null || bodyFatPercent == null) {
        return ParsedInbodyData(
          error: '행 $rowNumber: 필수 데이터(체중, 골격근량, 체지방률) 누락',
        );
      }

      return ParsedInbodyData(
        measuredAt: measuredAt,
        weight: weight,
        skeletalMuscleMass: skeletalMuscleMass,
        bodyFatPercent: bodyFatPercent,
        bodyFatMass: _parseDouble(columnMap['bodyFatMass'], row),
        bmi: _parseDouble(columnMap['bmi'], row),
        basalMetabolicRate: _parseDouble(columnMap['basalMetabolicRate'], row),
        totalBodyWater: _parseDouble(columnMap['totalBodyWater'], row),
        protein: _parseDouble(columnMap['protein'], row),
        minerals: _parseDouble(columnMap['minerals'], row),
        visceralFatLevel: _parseInt(columnMap['visceralFatLevel'], row),
        inbodyScore: _parseInt(columnMap['inbodyScore'], row),
      );
    } catch (e) {
      return ParsedInbodyData(error: '행 $rowNumber: 데이터를 읽지 못했어요 - $e');
    }
  }

  /// 헤더 없이 기본 순서로 파싱
  List<ParsedInbodyData> _parseWithoutHeader(List<List<dynamic>> rows) {
    // 기본 순서: 날짜, 체중, 골격근량, 체지방률, 체지방량, BMI...
    final defaultMap = {
      'measuredAt': 0,
      'weight': 1,
      'skeletalMuscleMass': 2,
      'bodyFatPercent': 3,
      'bodyFatMass': 4,
      'bmi': 5,
    };

    return rows
        .asMap()
        .entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => _parseRow(e.value, defaultMap, e.key + 1))
        .toList();
  }

  double? _parseDouble(int? index, List<dynamic> row) {
    if (index == null || index >= row.length) return null;
    final value = row[index];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(str);
  }

  int? _parseInt(int? index, List<dynamic> row) {
    if (index == null || index >= row.length) return null;
    final value = row[index];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final str = value.toString().replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(str);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final str = value.toString().trim();
    if (str.isEmpty) return null;

    // 다양한 날짜 형식 파싱 시도
    final patterns = [
      RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'), // 2024-01-15
      RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})'), // 01-15-2024
      RegExp(r'(\d{4})(\d{2})(\d{2})'), // 20240115
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(str);
      if (match != null) {
        try {
          int year, month, day;
          if (pattern == patterns[1]) {
            // MM-DD-YYYY
            month = int.parse(match.group(1)!);
            day = int.parse(match.group(2)!);
            year = int.parse(match.group(3)!);
          } else {
            // YYYY-MM-DD or YYYYMMDD
            year = int.parse(match.group(1)!);
            month = int.parse(match.group(2)!);
            day = int.parse(match.group(3)!);
          }
          return DateTime(year, month, day);
        } catch (_) {
          continue;
        }
      }
    }

    return DateTime.tryParse(str);
  }

  /// 파싱된 데이터를 Firestore에 저장
  Future<InbodyImportResult> importToFirestore(
    String memberId,
    List<ParsedInbodyData> parsedData,
  ) async {
    int successCount = 0;
    int failCount = 0;
    final List<String> errors = [];

    for (final data in parsedData) {
      if (!data.isValid) {
        failCount++;
        if (data.error != null) {
          errors.add(data.error!);
        }
        continue;
      }

      try {
        final record = InbodyRecordModel(
          id: '',
          memberId: memberId,
          measuredAt: data.measuredAt!,
          weight: data.weight!,
          skeletalMuscleMass: data.skeletalMuscleMass!,
          bodyFatPercent: data.bodyFatPercent!,
          bodyFatMass: data.bodyFatMass,
          bmi: data.bmi,
          basalMetabolicRate: data.basalMetabolicRate,
          totalBodyWater: data.totalBodyWater,
          protein: data.protein,
          minerals: data.minerals,
          visceralFatLevel: data.visceralFatLevel,
          inbodyScore: data.inbodyScore,
          source: InbodySource.inbodyApp,
          createdAt: DateTime.now(),
        );

        await repository.create(record);
        successCount++;
      } catch (e) {
        failCount++;
        errors.add('저장에 실패했어요: $e');
      }
    }

    return InbodyImportResult(
      totalRows: parsedData.length,
      successCount: successCount,
      failCount: failCount,
      errors: errors,
    );
  }

  /// CSV 파일 선택 및 한 번에 가져오기
  Future<InbodyImportResult?> pickAndImport(String memberId) async {
    final parsedData = await pickAndParseCSV();
    if (parsedData == null || parsedData.isEmpty) {
      return null;
    }
    return importToFirestore(memberId, parsedData);
  }
}
