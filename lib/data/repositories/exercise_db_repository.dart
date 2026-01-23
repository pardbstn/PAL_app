import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_db_model.dart';
import 'base_repository.dart';

/// ExerciseDbRepository Provider
final exerciseDbRepositoryProvider = Provider<ExerciseDbRepository>((ref) {
  return ExerciseDbRepository(firestore: ref.watch(firestoreProvider));
});

/// 운동 DB Repository
/// /exercises 컬렉션 - 800개 한국어 번역 운동 데이터
class ExerciseDbRepository extends BaseRepository<ExerciseDbModel> {
  ExerciseDbRepository({required super.firestore})
      : super(collectionPath: 'exercises');

  @override
  Future<ExerciseDbModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return ExerciseDbModel.fromFirestore(doc);
  }

  @override
  Future<List<ExerciseDbModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => ExerciseDbModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(ExerciseDbModel exercise) async {
    final docRef = await collection.add(exercise.toFirestore());
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
  Stream<ExerciseDbModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ExerciseDbModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<ExerciseDbModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ExerciseDbModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 키워드로 운동 검색
  /// nameKo가 keyword로 시작하거나 tags 배열에 keyword가 포함된 결과를 반환
  Future<List<ExerciseDbModel>> searchByKeyword(
    String keyword, {
    int limit = 10,
  }) async {
    // nameKo가 keyword로 시작하는 운동 검색
    final nameSnapshot = await collection
        .where('nameKo', isGreaterThanOrEqualTo: keyword)
        .where('nameKo', isLessThanOrEqualTo: '$keyword\uf8ff')
        .limit(limit)
        .get();

    // tags 배열에 keyword가 포함된 운동 검색
    final tagSnapshot = await collection
        .where('tags', arrayContains: keyword)
        .limit(limit)
        .get();

    // 결과 병합 및 중복 제거
    final Map<String, ExerciseDbModel> resultMap = {};

    for (final doc in nameSnapshot.docs) {
      final exercise = ExerciseDbModel.fromFirestore(doc);
      resultMap[exercise.id] = exercise;
    }

    for (final doc in tagSnapshot.docs) {
      final exercise = ExerciseDbModel.fromFirestore(doc);
      resultMap[exercise.id] = exercise;
    }

    // limit 개수만큼 반환
    return resultMap.values.take(limit).toList();
  }

  /// 주요 근육군으로 운동 조회
  Future<List<ExerciseDbModel>> getByPrimaryMuscle(
    String muscle, {
    int limit = 20,
  }) async {
    final snapshot = await collection
        .where('primaryMuscle', isEqualTo: muscle)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => ExerciseDbModel.fromFirestore(doc))
        .toList();
  }

  /// 여러 ID로 운동 일괄 조회
  Future<List<ExerciseDbModel>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final futures = ids.map((id) => collection.doc(id).get());
    final docs = await Future.wait(futures);

    return docs
        .where((doc) => doc.exists)
        .map((doc) => ExerciseDbModel.fromFirestore(doc))
        .toList();
  }

  /// 대체 운동 추천
  /// 동일한 primaryMuscle을 가진 운동 중 제외 목록을 뺀 결과 반환
  Future<List<ExerciseDbModel>> getAlternatives(
    String exerciseId,
    List<String> excludedIds, {
    int limit = 5,
  }) async {
    // 현재 운동의 primaryMuscle 조회
    final exercise = await get(exerciseId);
    if (exercise == null) return [];

    // 같은 primaryMuscle을 가진 운동 조회 (제외 목록보다 넉넉하게 가져옴)
    final snapshot = await collection
        .where('primaryMuscle', isEqualTo: exercise.primaryMuscle)
        .limit(limit + excludedIds.length + 1)
        .get();

    // 제외 목록 필터링 (Firestore not-in은 10개 제한이므로 인메모리 필터링)
    final allExcluded = {...excludedIds, exerciseId};
    return snapshot.docs
        .map((doc) => ExerciseDbModel.fromFirestore(doc))
        .where((e) => !allExcluded.contains(e.id))
        .take(limit)
        .toList();
  }
}
