import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/core/constants/exercise_constants.dart';
import 'package:flutter_pal_app/data/models/exercise_db_model.dart';

/// 대체 운동 결과
class AlternativeExercise {
  final String exerciseId;
  final String name;
  final String equipment;
  final String primaryMuscle;
  final String reason;

  const AlternativeExercise({
    required this.exerciseId,
    required this.name,
    required this.equipment,
    required this.primaryMuscle,
    required this.reason,
  });
}

/// 운동 검색 Provider (로컬 데이터 검색)
final exerciseSearchProvider =
    FutureProvider.family<List<ExerciseDbModel>, String>((ref, keyword) async {
  if (keyword.trim().isEmpty) return [];

  final query = keyword.trim().toLowerCase();

  final results = ExerciseConstants.exercises.where((ex) {
    final name = (ex['nameKo'] as String? ?? '').toLowerCase();
    final equipment = (ex['equipment'] as String? ?? '').toLowerCase();
    final muscle = (ex['primaryMuscle'] as String? ?? '').toLowerCase();
    return name.contains(query) ||
        equipment.contains(query) ||
        muscle.contains(query);
  }).take(10).toList();

  return results.map((ex) {
    return ExerciseDbModel(
      id: ex['id']?.toString() ?? '',
      nameKo: ex['nameKo']?.toString() ?? '',
      nameEn: '',
      equipment: ex['equipment']?.toString() ?? '',
      primaryMuscle: ex['primaryMuscle']?.toString() ?? '',
      secondaryMuscles: const [],
      level: ex['level']?.toString() ?? '',
    );
  }).toList();
});

/// 대체 운동 요청 파라미터
class AlternativeRequest {
  final String exerciseId;
  final List<String> excludedIds;

  const AlternativeRequest({
    required this.exerciseId,
    this.excludedIds = const [],
  });

  @override
  bool operator ==(Object other) =>
      other is AlternativeRequest &&
      other.exerciseId == exerciseId;

  @override
  int get hashCode => exerciseId.hashCode;
}

/// 대체 운동 추천 Provider (로컬 데이터 기반)
final alternativeExercisesProvider =
    FutureProvider.family<List<AlternativeExercise>, AlternativeRequest>(
        (ref, request) async {
  // 현재 운동의 근육군 찾기
  final currentExercise = ExerciseConstants.exercises.firstWhere(
    (ex) => ex['id'] == request.exerciseId,
    orElse: () => <String, dynamic>{},
  );

  if (currentExercise.isEmpty) return [];

  final targetMuscle = currentExercise['primaryMuscle'] as String? ?? '';
  final currentName = currentExercise['nameKo'] as String? ?? '';

  // 같은 근육군에서 제외 목록과 현재 운동을 빼고 3개 추천
  final allExcluded = [...request.excludedIds, request.exerciseId];
  final alternatives = ExerciseConstants.exercises
      .where((ex) =>
          ex['primaryMuscle'] == targetMuscle &&
          !allExcluded.contains(ex['id']))
      .take(3)
      .map((ex) {
    final name = ex['nameKo']?.toString() ?? '';
    final equipment = ex['equipment']?.toString() ?? '';
    return AlternativeExercise(
      exerciseId: ex['id']?.toString() ?? '',
      name: name,
      equipment: equipment,
      primaryMuscle: targetMuscle,
      reason: '$currentName 대신 $equipment을(를) 사용한 $targetMuscle 운동',
    );
  }).toList();

  return alternatives;
});
