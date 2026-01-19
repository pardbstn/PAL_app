import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'body_record_model.freezed.dart';
part 'body_record_model.g.dart';

/// 기록 소스
enum RecordSource {
  @JsonValue('manual')
  manual,
  @JsonValue('inbody_api')
  inbodyApi,
}

/// 체성분 기록 모델
/// 체중/체성분 기록
@freezed
sealed class BodyRecordModel with _$BodyRecordModel {
  const factory BodyRecordModel({
    /// 기록 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 측정 날짜
    @TimestampConverter() required DateTime recordDate,

    /// 체중 (kg)
    required double weight,

    /// 체지방률 (%)
    double? bodyFatPercent,

    /// 골격근량 (kg)
    double? muscleMass,

    /// BMI
    double? bmi,

    /// 기초대사량 (kcal)
    double? bmr,

    /// 기록 소스 ('manual' | 'inbody_api')
    @Default(RecordSource.manual) RecordSource source,

    /// 메모
    String? note,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,
  }) = _BodyRecordModel;

  factory BodyRecordModel.fromJson(Map<String, dynamic> json) =>
      _$BodyRecordModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory BodyRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BodyRecordModel.fromJson({...data, 'id': doc.id});
  }
}

/// BodyRecordModel 확장 메서드
extension BodyRecordModelX on BodyRecordModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }

  /// 수동 입력 여부
  bool get isManualEntry => source == RecordSource.manual;

  /// 인바디 데이터 여부
  bool get isInbodyData => source == RecordSource.inbodyApi;

  /// 체지방량 계산 (kg)
  double? get fatMass {
    if (bodyFatPercent == null) return null;
    return weight * (bodyFatPercent! / 100);
  }

  /// 제지방량 계산 (kg)
  double? get leanMass {
    final fat = fatMass;
    if (fat == null) return null;
    return weight - fat;
  }
}
