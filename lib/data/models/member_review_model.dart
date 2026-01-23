import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'member_review_model.freezed.dart';
part 'member_review_model.g.dart';

class ReviewTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const ReviewTimestampConverter();
  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }
  @override
  dynamic toJson(DateTime date) => Timestamp.fromDate(date);
}

@freezed
sealed class MemberReviewModel with _$MemberReviewModel {
  const factory MemberReviewModel({
    @Default('') String id,
    required String memberId,
    required String memberName,
    @Default(5) int coachingSatisfaction,
    @Default(5) int communication,
    @Default(5) int kindness,
    @Default('') String comment,
    @ReviewTimestampConverter() required DateTime createdAt,
  }) = _MemberReviewModel;

  factory MemberReviewModel.fromJson(Map<String, dynamic> json) =>
      _$MemberReviewModelFromJson(json);

  /// 회원 평가 평균 (3개 항목)
  static double averageRating(MemberReviewModel review) {
    return (review.coachingSatisfaction + review.communication + review.kindness) / 3.0;
  }
}
