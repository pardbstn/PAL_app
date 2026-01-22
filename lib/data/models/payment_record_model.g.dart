// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentRecordModel _$PaymentRecordModelFromJson(Map<String, dynamic> json) =>
    _PaymentRecordModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String,
      amount: (json['amount'] as num).toInt(),
      paymentDate: const TimestampConverter().fromJson(json['paymentDate']),
      ptSessions: (json['ptSessions'] as num).toInt(),
      paymentMethod: $enumDecode(_$PaymentMethodEnumMap, json['paymentMethod']),
      memo: json['memo'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$PaymentRecordModelToJson(_PaymentRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trainerId': instance.trainerId,
      'memberId': instance.memberId,
      'memberName': instance.memberName,
      'amount': instance.amount,
      'paymentDate': const TimestampConverter().toJson(instance.paymentDate),
      'ptSessions': instance.ptSessions,
      'paymentMethod': _$PaymentMethodEnumMap[instance.paymentMethod]!,
      'memo': instance.memo,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$PaymentMethodEnumMap = {
  PaymentMethod.card: 'card',
  PaymentMethod.cash: 'cash',
  PaymentMethod.transfer: 'transfer',
  PaymentMethod.other: 'other',
};

_PaymentSummary _$PaymentSummaryFromJson(Map<String, dynamic> json) =>
    _PaymentSummary(
      totalRevenue: (json['totalRevenue'] as num?)?.toInt() ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toInt() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      averagePerMember: (json['averagePerMember'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$PaymentSummaryToJson(_PaymentSummary instance) =>
    <String, dynamic>{
      'totalRevenue': instance.totalRevenue,
      'monthlyRevenue': instance.monthlyRevenue,
      'memberCount': instance.memberCount,
      'averagePerMember': instance.averagePerMember,
    };

_MonthlyRevenue _$MonthlyRevenueFromJson(Map<String, dynamic> json) =>
    _MonthlyRevenue(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      revenue: (json['revenue'] as num).toInt(),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$MonthlyRevenueToJson(_MonthlyRevenue instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'revenue': instance.revenue,
      'count': instance.count,
    };
