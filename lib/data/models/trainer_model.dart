import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'trainer_model.freezed.dart';
part 'trainer_model.g.dart';

/// 구독 티어
enum SubscriptionTier {
  @JsonValue('free')
  free,
  @JsonValue('basic')
  basic,
  @JsonValue('pro')
  pro,
}

/// AI 사용량 정보
@freezed
sealed class AiUsage with _$AiUsage {
  const factory AiUsage({
    /// 이번 달 커리큘럼 생성 횟수
    @Default(0) int curriculumCount,

    /// 이번 달 예측 횟수
    @Default(0) int predictionCount,

    /// 월별 리셋 날짜
    @TimestampConverter() required DateTime resetDate,
  }) = _AiUsage;

  factory AiUsage.fromJson(Map<String, dynamic> json) =>
      _$AiUsageFromJson(json);
}

/// 트레이너 모델
/// 트레이너 전용 프로필 정보
@freezed
sealed class TrainerModel with _$TrainerModel {
  const factory TrainerModel({
    /// 트레이너 문서 ID
    required String id,

    /// users 컬렉션 참조
    required String userId,

    /// 구독 티어 ('free' | 'basic' | 'pro')
    @Default(SubscriptionTier.free) SubscriptionTier subscriptionTier,

    /// 담당 회원 ID 목록
    @Default([]) List<String> memberIds,

    /// AI 사용량 정보
    required AiUsage aiUsage,
  }) = _TrainerModel;

  factory TrainerModel.fromJson(Map<String, dynamic> json) =>
      _$TrainerModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory TrainerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = DateTime.now();

    // aiUsage 필드 안전하게 처리
    Map<String, dynamic> sanitizedAiUsage;
    final rawAiUsage = data['aiUsage'];

    if (rawAiUsage is Map<String, dynamic>) {
      // curriculumCount와 predictionCount가 숫자인지 확인
      final curriculumCount = rawAiUsage['curriculumCount'];
      final predictionCount = rawAiUsage['predictionCount'];

      sanitizedAiUsage = {
        'curriculumCount': curriculumCount is num ? curriculumCount : 0,
        'predictionCount': predictionCount is num ? predictionCount : 0,
        'resetDate': rawAiUsage['resetDate'] ?? Timestamp.fromDate(DateTime(now.year, now.month, 1)),
      };
    } else {
      // aiUsage가 없거나 잘못된 형식인 경우 기본값 사용
      sanitizedAiUsage = {
        'curriculumCount': 0,
        'predictionCount': 0,
        'resetDate': Timestamp.fromDate(DateTime(now.year, now.month, 1)),
      };
    }

    return TrainerModel.fromJson({
      ...data,
      'id': doc.id,
      'aiUsage': sanitizedAiUsage,
    });
  }
}

/// TrainerModel 확장 메서드
extension TrainerModelX on TrainerModel {
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'subscriptionTier': subscriptionTier.name,
      'memberIds': memberIds,
      'aiUsage': {
        'curriculumCount': aiUsage.curriculumCount,
        'predictionCount': aiUsage.predictionCount,
        'resetDate': Timestamp.fromDate(aiUsage.resetDate),
      },
    };
  }

  /// 담당 회원 수
  int get memberCount => memberIds.length;

  /// 무료 티어 여부
  bool get isFreeTier => subscriptionTier == SubscriptionTier.free;

  /// Pro 티어 여부
  bool get isProTier => subscriptionTier == SubscriptionTier.pro;

  /// 이번 달 AI 사용량 초과 여부 - 모든 티어 무제한
  bool get isAiLimitExceeded {
    // 모든 기능 무료 개방 - 제한 없음
    return false;
  }
}
