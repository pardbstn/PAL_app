import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/schedule_model.dart';
import 'package:flutter_pal_app/data/repositories/schedule_repository.dart';

/// 오늘 일정 Provider (트레이너용) - 실시간 스트림
final todaySchedulesProvider =
    StreamProvider.family<List<ScheduleModel>, String>((ref, trainerId) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.todaySchedulesStream(trainerId);
});

/// 월별 일정 Provider (autoDispose로 캐시 관리)
final monthSchedulesProvider = FutureProvider.autoDispose
    .family<List<ScheduleModel>, MonthScheduleParams>((ref, params) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedulesForMonth(params.trainerId, params.month);
});

/// 회원 일정 Provider (실시간 스트림)
final memberSchedulesProvider =
    StreamProvider.family<List<ScheduleModel>, String>((ref, memberId) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.memberSchedulesStream(memberId);
});

/// 회원의 다음 PT 일정 Provider (홈화면용)
final nextMemberPtScheduleProvider =
    StreamProvider.family<ScheduleModel?, String>((ref, memberId) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.memberSchedulesStream(memberId).map((schedules) {
    final now = DateTime.now();
    // PT 일정만 필터링, 예정된 상태, 현재 시간 이후
    final upcomingPt = schedules
        .where((s) =>
            s.scheduleType == ScheduleType.pt &&
            s.status == ScheduleStatus.scheduled &&
            s.scheduledAt.isAfter(now))
        .toList();

    if (upcomingPt.isEmpty) return null;

    // 가장 빠른 일정 반환
    upcomingPt.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return upcomingPt.first;
  });
});

/// 일정 상태 클래스
class ScheduleState {
  final List<ScheduleModel> schedules;
  final bool isLoading;
  final String? error;

  const ScheduleState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  ScheduleState copyWith({
    List<ScheduleModel>? schedules,
    bool? isLoading,
    String? error,
  }) {
    return ScheduleState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 일정 관리 Notifier
class ScheduleNotifier extends Notifier<ScheduleState> {
  late ScheduleRepository _repository;
  late String _trainerId;
  DateTime _currentMonth = DateTime.now();

  @override
  ScheduleState build() {
    return const ScheduleState(isLoading: true);
  }

  void initialize(String trainerId) {
    _trainerId = trainerId;
    _repository = ref.read(scheduleRepositoryProvider);
    loadMonthSchedules();
  }

  DateTime get currentMonth => _currentMonth;

  /// 월별 일정 로드
  Future<void> loadMonthSchedules() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final schedules =
          await _repository.getSchedulesForMonth(_trainerId, _currentMonth);
      state = state.copyWith(schedules: schedules, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// 월 변경
  Future<void> changeMonth(DateTime month) async {
    _currentMonth = month;
    await loadMonthSchedules();
  }

  /// 일정 추가
  Future<void> addSchedule(ScheduleModel schedule) async {
    await _repository.addSchedule(schedule);
    await loadMonthSchedules();
  }

  /// 일정 완료
  Future<void> completeSchedule(String scheduleId) async {
    await _repository.completeSchedule(scheduleId);
    await loadMonthSchedules();
  }

  /// 일정 상태 변경
  Future<void> updateScheduleStatus(
      String scheduleId, ScheduleStatus status) async {
    await _repository.updateScheduleStatus(scheduleId, status);
    await loadMonthSchedules();
  }

  /// 일정 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    await _repository.deleteSchedule(scheduleId);
    await loadMonthSchedules();
  }

  /// 그룹 일정 삭제
  Future<void> deleteScheduleGroup(String groupId) async {
    await _repository.deleteScheduleGroup(groupId);
    await loadMonthSchedules();
  }
}

/// Notifier Provider
final scheduleNotifierProvider =
    NotifierProvider<ScheduleNotifier, ScheduleState>(ScheduleNotifier.new);

/// Helper class for month schedule params
class MonthScheduleParams {
  final String trainerId;
  final DateTime month;

  MonthScheduleParams({required this.trainerId, required this.month});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonthScheduleParams &&
        other.trainerId == trainerId &&
        other.month.year == month.year &&
        other.month.month == month.month;
  }

  @override
  int get hashCode =>
      trainerId.hashCode ^ month.year.hashCode ^ month.month.hashCode;
}
