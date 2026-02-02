import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_model.dart';
import 'base_repository.dart';

/// TrainerRepository Provider
final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  return TrainerRepository(firestore: ref.watch(firestoreProvider));
});

/// 트레이너 Repository
class TrainerRepository extends BaseRepository<TrainerModel> {
  TrainerRepository({required super.firestore})
      : super(collectionPath: 'trainers');

  @override
  Future<TrainerModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return TrainerModel.fromFirestore(doc);
  }

  @override
  Future<List<TrainerModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => TrainerModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(TrainerModel trainer) async {
    final docRef = await collection.add(trainer.toFirestore());
    return docRef.id;
  }

  /// 사용자 ID로 트레이너 생성
  Future<String> createForUser(String userId) async {
    final now = DateTime.now();
    final trainer = TrainerModel(
      id: '',
      userId: userId,
      subscriptionTier: SubscriptionTier.free,
      memberIds: [],
      aiUsage: AiUsage(
        curriculumCount: 0,
        predictionCount: 0,
        resetDate: DateTime(now.year, now.month, 1),
      ),
    );
    return create(trainer);
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
  Stream<TrainerModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<TrainerModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainerModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 사용자 ID로 트레이너 찾기
  Future<TrainerModel?> getByUserId(String userId) async {
    final snapshot =
        await collection.where('userId', isEqualTo: userId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return TrainerModel.fromFirestore(snapshot.docs.first);
  }

  /// 사용자 ID로 트레이너 실시간 감시
  Stream<TrainerModel?> watchByUserId(String userId) {
    return collection
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return TrainerModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// 회원 추가
  Future<void> addMember(String trainerId, String memberId) async {
    await collection.doc(trainerId).update({
      'memberIds': FieldValue.arrayUnion([memberId]),
    });
  }

  /// 회원 제거
  Future<void> removeMember(String trainerId, String memberId) async {
    await collection.doc(trainerId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
    });
  }

  /// 회원을 다른 트레이너로 이전
  Future<void> transferMember(
    String fromTrainerId,
    String toTrainerId,
    String memberId,
  ) async {
    // 기존 트레이너에서 제거
    await removeMember(fromTrainerId, memberId);
    // 새 트레이너에 추가
    await addMember(toTrainerId, memberId);
  }

  /// AI 사용량 증가
  Future<void> incrementAiUsage(
    String trainerId, {
    bool curriculum = false,
    bool prediction = false,
  }) async {
    final updates = <String, dynamic>{};
    if (curriculum) {
      updates['aiUsage.curriculumCount'] = FieldValue.increment(1);
    }
    if (prediction) {
      updates['aiUsage.predictionCount'] = FieldValue.increment(1);
    }
    if (updates.isNotEmpty) {
      await collection.doc(trainerId).update(updates);
    }
  }

  /// 구독 티어 변경
  Future<void> updateSubscriptionTier(
    String trainerId,
    SubscriptionTier tier,
  ) async {
    await collection.doc(trainerId).update({
      'subscriptionTier': tier.name,
    });
  }
}
