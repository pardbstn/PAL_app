import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';

/// 회원의 커리큘럼 목록 (실시간 스트림)
final curriculumsProvider =
    StreamProvider.family<List<CurriculumModel>, String>((ref, memberId) {
  final repository = ref.watch(curriculumRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchByMemberId(memberId);
});

/// 다음 진행할 커리큘럼 (미완료 중 가장 낮은 회차)
final nextCurriculumProvider =
    Provider.family<AsyncValue<CurriculumModel?>, String>((ref, memberId) {
  final curriculumsAsync = ref.watch(curriculumsProvider(memberId));

  return curriculumsAsync.whenData((curriculums) {
    if (curriculums.isEmpty) return null;

    // 미완료 커리큘럼 중 가장 낮은 회차
    final incomplete = curriculums.where((c) => !c.isCompleted).toList();
    if (incomplete.isEmpty) return null;

    // sessionNumber 기준 정렬 (이미 정렬되어 있지만 확실히)
    incomplete.sort((a, b) => a.sessionNumber.compareTo(b.sessionNumber));
    return incomplete.first;
  });
});

/// 완료된 커리큘럼 수
final completedCurriculumsCountProvider =
    Provider.family<AsyncValue<int>, String>((ref, memberId) {
  final curriculumsAsync = ref.watch(curriculumsProvider(memberId));

  return curriculumsAsync.whenData((curriculums) {
    return curriculums.where((c) => c.isCompleted).length;
  });
});

/// 커리큘럼 진행 통계
final curriculumStatsProvider =
    Provider.family<AsyncValue<CurriculumStats>, String>((ref, memberId) {
  final curriculumsAsync = ref.watch(curriculumsProvider(memberId));

  return curriculumsAsync.whenData((curriculums) {
    final total = curriculums.length;
    final completed = curriculums.where((c) => c.isCompleted).length;
    final incomplete = total - completed;

    return CurriculumStats(
      total: total,
      completed: completed,
      incomplete: incomplete,
      progressRate: total > 0 ? completed / total : 0.0,
    );
  });
});

/// 커리큘럼 통계 데이터 클래스
class CurriculumStats {
  final int total;
  final int completed;
  final int incomplete;
  final double progressRate;

  const CurriculumStats({
    required this.total,
    required this.completed,
    required this.incomplete,
    required this.progressRate,
  });
}

/// 커리큘럼 관리 Notifier (CRUD 액션)
class CurriculumsNotifier extends AsyncNotifier<void> {
  CurriculumRepository get _repository => ref.read(curriculumRepositoryProvider);

  @override
  Future<void> build() async {}

  /// 커리큘럼 완료 처리
  Future<void> markAsCompleted(String curriculumId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsCompleted(curriculumId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 커리큘럼 미완료 처리
  Future<void> markAsIncomplete(String curriculumId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.markAsIncomplete(curriculumId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 커리큘럼 삭제
  Future<void> deleteCurriculum(String curriculumId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(curriculumId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// 커리큘럼 관리 Provider
final curriculumsNotifierProvider =
    AsyncNotifierProvider<CurriculumsNotifier, void>(() {
  return CurriculumsNotifier();
});

/// 오늘 예정된 일정 데이터 클래스
class TodaySchedule {
  final String memberId;
  final String memberName;
  final CurriculumModel curriculum;

  const TodaySchedule({
    required this.memberId,
    required this.memberName,
    required this.curriculum,
  });
}
