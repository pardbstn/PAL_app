import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_request_model.dart';
import 'base_repository.dart';

final trainerRequestRepositoryProvider = Provider<TrainerRequestRepository>((ref) {
  return TrainerRequestRepository(firestore: ref.watch(firestoreProvider));
});

class TrainerRequestRepository extends BaseRepository<TrainerRequestModel> {
  TrainerRequestRepository({required super.firestore})
      : super(collectionPath: 'trainer_requests');

  /// 요청 생성
  @override
  Future<String> create(TrainerRequestModel request) async {
    final docRef = await collection.add(request.toFirestore());
    return docRef.id;
  }

  /// 요청 조회
  @override
  Future<TrainerRequestModel?> get(String requestId) async {
    final doc = await collection.doc(requestId).get();
    if (!doc.exists) return null;
    return TrainerRequestModel.fromFirestore(doc);
  }

  @override
  Future<List<TrainerRequestModel>> getAll() async {
    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => TrainerRequestModel.fromFirestore(doc)).toList();
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
  Stream<TrainerRequestModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerRequestModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<TrainerRequestModel>> watchAll() {
    return collection.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TrainerRequestModel.fromFirestore(doc)).toList());
  }

  /// 회원별 요청 목록 조회
  Future<List<TrainerRequestModel>> getByMemberId(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TrainerRequestModel.fromFirestore(doc))
        .toList();
  }

  /// 회원별 요청 실시간 감시
  Stream<List<TrainerRequestModel>> watchByMemberId(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainerRequestModel.fromFirestore(doc))
            .toList());
  }

  /// 트레이너별 요청 목록 조회
  Future<List<TrainerRequestModel>> getByTrainerId(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TrainerRequestModel.fromFirestore(doc))
        .toList();
  }

  /// 트레이너별 대기 중인 요청 실시간 감시
  Stream<List<TrainerRequestModel>> watchPendingByTrainerId(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TrainerRequestModel.fromFirestore(doc))
            .toList());
  }

  /// 트레이너별 대기 중인 요청 수 실시간 감시
  Stream<int> watchPendingCount(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: RequestStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 답변 등록
  Future<void> submitResponse(String requestId, String response) async {
    await collection.doc(requestId).update({
      'response': response,
      'status': RequestStatus.answered.name,
      'answeredAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 상태 업데이트
  Future<void> updateStatus(String requestId, RequestStatus status) async {
    await collection.doc(requestId).update({
      'status': status.name,
    });
  }

  /// 만료 처리 (48시간 초과)
  Future<void> processExpiredRequests() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 48));
    final snapshot = await collection
        .where('status', isEqualTo: RequestStatus.pending.name)
        .where('createdAt', isLessThan: Timestamp.fromDate(cutoff))
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'status': RequestStatus.expired.name,
      });
    }
    await batch.commit();
  }

  /// 트레이너 수익 계산 (완료된 요청들)
  Future<int> calculateTrainerRevenue(String trainerId, {DateTime? from, DateTime? to}) async {
    var query = collection
        .where('trainerId', isEqualTo: trainerId)
        .where('status', isEqualTo: RequestStatus.answered.name);

    if (from != null) {
      query = query.where('answeredAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      query = query.where('answeredAt', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    final snapshot = await query.get();
    return snapshot.docs.fold<int>(0, (total, doc) {
      final request = TrainerRequestModel.fromFirestore(doc);
      return total + request.trainerRevenue;
    });
  }
}
