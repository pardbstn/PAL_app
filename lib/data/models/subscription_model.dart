import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum SubscriptionPlan {
  @JsonValue('free')
  free('무료'),
  @JsonValue('premium')
  premium('프리미엄');

  final String label;
  const SubscriptionPlan(this.label);
}

class SubscriptionTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const SubscriptionTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

class SubscriptionNullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const SubscriptionNullableTimestampConverter();

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

@freezed
sealed class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String userId,
    @Default(SubscriptionPlan.free) SubscriptionPlan plan,
    @SubscriptionTimestampConverter() required DateTime startDate,
    @SubscriptionNullableTimestampConverter() DateTime? endDate,
    @Default(true) bool isActive,
    @Default([]) List<String> features,
    /// 이번 달 남은 트레이너 질문 횟수 (프리미엄: 3회)
    @Default(0) int monthlyQuestionCount,
    @SubscriptionTimestampConverter() required DateTime createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  factory SubscriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SubscriptionModel.fromJson({...data, 'id': doc.id});
  }
}

extension SubscriptionModelX on SubscriptionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'plan': plan.name,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'isActive': isActive,
      'features': features,
      'monthlyQuestionCount': monthlyQuestionCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isPremium => plan == SubscriptionPlan.premium && isActive;

  bool get hasQuestionRemaining => monthlyQuestionCount > 0;

  String get planText => isPremium ? '프리미엄 (월 4,900원)' : '무료';

  String get questionCountText => '$monthlyQuestionCount회 남음';

  /// 프리미엄 기능 목록
  static const List<String> premiumFeatures = [
    'ai_workout_recommendation',
    'ai_diet_analysis',
    'monthly_report',
    'trainer_question',
  ];

  bool hasFeature(String feature) {
    if (isPremium) return true;
    return features.contains(feature);
  }
}
