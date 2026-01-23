import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_rating_model.dart';
import 'package:flutter_pal_app/data/models/member_review_model.dart';
import 'package:flutter_pal_app/data/repositories/trainer_rating_repository.dart';

/// 트레이너 평점 레포지토리 프로바이더
final trainerRatingRepositoryProvider = Provider<TrainerRatingRepository>((ref) {
  return TrainerRatingRepository();
});

/// 트레이너 평점 스트림 프로바이더
final trainerRatingProvider = StreamProvider.family<TrainerRatingModel?, String>((ref, trainerId) {
  final repo = ref.watch(trainerRatingRepositoryProvider);
  return repo.watchRating(trainerId);
});

/// 트레이너 리뷰 목록 스트림 프로바이더
final trainerReviewsProvider = StreamProvider.family<List<MemberReviewModel>, String>((ref, trainerId) {
  final repo = ref.watch(trainerRatingRepositoryProvider);
  return repo.watchReviews(trainerId);
});

/// 리뷰 작성 상태
enum ReviewSubmitStatus { idle, submitting, success, error }

/// 리뷰 작성 상태 클래스
class ReviewSubmitState {
  final ReviewSubmitStatus status;
  final String? errorMessage;

  const ReviewSubmitState({
    this.status = ReviewSubmitStatus.idle,
    this.errorMessage,
  });

  ReviewSubmitState copyWith({
    ReviewSubmitStatus? status,
    String? errorMessage,
  }) {
    return ReviewSubmitState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 리뷰 작성 노티파이어
class ReviewSubmitNotifier extends Notifier<ReviewSubmitState> {
  @override
  ReviewSubmitState build() => const ReviewSubmitState();

  /// 리뷰 제출
  Future<bool> submitReview({
    required String trainerId,
    required String memberId,
    required String memberName,
    required int coachingSatisfaction,
    required int communication,
    required int kindness,
    String comment = '',
  }) async {
    state = state.copyWith(status: ReviewSubmitStatus.submitting);

    try {
      final repo = ref.read(trainerRatingRepositoryProvider);
      final review = MemberReviewModel(
        memberId: memberId,
        memberName: memberName,
        coachingSatisfaction: coachingSatisfaction,
        communication: communication,
        kindness: kindness,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await repo.addReview(trainerId, review);
      state = state.copyWith(status: ReviewSubmitStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: ReviewSubmitStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// 상태 리셋
  void reset() {
    state = const ReviewSubmitState();
  }
}

/// 리뷰 작성 프로바이더
final reviewSubmitProvider = NotifierProvider<ReviewSubmitNotifier, ReviewSubmitState>(() {
  return ReviewSubmitNotifier();
});
