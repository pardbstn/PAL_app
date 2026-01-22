import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pal_app/data/models/payment_record_model.dart';
import 'package:flutter_pal_app/data/repositories/payment_repository.dart';
import 'package:flutter_pal_app/presentation/providers/auth_provider.dart';

// ============================================================================
// 파라미터 타입 정의
// ============================================================================

/// 월별 결제 조회 파라미터
typedef MonthlyPaymentsParams = ({String trainerId, int year, int month});

/// 연간 매출 조회 파라미터
typedef YearlyRevenueParams = ({String trainerId, int year});

// ============================================================================
// 선택된 연도/월 상태 관리
// ============================================================================

/// 현재 선택된 연도
class SelectedYearNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().year;

  void setYear(int year) => state = year;
}

final selectedYearProvider =
    NotifierProvider<SelectedYearNotifier, int>(() => SelectedYearNotifier());

/// 현재 선택된 월
class SelectedMonthNotifier extends Notifier<int> {
  @override
  int build() => DateTime.now().month;

  void setMonth(int month) => state = month;
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, int>(() => SelectedMonthNotifier());

// ============================================================================
// Family Providers (명시적 파라미터 타입)
// ============================================================================

/// 트레이너의 월별 결제 내역 Provider (family - 실시간)
final monthlyPaymentsFamilyProvider = StreamProvider.family<
    List<PaymentRecordModel>, MonthlyPaymentsParams>((ref, params) {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.watchPaymentsByTrainerMonth(
    params.trainerId,
    params.year,
    params.month,
  );
});

/// 결제 요약 Provider (family - 월별)
final paymentSummaryFamilyProvider =
    FutureProvider.family<PaymentSummary, MonthlyPaymentsParams>(
        (ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getMonthlySummary(
    params.trainerId,
    params.year,
    params.month,
  );
});

/// 연간 매출 데이터 Provider (family - 차트용)
final yearlyRevenueProvider =
    FutureProvider.family<List<MonthlyRevenue>, YearlyRevenueParams>(
        (ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getMonthlyRevenueData(
    params.trainerId,
    params.year,
  );
});

/// 연간 결제 요약 Provider (family)
final yearlySummaryFamilyProvider =
    FutureProvider.family<List<PaymentSummary>, YearlyRevenueParams>(
        (ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.getYearlySummary(
    params.trainerId,
    params.year,
  );
});

/// 회원별 결제 내역 Provider (family - 실시간)
final memberPaymentHistoryProvider =
    StreamProvider.family<List<PaymentRecordModel>, String>((ref, memberId) {
  final repository = ref.watch(paymentRepositoryProvider);

  if (memberId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchPaymentsByMember(memberId);
});

/// 회원별 결제 내역 Provider (family - 일회성 조회)
final memberPaymentsFutureProvider =
    FutureProvider.family<List<PaymentRecordModel>, String>(
        (ref, memberId) async {
  final repository = ref.watch(paymentRepositoryProvider);

  if (memberId.isEmpty) {
    return [];
  }

  return await repository.getPaymentsByMember(memberId);
});

/// 트레이너의 전체 결제 내역 Provider (family - 실시간)
final trainerPaymentsFamilyProvider =
    StreamProvider.family<List<PaymentRecordModel>, String>((ref, trainerId) {
  final repository = ref.watch(paymentRepositoryProvider);

  if (trainerId.isEmpty) {
    return Stream.value([]);
  }

  return repository.watchByTrainerId(trainerId);
});

/// 단일 결제 기록 조회 Provider (family)
final paymentDetailProvider =
    FutureProvider.family<PaymentRecordModel?, String>((ref, paymentId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return await repository.get(paymentId);
});

// ============================================================================
// 기존 호환성 Provider (현재 트레이너 기반 자동 조회)
// ============================================================================

/// 트레이너의 전체 결제 내역 (실시간 스트림)
final paymentsProvider = StreamProvider<List<PaymentRecordModel>>((ref) {
  final trainer = ref.watch(currentTrainerProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);

  if (trainer == null || trainer.id.isEmpty) {
    return Stream.value([]);
  }

  return paymentRepository.watchByTrainerId(trainer.id);
});

/// 월별 결제 내역 (실시간 스트림 - 선택된 연/월 기준)
final monthlyPaymentsProvider =
    StreamProvider<List<PaymentRecordModel>>((ref) {
  final trainer = ref.watch(currentTrainerProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);

  if (trainer == null || trainer.id.isEmpty) {
    return Stream.value([]);
  }

  return paymentRepository.watchPaymentsByTrainerMonth(trainer.id, year, month);
});

/// 월별 매출 요약 (선택된 연/월 기준)
final paymentSummaryProvider = FutureProvider<PaymentSummary>((ref) async {
  final trainer = ref.watch(currentTrainerProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);

  if (trainer == null || trainer.id.isEmpty) {
    return const PaymentSummary(
      totalRevenue: 0,
      monthlyRevenue: 0,
      memberCount: 0,
      averagePerMember: 0,
    );
  }

  return paymentRepository.getMonthlySummary(trainer.id, year, month);
});

/// 연간 매출 요약 (선택된 연도 기준)
final yearlyPaymentSummaryProvider =
    FutureProvider<PaymentSummary>((ref) async {
  final trainer = ref.watch(currentTrainerProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);
  final year = ref.watch(selectedYearProvider);

  if (trainer == null || trainer.id.isEmpty) {
    return const PaymentSummary(
      totalRevenue: 0,
      monthlyRevenue: 0,
      memberCount: 0,
      averagePerMember: 0,
    );
  }

  return paymentRepository.getYearlyTotalSummary(trainer.id, year);
});

/// 월별 매출 차트 데이터 (선택된 연도 기준)
final monthlyRevenueChartProvider =
    FutureProvider<List<MonthlyRevenue>>((ref) async {
  final trainer = ref.watch(currentTrainerProvider);
  final paymentRepository = ref.watch(paymentRepositoryProvider);
  final year = ref.watch(selectedYearProvider);

  if (trainer == null || trainer.id.isEmpty) {
    return [];
  }

  return paymentRepository.getMonthlyRevenueData(trainer.id, year);
});

// ============================================================================
// PaymentNotifier - CRUD 관리
// ============================================================================

/// 결제 관리 Notifier (CRUD 액션)
class PaymentNotifier extends AsyncNotifier<void> {
  PaymentRepository get _repository => ref.read(paymentRepositoryProvider);

  @override
  Future<void> build() async {}

  /// 결제 기록 저장 (PaymentRecordModel 직접 전달)
  Future<String?> savePayment(PaymentRecordModel record) async {
    state = const AsyncValue.loading();

    try {
      final paymentId = await _repository.savePayment(record);
      state = const AsyncValue.data(null);

      // 관련 provider들 갱신
      _invalidateRelatedProviders(
        trainerId: record.trainerId,
        memberId: record.memberId,
        year: record.paymentDate.year,
        month: record.paymentDate.month,
      );

      return paymentId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 결제 등록 (개별 파라미터 전달)
  Future<String> addPayment({
    required String memberId,
    required String memberName,
    required int amount,
    required DateTime paymentDate,
    required int ptSessions,
    required PaymentMethod paymentMethod,
    String? memo,
  }) async {
    state = const AsyncValue.loading();

    try {
      final trainer = ref.read(currentTrainerProvider);
      if (trainer == null) {
        throw Exception('트레이너 정보를 찾을 수 없습니다.');
      }

      final payment = PaymentRecordModel(
        id: '',
        trainerId: trainer.id,
        memberId: memberId,
        memberName: memberName,
        amount: amount,
        paymentDate: paymentDate,
        ptSessions: ptSessions,
        paymentMethod: paymentMethod,
        memo: memo,
        createdAt: DateTime.now(),
      );

      final paymentId = await _repository.savePayment(payment);
      state = const AsyncValue.data(null);

      // 관련 provider들 갱신
      _invalidateRelatedProviders(
        trainerId: trainer.id,
        memberId: memberId,
        year: paymentDate.year,
        month: paymentDate.month,
      );

      return paymentId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// 결제 기록 삭제
  Future<bool> deletePayment(String id) async {
    state = const AsyncValue.loading();

    try {
      // 삭제 전에 결제 정보 조회 (관련 provider 갱신용)
      final payment = await _repository.get(id);

      if (payment == null) {
        state = AsyncValue.error(
          Exception('결제 기록을 찾을 수 없습니다.'),
          StackTrace.current,
        );
        return false;
      }

      await _repository.delete(id);
      state = const AsyncValue.data(null);

      // 관련 provider들 갱신
      _invalidateRelatedProviders(
        trainerId: payment.trainerId,
        memberId: payment.memberId,
        year: payment.paymentDate.year,
        month: payment.paymentDate.month,
      );

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 결제 기록 업데이트
  Future<bool> updatePayment(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    try {
      // 업데이트 전에 기존 결제 정보 조회 (관련 provider 갱신용)
      final payment = await _repository.get(id);

      if (payment == null) {
        state = AsyncValue.error(
          Exception('결제 기록을 찾을 수 없습니다.'),
          StackTrace.current,
        );
        return false;
      }

      await _repository.update(id, data);
      state = const AsyncValue.data(null);

      // 관련 provider들 갱신
      _invalidateRelatedProviders(
        trainerId: payment.trainerId,
        memberId: payment.memberId,
        year: payment.paymentDate.year,
        month: payment.paymentDate.month,
      );

      // 날짜가 변경된 경우 새로운 날짜의 provider도 갱신
      if (data.containsKey('paymentDate')) {
        final newDate = data['paymentDate'] as DateTime;
        if (newDate.year != payment.paymentDate.year ||
            newDate.month != payment.paymentDate.month) {
          ref.invalidate(monthlyPaymentsFamilyProvider((
            trainerId: payment.trainerId,
            year: newDate.year,
            month: newDate.month,
          )));
          ref.invalidate(paymentSummaryFamilyProvider((
            trainerId: payment.trainerId,
            year: newDate.year,
            month: newDate.month,
          )));
        }
      }

      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// 관련 Provider들 갱신
  void _invalidateRelatedProviders({
    required String trainerId,
    required String memberId,
    required int year,
    required int month,
  }) {
    // Family providers 갱신
    ref.invalidate(monthlyPaymentsFamilyProvider((
      trainerId: trainerId,
      year: year,
      month: month,
    )));

    ref.invalidate(paymentSummaryFamilyProvider((
      trainerId: trainerId,
      year: year,
      month: month,
    )));

    ref.invalidate(yearlyRevenueProvider((
      trainerId: trainerId,
      year: year,
    )));

    ref.invalidate(yearlySummaryFamilyProvider((
      trainerId: trainerId,
      year: year,
    )));

    ref.invalidate(trainerPaymentsFamilyProvider(trainerId));
    ref.invalidate(memberPaymentHistoryProvider(memberId));
    ref.invalidate(memberPaymentsFutureProvider(memberId));

    // 기존 호환성 providers 갱신 (현재 트레이너 기반)
    ref.invalidate(paymentsProvider);
    ref.invalidate(monthlyPaymentsProvider);
    ref.invalidate(paymentSummaryProvider);
    ref.invalidate(yearlyPaymentSummaryProvider);
    ref.invalidate(monthlyRevenueChartProvider);
    ref.invalidate(paymentStatsProvider);
  }
}

/// 결제 관리 Provider
final paymentNotifierProvider =
    AsyncNotifierProvider<PaymentNotifier, void>(() {
  return PaymentNotifier();
});

// ============================================================================
// 통계 및 유틸리티
// ============================================================================

/// 결제 통계 (대시보드용)
final paymentStatsProvider = Provider<AsyncValue<PaymentStats>>((ref) {
  final paymentsAsync = ref.watch(monthlyPaymentsProvider);
  final year = ref.watch(selectedYearProvider);
  final month = ref.watch(selectedMonthProvider);

  return paymentsAsync.whenData((payments) {
    final totalRevenue = payments.fold<int>(0, (sum, p) => sum + p.amount);
    final totalSessions =
        payments.fold<int>(0, (sum, p) => sum + p.ptSessions);
    final uniqueMembers = payments.map((p) => p.memberId).toSet();
    final memberCount = uniqueMembers.length;
    final averagePerMember = memberCount > 0 ? totalRevenue ~/ memberCount : 0;
    final averagePerSession =
        totalSessions > 0 ? totalRevenue ~/ totalSessions : 0;

    // 결제 방법별 분포
    final methodDistribution = <PaymentMethod, int>{};
    for (final method in PaymentMethod.values) {
      methodDistribution[method] =
          payments.where((p) => p.paymentMethod == method).length;
    }

    return PaymentStats(
      year: year,
      month: month,
      totalRevenue: totalRevenue,
      totalSessions: totalSessions,
      memberCount: memberCount,
      paymentCount: payments.length,
      averagePerMember: averagePerMember,
      averagePerSession: averagePerSession,
      methodDistribution: methodDistribution,
    );
  });
});

/// 결제 통계 Family Provider (특정 트레이너/연/월 기준)
final paymentStatsFamilyProvider =
    FutureProvider.family<PaymentStats, MonthlyPaymentsParams>(
        (ref, params) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final payments = await repository.getPaymentsByTrainerMonth(
    params.trainerId,
    params.year,
    params.month,
  );

  final totalRevenue = payments.fold<int>(0, (sum, p) => sum + p.amount);
  final totalSessions = payments.fold<int>(0, (sum, p) => sum + p.ptSessions);
  final uniqueMembers = payments.map((p) => p.memberId).toSet();
  final memberCount = uniqueMembers.length;
  final averagePerMember = memberCount > 0 ? totalRevenue ~/ memberCount : 0;
  final averagePerSession =
      totalSessions > 0 ? totalRevenue ~/ totalSessions : 0;

  // 결제 방법별 분포
  final methodDistribution = <PaymentMethod, int>{};
  for (final method in PaymentMethod.values) {
    methodDistribution[method] =
        payments.where((p) => p.paymentMethod == method).length;
  }

  return PaymentStats(
    year: params.year,
    month: params.month,
    totalRevenue: totalRevenue,
    totalSessions: totalSessions,
    memberCount: memberCount,
    paymentCount: payments.length,
    averagePerMember: averagePerMember,
    averagePerSession: averagePerSession,
    methodDistribution: methodDistribution,
  );
});

/// 결제 통계 모델
class PaymentStats {
  final int year;
  final int month;
  final int totalRevenue;
  final int totalSessions;
  final int memberCount;
  final int paymentCount;
  final int averagePerMember;
  final int averagePerSession;
  final Map<PaymentMethod, int> methodDistribution;

  const PaymentStats({
    required this.year,
    required this.month,
    required this.totalRevenue,
    required this.totalSessions,
    required this.memberCount,
    required this.paymentCount,
    required this.averagePerMember,
    required this.averagePerSession,
    required this.methodDistribution,
  });
}

/// 결제 통계 데이터 클래스 (대시보드 성장률 계산용)
class PaymentStatistics {
  final int currentMonthRevenue;
  final int previousMonthRevenue;
  final double growthRate;
  final int totalPaymentsCount;
  final int averagePaymentAmount;

  const PaymentStatistics({
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.growthRate,
    required this.totalPaymentsCount,
    required this.averagePaymentAmount,
  });

  /// 성장률 계산
  static double calculateGrowthRate(int current, int previous) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }
}

/// 결제 성장률 통계 Provider (대시보드용)
final paymentGrowthStatisticsProvider =
    FutureProvider.family<PaymentStatistics, String>(
        (ref, trainerId) async {
  final repository = ref.watch(paymentRepositoryProvider);
  final now = DateTime.now();

  // 현재 월 데이터
  final currentMonthSummary = await repository.getMonthlySummary(
    trainerId,
    now.year,
    now.month,
  );

  // 이전 월 데이터
  final previousMonth = now.month == 1
      ? DateTime(now.year - 1, 12)
      : DateTime(now.year, now.month - 1);
  final previousMonthSummary = await repository.getMonthlySummary(
    trainerId,
    previousMonth.year,
    previousMonth.month,
  );

  // 현재 월 결제 내역 (카운트 및 평균 계산용)
  final currentMonthPayments = await repository.getPaymentsByTrainerMonth(
    trainerId,
    now.year,
    now.month,
  );

  final totalCount = currentMonthPayments.length;
  final averageAmount =
      totalCount > 0 ? currentMonthSummary.totalRevenue ~/ totalCount : 0;

  return PaymentStatistics(
    currentMonthRevenue: currentMonthSummary.totalRevenue,
    previousMonthRevenue: previousMonthSummary.totalRevenue,
    growthRate: PaymentStatistics.calculateGrowthRate(
      currentMonthSummary.totalRevenue,
      previousMonthSummary.totalRevenue,
    ),
    totalPaymentsCount: totalCount,
    averagePaymentAmount: averageAmount,
  );
});
