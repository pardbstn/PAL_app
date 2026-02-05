import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firestore_constants.dart';
import '../models/trainer_rating_model.dart';
import '../models/member_review_model.dart';

/// 트레이너 평점 레포지토리
class TrainerRatingRepository {
  final FirebaseFirestore _firestore;

  TrainerRatingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 트레이너 평점 조회
  Future<TrainerRatingModel?> getRating(String trainerId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.rating)
        .doc('current')
        .get();
    if (!doc.exists) return null;
    return TrainerRatingModel.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// 트레이너 평점 업데이트
  Future<void> updateRating(String trainerId, TrainerRatingModel rating) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.rating)
        .doc('current')
        .set(rating.toJson());
  }

  /// 리뷰 목록 조회
  Future<List<MemberReviewModel>> getReviews(String trainerId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.reviews)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => MemberReviewModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  /// 리뷰 작성
  Future<void> addReview(String trainerId, MemberReviewModel review) async {
    await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.reviews)
        .add(review.toJson());
    // 평점 재계산
    await _recalculateRating(trainerId);
  }

  /// 평점 재계산 (회원 리뷰 기반)
  Future<void> _recalculateRating(String trainerId) async {
    final reviews = await getReviews(trainerId, limit: 1000);
    if (reviews.isEmpty) return;

    double totalMemberRating = 0;
    for (final review in reviews) {
      totalMemberRating += MemberReviewModel.averageRating(review);
    }
    final memberRating = totalMemberRating / reviews.length;

    // 기존 AI 점수 유지
    final existing = await getRating(trainerId);
    final aiRating = existing?.aiRating ?? 0.0;

    // 종합 = (회원 60%) + (AI 40%)
    final overall = aiRating > 0
        ? (memberRating * 0.6) + (aiRating * 0.4)
        : memberRating;

    await updateRating(trainerId, TrainerRatingModel(
      overall: double.parse(overall.toStringAsFixed(1)),
      memberRating: double.parse(memberRating.toStringAsFixed(1)),
      aiRating: double.parse(aiRating.toStringAsFixed(1)),
      reviewCount: reviews.length,
      lastUpdated: DateTime.now(),
    ));
  }

  /// AI 평점 업데이트
  Future<void> updateAiRating(String trainerId, double aiScore) async {
    final existing = await getRating(trainerId);
    final memberRating = existing?.memberRating ?? 0.0;
    final reviewCount = existing?.reviewCount ?? 0;

    final overall = memberRating > 0
        ? (memberRating * 0.6) + (aiScore * 0.4)
        : aiScore;

    await updateRating(trainerId, TrainerRatingModel(
      overall: double.parse(overall.toStringAsFixed(1)),
      memberRating: double.parse(memberRating.toStringAsFixed(1)),
      aiRating: double.parse(aiScore.toStringAsFixed(1)),
      reviewCount: reviewCount,
      lastUpdated: DateTime.now(),
    ));
  }

  /// 리뷰 스트림 (실시간)
  Stream<List<MemberReviewModel>> watchReviews(String trainerId) {
    return _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.reviews)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberReviewModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// 특정 회원의 리뷰 조회
  Future<MemberReviewModel?> getMemberReview(String trainerId, String memberId) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.reviews)
        .where('memberId', isEqualTo: memberId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return MemberReviewModel.fromJson({...doc.data(), 'id': doc.id});
  }

  /// 평점 스트림 (실시간)
  Stream<TrainerRatingModel?> watchRating(String trainerId) {
    return _firestore
        .collection(FirestoreCollections.trainers)
        .doc(trainerId)
        .collection(FirestoreCollections.rating)
        .doc('current')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return TrainerRatingModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }
}
