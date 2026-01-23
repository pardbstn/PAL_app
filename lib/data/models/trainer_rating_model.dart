import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trainer_rating_model.freezed.dart';
part 'trainer_rating_model.g.dart';

class RatingTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const RatingTimestampConverter();
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
sealed class TrainerRatingModel with _$TrainerRatingModel {
  const factory TrainerRatingModel({
    @Default('') String id,
    @Default(0.0) double overall,
    @Default(0.0) double memberRating,
    @Default(0.0) double aiRating,
    @Default(0) int reviewCount,
    @RatingTimestampConverter() required DateTime lastUpdated,
  }) = _TrainerRatingModel;

  factory TrainerRatingModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerRatingModelFromJson(json);
}
