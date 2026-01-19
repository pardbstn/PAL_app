import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/schedule_model.dart';
import 'base_repository.dart';

/// ScheduleRepository Provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(firestore: ref.watch(firestoreProvider));
});

/// 일정 Repository
class ScheduleRepository {
  final FirebaseFirestore firestore;

  ScheduleRepository({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('schedules');

  /// 특정 날짜의 일정 조회
  Future<List<ScheduleModel>> getSchedulesForDay(
      String trainerId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    debugPrint('=== 일별 일정 조회 ===');
    debugPrint('trainerId: $trainerId');
    debugPrint('기간: $startOfDay ~ $endOfDay');

    // trainerId로만 쿼리 (복합 인덱스 불필요)
    final snapshot = await _collection
        .where('trainerId', isEqualTo: trainerId)
        .get();

    debugPrint('전체 일정 수: ${snapshot.docs.length}');

    // 클라이언트에서 날짜 필터링
    final schedules = snapshot.docs
        .map((doc) => _docToSchedule(doc))
        .where((schedule) {
          final scheduleDate = schedule.scheduledAt;
          return scheduleDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                 scheduleDate.isBefore(endOfDay);
        })
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    debugPrint('필터링된 일정 수: ${schedules.length}');
    for (final s in schedules) {
      debugPrint('  - ${s.memberName}: ${s.scheduledAt}');
    }

    return schedules;
  }

  /// 월별 일정 조회
  Future<List<ScheduleModel>> getSchedulesForMonth(
      String trainerId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    debugPrint('=== 월별 일정 조회 ===');
    debugPrint('trainerId: $trainerId');
    debugPrint('기간: $startOfMonth ~ $endOfMonth');

    // trainerId로만 먼저 조회 (복합 인덱스 문제 회피)
    final snapshot = await _collection
        .where('trainerId', isEqualTo: trainerId)
        .get();

    debugPrint('전체 일정 수: ${snapshot.docs.length}');

    // 클라이언트에서 날짜 필터링
    final schedules = snapshot.docs
        .map((doc) => _docToSchedule(doc))
        .where((schedule) {
          final date = schedule.scheduledAt;
          return date.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
                 date.isBefore(endOfMonth);
        })
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    debugPrint('필터링된 일정 수: ${schedules.length}');
    for (final s in schedules) {
      debugPrint('  - ${s.memberName}: ${s.scheduledAt}');
    }

    return schedules;
  }

  /// 회원의 일정 조회
  Future<List<ScheduleModel>> getMemberSchedules(String memberId) async {
    final snapshot =
        await _collection.where('memberId', isEqualTo: memberId).get();

    final schedules = snapshot.docs
        .map((doc) => _docToSchedule(doc))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return schedules;
  }

  /// 회원 일정 실시간 스트림
  Stream<List<ScheduleModel>> memberSchedulesStream(String memberId) {
    return _collection
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final schedules = snapshot.docs
          .map((doc) => _docToSchedule(doc))
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return schedules;
    });
  }

  /// 일정 추가
  Future<String> addSchedule(ScheduleModel schedule) async {
    debugPrint('=== 일정 저장 ===');
    debugPrint('trainerId: ${schedule.trainerId}');
    debugPrint('memberId: ${schedule.memberId}');
    debugPrint('memberName: ${schedule.memberName}');
    debugPrint('scheduledAt: ${schedule.scheduledAt}');

    final data = {
      'trainerId': schedule.trainerId,
      'memberId': schedule.memberId,
      'memberName': schedule.memberName,
      'scheduledAt': Timestamp.fromDate(schedule.scheduledAt),
      'duration': schedule.duration,
      'status': schedule.status.name,
      'scheduleType': schedule.scheduleType.name,
      'title': schedule.title,
      'note': schedule.note,
      'groupId': schedule.groupId,
      'createdAt': Timestamp.fromDate(schedule.createdAt),
    };

    final docRef = await _collection.add(data);
    debugPrint('저장 완료: ${docRef.id}');
    return docRef.id;
  }

  /// 일정 수정
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _collection.doc(schedule.id).update({
      'scheduledAt': Timestamp.fromDate(schedule.scheduledAt),
      'duration': schedule.duration,
      'status': schedule.status.name,
      'note': schedule.note,
    });
  }

  /// 일정 삭제
  Future<void> deleteSchedule(String scheduleId) async {
    await _collection.doc(scheduleId).delete();
  }

  /// 그룹 일정 삭제 (반복 일정 전체)
  Future<void> deleteScheduleGroup(String groupId) async {
    final snapshot =
        await _collection.where('groupId', isEqualTo: groupId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 일정 완료 처리
  Future<void> completeSchedule(String scheduleId) async {
    await _collection.doc(scheduleId).update({
      'status': ScheduleStatus.completed.name,
    });
  }

  /// 일정 상태 변경
  Future<void> updateScheduleStatus(
      String scheduleId, ScheduleStatus status) async {
    await _collection.doc(scheduleId).update({
      'status': status.name,
    });
  }

  /// 트레이너의 오늘 일정 실시간 스트림 (홈 화면용)
  /// 복합 인덱스 없이 클라이언트 필터링 방식 사용
  Stream<List<ScheduleModel>> todaySchedulesStream(String trainerId) {
    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final schedules = snapshot.docs
          .map((doc) => _docToSchedule(doc))
          .where((schedule) {
            final date = schedule.scheduledAt;
            return date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                   date.isBefore(endOfDay);
          })
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return schedules;
    });
  }

  /// Firestore 문서를 ScheduleModel로 변환
  ScheduleModel _docToSchedule(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // scheduledAt 처리 (Timestamp 또는 String)
    DateTime scheduledAt;
    final scheduledAtData = data['scheduledAt'];
    if (scheduledAtData is Timestamp) {
      scheduledAt = scheduledAtData.toDate();
    } else if (scheduledAtData is String) {
      scheduledAt = DateTime.parse(scheduledAtData);
    } else {
      scheduledAt = DateTime.now();
    }

    // createdAt 처리
    DateTime createdAt;
    final createdAtData = data['createdAt'];
    if (createdAtData is Timestamp) {
      createdAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      createdAt = DateTime.parse(createdAtData);
    } else {
      createdAt = DateTime.now();
    }

    // status 처리
    ScheduleStatus status;
    final statusStr = data['status'] as String?;
    switch (statusStr) {
      case 'completed':
        status = ScheduleStatus.completed;
      case 'cancelled':
        status = ScheduleStatus.cancelled;
      case 'noShow':
        status = ScheduleStatus.noShow;
      default:
        status = ScheduleStatus.scheduled;
    }

    // scheduleType 처리 (기본값: pt)
    ScheduleType scheduleType;
    final scheduleTypeStr = data['scheduleType'] as String?;
    switch (scheduleTypeStr) {
      case 'personal':
        scheduleType = ScheduleType.personal;
      default:
        scheduleType = ScheduleType.pt;
    }

    return ScheduleModel(
      id: doc.id,
      trainerId: data['trainerId'] ?? '',
      memberId: data['memberId'] ?? '',
      memberName: data['memberName'],
      scheduledAt: scheduledAt,
      duration: data['duration'] ?? 60,
      status: status,
      scheduleType: scheduleType,
      title: data['title'] as String?,
      note: data['note'],
      groupId: data['groupId'],
      createdAt: createdAt,
    );
  }
}
