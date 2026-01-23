import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trainer_preset_model.dart';
import 'base_repository.dart';

/// TrainerPresetRepository Provider
final trainerPresetRepositoryProvider =
    Provider<TrainerPresetRepository>((ref) {
  return TrainerPresetRepository(firestore: ref.watch(firestoreProvider));
});

/// 트레이너 프리셋 Repository
/// 트레이너별 AI 커리큘럼 생성 기본 설정 관리
class TrainerPresetRepository extends BaseRepository<TrainerPresetModel> {
  TrainerPresetRepository({required super.firestore})
      : super(collectionPath: 'trainer_presets');

  @override
  Future<TrainerPresetModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return TrainerPresetModel.fromFirestore(doc);
  }

  @override
  Future<List<TrainerPresetModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => TrainerPresetModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(TrainerPresetModel preset) async {
    await collection.doc(preset.trainerId).set(preset.toFirestore());
    return preset.trainerId;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<TrainerPresetModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return TrainerPresetModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<TrainerPresetModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TrainerPresetModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 트레이너 ID로 프리셋 조회 (문서 ID = trainerId)
  Future<TrainerPresetModel?> getByTrainerId(String trainerId) async {
    return get(trainerId);
  }

  /// 트레이너 ID로 프리셋 실시간 감시
  Stream<TrainerPresetModel?> watchByTrainerId(String trainerId) {
    return watch(trainerId);
  }

  /// 프리셋 생성 또는 업데이트 (Upsert)
  Future<void> createOrUpdate(TrainerPresetModel preset) async {
    await collection.doc(preset.trainerId).set(
          preset.toFirestore(),
          SetOptions(merge: true),
        );
  }
}
