import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/curriculum_model.dart';
import 'package:flutter_pal_app/data/repositories/curriculum_repository.dart';
import 'package:flutter_pal_app/data/repositories/member_repository.dart';

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

  /// 커리큘럼 추가 (연장)
  /// [memberId] 회원 ID
  /// [trainerId] 트레이너 ID
  /// [additionalSessions] 추가할 회차 수 (최대 50)
  /// [curriculums] AI로 생성된 커리큘럼 목록 (선택사항)
  Future<void> addAdditionalSessions({
    required String memberId,
    required String trainerId,
    required int additionalSessions,
    List<CurriculumModel>? curriculums,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 현재 최대 회차 번호 가져오기
      final maxSession = await _repository.getMaxSessionNumber(memberId);
      final startSession = maxSession + 1;
      final endSession = startSession + additionalSessions - 1;

      // 최대 70회차까지만 허용
      if (endSession > 70) {
        throw Exception('최대 70회차까지만 추가할 수 있어요');
      }

      // AI로 생성된 커리큘럼이 있으면 사용, 없으면 빈 커리큘럼 생성
      final now = DateTime.now();
      final newCurriculums = <CurriculumModel>[];

      if (curriculums != null && curriculums.isNotEmpty) {
        // AI 생성 커리큘럼 사용 - 회차 번호 재조정
        for (int i = 0; i < curriculums.length && i < additionalSessions; i++) {
          final curriculum = curriculums[i];
          newCurriculums.add(curriculum.copyWith(
            id: '',
            memberId: memberId,
            trainerId: trainerId,
            sessionNumber: startSession + i,
            createdAt: now,
            updatedAt: now,
          ));
        }
        // AI 생성된 커리큘럼 수가 부족하면 나머지는 빈 커리큘럼
        for (int i = newCurriculums.length; i < additionalSessions; i++) {
          newCurriculums.add(CurriculumModel(
            id: '',
            memberId: memberId,
            trainerId: trainerId,
            sessionNumber: startSession + i,
            title: '${startSession + i}회차',
            exercises: [],
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ));
        }
      } else {
        // 빈 커리큘럼 생성
        for (int i = startSession; i <= endSession; i++) {
          newCurriculums.add(CurriculumModel(
            id: '',
            memberId: memberId,
            trainerId: trainerId,
            sessionNumber: i,
            title: '$i회차',
            exercises: [],
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
          ));
        }
      }

      // 일괄 생성
      await _repository.createBatch(newCurriculums);

      // 회원의 totalSessions 업데이트
      final memberRepository = ref.read(memberRepositoryProvider);
      final member = await memberRepository.get(memberId);
      if (member != null) {
        final newTotalSessions = member.ptInfo.totalSessions + additionalSessions;
        await memberRepository.updateSessionProgress(
          memberId,
          totalSessions: newTotalSessions,
        );
      }

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
