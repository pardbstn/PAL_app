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

// ============================================================================
// 리뷰 정렬/필터링 (트레이너 평점 상세 화면용)
// ============================================================================

/// 리뷰 정렬 옵션
enum ReviewSortOption {
  newest('최신순'),
  oldest('오래된순'),
  highest('높은 점수순'),
  lowest('낮은 점수순');

  final String label;
  const ReviewSortOption(this.label);
}

/// 리뷰 정렬 옵션 Notifier
class ReviewSortOptionNotifier extends Notifier<ReviewSortOption> {
  @override
  ReviewSortOption build() => ReviewSortOption.newest;

  void setOption(ReviewSortOption option) {
    state = option;
  }
}

/// 현재 선택된 정렬 옵션
final reviewSortOptionProvider = NotifierProvider<ReviewSortOptionNotifier, ReviewSortOption>(() {
  return ReviewSortOptionNotifier();
});

/// 정렬된 리뷰 목록 Provider
final sortedTrainerReviewsProvider = Provider.family<AsyncValue<List<MemberReviewModel>>, String>((ref, trainerId) {
  final reviewsAsync = ref.watch(trainerReviewsProvider(trainerId));
  final sortOption = ref.watch(reviewSortOptionProvider);

  return reviewsAsync.whenData((reviews) {
    final sorted = List<MemberReviewModel>.from(reviews);
    switch (sortOption) {
      case ReviewSortOption.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case ReviewSortOption.oldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case ReviewSortOption.highest:
        sorted.sort((a, b) => MemberReviewModel.averageRating(b).compareTo(MemberReviewModel.averageRating(a)));
      case ReviewSortOption.lowest:
        sorted.sort((a, b) => MemberReviewModel.averageRating(a).compareTo(MemberReviewModel.averageRating(b)));
    }
    return sorted;
  });
});

/// 카테고리별 평균 점수 계산 Provider
final categoryAveragesProvider = Provider.family<({double coaching, double communication, double kindness})?, String>((ref, trainerId) {
  final reviewsAsync = ref.watch(trainerReviewsProvider(trainerId));

  return reviewsAsync.whenOrNull(data: (reviews) {
    if (reviews.isEmpty) return null;

    double totalCoaching = 0;
    double totalCommunication = 0;
    double totalKindness = 0;

    for (final review in reviews) {
      totalCoaching += review.coachingSatisfaction;
      totalCommunication += review.communication;
      totalKindness += review.kindness;
    }

    return (
      coaching: totalCoaching / reviews.length,
      communication: totalCommunication / reviews.length,
      kindness: totalKindness / reviews.length,
    );
  });
});

// ============================================================================
// 회원용 Provider (내가 작성한 리뷰 조회)
// ============================================================================

/// 회원이 작성한 리뷰 조회 파라미터
typedef MemberReviewParams = ({String trainerId, String memberId});

/// 회원이 작성한 리뷰 Provider
final memberOwnReviewProvider = FutureProvider.family<MemberReviewModel?, MemberReviewParams>((ref, params) async {
  final repo = ref.watch(trainerRatingRepositoryProvider);
  return repo.getMemberReview(params.trainerId, params.memberId);
});
