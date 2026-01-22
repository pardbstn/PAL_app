import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'payment_record_model.freezed.dart';
part 'payment_record_model.g.dart';

/// 결제 방법
enum PaymentMethod {
  /// 카드 결제
  @JsonValue('card')
  card,

  /// 현금 결제
  @JsonValue('cash')
  cash,

  /// 계좌이체
  @JsonValue('transfer')
  transfer,

  /// 기타
  @JsonValue('other')
  other,
}

/// 결제 기록 모델
/// 트레이너의 PT 결제 및 매출 추적용
@freezed
sealed class PaymentRecordModel with _$PaymentRecordModel {
  const PaymentRecordModel._();

  const factory PaymentRecordModel({
    /// 결제 기록 문서 ID
    required String id,

    /// 트레이너 ID
    required String trainerId,

    /// 회원 ID
    required String memberId,

    /// 회원 이름 (조회 편의용)
    required String memberName,

    /// 결제 금액 (원 단위)
    required int amount,

    /// 결제 일자
    @TimestampConverter() required DateTime paymentDate,

    /// 구매한 PT 횟수
    required int ptSessions,

    /// 결제 방법
    required PaymentMethod paymentMethod,

    /// 메모 (선택)
    String? memo,

    /// 생성 일시
    @TimestampConverter() required DateTime createdAt,
  }) = _PaymentRecordModel;

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentRecordModelFromJson(json);

  /// Firestore 문서로부터 생성
  factory PaymentRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentRecordModel._fromMap({...data, 'id': doc.id});
  }

  /// Map으로부터 안전하게 생성
  factory PaymentRecordModel._fromMap(Map<String, dynamic> data) {
    return PaymentRecordModel(
      id: data['id'] as String? ?? '',
      trainerId: data['trainerId'] as String? ?? '',
      memberId: data['memberId'] as String? ?? '',
      memberName: data['memberName'] as String? ?? '',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      paymentDate: _parseTimestamp(data['paymentDate']) ?? DateTime.now(),
      ptSessions: (data['ptSessions'] as num?)?.toInt() ?? 0,
      paymentMethod: _parsePaymentMethod(data['paymentMethod']),
      memo: data['memo'] as String?,
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
    );
  }

  /// Timestamp 파싱 헬퍼
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// PaymentMethod 파싱 헬퍼
  static PaymentMethod _parsePaymentMethod(dynamic value) {
    if (value == null) return PaymentMethod.other;
    final str = value.toString().toLowerCase();
    return PaymentMethod.values.firstWhere(
      (m) => m.name == str,
      orElse: () => PaymentMethod.other,
    );
  }

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'trainerId': trainerId,
      'memberId': memberId,
      'memberName': memberName,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'ptSessions': ptSessions,
      'paymentMethod': paymentMethod.name,
      'memo': memo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// 결제 방법 라벨 (한글)
  String get paymentMethodLabel => switch (paymentMethod) {
        PaymentMethod.card => '카드',
        PaymentMethod.cash => '현금',
        PaymentMethod.transfer => '계좌이체',
        PaymentMethod.other => '기타',
      };

  /// PT 1회당 단가
  double get pricePerSession {
    if (ptSessions == 0) return 0;
    return amount / ptSessions;
  }

  /// 금액 포맷팅 (예: "1,500,000원")
  String get formattedAmount {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formatted원';
  }
}

/// 결제 요약 모델
/// 매출 통계 표시용
@freezed
sealed class PaymentSummary with _$PaymentSummary {
  const PaymentSummary._();

  const factory PaymentSummary({
    /// 총 매출액 (원)
    @Default(0) int totalRevenue,

    /// 이번 달 매출액 (원)
    @Default(0) int monthlyRevenue,

    /// 결제한 회원 수
    @Default(0) int memberCount,

    /// 회원당 평균 결제액
    @Default(0.0) double averagePerMember,
  }) = _PaymentSummary;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) =>
      _$PaymentSummaryFromJson(json);

  /// 결제 기록 리스트로부터 요약 생성
  factory PaymentSummary.fromRecords(List<PaymentRecordModel> records) {
    if (records.isEmpty) {
      return const PaymentSummary();
    }

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    // 총 매출
    final total = records.fold<int>(0, (acc, r) => acc + r.amount);

    // 이번 달 매출
    final monthly = records
        .where((r) =>
            r.paymentDate.year == currentMonth.year &&
            r.paymentDate.month == currentMonth.month)
        .fold<int>(0, (acc, r) => acc + r.amount);

    // 유니크 회원 수
    final uniqueMembers = records.map((r) => r.memberId).toSet().length;

    // 회원당 평균
    final average = uniqueMembers > 0 ? total / uniqueMembers : 0.0;

    return PaymentSummary(
      totalRevenue: total,
      monthlyRevenue: monthly,
      memberCount: uniqueMembers,
      averagePerMember: average,
    );
  }

  /// 총 매출 포맷팅
  String get formattedTotalRevenue => _formatCurrency(totalRevenue);

  /// 이번 달 매출 포맷팅
  String get formattedMonthlyRevenue => _formatCurrency(monthlyRevenue);

  /// 회원당 평균 포맷팅
  String get formattedAveragePerMember =>
      _formatCurrency(averagePerMember.round());

  /// 통화 포맷팅 헬퍼
  String _formatCurrency(int amount) {
    final formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '$formatted원';
  }
}

/// 월별 매출 데이터 (차트용)
@freezed
sealed class MonthlyRevenue with _$MonthlyRevenue {
  const factory MonthlyRevenue({
    /// 년도
    required int year,

    /// 월 (1-12)
    required int month,

    /// 매출 (원)
    required int revenue,

    /// 결제 건수
    required int count,
  }) = _MonthlyRevenue;

  factory MonthlyRevenue.fromJson(Map<String, dynamic> json) =>
      _$MonthlyRevenueFromJson(json);
}
