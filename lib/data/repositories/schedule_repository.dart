import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/firestore_constants.dart';
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
      firestore.collection(FirestoreCollections.schedules);

  /// 특정 날짜의 일정 조회
  Future<List<ScheduleModel>> getSchedulesForDay(
      String trainerId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 복합 인덱스 사용: trainerId + scheduledAt
    final snapshot = await _collection
        .where('trainerId', isEqualTo: trainerId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs.map((doc) => _docToSchedule(doc)).toList();
  }

  /// 월별 일정 조회
  Future<List<ScheduleModel>> getSchedulesForMonth(
      String trainerId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    // 복합 인덱스 사용: trainerId + scheduledAt
    final snapshot = await _collection
        .where('trainerId', isEqualTo: trainerId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs.map((doc) => _docToSchedule(doc)).toList();
  }

  /// 회원의 개인 일정 조회 (trainerId가 null인 일정만)
  Future<List<ScheduleModel>> getMemberSchedules(String memberId) async {
    final snapshot =
        await _collection.where('memberId', isEqualTo: memberId).get();

    final schedules = snapshot.docs
        .map((doc) => _docToSchedule(doc))
        // 회원 개인 일정만 필터링 (trainerId가 null 또는 빈 문자열)
        .where((s) => s.trainerId == null || s.trainerId!.isEmpty)
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    return schedules;
  }

  /// 회원 월별 개인 일정 조회 (trainerId가 null인 일정만)
  Future<List<ScheduleModel>> getMemberSchedulesForMonth(
      String memberId, DateTime month) async {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 1);

    // 복합 인덱스 사용: memberId + scheduledAt
    final snapshot = await _collection
        .where('memberId', isEqualTo: memberId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs
        .map((doc) => _docToSchedule(doc))
        // 회원 개인 일정만 필터링 (trainerId가 null 또는 빈 문자열)
        .where((s) => s.trainerId == null || s.trainerId!.isEmpty)
        .toList();
  }

  /// 회원 개인 일정 실시간 스트림 (trainerId가 null인 일정만)
  Stream<List<ScheduleModel>> memberSchedulesStream(String memberId) {
    return _collection
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final schedules = snapshot.docs
          .map((doc) => _docToSchedule(doc))
          // 회원 개인 일정만 필터링 (trainerId가 null 또는 빈 문자열)
          .where((s) => s.trainerId == null || s.trainerId!.isEmpty)
          .toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      return schedules;
    });
  }

  /// 일정 추가
  Future<String> addSchedule(ScheduleModel schedule) async {
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
    return docRef.id;
  }

  /// 일정 수정
  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _collection.doc(schedule.id).update({
      'scheduledAt': Timestamp.fromDate(schedule.scheduledAt),
      'duration': schedule.duration,
      'status': schedule.status.name,
      'title': schedule.title,
      'note': schedule.note,
      'memberId': schedule.memberId,
      'memberName': schedule.memberName,
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
  /// 복합 인덱스 사용: trainerId + scheduledAt
  Stream<List<ScheduleModel>> todaySchedulesStream(String trainerId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _collection
        .where('trainerId', isEqualTo: trainerId)
        .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) {
      final schedules = snapshot.docs
          .map((doc) => _docToSchedule(doc))
          .toList();
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
      trainerId: data['trainerId'] as String?, // 회원 개인 일정은 null
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
