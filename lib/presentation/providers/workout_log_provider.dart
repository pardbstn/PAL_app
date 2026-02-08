import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/workout_log_model.dart';
import 'package:flutter_pal_app/data/repositories/workout_log_repository.dart';

/// 사용자의 운동 기록 목록 (실시간 스트림)
final workoutLogsProvider =
    StreamProvider.family<List<WorkoutLogModel>, String>((ref, userId) {
      final repository = ref.watch(workoutLogRepositoryProvider);

      if (userId.isEmpty) {
        return Stream.value([]);
      }

      return repository.watchByUserId(userId, limit: 30);
    });

/// 오늘의 운동 기록
final todayWorkoutProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, userId) async {
      final repository = ref.watch(workoutLogRepositoryProvider);

      if (userId.isEmpty) {
        return [];
      }

      final today = DateTime.now();
      return repository.getByDate(userId, today);
    });

/// 주간 운동 요약 데이터
final weeklyWorkoutSummaryProvider =
    FutureProvider.family<WeeklyWorkoutSummary, String>((ref, userId) async {
      final repository = ref.watch(workoutLogRepositoryProvider);

      if (userId.isEmpty) {
        return const WeeklyWorkoutSummary(
          totalDurationMinutes: 0,
          workoutDays: 0,
          totalExercises: 0,
          logs: [],
        );
      }

      final logs = await repository.getWeeklySummary(userId);

      // 총 운동 시간
      final totalDuration = logs.fold<int>(
        0,
        (sum, log) => sum + log.durationMinutes,
      );

      // 운동한 일수 (중복 제거)
      final workoutDays = logs
          .map(
            (log) => DateTime(
              log.workoutDate.year,
              log.workoutDate.month,
              log.workoutDate.day,
            ),
          )
          .toSet()
          .length;

      // 총 운동 개수
      final totalExercises = logs.fold<int>(
        0,
        (sum, log) => sum + log.exercises.length,
      );

      return WeeklyWorkoutSummary(
        totalDurationMinutes: totalDuration,
        workoutDays: workoutDays,
        totalExercises: totalExercises,
        logs: logs,
      );
    });

/// 월별 운동 히스토리
final monthlyWorkoutHistoryProvider =
    FutureProvider.family<List<WorkoutLogModel>, MonthlyWorkoutParams>((
      ref,
      params,
    ) async {
      final repository = ref.watch(workoutLogRepositoryProvider);

      if (params.userId.isEmpty) {
        return [];
      }

      return repository.getMonthlySummary(
        params.userId,
        params.year,
        params.month,
      );
    });

/// 운동 기록 상태 관리 Notifier
class WorkoutLogNotifier extends AsyncNotifier<void> {
  WorkoutLogRepository get _repository => ref.read(workoutLogRepositoryProvider);

  @override
  Future<void> build() async {}

  /// 운동 기록 추가
  Future<String> addWorkoutLog(WorkoutLogModel log) async {
    state = const AsyncValue.loading();
    try {
      final id = await _repository.create(log);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 운동 기록 수정
  Future<void> updateWorkoutLog(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.update(id, data);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 운동 기록 삭제
  Future<void> deleteWorkoutLog(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.delete(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

/// WorkoutLogNotifier Provider
final workoutLogNotifierProvider =
    AsyncNotifierProvider<WorkoutLogNotifier, void>(() {
  return WorkoutLogNotifier();
});

/// 주간 운동 요약 데이터 클래스
class WeeklyWorkoutSummary {
  final int totalDurationMinutes;
  final int workoutDays;
  final int totalExercises;
  final List<WorkoutLogModel> logs;

  const WeeklyWorkoutSummary({
    required this.totalDurationMinutes,
    required this.workoutDays,
    required this.totalExercises,
    required this.logs,
  });
}

/// 월별 운동 조회 파라미터
class MonthlyWorkoutParams {
  final String userId;
  final int year;
  final int month;

  const MonthlyWorkoutParams({
    required this.userId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyWorkoutParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => Object.hash(userId, year, month);
}
