import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_performance_model.freezed.dart';
part 'trainer_performance_model.g.dart';

class PerformanceTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const PerformanceTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

@freezed
sealed class TrainerPerformanceModel with _$TrainerPerformanceModel {
  const factory TrainerPerformanceModel({
    required String id,
    required String trainerId,
    /// 재등록률 (0.0 ~ 1.0)
    @Default(0.0) double reregistrationRate,
    /// 목표달성률 (0.0 ~ 1.0)
    @Default(0.0) double goalAchievementRate,
    /// 평균 체성분 변화 (kg, 양수=증가, 음수=감소)
    @Default(0.0) double avgBodyCompositionChange,
    /// 출석률 관리 (0.0 ~ 1.0)
    @Default(0.0) double attendanceManagementRate,
    /// 총 평가 수
    @Default(0) int totalReviews,
    /// 평균 평점 (1.0 ~ 5.0)
    @Default(0.0) double averageRating,
    /// 총 회원 수
    @Default(0) int totalMembers,
    /// 활성 회원 수
    @Default(0) int activeMembers,
    @PerformanceTimestampConverter() required DateTime updatedAt,
  }) = _TrainerPerformanceModel;

  factory TrainerPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerPerformanceModelFromJson(json);

  factory TrainerPerformanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerPerformanceModel.fromJson({...data, 'id': doc.id});
  }
}

extension TrainerPerformanceModelX on TrainerPerformanceModel {
  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'reregistrationRate': reregistrationRate,
      'goalAchievementRate': goalAchievementRate,
      'avgBodyCompositionChange': avgBodyCompositionChange,
      'attendanceManagementRate': attendanceManagementRate,
      'totalReviews': totalReviews,
      'averageRating': averageRating,
      'totalMembers': totalMembers,
      'activeMembers': activeMembers,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// 재등록률 퍼센트
  String get reregistrationRateText => '${(reregistrationRate * 100).toInt()}%';

  /// 목표달성률 퍼센트
  String get goalAchievementRateText => '${(goalAchievementRate * 100).toInt()}%';

  /// 출석률 퍼센트
  String get attendanceRateText => '${(attendanceManagementRate * 100).toInt()}%';

  /// 평점 텍스트
  String get ratingText => averageRating.toStringAsFixed(1);

  /// 체성분 변화 텍스트
  String get bodyChangeText {
    if (avgBodyCompositionChange == 0) return '변화 없음';
    final sign = avgBodyCompositionChange > 0 ? '+' : '';
    return '$sign${avgBodyCompositionChange.toStringAsFixed(1)}kg';
  }

  /// 평가 공개 가능 여부 (5개 이상)
  bool get canShowReviews => totalReviews >= 5;
}
