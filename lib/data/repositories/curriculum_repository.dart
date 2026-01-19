import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curriculum_model.dart';
import 'base_repository.dart';

/// CurriculumRepository Provider
final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return CurriculumRepository(firestore: ref.watch(firestoreProvider));
});

/// 커리큘럼 Repository
class CurriculumRepository extends BaseRepository<CurriculumModel> {
  CurriculumRepository({required super.firestore})
      : super(collectionPath: 'curriculums');

  @override
  Future<CurriculumModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return CurriculumModel.fromFirestore(doc);
  }

  @override
  Future<List<CurriculumModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => CurriculumModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(CurriculumModel curriculum) async {
    final docRef = await collection.add(curriculum.toFirestore());
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
  Stream<CurriculumModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CurriculumModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<CurriculumModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CurriculumModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 커리큘럼 목록
  Future<List<CurriculumModel>> getByMemberId(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('sessionNumber')
        .get();
    return snapshot.docs
        .map((doc) => CurriculumModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 커리큘럼 목록 실시간 감시
  Stream<List<CurriculumModel>> watchByMemberId(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('sessionNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CurriculumModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 트레이너의 모든 커리큘럼 목록
  Future<List<CurriculumModel>> getByTrainerId(String trainerId) async {
    final snapshot =
        await collection.where('trainerId', isEqualTo: trainerId).get();
    return snapshot.docs
        .map((doc) => CurriculumModel.fromFirestore(doc))
        .toList();
  }

  /// 특정 회원의 특정 회차 커리큘럼
  Future<CurriculumModel?> getByMemberAndSession(
    String memberId,
    int sessionNumber,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('sessionNumber', isEqualTo: sessionNumber)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return CurriculumModel.fromFirestore(snapshot.docs.first);
  }

  /// 다음 회차 번호 가져오기
  Future<int> getNextSessionNumber(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('sessionNumber', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return 1;
    final lastCurriculum = CurriculumModel.fromFirestore(snapshot.docs.first);
    return lastCurriculum.sessionNumber + 1;
  }

  /// 커리큘럼 완료 처리
  Future<void> markAsCompleted(String id) async {
    await collection.doc(id).update({
      'isCompleted': true,
      'completedDate': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 커리큘럼 미완료 처리
  Future<void> markAsIncomplete(String id) async {
    await collection.doc(id).update({
      'isCompleted': false,
      'completedDate': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 운동 목록 업데이트
  Future<void> updateExercises(String id, List<Exercise> exercises) async {
    await collection.doc(id).update({
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 예정 날짜 업데이트
  Future<void> updateScheduledDate(String id, DateTime date) async {
    await collection.doc(id).update({
      'scheduledDate': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 미완료 커리큘럼 목록 (회원별)
  Future<List<CurriculumModel>> getIncompleteByMemberId(
    String memberId,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('isCompleted', isEqualTo: false)
        .orderBy('sessionNumber')
        .get();
    return snapshot.docs
        .map((doc) => CurriculumModel.fromFirestore(doc))
        .toList();
  }

  /// 날짜 범위로 커리큘럼 조회
  Future<List<CurriculumModel>> getByDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('scheduledDate', isGreaterThanOrEqualTo: startDate)
        .where('scheduledDate', isLessThanOrEqualTo: endDate)
        .get();
    return snapshot.docs
        .map((doc) => CurriculumModel.fromFirestore(doc))
        .toList();
  }
}
