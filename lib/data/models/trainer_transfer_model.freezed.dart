// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_transfer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerTransferModel {

/// Firestore 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 회원 이름
 String get memberName;/// 현재 트레이너 ID
 String get fromTrainerId;/// 현재 트레이너 이름
 String get fromTrainerName;/// 새 트레이너 ID
 String get toTrainerId;/// 새 트레이너 이름
 String get toTrainerName;/// 전환 상태
 TransferStatus get status;/// 전환 사유
 String get reason;/// 요청일
@TimestampConverter() DateTime get requestedAt;/// 응답일
@NullableTimestampConverter() DateTime? get respondedAt;
/// Create a copy of TrainerTransferModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerTransferModelCopyWith<TrainerTransferModel> get copyWith => _$TrainerTransferModelCopyWithImpl<TrainerTransferModel>(this as TrainerTransferModel, _$identity);

  /// Serializes this TrainerTransferModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerTransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.fromTrainerId, fromTrainerId) || other.fromTrainerId == fromTrainerId)&&(identical(other.fromTrainerName, fromTrainerName) || other.fromTrainerName == fromTrainerName)&&(identical(other.toTrainerId, toTrainerId) || other.toTrainerId == toTrainerId)&&(identical(other.toTrainerName, toTrainerName) || other.toTrainerName == toTrainerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,fromTrainerId,fromTrainerName,toTrainerId,toTrainerName,status,reason,requestedAt,respondedAt);

