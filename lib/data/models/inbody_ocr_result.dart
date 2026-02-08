import 'package:freezed_annotation/freezed_annotation.dart';

part 'inbody_ocr_result.freezed.dart';
part 'inbody_ocr_result.g.dart';

/// 인바디 OCR 결과 모델
@freezed
abstract class InbodyOcrResult with _$InbodyOcrResult {
  const factory InbodyOcrResult({
    /// 체중 (kg)
    double? weight,
    /// 골격근량 (kg)
    @JsonKey(name: 'skeletalMuscleMass') double? skeletalMuscle,
    /// 체지방량 (kg)
    @JsonKey(name: 'bodyFatMass') double? bodyFat,
    /// 체지방률 (%)
    double? bodyFatPercent,
    /// BMI
    double? bmi,
    /// 기초대사량 (kcal)
    double? basalMetabolicRate,
    /// 측정 날짜 (문자열)
    String? measureDate,
    /// OCR 신뢰도 (0.0~1.0)
    @Default(0.0) double confidence,
    /// 원본 텍스트
    @Default('') String rawText,
    /// 오류 메시지
    String? errorMessage,
  }) = _InbodyOcrResult;

  factory InbodyOcrResult.fromJson(Map<String, dynamic> json) =>
      _$InbodyOcrResultFromJson(json);
}
