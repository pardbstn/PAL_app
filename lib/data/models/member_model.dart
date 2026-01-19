import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

/// 운동 목표
enum FitnessGoal {
  @JsonValue('diet')
  diet,
  @JsonValue('bulk')
  bulk,
  @JsonValue('fitness')
  fitness,
  @JsonValue('rehab')
  rehab,
}

/// 운동 경험 수준
enum ExperienceLevel {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// PT 정보
@freezed
sealed class PtInfo with _$PtInfo {
  const factory PtInfo({
    /// 총 PT 회차 (예: 30)
    required int totalSessions,

    /// 완료 회차 (예: 12)
    @Default(0) int completedSessions,

    /// PT 시작일
    @TimestampConverter() required DateTime startDate,
  }) = _PtInfo;

  factory PtInfo.fromJson(Map<String, dynamic> json) => _$PtInfoFromJson(json);
}

/// 회원 모델
/// 회원 전용 프로필 및 PT 정보
@freezed
sealed class MemberModel with _$MemberModel {
  const factory MemberModel({
    /// 회원 문서 ID
    required String id,

    /// users 컬렉션 참조
    required String userId,

    /// 담당 트레이너 ID
    required String trainerId,

    /// 운동 목표 ('diet'|'bulk'|'fitness'|'rehab')
    required FitnessGoal goal,

    /// 운동 경험 수준 ('beginner'|'intermediate'|'advanced')
    required ExperienceLevel experience,

    /// PT 정보
    required PtInfo ptInfo,

    /// 목표 체중 (kg)
    double? targetWeight,

    /// 트레이너 메모 (부상, 제한사항)
    String? memo,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory MemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // ptInfo 필드 안전하게 처리
    Map<String, dynamic> sanitizedPtInfo;
    final rawPtInfo = data['ptInfo'];

    if (rawPtInfo is Map<String, dynamic>) {
      final totalSessions = rawPtInfo['totalSessions'];
      final completedSessions = rawPtInfo['completedSessions'];

      sanitizedPtInfo = {
        'totalSessions': totalSessions is num ? totalSessions : 0,
        'completedSessions': completedSessions is num ? completedSessions : 0,
        'startDate': rawPtInfo['startDate'] ?? Timestamp.fromDate(DateTime.now()),
      };
    } else {
      sanitizedPtInfo = {
        'totalSessions': 0,
        'completedSessions': 0,
        'startDate': Timestamp.fromDate(DateTime.now()),
      };
    }

    // targetWeight 안전하게 처리
    final rawTargetWeight = data['targetWeight'];
    final targetWeight = rawTargetWeight is num ? rawTargetWeight : null;

    return MemberModel.fromJson({
      ...data,
      'id': doc.id,
      'ptInfo': sanitizedPtInfo,
      'targetWeight': targetWeight,
    });
  }
}

/// MemberModel 확장 메서드
extension MemberModelX on MemberModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainerId': trainerId,
      'goal': goal.name,
      'experience': experience.name,
      'ptInfo': {
        'totalSessions': ptInfo.totalSessions,
        'completedSessions': ptInfo.completedSessions,
        'startDate': Timestamp.fromDate(ptInfo.startDate),
      },
      if (targetWeight != null) 'targetWeight': targetWeight,
      if (memo != null) 'memo': memo,
    };
  }

  /// PT 진행률 (0.0 ~ 1.0)
  double get progressRate {
    if (ptInfo.totalSessions == 0) return 0.0;
    return ptInfo.completedSessions / ptInfo.totalSessions;
  }

  /// 남은 PT 회차
  int get remainingSessions =>
      ptInfo.totalSessions - ptInfo.completedSessions;

  /// 목표 라벨
  String get goalLabel => switch (goal) {
        FitnessGoal.diet => '다이어트',
        FitnessGoal.bulk => '벌크업',
        FitnessGoal.fitness => '체력 향상',
        FitnessGoal.rehab => '재활',
      };

  /// 경험 수준 라벨
  String get experienceLabel => switch (experience) {
        ExperienceLevel.beginner => '초급',
        ExperienceLevel.intermediate => '중급',
        ExperienceLevel.advanced => '고급',
      };
}