@override
String toString() {
  return 'TrainerTransferModel(id: $id, memberId: $memberId, memberName: $memberName, fromTrainerId: $fromTrainerId, fromTrainerName: $fromTrainerName, toTrainerId: $toTrainerId, toTrainerName: $toTrainerName, status: $status, reason: $reason, requestedAt: $requestedAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $TrainerTransferModelCopyWith<$Res>  {
  factory $TrainerTransferModelCopyWith(TrainerTransferModel value, $Res Function(TrainerTransferModel) _then) = _$TrainerTransferModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String memberName, String fromTrainerId, String fromTrainerName, String toTrainerId, String toTrainerName, TransferStatus status, String reason,@TimestampConverter() DateTime requestedAt,@NullableTimestampConverter() DateTime? respondedAt
});




}
/// @nodoc
class _$TrainerTransferModelCopyWithImpl<$Res>
    implements $TrainerTransferModelCopyWith<$Res> {
  _$TrainerTransferModelCopyWithImpl(this._self, this._then);

  final TrainerTransferModel _self;
  final $Res Function(TrainerTransferModel) _then;

/// Create a copy of TrainerTransferModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? fromTrainerId = null,Object? fromTrainerName = null,Object? toTrainerId = null,Object? toTrainerName = null,Object? status = null,Object? reason = null,Object? requestedAt = null,Object? respondedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,fromTrainerId: null == fromTrainerId ? _self.fromTrainerId : fromTrainerId // ignore: cast_nullable_to_non_nullable
as String,fromTrainerName: null == fromTrainerName ? _self.fromTrainerName : fromTrainerName // ignore: cast_nullable_to_non_nullable
as String,toTrainerId: null == toTrainerId ? _self.toTrainerId : toTrainerId // ignore: cast_nullable_to_non_nullable
as String,toTrainerName: null == toTrainerName ? _self.toTrainerName : toTrainerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerTransferModel].
extension TrainerTransferModelPatterns on TrainerTransferModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerTransferModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerTransferModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerTransferModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerTransferModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerTransferModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerTransferModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String fromTrainerId,  String fromTrainerName,  String toTrainerId,  String toTrainerName,  TransferStatus status,  String reason, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerTransferModel() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.fromTrainerId,_that.fromTrainerName,_that.toTrainerId,_that.toTrainerName,_that.status,_that.reason,_that.requestedAt,_that.respondedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  String fromTrainerId,  String fromTrainerName,  String toTrainerId,  String toTrainerName,  TransferStatus status,  String reason, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? respondedAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerTransferModel():
return $default(_that.id,_that.memberId,_that.memberName,_that.fromTrainerId,_that.fromTrainerName,_that.toTrainerId,_that.toTrainerName,_that.status,_that.reason,_that.requestedAt,_that.respondedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String memberName,  String fromTrainerId,  String fromTrainerName,  String toTrainerId,  String toTrainerName,  TransferStatus status,  String reason, @TimestampConverter()  DateTime requestedAt, @NullableTimestampConverter()  DateTime? respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerTransferModel() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.fromTrainerId,_that.fromTrainerName,_that.toTrainerId,_that.toTrainerName,_that.status,_that.reason,_that.requestedAt,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerTransferModel implements TrainerTransferModel {
  const _TrainerTransferModel({this.id = '', required this.memberId, required this.memberName, required this.fromTrainerId, required this.fromTrainerName, required this.toTrainerId, required this.toTrainerName, this.status = TransferStatus.pending, this.reason = '', @TimestampConverter() required this.requestedAt, @NullableTimestampConverter() this.respondedAt});
  factory _TrainerTransferModel.fromJson(Map<String, dynamic> json) => _$TrainerTransferModelFromJson(json);

/// Firestore 문서 ID
@override@JsonKey() final  String id;
/// 회원 ID
@override final  String memberId;
/// 회원 이름
@override final  String memberName;
/// 현재 트레이너 ID
@override final  String fromTrainerId;
/// 현재 트레이너 이름
@override final  String fromTrainerName;
/// 새 트레이너 ID
@override final  String toTrainerId;
/// 새 트레이너 이름
@override final  String toTrainerName;
/// 전환 상태
@override@JsonKey() final  TransferStatus status;
/// 전환 사유
@override@JsonKey() final  String reason;
/// 요청일
@override@TimestampConverter() final  DateTime requestedAt;
/// 응답일
@override@NullableTimestampConverter() final  DateTime? respondedAt;

/// Create a copy of TrainerTransferModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerTransferModelCopyWith<_TrainerTransferModel> get copyWith => __$TrainerTransferModelCopyWithImpl<_TrainerTransferModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerTransferModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerTransferModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.fromTrainerId, fromTrainerId) || other.fromTrainerId == fromTrainerId)&&(identical(other.fromTrainerName, fromTrainerName) || other.fromTrainerName == fromTrainerName)&&(identical(other.toTrainerId, toTrainerId) || other.toTrainerId == toTrainerId)&&(identical(other.toTrainerName, toTrainerName) || other.toTrainerName == toTrainerName)&&(identical(other.status, status) || other.status == status)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,fromTrainerId,fromTrainerName,toTrainerId,toTrainerName,status,reason,requestedAt,respondedAt);

@override
String toString() {
  return 'TrainerTransferModel(id: $id, memberId: $memberId, memberName: $memberName, fromTrainerId: $fromTrainerId, fromTrainerName: $fromTrainerName, toTrainerId: $toTrainerId, toTrainerName: $toTrainerName, status: $status, reason: $reason, requestedAt: $requestedAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerTransferModelCopyWith<$Res> implements $TrainerTransferModelCopyWith<$Res> {
  factory _$TrainerTransferModelCopyWith(_TrainerTransferModel value, $Res Function(_TrainerTransferModel) _then) = __$TrainerTransferModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String memberName, String fromTrainerId, String fromTrainerName, String toTrainerId, String toTrainerName, TransferStatus status, String reason,@TimestampConverter() DateTime requestedAt,@NullableTimestampConverter() DateTime? respondedAt
});




}
/// @nodoc
class __$TrainerTransferModelCopyWithImpl<$Res>
    implements _$TrainerTransferModelCopyWith<$Res> {
  __$TrainerTransferModelCopyWithImpl(this._self, this._then);

  final _TrainerTransferModel _self;
  final $Res Function(_TrainerTransferModel) _then;

/// Create a copy of TrainerTransferModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? fromTrainerId = null,Object? fromTrainerName = null,Object? toTrainerId = null,Object? toTrainerName = null,Object? status = null,Object? reason = null,Object? requestedAt = null,Object? respondedAt = freezed,}) {
  return _then(_TrainerTransferModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,fromTrainerId: null == fromTrainerId ? _self.fromTrainerId : fromTrainerId // ignore: cast_nullable_to_non_nullable
as String,fromTrainerName: null == fromTrainerName ? _self.fromTrainerName : fromTrainerName // ignore: cast_nullable_to_non_nullable
as String,toTrainerId: null == toTrainerId ? _self.toTrainerId : toTrainerId // ignore: cast_nullable_to_non_nullable
as String,toTrainerName: null == toTrainerName ? _self.toTrainerName : toTrainerName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TransferStatus,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,requestedAt: null == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
