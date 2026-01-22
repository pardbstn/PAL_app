// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PaymentRecordModel {

/// 결제 기록 문서 ID
 String get id;/// 트레이너 ID
 String get trainerId;/// 회원 ID
 String get memberId;/// 회원 이름 (조회 편의용)
 String get memberName;/// 결제 금액 (원 단위)
 int get amount;/// 결제 일자
@TimestampConverter() DateTime get paymentDate;/// 구매한 PT 횟수
 int get ptSessions;/// 결제 방법
 PaymentMethod get paymentMethod;/// 메모 (선택)
 String? get memo;/// 생성 일시
@TimestampConverter() DateTime get createdAt;
/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentRecordModelCopyWith<PaymentRecordModel> get copyWith => _$PaymentRecordModelCopyWithImpl<PaymentRecordModel>(this as PaymentRecordModel, _$identity);

  /// Serializes this PaymentRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.ptSessions, ptSessions) || other.ptSessions == ptSessions)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,memberName,amount,paymentDate,ptSessions,paymentMethod,memo,createdAt);

@override
String toString() {
  return 'PaymentRecordModel(id: $id, trainerId: $trainerId, memberId: $memberId, memberName: $memberName, amount: $amount, paymentDate: $paymentDate, ptSessions: $ptSessions, paymentMethod: $paymentMethod, memo: $memo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $PaymentRecordModelCopyWith<$Res>  {
  factory $PaymentRecordModelCopyWith(PaymentRecordModel value, $Res Function(PaymentRecordModel) _then) = _$PaymentRecordModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String memberId, String memberName, int amount,@TimestampConverter() DateTime paymentDate, int ptSessions, PaymentMethod paymentMethod, String? memo,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$PaymentRecordModelCopyWithImpl<$Res>
    implements $PaymentRecordModelCopyWith<$Res> {
  _$PaymentRecordModelCopyWithImpl(this._self, this._then);

  final PaymentRecordModel _self;
  final $Res Function(PaymentRecordModel) _then;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? memberName = null,Object? amount = null,Object? paymentDate = null,Object? ptSessions = null,Object? paymentMethod = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,ptSessions: null == ptSessions ? _self.ptSessions : ptSessions // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentRecordModel].
extension PaymentRecordModelPatterns on PaymentRecordModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _PaymentRecordModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  String memberName,  int amount, @TimestampConverter()  DateTime paymentDate,  int ptSessions,  PaymentMethod paymentMethod,  String? memo, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.amount,_that.paymentDate,_that.ptSessions,_that.paymentMethod,_that.memo,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  String memberName,  int amount, @TimestampConverter()  DateTime paymentDate,  int ptSessions,  PaymentMethod paymentMethod,  String? memo, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel():
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.amount,_that.paymentDate,_that.ptSessions,_that.paymentMethod,_that.memo,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String memberId,  String memberName,  int amount, @TimestampConverter()  DateTime paymentDate,  int ptSessions,  PaymentMethod paymentMethod,  String? memo, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentRecordModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.amount,_that.paymentDate,_that.ptSessions,_that.paymentMethod,_that.memo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentRecordModel extends PaymentRecordModel {
  const _PaymentRecordModel({required this.id, required this.trainerId, required this.memberId, required this.memberName, required this.amount, @TimestampConverter() required this.paymentDate, required this.ptSessions, required this.paymentMethod, this.memo, @TimestampConverter() required this.createdAt}): super._();
  factory _PaymentRecordModel.fromJson(Map<String, dynamic> json) => _$PaymentRecordModelFromJson(json);

/// 결제 기록 문서 ID
@override final  String id;
/// 트레이너 ID
@override final  String trainerId;
/// 회원 ID
@override final  String memberId;
/// 회원 이름 (조회 편의용)
@override final  String memberName;
/// 결제 금액 (원 단위)
@override final  int amount;
/// 결제 일자
@override@TimestampConverter() final  DateTime paymentDate;
/// 구매한 PT 횟수
@override final  int ptSessions;
/// 결제 방법
@override final  PaymentMethod paymentMethod;
/// 메모 (선택)
@override final  String? memo;
/// 생성 일시
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentRecordModelCopyWith<_PaymentRecordModel> get copyWith => __$PaymentRecordModelCopyWithImpl<_PaymentRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.paymentDate, paymentDate) || other.paymentDate == paymentDate)&&(identical(other.ptSessions, ptSessions) || other.ptSessions == ptSessions)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,memberName,amount,paymentDate,ptSessions,paymentMethod,memo,createdAt);

