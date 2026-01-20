import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inbody_record_model.dart';
import 'base_repository.dart';

/// InbodyRepository Provider
final inbodyRepositoryProvider = Provider<InbodyRepository>((ref) {
  return InbodyRepository(firestore: ref.watch(firestoreProvider));
});

/// 인바디 기록 Repository
/// 컬렉션: inbody_records
class InbodyRepository extends BaseRepository<InbodyRecordModel> {
  InbodyRepository({required super.firestore})
      : super(collectionPath: 'inbody_records');

  @override
  Future<InbodyRecordModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return InbodyRecordModel.fromFirestore(doc);
  }

  @override
  Future<List<InbodyRecordModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => InbodyRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(InbodyRecordModel record) async {
    final docRef = await collection.add(record.toFirestore());
    return docRef.id;
  }

  /// 인바디 기록 저장 (create alias)
  Future<String> save(InbodyRecordModel record) => create(record);

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<InbodyRecordModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return InbodyRecordModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<InbodyRecordModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InbodyRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 최신 인바디 기록 가져오기
  Future<InbodyRecordModel?> getLatest(String memberId) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('measuredAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return InbodyRecordModel.fromFirestore(snapshot.docs.first);
  }

  /// 회원의 인바디 기록 목록 (최신순)
  Future<List<InbodyRecordModel>> getByMemberId(
    String memberId, {
    int? limit,
  }) async {
    var query = collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('measuredAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => InbodyRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 날짜 범위로 인바디 기록 조회
  Future<List<InbodyRecordModel>> getByRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('measuredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('measuredAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('measuredAt')
        .get();

    return snapshot.docs
        .map((doc) => InbodyRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 최신 인바디 기록 실시간 감시
  Stream<InbodyRecordModel?> watchLatest(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('measuredAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return InbodyRecordModel.fromFirestore(snapshot.docs.first);
    });
  }

  /// 회원의 인바디 기록 목록 실시간 감시 (최신순)
  Stream<List<InbodyRecordModel>> watchByMemberId(
    String memberId, {
    int? limit,
  }) {
    var query = collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('measuredAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => InbodyRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 특정 날짜의 인바디 기록 가져오기
  Future<InbodyRecordModel?> getByDate(String memberId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('measuredAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('measuredAt', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return InbodyRecordModel.fromFirestore(snapshot.docs.first);
  }

  /// 체중 변화 계산 (최근 두 기록 비교)
  Future<double?> getWeightChange(String memberId) async {
    final records = await getByMemberId(memberId, limit: 2);
    if (records.length < 2) return null;

    // records[0]이 최신, records[1]이 이전
    return records[0].weight - records[1].weight;
  }

  /// 골격근량 변화 계산 (최근 두 기록 비교)
  Future<double?> getMuscleMassChange(String memberId) async {
    final records = await getByMemberId(memberId, limit: 2);
    if (records.length < 2) return null;

    return records[0].skeletalMuscleMass - records[1].skeletalMuscleMass;
  }

  /// 체지방률 변화 계산 (최근 두 기록 비교)
  Future<double?> getBodyFatPercentChange(String memberId) async {
    final records = await getByMemberId(memberId, limit: 2);
    if (records.length < 2) return null;

    return records[0].bodyFatPercent - records[1].bodyFatPercent;
  }
}
