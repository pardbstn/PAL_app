import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reregistration_alert_model.dart';
import 'base_repository.dart';

final reregistrationAlertRepositoryProvider = Provider<ReregistrationAlertRepository>((ref) {
  return ReregistrationAlertRepository(firestore: ref.watch(firestoreProvider));
});

class ReregistrationAlertRepository extends BaseRepository<ReregistrationAlertModel> {
  ReregistrationAlertRepository({required super.firestore})
      : super(collectionPath: 'reregistration_alerts');

  @override
  Future<ReregistrationAlertModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return ReregistrationAlertModel.fromFirestore(doc);
  }

  @override
  Future<List<ReregistrationAlertModel>> getAll() async {
    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => ReregistrationAlertModel.fromFirestore(doc)).toList();
  }

  /// 알림 생성
  @override
  Future<String> create(ReregistrationAlertModel alert) async {
    final docRef = await collection.add(alert.toFirestore());
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
  Stream<ReregistrationAlertModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ReregistrationAlertModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<ReregistrationAlertModel>> watchAll() {
    return collection.orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReregistrationAlertModel.fromFirestore(doc)).toList());
  }

  /// 회원별 알림 조회
  Future<ReregistrationAlertModel?> getByMemberId(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return ReregistrationAlertModel.fromFirestore(snapshot.docs.first);
  }

  /// 트레이너별 대기 중인 알림 목록
  Future<List<ReregistrationAlertModel>> getPendingByTrainerId(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .where('reregistered', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ReregistrationAlertModel.fromFirestore(doc))
        .toList();
  }

  /// 트레이너별 알림 실시간 감시
  Stream<List<ReregistrationAlertModel>> watchByTrainerId(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .where('reregistered', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReregistrationAlertModel.fromFirestore(doc))
            .toList());
  }

  /// 알림 발송 시간 업데이트
  Future<void> markAlertSent(String alertId) async {
    await collection.doc(alertId).update({
      'alertSentAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// 재등록 완료 처리
  Future<void> markAsReregistered(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('reregistered', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'reregistered': true});
    }
    await batch.commit();
  }

  /// 진행률 업데이트
  Future<void> updateProgress(String memberId, int completed, int total) async {
    final alert = await getByMemberId(memberId);
    if (alert == null) return;

    await collection.doc(alert.id).update({
      'completedSessions': completed,
      'totalSessions': total,
      'progressRate': completed / total,
    });
  }

  /// 80% 이상 도달하고 알림 미발송인 회원 목록
  Future<List<ReregistrationAlertModel>> getReadyToAlert() async {
    final snapshot = await collection
        .where('progressRate', isGreaterThanOrEqualTo: 0.8)
        .where('alertSentAt', isNull: true)
        .where('reregistered', isEqualTo: false)
        .get();
    return snapshot.docs
        .map((doc) => ReregistrationAlertModel.fromFirestore(doc))
        .toList();
  }
}
