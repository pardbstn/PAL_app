import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'inbody_record_model.freezed.dart';
part 'inbody_record_model.g.dart';

/// 인바디 데이터 소스
enum InbodySource {
  @JsonValue('manual')
  manual,
  @JsonValue('inbody_api')
  inbodyApi,
  @JsonValue('inbody_app')
  inbodyApp,
}

/// 인바디 기록 모델
/// 기존 body_records와 별도로 상세한 인바디 측정 데이터를 저장
@freezed
sealed class InbodyRecordModel with _$InbodyRecordModel {
  const factory InbodyRecordModel({
    /// 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 측정 일시
    @TimestampConverter() required DateTime measuredAt,

    /// 체중 (kg)
    required double weight,

    /// 골격근량 (kg)
    required double skeletalMuscleMass,

    /// 체지방량 (kg)
    double? bodyFatMass,

    /// 체지방률 (%)
    required double bodyFatPercent,

    /// BMI (kg/m²)
    double? bmi,

    /// 기초대사량 (kcal)
    double? basalMetabolicRate,

    /// 체수분량 (L)
    double? totalBodyWater,

    /// 단백질량 (kg)
    double? protein,

    /// 무기질량 (kg)
    double? minerals,

    /// 내장지방 레벨
    int? visceralFatLevel,

    /// 인바디 점수
    int? inbodyScore,

    /// 데이터 소스
    @Default(InbodySource.manual) InbodySource source,

    /// 메모
    String? memo,

    /// 생성 일시
    @TimestampConverter() required DateTime createdAt,
  }) = _InbodyRecordModel;

  factory InbodyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$InbodyRecordModelFromJson(json);

  /// Firestore DocumentSnapshot에서 생성
  factory InbodyRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InbodyRecordModel.fromJson({...data, 'id': doc.id});
  }
}

/// InbodyRecordModel 확장 메서드
extension InbodyRecordModelX on InbodyRecordModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// 골격근량 대비 체지방량 비율 (SMM/BFM)
  double? get muscleToFatRatio {
    if (bodyFatMass == null || bodyFatMass == 0) return null;
    return skeletalMuscleMass / bodyFatMass!;
  }

  /// 체성분 균형 상태 (정상, 주의, 비만 등)
  String get bodyCompositionStatus {
    if (bodyFatPercent < 10) return '매우 낮음';
    if (bodyFatPercent < 18) return '낮음';
    if (bodyFatPercent < 25) return '정상';
    if (bodyFatPercent < 30) return '주의';
    return '비만';
  }

  /// 여성 기준 체성분 균형 상태
  String get bodyCompositionStatusFemale {
    if (bodyFatPercent < 18) return '매우 낮음';
    if (bodyFatPercent < 23) return '낮음';
    if (bodyFatPercent < 30) return '정상';
    if (bodyFatPercent < 35) return '주의';
    return '비만';
  }
}
