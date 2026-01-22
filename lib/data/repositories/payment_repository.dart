import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_record_model.dart';
import 'base_repository.dart';

/// PaymentRepository Provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(firestore: ref.watch(firestoreProvider));
});

/// 결제 Repository
/// Firestore 'payments' 컬렉션에 대한 데이터 접근 계층
///
/// 필요한 Firestore 복합 인덱스:
/// - trainerId (ASC) + paymentDate (DESC)
/// - memberId (ASC) + paymentDate (DESC)
class PaymentRepository extends BaseRepository<PaymentRecordModel> {
  PaymentRepository({required super.firestore})
      : super(collectionPath: 'payments');

  @override
  Future<PaymentRecordModel?> get(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (!doc.exists) return null;
      return PaymentRecordModel.fromFirestore(doc);
    } catch (e) {
      throw PaymentRepositoryException('결제 정보 조회 실패: $e');
    }
  }

  @override
  Future<List<PaymentRecordModel>> getAll() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw PaymentRepositoryException('결제 목록 조회 실패: $e');
    }
  }

  @override
  Future<String> create(PaymentRecordModel payment) async {
    try {
      final docRef = await collection.add(payment.toFirestore());
      return docRef.id;
    } catch (e) {
      throw PaymentRepositoryException('결제 생성 실패: $e');
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await collection.doc(id).update(data);
    } catch (e) {
      throw PaymentRepositoryException('결제 업데이트 실패: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      throw PaymentRepositoryException('결제 삭제 실패: $e');
    }
  }

  @override
  Stream<PaymentRecordModel?> watch(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return PaymentRecordModel.fromFirestore(doc);
    });
  }

  @override
  Stream<List<PaymentRecordModel>> watchAll() {
    return collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  // =========================================================================
  // 결제 저장/수정/삭제
  // =========================================================================

  /// 결제 저장
  /// [record] 저장할 결제 기록
  /// Returns: 생성된 문서 ID
  Future<String> savePayment(PaymentRecordModel record) async {
    return create(record);
  }

  /// 결제 삭제
  /// [id] 삭제할 결제 문서 ID
  Future<void> deletePayment(String id) async {
    return delete(id);
  }

  /// 결제 업데이트
  /// [id] 업데이트할 결제 문서 ID
  /// [data] 업데이트할 필드 맵
  Future<void> updatePayment(String id, Map<String, dynamic> data) async {
    return update(id, data);
  }

  // =========================================================================
  // 트레이너별 결제 조회
  // =========================================================================

  /// 트레이너의 결제 내역 조회
  /// [trainerId] 트레이너 ID
  /// [month] 조회할 월 (null이면 전체 기간)
  ///
  /// 인덱스: trainerId (ASC) + paymentDate (DESC)
  Future<List<PaymentRecordModel>> getPaymentsByTrainer(
    String trainerId, {
    DateTime? month,
  }) async {
    try {
      Query<Map<String, dynamic>> query = collection
          .where('trainerId', isEqualTo: trainerId);

      if (month != null) {
        final startDate = DateTime(month.year, month.month, 1);
        final endDate = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

        query = query
            .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final snapshot = await query
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw PaymentRepositoryException('트레이너 결제 내역 조회 실패: $e');
    }
  }

  /// 트레이너의 월별 결제 내역 조회 (년도, 월 지정)
  Future<List<PaymentRecordModel>> getPaymentsByTrainerMonth(
    String trainerId,
    int year,
    int month,
  ) async {
    return getPaymentsByTrainer(
      trainerId,
      month: DateTime(year, month),
    );
  }

  /// 트레이너의 결제 내역 실시간 감시 (전체)
  /// [trainerId] 트레이너 ID
  ///
  /// 인덱스: trainerId (ASC) + paymentDate (DESC)
  Stream<List<PaymentRecordModel>> watchPaymentsByTrainer(String trainerId) {
    return collection
        .where('trainerId', isEqualTo: trainerId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  /// 트레이너의 월별 결제 내역 실시간 감시
  Stream<List<PaymentRecordModel>> watchPaymentsByTrainerMonth(
    String trainerId,
    int year,
    int month,
  ) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return collection
        .where('trainerId', isEqualTo: trainerId)
        .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  // =========================================================================
  // 회원별 결제 조회
  // =========================================================================

  /// 회원별 결제 내역 조회
  /// [memberId] 회원 ID
  ///
  /// 인덱스: memberId (ASC) + paymentDate (DESC)
  Future<List<PaymentRecordModel>> getPaymentsByMember(String memberId) async {
    try {
      final snapshot = await collection
          .where('memberId', isEqualTo: memberId)
          .orderBy('paymentDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw PaymentRepositoryException('회원 결제 내역 조회 실패: $e');
    }
  }

  /// 회원별 결제 내역 실시간 감시
  Stream<List<PaymentRecordModel>> watchPaymentsByMember(String memberId) {
    return collection
        .where('memberId', isEqualTo: memberId)
        .orderBy('paymentDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();
    });
  }

  // =========================================================================
  // 매출 요약
  // =========================================================================

  /// 월별 매출 요약 조회
  /// [trainerId] 트레이너 ID
  /// [year] 조회 년도
  /// [month] 조회 월 (1-12)
  Future<PaymentSummary> getMonthlySummary(
    String trainerId,
    int year,
    int month,
  ) async {
    try {
      final payments = await getPaymentsByTrainer(
        trainerId,
        month: DateTime(year, month),
      );

      if (payments.isEmpty) {
        return const PaymentSummary(
          totalRevenue: 0,
          monthlyRevenue: 0,
          memberCount: 0,
          averagePerMember: 0,
        );
      }

      final totalRevenue = payments.fold<int>(0, (acc, p) => acc + p.amount);
      final uniqueMembers = payments.map((p) => p.memberId).toSet();
      final memberCount = uniqueMembers.length;
      final averagePerMember = memberCount > 0 ? totalRevenue / memberCount : 0.0;

      return PaymentSummary(
        totalRevenue: totalRevenue,
        monthlyRevenue: totalRevenue,
        memberCount: memberCount,
        averagePerMember: averagePerMember,
      );
    } catch (e) {
      throw PaymentRepositoryException('월별 매출 요약 조회 실패: $e');
    }
  }

  /// 연간 매출 요약 조회 (월별 리스트)
  /// [trainerId] 트레이너 ID
  /// [year] 조회 년도
  /// Returns: 12개월치 PaymentSummary 리스트
  Future<List<PaymentSummary>> getYearlySummary(
    String trainerId,
    int year,
  ) async {
    try {
      final result = <PaymentSummary>[];

      for (int month = 1; month <= 12; month++) {
        final summary = await getMonthlySummary(trainerId, year, month);
        result.add(summary);
      }

      return result;
    } catch (e) {
      throw PaymentRepositoryException('연간 매출 요약 조회 실패: $e');
    }
  }

  /// 연간 매출 총합 요약 조회
  /// [trainerId] 트레이너 ID
  /// [year] 조회 년도
  Future<PaymentSummary> getYearlyTotalSummary(
    String trainerId,
    int year,
  ) async {
    try {
      final startDate = DateTime(year, 1, 1);
      final endDate = DateTime(year, 12, 31, 23, 59, 59);

      final snapshot = await collection
          .where('trainerId', isEqualTo: trainerId)
          .where('paymentDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('paymentDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final payments = snapshot.docs
          .map((doc) => PaymentRecordModel.fromFirestore(doc))
          .toList();

      if (payments.isEmpty) {
        return const PaymentSummary(
          totalRevenue: 0,
          monthlyRevenue: 0,
          memberCount: 0,
          averagePerMember: 0,
        );
      }

      final totalRevenue = payments.fold<int>(0, (acc, p) => acc + p.amount);
      final uniqueMembers = payments.map((p) => p.memberId).toSet();
      final memberCount = uniqueMembers.length;
      final averagePerMember = memberCount > 0 ? totalRevenue / memberCount : 0.0;
      final monthlyRevenue = totalRevenue ~/ 12;

      return PaymentSummary(
        totalRevenue: totalRevenue,
        monthlyRevenue: monthlyRevenue,
        memberCount: memberCount,
        averagePerMember: averagePerMember,
      );
    } catch (e) {
      throw PaymentRepositoryException('연간 매출 총합 조회 실패: $e');
    }
  }

  /// 월별 매출 데이터 조회 (차트용)
  /// [trainerId] 트레이너 ID
  /// [year] 조회 년도
  Future<List<MonthlyRevenue>> getMonthlyRevenueData(
    String trainerId,
    int year,
  ) async {
    try {
      final result = <MonthlyRevenue>[];

      for (int month = 1; month <= 12; month++) {
        final payments = await getPaymentsByTrainer(
          trainerId,
          month: DateTime(year, month),
        );
        final revenue = payments.fold<int>(0, (acc, p) => acc + p.amount);

        result.add(MonthlyRevenue(
          year: year,
          month: month,
          revenue: revenue,
          count: payments.length,
        ));
      }

      return result;
    } catch (e) {
      throw PaymentRepositoryException('월별 매출 데이터 조회 실패: $e');
    }
  }

  // =========================================================================
  // 하위 호환성 (deprecated)
  // =========================================================================

  /// 트레이너의 전체 결제 내역 실시간 감시
  /// @deprecated watchPaymentsByTrainer 사용 권장
  Stream<List<PaymentRecordModel>> watchByTrainerId(String trainerId) {
    return watchPaymentsByTrainer(trainerId);
  }
}

/// 결제 Repository 예외
class PaymentRepositoryException implements Exception {
  final String message;

  PaymentRepositoryException(this.message);

  @override
  String toString() => 'PaymentRepositoryException: $message';
}
