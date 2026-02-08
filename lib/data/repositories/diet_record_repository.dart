import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diet_record_model.dart';
import 'base_repository.dart';

/// DietRecordRepository Provider
final dietRecordRepositoryProvider = Provider<DietRecordRepository>((ref) {
  return DietRecordRepository(firestore: ref.watch(firestoreProvider));
});

/// 식단 기록 Repository
class DietRecordRepository extends BaseRepository<DietRecordModel> {
  DietRecordRepository({required super.firestore})
      : super(collectionPath: 'diet_records');

  @override
  Future<DietRecordModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return DietRecordModel.fromFirestore(doc);
  }

  @override
  Future<List<DietRecordModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => DietRecordModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<String> create(DietRecordModel record) async {
    final docRef = await collection.add(record.toFirestore());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await collection.doc(id).update(data);
  }

  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  @override
  Stream<DietRecordModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DietRecordModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<DietRecordModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DietRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 회원의 식단 기록 목록 (최신순)
  Future<List<DietRecordModel>> getByMemberId(
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
        .map((doc) => DietRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 회원의 식단 기록 실시간 감시 (최신순)
  Stream<List<DietRecordModel>> watchByMemberId(
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
          .map((doc) => DietRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 특정 날짜의 식단 기록
  Future<List<DietRecordModel>> getByDate(
    String memberId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('recordDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('recordDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('recordDate')
        .get();

    return snapshot.docs
        .map((doc) => DietRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 특정 날짜의 식단 기록 실시간 감시
  Stream<List<DietRecordModel>> watchByDate(
    String memberId,
    DateTime date,
  ) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return collection
        .where('memberId', isEqualTo: memberId)
        .where('recordDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('recordDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('recordDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DietRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 날짜 범위로 식단 기록 조회
  Future<List<DietRecordModel>> getByDateRange(
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
        .map((doc) => DietRecordModel.fromFirestore(doc))
        .toList();
  }

  /// 여러 회원의 최근 식단 기록 조회 (배치 쿼리)
  /// Firestore whereIn 10개 제한 대응: 10개씩 나눠서 쿼리
  Future<List<DietRecordModel>> getRecentByMemberIds(
    List<String> memberIds, {
    required DateTime since,
    int? limit,
  }) async {
    if (memberIds.isEmpty) return [];

    final List<DietRecordModel> allRecords = [];

    // whereIn은 최대 10개까지만 가능 → 10개씩 나눠서 쿼리
    for (var i = 0; i < memberIds.length; i += 10) {
      final chunk = memberIds.sublist(
        i,
        i + 10 > memberIds.length ? memberIds.length : i + 10,
      );

      final snapshot = await collection
          .where('memberId', whereIn: chunk)
          .where('recordDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('recordDate', descending: true)
          .get();

      allRecords.addAll(
        snapshot.docs.map((doc) => DietRecordModel.fromFirestore(doc)),
      );
    }

    // 전체 결과를 createdAt 내림차순 정렬
    allRecords.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (limit != null && allRecords.length > limit) {
      return allRecords.sublist(0, limit);
    }

    return allRecords;
  }

  /// AI 분석 결과 업데이트
  Future<void> updateAiAnalysis(String id, AiAnalysis analysis) async {
    await collection.doc(id).update({
      'aiAnalysis': analysis.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 이미지 URL 업데이트
  Future<void> updateImageUrl(String id, String imageUrl) async {
    await collection.doc(id).update({
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 하루 총 칼로리 계산
  Future<double> getDailyCalories(String memberId, DateTime date) async {
    final records = await getByDate(memberId, date);
    double total = 0.0;
    for (final record in records) {
      total += record.aiAnalysis?.calories ?? 0;
    }
    return total;
  }

  /// 하루 영양소 합계
  Future<Map<String, double>> getDailyNutrition(
    String memberId,
    DateTime date,
  ) async {
    final records = await getByDate(memberId, date);

    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final record in records) {
      if (record.aiAnalysis != null) {
        calories += record.aiAnalysis!.calories ?? 0;
        protein += record.aiAnalysis!.protein ?? 0;
        carbs += record.aiAnalysis!.carbs ?? 0;
        fat += record.aiAnalysis!.fat ?? 0;
      }
    }

    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// 식사 타입별 기록
  Future<List<DietRecordModel>> getByMealType(
    String memberId,
    MealType mealType, {
    int? limit,
  }) async {
    var query = collection
        .where('memberId', isEqualTo: memberId)
        .where('mealType', isEqualTo: mealType.name)
        .orderBy('recordDate', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => DietRecordModel.fromFirestore(doc))
        .toList();
  }
}