@override
String toString() {
  return 'PaymentRecordModel(id: $id, trainerId: $trainerId, memberId: $memberId, memberName: $memberName, amount: $amount, paymentDate: $paymentDate, ptSessions: $ptSessions, paymentMethod: $paymentMethod, memo: $memo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentRecordModelCopyWith<$Res> implements $PaymentRecordModelCopyWith<$Res> {
  factory _$PaymentRecordModelCopyWith(_PaymentRecordModel value, $Res Function(_PaymentRecordModel) _then) = __$PaymentRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String memberId, String memberName, int amount,@TimestampConverter() DateTime paymentDate, int ptSessions, PaymentMethod paymentMethod, String? memo,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$PaymentRecordModelCopyWithImpl<$Res>
    implements _$PaymentRecordModelCopyWith<$Res> {
  __$PaymentRecordModelCopyWithImpl(this._self, this._then);

  final _PaymentRecordModel _self;
  final $Res Function(_PaymentRecordModel) _then;

/// Create a copy of PaymentRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? memberName = null,Object? amount = null,Object? paymentDate = null,Object? ptSessions = null,Object? paymentMethod = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(_PaymentRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,paymentDate: null == paymentDate ? _self.paymentDate : paymentDate // ignore: cast_nullable_to_non_nullable
as DateTime,ptSessions: null == ptSessions ? _self.ptSessions : ptSessions // ignore: cast_nullable_to_non_nullable
as int,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as PaymentMethod,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$PaymentSummary {

/// 총 매출액 (원)
 int get totalRevenue;/// 이번 달 매출액 (원)
 int get monthlyRevenue;/// 결제한 회원 수
 int get memberCount;/// 회원당 평균 결제액
 double get averagePerMember;
/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentSummaryCopyWith<PaymentSummary> get copyWith => _$PaymentSummaryCopyWithImpl<PaymentSummary>(this as PaymentSummary, _$identity);

  /// Serializes this PaymentSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.monthlyRevenue, monthlyRevenue) || other.monthlyRevenue == monthlyRevenue)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.averagePerMember, averagePerMember) || other.averagePerMember == averagePerMember));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,monthlyRevenue,memberCount,averagePerMember);

@override
String toString() {
  return 'PaymentSummary(totalRevenue: $totalRevenue, monthlyRevenue: $monthlyRevenue, memberCount: $memberCount, averagePerMember: $averagePerMember)';
}


}

/// @nodoc
abstract mixin class $PaymentSummaryCopyWith<$Res>  {
  factory $PaymentSummaryCopyWith(PaymentSummary value, $Res Function(PaymentSummary) _then) = _$PaymentSummaryCopyWithImpl;
@useResult
$Res call({
 int totalRevenue, int monthlyRevenue, int memberCount, double averagePerMember
});




}
/// @nodoc
class _$PaymentSummaryCopyWithImpl<$Res>
    implements $PaymentSummaryCopyWith<$Res> {
  _$PaymentSummaryCopyWithImpl(this._self, this._then);

  final PaymentSummary _self;
  final $Res Function(PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalRevenue = null,Object? monthlyRevenue = null,Object? memberCount = null,Object? averagePerMember = null,}) {
  return _then(_self.copyWith(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as int,monthlyRevenue: null == monthlyRevenue ? _self.monthlyRevenue : monthlyRevenue // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,averagePerMember: null == averagePerMember ? _self.averagePerMember : averagePerMember // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentSummary].
extension PaymentSummaryPatterns on PaymentSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentSummary value)  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalRevenue,  int monthlyRevenue,  int memberCount,  double averagePerMember)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.totalRevenue,_that.monthlyRevenue,_that.memberCount,_that.averagePerMember);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalRevenue,  int monthlyRevenue,  int memberCount,  double averagePerMember)  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary():
return $default(_that.totalRevenue,_that.monthlyRevenue,_that.memberCount,_that.averagePerMember);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalRevenue,  int monthlyRevenue,  int memberCount,  double averagePerMember)?  $default,) {final _that = this;
switch (_that) {
case _PaymentSummary() when $default != null:
return $default(_that.totalRevenue,_that.monthlyRevenue,_that.memberCount,_that.averagePerMember);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaymentSummary extends PaymentSummary {
  const _PaymentSummary({this.totalRevenue = 0, this.monthlyRevenue = 0, this.memberCount = 0, this.averagePerMember = 0.0}): super._();
  factory _PaymentSummary.fromJson(Map<String, dynamic> json) => _$PaymentSummaryFromJson(json);

/// 총 매출액 (원)
@override@JsonKey() final  int totalRevenue;
/// 이번 달 매출액 (원)
@override@JsonKey() final  int monthlyRevenue;
/// 결제한 회원 수
@override@JsonKey() final  int memberCount;
/// 회원당 평균 결제액
@override@JsonKey() final  double averagePerMember;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentSummaryCopyWith<_PaymentSummary> get copyWith => __$PaymentSummaryCopyWithImpl<_PaymentSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaymentSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentSummary&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.monthlyRevenue, monthlyRevenue) || other.monthlyRevenue == monthlyRevenue)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.averagePerMember, averagePerMember) || other.averagePerMember == averagePerMember));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalRevenue,monthlyRevenue,memberCount,averagePerMember);

@override
String toString() {
  return 'PaymentSummary(totalRevenue: $totalRevenue, monthlyRevenue: $monthlyRevenue, memberCount: $memberCount, averagePerMember: $averagePerMember)';
}


}

