import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/trainer_transfer_model.dart';
import 'package:flutter_pal_app/data/repositories/base_repository.dart';

/// TrainerTransferRepository Provider
final trainerTransferRepositoryProvider =
    Provider<TrainerTransferRepository>((ref) {
  return TrainerTransferRepository(firestore: ref.watch(firestoreProvider));
});

/// 트레이너 전환 Repository
class TrainerTransferRepository extends BaseRepository<TrainerTransferModel> {
  TrainerTransferRepository({required super.firestore})
      : super(collectionPath: 'trainer_transfers');

  @override
  Future<TrainerTransferModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return TrainerTransferModel.fromFirestore(doc);
  }

  @override
  Future<List<TrainerTransferModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => TrainerTransferModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(TrainerTransferModel transfer) async {
    final docRef = await collection.add(transfer.toJson());
    return docRef.id;
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
  Stream<TrainerTransferModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerTransferModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<TrainerTransferModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainerTransferModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 대기 중인 전환 요청 조회
  Future<List<TrainerTransferModel>> getPendingForMember(
      String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TrainerTransferModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 대기 중인 전환 요청 실시간 감시
  Stream<List<TrainerTransferModel>> watchPendingForMember(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainerTransferModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 모든 전환 이력 조회
  Future<List<TrainerTransferModel>> getByMemberId(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('requestedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TrainerTransferModel.fromFirestore(doc))
        .toList();
  }

  /// 트레이너와 관련된 모든 전환 이력 조회 (발신/수신 모두)
  Future<List<TrainerTransferModel>> getByTrainerId(String trainerId) async {
    // fromTrainerId 조회
    final fromSnapshot = await collection
        .where('fromTrainerId', isEqualTo: trainerId)
        .orderBy('requestedAt', descending: true)
        .get();

    // toTrainerId 조회
    final toSnapshot = await collection
        .where('toTrainerId', isEqualTo: trainerId)
        .orderBy('requestedAt', descending: true)
        .get();

    // 중복 제거 후 병합
    final fromTransfers = fromSnapshot.docs
        .map((doc) => TrainerTransferModel.fromFirestore(doc))
        .toList();
    final toTransfers = toSnapshot.docs
        .map((doc) => TrainerTransferModel.fromFirestore(doc))
        .toList();

    final allTransfers = [...fromTransfers, ...toTransfers];
    final uniqueIds = <String>{};
    final uniqueTransfers = <TrainerTransferModel>[];

    for (final transfer in allTransfers) {
      if (!uniqueIds.contains(transfer.id)) {
        uniqueIds.add(transfer.id);
        uniqueTransfers.add(transfer);
      }
    }

    // 최신순 정렬
    uniqueTransfers.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));

    return uniqueTransfers;
  }

  /// 전환 요청 수락
  Future<void> acceptTransfer(String transferId) async {
    await collection.doc(transferId).update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 전환 요청 거절
  Future<void> rejectTransfer(String transferId) async {
    await collection.doc(transferId).update({
      'status': 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 전환 요청 취소
  Future<void> cancelTransfer(String transferId) async {
    await collection.doc(transferId).update({
      'status': 'cancelled',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }
}
