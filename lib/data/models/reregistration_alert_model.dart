import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'reregistration_alert_model.freezed.dart';
part 'reregistration_alert_model.g.dart';

class ReregistrationTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const ReregistrationTimestampConverter();

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

class ReregistrationRequiredTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const ReregistrationRequiredTimestampConverter();

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
sealed class ReregistrationAlertModel with _$ReregistrationAlertModel {
  const factory ReregistrationAlertModel({
    required String id,
    required String memberId,
    required String trainerId,
    required int totalSessions,
    required int completedSessions,
    required double progressRate,
    @ReregistrationTimestampConverter() DateTime? alertSentAt,
    @Default(false) bool reregistered,
    @ReregistrationRequiredTimestampConverter() required DateTime createdAt,
  }) = _ReregistrationAlertModel;

  factory ReregistrationAlertModel.fromJson(Map<String, dynamic> json) =>
      _$ReregistrationAlertModelFromJson(json);

  factory ReregistrationAlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReregistrationAlertModel.fromJson({...data, 'id': doc.id});
  }
}

extension ReregistrationAlertModelX on ReregistrationAlertModel {
  Map<String, dynamic> toFirestore() {
    return {
      'memberId': memberId,
      'trainerId': trainerId,
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'progressRate': progressRate,
      if (alertSentAt != null) 'alertSentAt': Timestamp.fromDate(alertSentAt!),
      'reregistered': reregistered,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get shouldSendAlert => progressRate >= 0.8 && alertSentAt == null && !reregistered;

  int get remainingSessions => totalSessions - completedSessions;

  String get progressPercentage => '${(progressRate * 100).toInt()}%';
}
