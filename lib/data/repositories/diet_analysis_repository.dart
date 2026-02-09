/// 식단 분석 Repository
///
/// AI Vision으로 분석된 식단 데이터 액세스 레이어
/// 회원의 영양 섭취 추적을 위한 저장소
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diet_analysis_model.dart';
import 'base_repository.dart';

/// DietAnalysisRepository Provider
final dietAnalysisRepositoryProvider = Provider<DietAnalysisRepository>((ref) {
  return DietAnalysisRepository(firestore: ref.watch(firestoreProvider));
});

/// 식단 분석 Repository
/// 회원의 식단 기록 CRUD 및 실시간 구독 제공
class DietAnalysisRepository extends BaseRepository<DietAnalysisModel> {
  DietAnalysisRepository({required super.firestore})
      : super(collectionPath: 'diet_records');

  // ============================================================
  // BaseRepository 필수 메서드 구현
  // ============================================================

  /// 단일 식단 기록 조회
  @override
  Future<DietAnalysisModel?> get(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return DietAnalysisModel.fromFirestore(doc);
  }

  /// 모든 식단 기록 조회
  @override
  Future<List<DietAnalysisModel>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs
        .map((doc) => DietAnalysisModel.fromFirestore(doc))
        .toList();
  }

  /// 식단 기록 생성
  @override
  Future<String> create(DietAnalysisModel record) async {
    final docRef = await collection.add(record.toFirestore());
    return docRef.id;
  }

  /// 식단 기록 업데이트
  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await collection.doc(id).update(data);
  }

  /// 식단 기록 삭제
  @override
  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  /// 단일 식단 기록 실시간 감시
  @override
  Stream<DietAnalysisModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return DietAnalysisModel.fromFirestore(doc);
    });
  }

  /// 모든 식단 기록 실시간 감시
  @override
  Stream<List<DietAnalysisModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => DietAnalysisModel.fromFirestore(doc))
          .toList();
    });
  }

  // ============================================================
  // 커스텀 메서드
  // ============================================================

  /// 식단 기록 저장
  ///
  /// [record] 저장할 식단 기록 모델
  Future<String> saveDietAnalysis(DietAnalysisModel record) async {
    final docRef = await collection.add(record.toFirestore());
    return docRef.id;
  }

  /// 특정 날짜의 식단 기록 조회
  ///
  /// [memberId] 회원 ID
  /// [date] 조회할 날짜
  Future<List<DietAnalysisModel>> getDietRecordsByDate(
    String memberId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      // 복합 인덱스가 있는 경우 최적화된 쿼리
      final snapshot = await collection
          .where('memberId', isEqualTo: memberId)
          .where('analyzedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('analyzedAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('analyzedAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => DietAnalysisModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      // 인덱스 오류 시 단순 쿼리 + 클라이언트 필터링
      final snapshot = await collection
          .where('memberId', isEqualTo: memberId)
          .get();

      final records = snapshot.docs
          .map((doc) => DietAnalysisModel.fromFirestore(doc))
          .where((record) =>
              record.analyzedAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              record.analyzedAt.isBefore(endOfDay))
          .toList();

      records.sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));
      return records;
    }
  }

  /// 오늘의 식단 기록 실시간 감시
  ///
  /// [memberId] 회원 ID
  Stream<List<DietAnalysisModel>> watchTodayDietRecords(String memberId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // 단순 쿼리 사용 (인덱스 없이 작동) + 클라이언트 필터링
    return collection
        .where('memberId', isEqualTo: memberId)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => DietAnalysisModel.fromFirestore(doc))
          .where((record) =>
              record.analyzedAt.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              record.analyzedAt.isBefore(endOfDay))
          .toList();

      records.sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));
      return records;
    });
  }

  /// 일일 영양 요약 조회
  ///
  /// [memberId] 회원 ID
  /// [date] 조회할 날짜
  Future<DailyNutritionSummary> getDailySummary(
    String memberId,
    DateTime date,
  ) async {
    final records = await getDietRecordsByDate(memberId, date);

    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final record in records) {
      totalCalories += record.calories;
      totalProtein += record.protein;
      totalCarbs += record.carbs;
      totalFat += record.fat;
    }

    return DailyNutritionSummary(
      date: date,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      records: records,
    );
  }

  /// 오늘의 영양 요약 실시간 감시
  ///
  /// [memberId] 회원 ID
  Stream<DailyNutritionSummary> watchTodaySummary(String memberId) {
    return watchTodayDietRecords(memberId).map((records) {
      int totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final record in records) {
        totalCalories += record.calories;
        totalProtein += record.protein;
        totalCarbs += record.carbs;
        totalFat += record.fat;
      }

      return DailyNutritionSummary(
        date: DateTime.now(),
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        records: records,
      );
    });
  }

  /// 식단 기록의 영양소 업데이트 (배수 조정 후)
  Future<void> updateNutrition(String recordId, {
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required List<Map<String, dynamic>> foods,
  }) async {
    await collection.doc(recordId).update({
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'foods': foods,
    });
  }

  /// 식단 기록 삭제
  ///
  /// [recordId] 삭제할 식단 기록 ID
  Future<void> deleteDietRecord(String recordId) async {
    await collection.doc(recordId).delete();
  }

  /// 회원의 최근 식단 기록 조회
  ///
  /// [memberId] 회원 ID
  /// [limit] 최대 조회 개수
  Future<List<DietAnalysisModel>> getRecentRecords(
    String memberId, {
    int limit = 20,
  }) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('analyzedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => DietAnalysisModel.fromFirestore(doc))
        .toList();
  }

  /// 기간별 식단 기록 조회
  ///
  /// [memberId] 회원 ID
  /// [startDate] 시작 날짜
  /// [endDate] 종료 날짜
  Future<List<DietAnalysisModel>> getRecordsByDateRange(
    String memberId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await collection
        .where('memberId', isEqualTo: memberId)
        .where('analyzedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('analyzedAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('analyzedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DietAnalysisModel.fromFirestore(doc))
        .toList();
  }
}