/// @nodoc
abstract mixin class _$PaymentSummaryCopyWith<$Res> implements $PaymentSummaryCopyWith<$Res> {
  factory _$PaymentSummaryCopyWith(_PaymentSummary value, $Res Function(_PaymentSummary) _then) = __$PaymentSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalRevenue, int monthlyRevenue, int memberCount, double averagePerMember
});




}
/// @nodoc
class __$PaymentSummaryCopyWithImpl<$Res>
    implements _$PaymentSummaryCopyWith<$Res> {
  __$PaymentSummaryCopyWithImpl(this._self, this._then);

  final _PaymentSummary _self;
  final $Res Function(_PaymentSummary) _then;

/// Create a copy of PaymentSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalRevenue = null,Object? monthlyRevenue = null,Object? memberCount = null,Object? averagePerMember = null,}) {
  return _then(_PaymentSummary(
totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as int,monthlyRevenue: null == monthlyRevenue ? _self.monthlyRevenue : monthlyRevenue // ignore: cast_nullable_to_non_nullable
as int,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,averagePerMember: null == averagePerMember ? _self.averagePerMember : averagePerMember // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$MonthlyRevenue {

/// 년도
 int get year;/// 월 (1-12)
 int get month;/// 매출 (원)
 int get revenue;/// 결제 건수
 int get count;
/// Create a copy of MonthlyRevenue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthlyRevenueCopyWith<MonthlyRevenue> get copyWith => _$MonthlyRevenueCopyWithImpl<MonthlyRevenue>(this as MonthlyRevenue, _$identity);

  /// Serializes this MonthlyRevenue to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthlyRevenue&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,revenue,count);

@override
String toString() {
  return 'MonthlyRevenue(year: $year, month: $month, revenue: $revenue, count: $count)';
}


}

/// @nodoc
abstract mixin class $MonthlyRevenueCopyWith<$Res>  {
  factory $MonthlyRevenueCopyWith(MonthlyRevenue value, $Res Function(MonthlyRevenue) _then) = _$MonthlyRevenueCopyWithImpl;
@useResult
$Res call({
 int year, int month, int revenue, int count
});




}
/// @nodoc
class _$MonthlyRevenueCopyWithImpl<$Res>
    implements $MonthlyRevenueCopyWith<$Res> {
  _$MonthlyRevenueCopyWithImpl(this._self, this._then);

  final MonthlyRevenue _self;
  final $Res Function(MonthlyRevenue) _then;

/// Create a copy of MonthlyRevenue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? revenue = null,Object? count = null,}) {
  return _then(_self.copyWith(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthlyRevenue].
extension MonthlyRevenuePatterns on MonthlyRevenue {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthlyRevenue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthlyRevenue() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthlyRevenue value)  $default,){
final _that = this;
switch (_that) {
case _MonthlyRevenue():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthlyRevenue value)?  $default,){
final _that = this;
switch (_that) {
case _MonthlyRevenue() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int revenue,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthlyRevenue() when $default != null:
return $default(_that.year,_that.month,_that.revenue,_that.count);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int revenue,  int count)  $default,) {final _that = this;
switch (_that) {
case _MonthlyRevenue():
return $default(_that.year,_that.month,_that.revenue,_that.count);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int revenue,  int count)?  $default,) {final _that = this;
switch (_that) {
case _MonthlyRevenue() when $default != null:
return $default(_that.year,_that.month,_that.revenue,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthlyRevenue implements MonthlyRevenue {
  const _MonthlyRevenue({required this.year, required this.month, required this.revenue, required this.count});
  factory _MonthlyRevenue.fromJson(Map<String, dynamic> json) => _$MonthlyRevenueFromJson(json);

/// 년도
@override final  int year;
/// 월 (1-12)
@override final  int month;
/// 매출 (원)
@override final  int revenue;
/// 결제 건수
@override final  int count;

/// Create a copy of MonthlyRevenue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthlyRevenueCopyWith<_MonthlyRevenue> get copyWith => __$MonthlyRevenueCopyWithImpl<_MonthlyRevenue>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthlyRevenueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthlyRevenue&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.revenue, revenue) || other.revenue == revenue)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,year,month,revenue,count);

@override
String toString() {
  return 'MonthlyRevenue(year: $year, month: $month, revenue: $revenue, count: $count)';
}


}

/// @nodoc
abstract mixin class _$MonthlyRevenueCopyWith<$Res> implements $MonthlyRevenueCopyWith<$Res> {
  factory _$MonthlyRevenueCopyWith(_MonthlyRevenue value, $Res Function(_MonthlyRevenue) _then) = __$MonthlyRevenueCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int revenue, int count
});




}
/// @nodoc
class __$MonthlyRevenueCopyWithImpl<$Res>
    implements _$MonthlyRevenueCopyWith<$Res> {
  __$MonthlyRevenueCopyWithImpl(this._self, this._then);

  final _MonthlyRevenue _self;
  final $Res Function(_MonthlyRevenue) _then;

/// Create a copy of MonthlyRevenue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? revenue = null,Object? count = null,}) {
  return _then(_MonthlyRevenue(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as int,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
