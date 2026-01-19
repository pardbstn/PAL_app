import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_record_model.dart';
import 'base_repository.dart';

/// BodyRecordRepository Provider
final bodyRecordRepositoryProvider = Provider<BodyRecordRepository>((ref) {
  return BodyRecordRepository(firestore: ref.watch(firestoreProvider));
});

/// 체성분 기록 Repository
class BodyRecordRepository extends BaseRepository<BodyRecordModel> {
  BodyRecordRepository({required super.firestore})
      : super(collectionPath: 'body_records');

  @override
  Future<BodyRecordModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return BodyRecordModel.fromFirestore(doc);
  }

  @override
  Future<List<BodyRecordModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => BodyRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(BodyRecordModel record) async {
    final docRef = await collection.add(record.toFirestore());
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
  Stream<BodyRecordModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return BodyRecordModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<BodyRecordModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BodyRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 체성분 기록 목록 (최신순)
  Future<List<BodyRecordModel>> getByMemberId(
    String memberId, {
    int? limit,
  }) async {
    var query = collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('recordDate', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => BodyRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 체성분 기록 실시간 감시 (최신순)
  Stream<List<BodyRecordModel>> watchByMemberId(
    String memberId, {
    int? limit,
  }) {
    var query = collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('recordDate', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BodyRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 최신 체성분 기록 가져오기
  Future<BodyRecordModel?> getLatestByMemberId(String memberId) async {
    final records = await getByMemberId(memberId, limit: 1);
    return records.isNotEmpty ? records.first : null;
  }

  /// 날짜 범위로 체성분 기록 조회
  Future<List<BodyRecordModel>> getByDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('recordDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('recordDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('recordDate')
        .get();
    return snapshot.docs
        .map((doc) => BodyRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 특정 날짜의 기록 가져오기
  Future<BodyRecordModel?> getByDate(String memberId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('recordDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('recordDate', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return BodyRecordModel.fromFirestore(snapshot.docs.first);
  }

  /// 체중 변화 계산 (최근 N일)
  Future<double?> getWeightChange(String memberId, int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));

    final records = await getByDateRange(memberId, startDate, endDate);
    if (records.length < 2) return null;

    final firstWeight = records.first.weight;
    final lastWeight = records.last.weight;
    return lastWeight - firstWeight;
  }
}
