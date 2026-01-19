import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'session_signature_model.freezed.dart';
part 'session_signature_model.g.dart';

/// 수업 완료 서명 모델
/// PT 수업 완료 시 회원의 전자서명 기록
@freezed
sealed class SessionSignatureModel with _$SessionSignatureModel {
  const factory SessionSignatureModel({
    /// 서명 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 트레이너 ID
    required String trainerId,

    /// 커리큘럼 ID (연결된 회차)
    required String curriculumId,

    /// 회차 번호
    required int sessionNumber,

    /// 서명 이미지 URL (Supabase Storage)
    required String signatureImageUrl,

    /// 서명 일시
    @TimestampConverter() required DateTime signedAt,

    /// 수업 메모 (선택)
    String? memo,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,

    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _SessionSignatureModel;

  factory SessionSignatureModel.fromJson(Map<String, dynamic> json) =>
      _$SessionSignatureModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory SessionSignatureModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionSignatureModel.fromJson({...data, 'id': doc.id});
  }
}

/// SessionSignatureModel 확장 메서드
extension SessionSignatureModelX on SessionSignatureModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    return json;
  }

  /// 서명 날짜 포맷 (yyyy.MM.dd)
  String get signedDateFormatted {
    return '${signedAt.year}.${signedAt.month.toString().padLeft(2, '0')}.${signedAt.day.toString().padLeft(2, '0')}';
  }

  /// 서명 시간 포맷 (HH:mm)
  String get signedTimeFormatted {
    return '${signedAt.hour.toString().padLeft(2, '0')}:${signedAt.minute.toString().padLeft(2, '0')}';
  }
}
