import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/curriculum_template_model.dart';
import '../models/member_model.dart';
import 'base_repository.dart';

/// CurriculumTemplateRepository Provider
final curriculumTemplateRepositoryProvider =
    Provider<CurriculumTemplateRepository>((ref) {
  return CurriculumTemplateRepository(firestore: ref.watch(firestoreProvider));
});

/// 커리큘럼 템플릿 Repository
class CurriculumTemplateRepository
    extends BaseRepository<CurriculumTemplateModel> {
  CurriculumTemplateRepository({required super.firestore})
      : super(collectionPath: 'curriculum_templates');

  @override
  Future<CurriculumTemplateModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return CurriculumTemplateModel.fromFirestore(doc);
  }

  @override
  Future<List<CurriculumTemplateModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => CurriculumTemplateModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(CurriculumTemplateModel template) async {
    final docRef = await collection.add(template.toFirestore());
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
  Stream<CurriculumTemplateModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return CurriculumTemplateModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<CurriculumTemplateModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CurriculumTemplateModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 트레이너별 템플릿 목록 가져오기 (클라이언트 측 정렬로 인덱스 불필요)
  Future<List<CurriculumTemplateModel>> getByTrainerId(String trainerId) async {
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .get();
    final templates = snapshot.docs
        .map((doc) => CurriculumTemplateModel.fromFirestore(doc))
        .toList();
    // 클라이언트 측 정렬 (최신순)
    templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return templates;
  }

  /// 트레이너별 템플릿 실시간 감시 (클라이언트 측 정렬로 인덱스 불필요)
  Stream<List<CurriculumTemplateModel>> watchByTrainerId(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      final templates = snapshot.docs
          .map((doc) => CurriculumTemplateModel.fromFirestore(doc))
          .toList();
      // 클라이언트 측 정렬 (최신순)
      templates.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return templates;
    });
  }

  /// 목표와 경험 수준으로 템플릿 필터링 (클라이언트 측 정렬로 인덱스 불필요)
  Future<List<CurriculumTemplateModel>> getByGoalAndExperience({
    required String trainerId,
    required FitnessGoal goal,
    required ExperienceLevel experience,
  }) async {
    // 트레이너 템플릿만 가져온 후 클라이언트에서 필터링
    final snapshot = await collection
        .where('trainerId', isEqualTo: trainerId)
        .get();
    final templates = snapshot.docs
        .map((doc) => CurriculumTemplateModel.fromFirestore(doc))
        .where((t) => t.goal == goal && t.experience == experience)
        .toList();
    // 클라이언트 측 정렬 (사용 횟수순)
    templates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return templates;
  }

  /// 사용 횟수 증가
  Future<void> incrementUsageCount(String id) async {
    await collection.doc(id).update({
      'usageCount': FieldValue.increment(1),
    });
  }

  /// 템플릿 이름 수정
  Future<void> updateName(String id, String name) async {
    await collection.doc(id).update({
      'name': name,
      'updatedAt': Timestamp.now(),
    });
  }
}
