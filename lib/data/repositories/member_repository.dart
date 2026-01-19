import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member_model.dart';
import 'base_repository.dart';

/// MemberRepository Provider
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(firestore: ref.watch(firestoreProvider));
});

/// 회원 Repository
class MemberRepository extends BaseRepository<MemberModel> {
  MemberRepository({required super.firestore})
      : super(collectionPath: 'members');

  @override
  Future<MemberModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return MemberModel.fromFirestore(doc);
  }

  @override
  Future<List<MemberModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => MemberModel.fromFirestore(doc)).toList();
  }

  @override
  Future<String> create(MemberModel member) async {
    final docRef = await collection.add(member.toFirestore());
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
  Stream<MemberModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return MemberModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<MemberModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 사용자 ID로 회원 찾기
  Future<MemberModel?> getByUserId(String userId) async {
    final snapshot =
        await collection.where('userId', isEqualTo: userId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return MemberModel.fromFirestore(snapshot.docs.first);
  }

  /// 사용자 ID로 회원 실시간 감시
  Stream<MemberModel?> watchByUserId(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return MemberModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// 트레이너의 회원 목록
  Future<List<MemberModel>> getByTrainerId(String trainerId) async {
    final snapshot =
        await collection.where('trainerId', isEqualTo: trainerId).get();
    return snapshot.docs.map((doc) => MemberModel.fromFirestore(doc)).toList();
  }

  /// 트레이너의 회원 목록 실시간 감시
  Stream<List<MemberModel>> watchByTrainerId(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MemberModel.fromFirestore(doc))
          .toList();
    });
  }

  /// PT 회차 업데이트
  Future<void> updateSessionProgress(
    String memberId, {
    int? completedSessions,
    int? totalSessions,
  }) async {
    final updates = <String, dynamic>{};
    if (completedSessions != null) {
      updates['ptInfo.completedSessions'] = completedSessions;
    }
    if (totalSessions != null) {
      updates['ptInfo.totalSessions'] = totalSessions;
    }
    if (updates.isNotEmpty) {
      await collection.doc(memberId).update(updates);
    }
  }

  /// PT 회차 1회 증가
  Future<void> incrementCompletedSession(String memberId) async {
    await collection.doc(memberId).update({
      'ptInfo.completedSessions': FieldValue.increment(1),
    });
  }

  /// 목표 변경
  Future<void> updateGoal(String memberId, FitnessGoal goal) async {
    await collection.doc(memberId).update({
      'goal': goal.name,
    });
  }

  /// 목표 체중 업데이트
  Future<void> updateTargetWeight(String memberId, double weight) async {
    await collection.doc(memberId).update({
      'targetWeight': weight,
    });
  }

  /// 트레이너 메모 업데이트
  Future<void> updateMemo(String memberId, String memo) async {
    await collection.doc(memberId).update({
      'memo': memo,
    });
  }
}
