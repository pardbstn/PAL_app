// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BodyRecordModel {

/// 기록 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 측정 날짜
@TimestampConverter() DateTime get recordDate;/// 체중 (kg)
 double get weight;/// 체지방률 (%)
 double? get bodyFatPercent;/// 골격근량 (kg)
 double? get muscleMass;/// BMI
 double? get bmi;/// 기초대사량 (kcal)
 double? get bmr;/// 기록 소스 ('manual' | 'inbody_api')
 RecordSource get source;/// 메모
 String? get note;/// 생성일
@TimestampConverter() DateTime get createdAt;
/// Create a copy of BodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyRecordModelCopyWith<BodyRecordModel> get copyWith => _$BodyRecordModelCopyWithImpl<BodyRecordModel>(this as BodyRecordModel, _$identity);

  /// Serializes this BodyRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.muscleMass, muscleMass) || other.muscleMass == muscleMass)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.bmr, bmr) || other.bmr == bmr)&&(identical(other.source, source) || other.source == source)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,recordDate,weight,bodyFatPercent,muscleMass,bmi,bmr,source,note,createdAt);

@override
String toString() {
  return 'BodyRecordModel(id: $id, memberId: $memberId, recordDate: $recordDate, weight: $weight, bodyFatPercent: $bodyFatPercent, muscleMass: $muscleMass, bmi: $bmi, bmr: $bmr, source: $source, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BodyRecordModelCopyWith<$Res>  {
  factory $BodyRecordModelCopyWith(BodyRecordModel value, $Res Function(BodyRecordModel) _then) = _$BodyRecordModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime recordDate, double weight, double? bodyFatPercent, double? muscleMass, double? bmi, double? bmr, RecordSource source, String? note,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$BodyRecordModelCopyWithImpl<$Res>
    implements $BodyRecordModelCopyWith<$Res> {
  _$BodyRecordModelCopyWithImpl(this._self, this._then);

  final BodyRecordModel _self;
  final $Res Function(BodyRecordModel) _then;

/// Create a copy of BodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? recordDate = null,Object? weight = null,Object? bodyFatPercent = freezed,Object? muscleMass = freezed,Object? bmi = freezed,Object? bmr = freezed,Object? source = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,bodyFatPercent: freezed == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double?,muscleMass: freezed == muscleMass ? _self.muscleMass : muscleMass // ignore: cast_nullable_to_non_nullable
as double?,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,bmr: freezed == bmr ? _self.bmr : bmr // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RecordSource,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BodyRecordModel].
extension BodyRecordModelPatterns on BodyRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _BodyRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _BodyRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  double weight,  double? bodyFatPercent,  double? muscleMass,  double? bmi,  double? bmr,  RecordSource source,  String? note, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.recordDate,_that.weight,_that.bodyFatPercent,_that.muscleMass,_that.bmi,_that.bmr,_that.source,_that.note,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  double weight,  double? bodyFatPercent,  double? muscleMass,  double? bmi,  double? bmr,  RecordSource source,  String? note, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BodyRecordModel():
return $default(_that.id,_that.memberId,_that.recordDate,_that.weight,_that.bodyFatPercent,_that.muscleMass,_that.bmi,_that.bmr,_that.source,_that.note,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  double weight,  double? bodyFatPercent,  double? muscleMass,  double? bmi,  double? bmr,  RecordSource source,  String? note, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BodyRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.recordDate,_that.weight,_that.bodyFatPercent,_that.muscleMass,_that.bmi,_that.bmr,_that.source,_that.note,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyRecordModel implements BodyRecordModel {
  const _BodyRecordModel({required this.id, required this.memberId, @TimestampConverter() required this.recordDate, required this.weight, this.bodyFatPercent, this.muscleMass, this.bmi, this.bmr, this.source = RecordSource.manual, this.note, @TimestampConverter() required this.createdAt});
  factory _BodyRecordModel.fromJson(Map<String, dynamic> json) => _$BodyRecordModelFromJson(json);

/// 기록 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 측정 날짜
@override@TimestampConverter() final  DateTime recordDate;
/// 체중 (kg)
@override final  double weight;
/// 체지방률 (%)
@override final  double? bodyFatPercent;
/// 골격근량 (kg)
@override final  double? muscleMass;
/// BMI
@override final  double? bmi;
/// 기초대사량 (kcal)
@override final  double? bmr;
/// 기록 소스 ('manual' | 'inbody_api')
@override@JsonKey() final  RecordSource source;
/// 메모
@override final  String? note;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of BodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyRecordModelCopyWith<_BodyRecordModel> get copyWith => __$BodyRecordModelCopyWithImpl<_BodyRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.muscleMass, muscleMass) || other.muscleMass == muscleMass)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.bmr, bmr) || other.bmr == bmr)&&(identical(other.source, source) || other.source == source)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,recordDate,weight,bodyFatPercent,muscleMass,bmi,bmr,source,note,createdAt);

@override
String toString() {
  return 'BodyRecordModel(id: $id, memberId: $memberId, recordDate: $recordDate, weight: $weight, bodyFatPercent: $bodyFatPercent, muscleMass: $muscleMass, bmi: $bmi, bmr: $bmr, source: $source, note: $note, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BodyRecordModelCopyWith<$Res> implements $BodyRecordModelCopyWith<$Res> {
  factory _$BodyRecordModelCopyWith(_BodyRecordModel value, $Res Function(_BodyRecordModel) _then) = __$BodyRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime recordDate, double weight, double? bodyFatPercent, double? muscleMass, double? bmi, double? bmr, RecordSource source, String? note,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$BodyRecordModelCopyWithImpl<$Res>
    implements _$BodyRecordModelCopyWith<$Res> {
  __$BodyRecordModelCopyWithImpl(this._self, this._then);

  final _BodyRecordModel _self;
  final $Res Function(_BodyRecordModel) _then;

/// Create a copy of BodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? recordDate = null,Object? weight = null,Object? bodyFatPercent = freezed,Object? muscleMass = freezed,Object? bmi = freezed,Object? bmr = freezed,Object? source = null,Object? note = freezed,Object? createdAt = null,}) {
  return _then(_BodyRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,bodyFatPercent: freezed == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double?,muscleMass: freezed == muscleMass ? _self.muscleMass : muscleMass // ignore: cast_nullable_to_non_nullable
as double?,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,bmr: freezed == bmr ? _self.bmr : bmr // ignore: cast_nullable_to_non_nullable
as double?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RecordSource,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
