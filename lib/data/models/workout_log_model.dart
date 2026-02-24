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

/// 세트별 상세 (무게/횟수)
@freezed
sealed class SetDetail with _$SetDetail {
  const factory SetDetail({
    /// 반복 횟수
    required int reps,
    /// 무게 (kg)
    @Default(0.0) double weight,
  }) = _SetDetail;

  factory SetDetail.fromJson(Map<String, dynamic> json) =>
      _$SetDetailFromJson(json);
}

/// 개별 운동 기록
@freezed
sealed class WorkoutExercise with _$WorkoutExercise {
  @JsonSerializable(explicitToJson: true)
  const factory WorkoutExercise({
    /// 운동 이름
    required String name,
    /// 운동 부위
    required WorkoutCategory category,
    /// 세트 수 (요약용 - setDetails가 있으면 setDetails.length와 동일)
    required int sets,
    /// 반복 횟수 (요약용 - setDetails가 있으면 첫 세트 값)
    required int reps,
    /// 무게 (kg) (요약용 - setDetails가 있으면 최대값)
    @Default(0.0) double weight,
    /// 휴식 시간 (초)
    @Default(60) int restSeconds,
    /// 메모
    @Default('') String note,
    /// 세트별 상세 (null이면 균일 세트 - 하위호환)
    List<SetDetail>? setDetails,
  }) = _WorkoutExercise;

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) =>
      _$WorkoutExerciseFromJson(json);
}

/// WorkoutExercise 확장 메서드
extension WorkoutExerciseX on WorkoutExercise {
  /// 세트별 요약 텍스트 생성
  String get setSummaryText {
    if (setDetails != null && setDetails!.isNotEmpty) {
      final details = setDetails!;
      final allSame = details.every(
          (s) => s.reps == details.first.reps && s.weight == details.first.weight);
      if (allSame) {
        final w = details.first.weight;
        final wText = w > 0
            ? (w % 1 == 0 ? '${w.toInt()}kg' : '${w.toStringAsFixed(1)}kg')
            : '';
        return '${details.length}세트 × ${details.first.reps}회${wText.isNotEmpty ? ' $wText' : ''}';
      }
      return details
          .map((s) {
            final w = s.weight;
            final wText = w > 0
                ? (w % 1 == 0 ? '${w.toInt()}kg' : '${w.toStringAsFixed(1)}kg')
                : '';
            return '${wText.isNotEmpty ? '$wText×' : ''}${s.reps}회';
          })
          .join(', ');
    }
    final w = weight;
    final wText = w > 0
        ? (w % 1 == 0 ? ' ${w.toInt()}kg' : ' ${w.toStringAsFixed(1)}kg')
        : '';
    return '${sets}세트 × ${reps}회$wText';
  }
}

/// 운동 기록 모델
@freezed
sealed class WorkoutLogModel with _$WorkoutLogModel {
  const WorkoutLogModel._(); // ignore: unused_element

  @JsonSerializable(explicitToJson: true)
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
