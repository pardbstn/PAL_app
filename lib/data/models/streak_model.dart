import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_model.freezed.dart';
part 'streak_model.g.dart';

enum StreakType {
  @JsonValue('weight')
  weight('체중'),
  @JsonValue('diet')
  diet('식단');

  final String label;
  const StreakType(this.label);
}

class StreakTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const StreakTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return null;
  }

  @override
  dynamic toJson(DateTime? date) => date?.toIso8601String();
}

class StreakRequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const StreakRequiredTimestampConverter();

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
sealed class StreakModel with _$StreakModel {
  const factory StreakModel({
    required String id,
    required String memberId,
    @Default(0) int weightStreak,
    @Default(0) int dietStreak,
    @Default(0) int longestWeightStreak,
    @Default(0) int longestDietStreak,
    @StreakTimestampConverter() DateTime? lastWeightRecordDate,
    @StreakTimestampConverter() DateTime? lastDietRecordDate,
    @Default([]) List<String> badges,
    @StreakRequiredTimestampConverter() required DateTime updatedAt,
  }) = _StreakModel;

  factory StreakModel.fromJson(Map<String, dynamic> json) =>
      _$StreakModelFromJson(json);

  factory StreakModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakModel.fromJson({...data, 'id': doc.id});
  }
}

extension StreakModelX on StreakModel {
  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'weightStreak': weightStreak,
      'dietStreak': dietStreak,
      'longestWeightStreak': longestWeightStreak,
      'longestDietStreak': longestDietStreak,
      if (lastWeightRecordDate != null)
        'lastWeightRecordDate': Timestamp.fromDate(lastWeightRecordDate!),
      if (lastDietRecordDate != null)
        'lastDietRecordDate': Timestamp.fromDate(lastDietRecordDate!),
      'badges': badges,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  int get totalStreak => weightStreak + dietStreak;

  bool get hasWeightStreak => weightStreak > 0;
  bool get hasDietStreak => dietStreak > 0;

  String get weightStreakText => '$weightStreak일 연속';
  String get dietStreakText => '$dietStreak일 연속';
}
