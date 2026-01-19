import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session_signature_model.dart';
import 'base_repository.dart';

/// SessionSignatureRepository Provider
final sessionSignatureRepositoryProvider =
    Provider<SessionSignatureRepository>((ref) {
  return SessionSignatureRepository(firestore: ref.watch(firestoreProvider));
});

/// 수업 서명 Repository
class SessionSignatureRepository extends BaseRepository<SessionSignatureModel> {
  SessionSignatureRepository({required super.firestore})
      : super(collectionPath: 'session_signatures');

  @override
  Future<SessionSignatureModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return SessionSignatureModel.fromFirestore(doc);
  }

  @override
  Future<List<SessionSignatureModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => SessionSignatureModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(SessionSignatureModel signature) async {
    final docRef = await collection.add(signature.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<SessionSignatureModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return SessionSignatureModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<SessionSignatureModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionSignatureModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 서명 기록 목록
  Future<List<SessionSignatureModel>> getByMemberId(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('sessionNumber', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => SessionSignatureModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 서명 기록 실시간 감시
  Stream<List<SessionSignatureModel>> watchByMemberId(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('sessionNumber', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionSignatureModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 특정 커리큘럼의 서명 조회
  Future<SessionSignatureModel?> getByCurriculumId(String curriculumId) async {
    final snapshot = await collection
        .where('curriculumId', isEqualTo: curriculumId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return SessionSignatureModel.fromFirestore(snapshot.docs.first);
  }

  /// 특정 커리큘럼의 서명 실시간 감시
  Stream<SessionSignatureModel?> watchByCurriculumId(String curriculumId) {
    return collection
        .where('curriculumId', isEqualTo: curriculumId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return SessionSignatureModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// 트레이너의 모든 서명 기록
  Future<List<SessionSignatureModel>> getByTrainerId(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('signedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => SessionSignatureModel.fromFirestore(doc))
        .toList();
  }

  /// 날짜 범위로 서명 기록 조회
  Future<List<SessionSignatureModel>> getByDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('signedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('signedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('signedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => SessionSignatureModel.fromFirestore(doc))
        .toList();
  }
}
