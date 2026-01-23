import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_review_model.dart';
import 'base_repository.dart';

final trainerReviewRepositoryProvider = Provider<TrainerReviewRepository>((ref) {
  return TrainerReviewRepository(firestore: ref.watch(firestoreProvider));
});

class TrainerReviewRepository extends BaseRepository<TrainerReviewModel> {
  TrainerReviewRepository({required super.firestore})
      : super(collectionPath: 'trainer_reviews');

  /// 평가 생성
  @override
  Future<String> create(TrainerReviewModel review) async {
    final docRef = await collection.add(review.toFirestore());
    return docRef.id;
  }

  /// 트레이너별 모든 평가 조회
  Future<List<TrainerReviewModel>> getByTrainerId(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .get();
    final reviews = snapshot.docs
        .map((doc) => TrainerReviewModel.fromFirestore(doc))
        .toList();
    // 클라이언트에서 최신순 정렬 (복합 인덱스 불필요)
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  /// 트레이너별 공개 평가만 조회 (5개 이상일 때)
  Future<List<TrainerReviewModel>> getPublicReviews(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('isPublic', isEqualTo: true)
        .get();
    final reviews = snapshot.docs
        .map((doc) => TrainerReviewModel.fromFirestore(doc))
        .toList();
    // 클라이언트에서 최신순 정렬 (복합 인덱스 불필요)
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  /// 트레이너별 평가 실시간 감시
  Stream<List<TrainerReviewModel>> watchByTrainerId(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      final reviews = snapshot.docs
          .map((doc) => TrainerReviewModel.fromFirestore(doc))
          .toList();
      // 클라이언트에서 최신순 정렬 (복합 인덱스 불필요)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  /// 평균 평점 계산
  Future<double> getAverageRating(String trainerId) async {
    final reviews = await getByTrainerId(trainerId);
    if (reviews.isEmpty) return 0.0;

    final total = reviews.fold<double>(
      0.0,
      (total, review) => total + review.averageRating,
    );
    return total / reviews.length;
  }

  /// 평균 평점 실시간 감시
  Stream<double> watchAverageRating(String trainerId) {
    return watchByTrainerId(trainerId).map((reviews) {
      if (reviews.isEmpty) return 0.0;
      final total = reviews.fold<double>(
        0.0,
        (total, review) => total + review.averageRating,
      );
      return total / reviews.length;
    });
  }

  /// 회원이 이미 평가했는지 확인
  Future<bool> hasReviewed(String memberId, String trainerId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('trainerId', isEqualTo: trainerId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// 총 평가 수 조회
  Future<int> getReviewCount(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// 평가 공개 처리 (5개 이상 누적 시)
  Future<void> makeReviewsPublic(String trainerId) async {
    final count = await getReviewCount(trainerId);
    if (count < 5) return;

    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('isPublic', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isPublic': true});
    }
    await batch.commit();
  }

  @override
  Future<TrainerReviewModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return TrainerReviewModel.fromFirestore(doc);
  }

  @override
  Future<List<TrainerReviewModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => TrainerReviewModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<TrainerReviewModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerReviewModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<TrainerReviewModel>> watchAll() {
    return collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TrainerReviewModel.fromFirestore(doc))
        .toList());
  }
}
