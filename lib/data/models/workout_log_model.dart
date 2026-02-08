import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_pal_app/data/models/user_model.dart';

part 'workout_log_model.freezed.dart';
part 'workout_log_model.g.dart';

/// 운동 종류
enum WorkoutCategory {
  @JsonValue('chest') chest,       // 가슴
  @JsonValue('back') back,         // 등
  @JsonValue('shoulder') shoulder, // 어깨
  @JsonValue('arm') arm,           // 팔
  @JsonValue('leg') leg,           // 하체
  @JsonValue('core') core,         // 코어
  @JsonValue('cardio') cardio,     // 유산소
  @JsonValue('other') other,       // 기타
}

/// 개별 운동 기록
@freezed
sealed class WorkoutExercise with _$WorkoutExercise {
  const factory WorkoutExercise({
    /// 운동 이름
    required String name,
    /// 운동 부위
    required WorkoutCategory category,
    /// 세트 수
    required int sets,
    /// 반복 횟수
    required int reps,
    /// 무게 (kg)
    @Default(0.0) double weight,
    /// 휴식 시간 (초)
    @Default(60) int restSeconds,
    /// 메모
    @Default('') String note,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}

/// 운동 기록 모델
@freezed
sealed class WorkoutLogModel with _$WorkoutLogModel {
  const WorkoutLogModel._(); // ignore: unused_element

  const factory WorkoutLogModel({
    /// Firestore 문서 ID
    @Default('') String id,
    /// 사용자 ID
    required String userId,
    /// 트레이너 ID (개인모드면 빈 문자열)
    @Default('') String trainerId,
    /// 운동 제목 (예: '상체 운동', '등 데이')
    @Default('') String title,
    /// 운동 날짜
    @TimestampConverter() required DateTime workoutDate,
    /// 운동 목록
    required List<WorkoutExercise> exercises,
    /// 총 운동 시간 (분)
    @Default(0) int durationMinutes,
    /// 전체 메모
    @Default('') String memo,
    /// 오운완 사진 URL (Supabase Storage)
    String? imageUrl,
    /// 생성일
    @TimestampConverter() required DateTime createdAt,
  }) = _WorkoutLogModel;

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory WorkoutLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutLogModel.fromJson({...data, 'id': doc.id});
  }

  /// Firestore 저장용 Map 변환 (id 제거 + exercises 직렬화)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'trainerId': trainerId,
      'title': title,
      'workoutDate': Timestamp.fromDate(workoutDate),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'durationMinutes': durationMinutes,
      'memo': memo,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
