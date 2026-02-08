import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/workout_log_model.dart';
import 'package:flutter_pal_app/data/repositories/base_repository.dart';

/// WorkoutLogRepository Provider
final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository(firestore: ref.watch(firestoreProvider));
});

/// 운동 기록 Repository
class WorkoutLogRepository extends BaseRepository<WorkoutLogModel> {
  WorkoutLogRepository({required super.firestore})
    : super(collectionPath: 'workout_logs');

  @override
  Future<WorkoutLogModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return WorkoutLogModel.fromFirestore(doc);
  }

  @override
  Future<List<WorkoutLogModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => WorkoutLogModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(WorkoutLogModel log) async {
    final docRef = await collection.add(log.toFirestore());
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
  Stream<WorkoutLogModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return WorkoutLogModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<WorkoutLogModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutLogModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 사용자의 운동 기록 목록 (최신순, 클라이언트 사이드 정렬)
  Future<List<WorkoutLogModel>> getByUserId(String userId, {int? limit}) async {
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .get();
    final logs = snapshot.docs
        .map((doc) => WorkoutLogModel.fromFirestore(doc))
        .toList()
      ..sort((a, b) => b.workoutDate.compareTo(a.workoutDate));

    if (limit != null && logs.length > limit) {
      return logs.sublist(0, limit);
    }
    return logs;
  }

  /// 사용자의 운동 기록 실시간 감시 (최신순, 클라이언트 사이드 정렬)
  Stream<List<WorkoutLogModel>> watchByUserId(String userId, {int? limit}) {
    return collection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => WorkoutLogModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.workoutDate.compareTo(a.workoutDate));

      if (limit != null && logs.length > limit) {
        return logs.sublist(0, limit);
      }
      return logs;
    });
  }

  /// 날짜 범위로 운동 기록 조회 (클라이언트 사이드 필터링/정렬)
  Future<List<WorkoutLogModel>> getByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .get();
    final logs = snapshot.docs
        .map((doc) => WorkoutLogModel.fromFirestore(doc))
        .where((log) =>
            !log.workoutDate.isBefore(startDate) &&
            !log.workoutDate.isAfter(endDate))
        .toList()
      ..sort((a, b) => a.workoutDate.compareTo(b.workoutDate));
    return logs;
  }

  /// 특정 날짜의 운동 기록 가져오기 (클라이언트 사이드 필터링)
  Future<List<WorkoutLogModel>> getByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await collection
        .where('userId', isEqualTo: userId)
        .get();
    final logs = snapshot.docs
        .map((doc) => WorkoutLogModel.fromFirestore(doc))
        .where((log) =>
            !log.workoutDate.isBefore(startOfDay) &&
            log.workoutDate.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.workoutDate.compareTo(a.workoutDate));
    return logs;
  }

  /// 이번 주 운동 기록 가져오기
  Future<List<WorkoutLogModel>> getWeeklySummary(String userId) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfDay.add(const Duration(days: 7));

    return getByDateRange(userId, startOfDay, endOfWeek);
  }

  /// 월별 운동 기록 가져오기
  Future<List<WorkoutLogModel>> getMonthlySummary(
    String userId,
    int year,
    int month,
  ) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return getByDateRange(userId, startOfMonth, endOfMonth);
  }

  /// 기간별 총 운동 시간 계산 (분)
  Future<int> getTotalDurationForPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final logs = await getByDateRange(userId, startDate, endDate);
    return logs.fold<int>(0, (total, log) => total + log.durationMinutes);
  }
}
