import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_review_model.freezed.dart';
part 'trainer_review_model.g.dart';

class ReviewTimestampConverter implements JsonConverter<DateTime, dynamic> {
  const ReviewTimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    return DateTime.now();
  }

  @override
  dynamic toJson(DateTime date) => date.toIso8601String();
}

/// 평가 자격 상태
enum ReviewEligibility {
  eligible,           // 평가 가능
  alreadyReviewed,    // 이미 평가함
  notEnoughSessions,  // PT 8회 미만
  expired,            // 14일 초과
  noCompletedPt,      // 완료된 PT 없음
}

@freezed
sealed class TrainerReviewModel with _$TrainerReviewModel {
  const factory TrainerReviewModel({
    required String id,
    required String trainerId,
    required String memberId,
    /// 전문성 (1-5)
    required int professionalism,
    /// 소통력 (1-5)
    required int communication,
    /// 시간준수 (1-5)
    required int punctuality,
    /// 변화만족도 (1-5)
    required int satisfaction,
    /// 재등록의향 (1-5)
    required int reregistrationIntent,
    String? comment,
    @Default(false) bool isPublic,
    @ReviewTimestampConverter() required DateTime createdAt,
  }) = _TrainerReviewModel;

  factory TrainerReviewModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerReviewModelFromJson(json);

  factory TrainerReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TrainerReviewModel.fromJson({...data, 'id': doc.id});
  }
}

extension TrainerReviewModelX on TrainerReviewModel {
  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'memberId': memberId,
      'professionalism': professionalism,
      'communication': communication,
      'punctuality': punctuality,
      'satisfaction': satisfaction,
      'reregistrationIntent': reregistrationIntent,
      if (comment != null) 'comment': comment,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 평균 평점 계산
  double get averageRating {
    return (professionalism + communication + punctuality +
            satisfaction + reregistrationIntent) / 5.0;
  }

  /// 별점 텍스트
  String get ratingText => averageRating.toStringAsFixed(1);

  /// 평가 항목별 라벨
  static const Map<String, String> ratingLabels = {
    'professionalism': '전문성',
    'communication': '소통력',
    'punctuality': '시간준수',
    'satisfaction': '변화만족도',
    'reregistrationIntent': '재등록의향',
  };
}
