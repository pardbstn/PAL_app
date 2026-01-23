import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'trainer_preset_model.freezed.dart';
part 'trainer_preset_model.g.dart';

/// 트레이너 프리셋 모델
/// 트레이너별 AI 커리큘럼 생성 기본 설정
@freezed
sealed class TrainerPresetModel with _$TrainerPresetModel {
  const factory TrainerPresetModel({
    /// 문서 ID (= trainerId)
    required String id,

    /// 트레이너 ID
    required String trainerId,

    /// 체육관 이름
    String? gymName,

    /// 자주 제외하는 운동 ID
    @Default([]) List<String> excludedExerciseIds,

    /// 기본 종목 수 (1-10)
    @Default(5) int defaultExerciseCount,

    /// 기본 세트 수 (1-10)
    @Default(3) int defaultSetCount,

    /// 선호 운동 스타일
    @Default([]) List<String> preferredStyles,

    /// 제외 부위 (부상)
    @Default([]) List<String> excludedBodyParts,

    /// 생성 일시
    @TimestampConverter() required DateTime createdAt,

    /// 수정 일시
    @TimestampConverter() required DateTime updatedAt,
  }) = _TrainerPresetModel;

  factory TrainerPresetModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerPresetModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory TrainerPresetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerPresetModel.fromJson({...data, 'id': doc.id});
  }
}

/// TrainerPresetModel 확장 메서드
extension TrainerPresetModelX on TrainerPresetModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
