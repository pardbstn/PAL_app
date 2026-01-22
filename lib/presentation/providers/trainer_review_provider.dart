import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trainer_review_model.dart';
import '../../data/models/trainer_performance_model.dart';
import '../../data/repositories/trainer_review_repository.dart';
import '../../data/repositories/trainer_performance_repository.dart';
import '../../data/services/review_validation_service.dart';

/// 트레이너별 평가 목록 실시간 감시
final trainerReviewsProvider = StreamProvider.family<List<TrainerReviewModel>, String>((ref, trainerId) {
  final repository = ref.watch(trainerReviewRepositoryProvider);
  return repository.watchByTrainerId(trainerId);
});

/// 트레이너별 공개 평가만 조회
final trainerPublicReviewsProvider = FutureProvider.family<List<TrainerReviewModel>, String>((ref, trainerId) async {
  final repository = ref.watch(trainerReviewRepositoryProvider);
  return repository.getPublicReviews(trainerId);
});

/// 트레이너 평균 평점 실시간 감시
final trainerAverageRatingProvider = StreamProvider.family<double, String>((ref, trainerId) {
  final repository = ref.watch(trainerReviewRepositoryProvider);
  return repository.watchAverageRating(trainerId);
});

/// 트레이너 성과 지표 실시간 감시
final trainerPerformanceProvider = StreamProvider.family<TrainerPerformanceModel?, String>((ref, trainerId) {
  final repository = ref.watch(trainerPerformanceRepositoryProvider);
  return repository.watch(trainerId);
});

/// 평가 자격 확인 파라미터
class ReviewCheckParams {
  final String memberId;
  final String trainerId;

  ReviewCheckParams({required this.memberId, required this.trainerId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewCheckParams &&
          memberId == other.memberId &&
          trainerId == other.trainerId;

  @override
  int get hashCode => memberId.hashCode ^ trainerId.hashCode;
}

/// 평가 자격 확인
final reviewEligibilityProvider = FutureProvider.family<ReviewEligibility, ReviewCheckParams>((ref, params) async {
  final service = ref.watch(reviewValidationServiceProvider);
  return service.validateReviewEligibility(params.memberId, params.trainerId);
});

/// 평가 관리 Notifier
class TrainerReviewNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// 평가 제출
  Future<String> submitReview(TrainerReviewModel review) async {
    final service = ref.read(reviewValidationServiceProvider);
    return await service.submitReview(review);
  }

  /// 성과 지표 업데이트
  Future<TrainerPerformanceModel> updatePerformance(String trainerId) async {
    final service = ref.read(reviewValidationServiceProvider);
    return await service.calculateAndUpdatePerformance(trainerId);
  }
}

final trainerReviewNotifierProvider = AsyncNotifierProvider<TrainerReviewNotifier, void>(() {
  return TrainerReviewNotifier();
});
