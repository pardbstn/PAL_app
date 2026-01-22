import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_performance_model.dart';
import 'base_repository.dart';

final trainerPerformanceRepositoryProvider = Provider<TrainerPerformanceRepository>((ref) {
  return TrainerPerformanceRepository(firestore: ref.watch(firestoreProvider));
});

class TrainerPerformanceRepository extends BaseRepository<TrainerPerformanceModel> {
  TrainerPerformanceRepository({required super.firestore})
      : super(collectionPath: 'trainer_performance');

  /// 성과 조회 (trainerId가 문서 ID)
  @override
  Future<TrainerPerformanceModel?> get(String trainerId) async {
    final doc = await collection.doc(trainerId).get();
    if (!doc.exists) return null;
    return TrainerPerformanceModel.fromFirestore(doc);
  }

  /// 성과 실시간 감시
  @override
  Stream<TrainerPerformanceModel?> watch(String trainerId) {
    return collection.doc(trainerId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerPerformanceModel.fromFirestore(doc);
    });
  }

  /// 성과 생성 또는 업데이트
  Future<void> createOrUpdate(TrainerPerformanceModel performance) async {
    await collection.doc(performance.trainerId).set(
      performance.toFirestore(),
      SetOptions(merge: true),
    );
  }

  /// 평점 업데이트
  Future<void> updateRating(String trainerId, double averageRating, int totalReviews) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 재등록률 업데이트
  Future<void> updateReregistrationRate(String trainerId, double rate) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'reregistrationRate': rate,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 목표달성률 업데이트
  Future<void> updateGoalAchievementRate(String trainerId, double rate) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'goalAchievementRate': rate,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 출석률 업데이트
  Future<void> updateAttendanceRate(String trainerId, double rate) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'attendanceManagementRate': rate,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 체성분 변화 평균 업데이트
  Future<void> updateAvgBodyChange(String trainerId, double avgChange) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'avgBodyCompositionChange': avgChange,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 회원 수 업데이트
  Future<void> updateMemberCounts(String trainerId, int total, int active) async {
    await collection.doc(trainerId).set({
      'trainerId': trainerId,
      'totalMembers': total,
      'activeMembers': active,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    }, SetOptions(merge: true));
  }

  /// 전체 성과 지표 한번에 업데이트
  Future<void> updateAllMetrics(TrainerPerformanceModel performance) async {
    await collection.doc(performance.trainerId).set(
      performance.toFirestore(),
    );
  }

  /// 랭킹 조회 (평점 기준)
  /// 리뷰 5개 이상인 트레이너만 필터링 후 클라이언트에서 정렬
  Future<List<TrainerPerformanceModel>> getRankingByRating({int limit = 10}) async {
    // 복합 인덱스 없이 작동하도록 클라이언트 측 정렬 사용
    final snapshot = await collection
        .where('totalReviews', isGreaterThanOrEqualTo: 5)
        .get();

    final results = snapshot.docs
        .map((doc) => TrainerPerformanceModel.fromFirestore(doc))
        .toList();

    // 평점 내림차순 정렬 (동점이면 리뷰 수 많은 순)
    results.sort((a, b) {
      final ratingCompare = b.averageRating.compareTo(a.averageRating);
      if (ratingCompare != 0) return ratingCompare;
      return b.totalReviews.compareTo(a.totalReviews);
    });

    return results.take(limit).toList();
  }

  /// 랭킹 조회 (재등록률 기준)
  Future<List<TrainerPerformanceModel>> getRankingByReregistration({int limit = 10}) async {
    final snapshot = await collection
        .orderBy('reregistrationRate', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => TrainerPerformanceModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(TrainerPerformanceModel item) async {
    await collection.doc(item.trainerId).set(item.toFirestore());
    return item.trainerId;
  }

  @override
  Future<List<TrainerPerformanceModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => TrainerPerformanceModel.fromFirestore(doc))
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
  Stream<List<TrainerPerformanceModel>> watchAll() {
    return collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => TrainerPerformanceModel.fromFirestore(doc))
        .toList());
  }
}
