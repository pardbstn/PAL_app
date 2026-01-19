import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'curriculum_model.freezed.dart';
part 'curriculum_model.g.dart';

/// 운동 항목
@freezed
sealed class Exercise with _$Exercise {
  const factory Exercise({
    /// 운동명 (예: '벤치프레스')
    required String name,

    /// 세트 수
    required int sets,

    /// 반복 횟수
    required int reps,

    /// 중량 (kg)
    double? weight,

    /// 휴식 시간 (초)
    int? restSeconds,

    /// 메모
    String? note,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}

/// 커리큘럼 모델
/// 회원별 커리큘럼 (회차별 운동 계획)
@freezed
sealed class CurriculumModel with _$CurriculumModel {
  const factory CurriculumModel({
    /// 커리큘럼 문서 ID
    required String id,

    /// 회원 ID
    required String memberId,

    /// 트레이너 ID
    required String trainerId,

    /// 회차 번호 (1, 2, 3...)
    required int sessionNumber,

    /// 제목 (예: '상체 운동')
    required String title,

    /// 운동 목록
    @Default([]) List<Exercise> exercises,

    /// 완료 여부
    @Default(false) bool isCompleted,

    /// 예정 날짜
    @NullableTimestampConverter() DateTime? scheduledDate,

    /// 완료 날짜
    @NullableTimestampConverter() DateTime? completedDate,

    /// AI 생성 여부
    @Default(false) bool isAiGenerated,

    /// 생성일
    @TimestampConverter() required DateTime createdAt,

    /// 수정일
    @TimestampConverter() required DateTime updatedAt,
  }) = _CurriculumModel;

  factory CurriculumModel.fromJson(Map<String, dynamic> json) =>
      _$CurriculumModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory CurriculumModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CurriculumModel.fromJson({...data, 'id': doc.id});
  }
}

/// CurriculumModel 확장 메서드
extension CurriculumModelX on CurriculumModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id'); // ID는 문서 ID로 사용
    // exercises를 명시적으로 직렬화
    json['exercises'] = exercises.map((e) => e.toJson()).toList();
    return json;
  }

  /// 총 운동 수
  int get exerciseCount => exercises.length;

  /// 총 세트 수
  int get totalSets =>
      exercises.fold(0, (total, exercise) => total + exercise.sets);

  /// 예상 소요 시간 (분) - 세트당 약 2분 기준
  int get estimatedDuration => totalSets * 2;
}

/// Exercise 확장 메서드
extension ExerciseX on Exercise {
  /// 운동 요약 문자열 (예: "벤치프레스 3세트 x 10회 · 60kg")
  String get summary {
    final weightStr = weight != null ? ' · ${weight!.toStringAsFixed(1)}kg' : '';
    return '$name $sets세트 x $reps회$weightStr';
  }

  /// 총 볼륨 (세트 x 반복 x 중량)
  double get volume => sets * reps * (weight ?? 0);
}
