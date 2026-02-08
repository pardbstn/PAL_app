import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// 사용자 역할
enum UserRoleType {
  @JsonValue('trainer')
  trainer,
  @JsonValue('member')
  member,
  @JsonValue('personal')
  personal,
}

/// Firestore Timestamp 변환기
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Nullable Timestamp 변환기
class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    }
    return null;
  }

  @override
  dynamic toJson(DateTime? date) =>
      date != null ? Timestamp.fromDate(date) : null;
}

/// 사용자 모델
/// Firebase Auth와 연동되는 기본 사용자 정보
@freezed
sealed class UserModel with _$UserModel {
  const factory UserModel({
    /// Firebase Auth UID
    required String uid,

    /// 이메일 주소
    required String email,

    /// 이름
    required String name,

    /// 역할 ('trainer' | 'member')
    required UserRoleType role,

    /// 프로필 이미지 URL
    String? profileImageUrl,

    /// 전화번호
    String? phone,

    /// 회원 코드 (4자리 숫자, 예: "1234") - 트레이너가 회원 추가 시 사용
    String? memberCode,

    /// 가입일
    @TimestampConverter() required DateTime createdAt,

    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({...data, 'uid': doc.id});
  }
}

/// UserModel 확장 메서드
extension UserModelX on UserModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('uid'); // UID는 문서 ID로 사용
    return json;
  }

  /// 트레이너 여부
  bool get isTrainer => role == UserRoleType.trainer;

  /// 회원 여부
  bool get isMember => role == UserRoleType.member;

  /// 개인모드 여부
  bool get isPersonal => role == UserRoleType.personal;

  /// 회원 태그 (이름#코드 형식, 예: "홍길동#1234")
  String get displayTag => memberCode != null ? '$name#$memberCode' : name;
}
