// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbody_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InbodyRecordModel {

/// 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 측정 일시
@TimestampConverter() DateTime get measuredAt;/// 체중 (kg)
 double get weight;/// 골격근량 (kg)
 double get skeletalMuscleMass;/// 체지방량 (kg)
 double? get bodyFatMass;/// 체지방률 (%)
 double get bodyFatPercent;/// BMI (kg/m²)
 double? get bmi;/// 기초대사량 (kcal)
 double? get basalMetabolicRate;/// 체수분량 (L)
 double? get totalBodyWater;/// 단백질량 (kg)
 double? get protein;/// 무기질량 (kg)
 double? get minerals;/// 내장지방 레벨
 int? get visceralFatLevel;/// 인바디 점수
 int? get inbodyScore;/// 데이터 소스
 InbodySource get source;/// 메모
 String? get memo;/// 생성 일시
@TimestampConverter() DateTime get createdAt;
/// Create a copy of InbodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InbodyRecordModelCopyWith<InbodyRecordModel> get copyWith => _$InbodyRecordModelCopyWithImpl<InbodyRecordModel>(this as InbodyRecordModel, _$identity);

  /// Serializes this InbodyRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InbodyRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.skeletalMuscleMass, skeletalMuscleMass) || other.skeletalMuscleMass == skeletalMuscleMass)&&(identical(other.bodyFatMass, bodyFatMass) || other.bodyFatMass == bodyFatMass)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.basalMetabolicRate, basalMetabolicRate) || other.basalMetabolicRate == basalMetabolicRate)&&(identical(other.totalBodyWater, totalBodyWater) || other.totalBodyWater == totalBodyWater)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.minerals, minerals) || other.minerals == minerals)&&(identical(other.visceralFatLevel, visceralFatLevel) || other.visceralFatLevel == visceralFatLevel)&&(identical(other.inbodyScore, inbodyScore) || other.inbodyScore == inbodyScore)&&(identical(other.source, source) || other.source == source)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,measuredAt,weight,skeletalMuscleMass,bodyFatMass,bodyFatPercent,bmi,basalMetabolicRate,totalBodyWater,protein,minerals,visceralFatLevel,inbodyScore,source,memo,createdAt);

@override
String toString() {
  return 'InbodyRecordModel(id: $id, memberId: $memberId, measuredAt: $measuredAt, weight: $weight, skeletalMuscleMass: $skeletalMuscleMass, bodyFatMass: $bodyFatMass, bodyFatPercent: $bodyFatPercent, bmi: $bmi, basalMetabolicRate: $basalMetabolicRate, totalBodyWater: $totalBodyWater, protein: $protein, minerals: $minerals, visceralFatLevel: $visceralFatLevel, inbodyScore: $inbodyScore, source: $source, memo: $memo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $InbodyRecordModelCopyWith<$Res>  {
  factory $InbodyRecordModelCopyWith(InbodyRecordModel value, $Res Function(InbodyRecordModel) _then) = _$InbodyRecordModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime measuredAt, double weight, double skeletalMuscleMass, double? bodyFatMass, double bodyFatPercent, double? bmi, double? basalMetabolicRate, double? totalBodyWater, double? protein, double? minerals, int? visceralFatLevel, int? inbodyScore, InbodySource source, String? memo,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$InbodyRecordModelCopyWithImpl<$Res>
    implements $InbodyRecordModelCopyWith<$Res> {
  _$InbodyRecordModelCopyWithImpl(this._self, this._then);

  final InbodyRecordModel _self;
  final $Res Function(InbodyRecordModel) _then;

/// Create a copy of InbodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? measuredAt = null,Object? weight = null,Object? skeletalMuscleMass = null,Object? bodyFatMass = freezed,Object? bodyFatPercent = null,Object? bmi = freezed,Object? basalMetabolicRate = freezed,Object? totalBodyWater = freezed,Object? protein = freezed,Object? minerals = freezed,Object? visceralFatLevel = freezed,Object? inbodyScore = freezed,Object? source = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,skeletalMuscleMass: null == skeletalMuscleMass ? _self.skeletalMuscleMass : skeletalMuscleMass // ignore: cast_nullable_to_non_nullable
as double,bodyFatMass: freezed == bodyFatMass ? _self.bodyFatMass : bodyFatMass // ignore: cast_nullable_to_non_nullable
as double?,bodyFatPercent: null == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,basalMetabolicRate: freezed == basalMetabolicRate ? _self.basalMetabolicRate : basalMetabolicRate // ignore: cast_nullable_to_non_nullable
as double?,totalBodyWater: freezed == totalBodyWater ? _self.totalBodyWater : totalBodyWater // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,minerals: freezed == minerals ? _self.minerals : minerals // ignore: cast_nullable_to_non_nullable
as double?,visceralFatLevel: freezed == visceralFatLevel ? _self.visceralFatLevel : visceralFatLevel // ignore: cast_nullable_to_non_nullable
as int?,inbodyScore: freezed == inbodyScore ? _self.inbodyScore : inbodyScore // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as InbodySource,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [InbodyRecordModel].
extension InbodyRecordModelPatterns on InbodyRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InbodyRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InbodyRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InbodyRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _InbodyRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InbodyRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _InbodyRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime measuredAt,  double weight,  double skeletalMuscleMass,  double? bodyFatMass,  double bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  double? totalBodyWater,  double? protein,  double? minerals,  int? visceralFatLevel,  int? inbodyScore,  InbodySource source,  String? memo, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InbodyRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.measuredAt,_that.weight,_that.skeletalMuscleMass,_that.bodyFatMass,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.totalBodyWater,_that.protein,_that.minerals,_that.visceralFatLevel,_that.inbodyScore,_that.source,_that.memo,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime measuredAt,  double weight,  double skeletalMuscleMass,  double? bodyFatMass,  double bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  double? totalBodyWater,  double? protein,  double? minerals,  int? visceralFatLevel,  int? inbodyScore,  InbodySource source,  String? memo, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _InbodyRecordModel():
return $default(_that.id,_that.memberId,_that.measuredAt,_that.weight,_that.skeletalMuscleMass,_that.bodyFatMass,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.totalBodyWater,_that.protein,_that.minerals,_that.visceralFatLevel,_that.inbodyScore,_that.source,_that.memo,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId, @TimestampConverter()  DateTime measuredAt,  double weight,  double skeletalMuscleMass,  double? bodyFatMass,  double bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  double? totalBodyWater,  double? protein,  double? minerals,  int? visceralFatLevel,  int? inbodyScore,  InbodySource source,  String? memo, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _InbodyRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.measuredAt,_that.weight,_that.skeletalMuscleMass,_that.bodyFatMass,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.totalBodyWater,_that.protein,_that.minerals,_that.visceralFatLevel,_that.inbodyScore,_that.source,_that.memo,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InbodyRecordModel implements InbodyRecordModel {
  const _InbodyRecordModel({required this.id, required this.memberId, @TimestampConverter() required this.measuredAt, required this.weight, required this.skeletalMuscleMass, this.bodyFatMass, required this.bodyFatPercent, this.bmi, this.basalMetabolicRate, this.totalBodyWater, this.protein, this.minerals, this.visceralFatLevel, this.inbodyScore, this.source = InbodySource.manual, this.memo, @TimestampConverter() required this.createdAt});
  factory _InbodyRecordModel.fromJson(Map<String, dynamic> json) => _$InbodyRecordModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 측정 일시
@override@TimestampConverter() final  DateTime measuredAt;
/// 체중 (kg)
@override final  double weight;
/// 골격근량 (kg)
@override final  double skeletalMuscleMass;
/// 체지방량 (kg)
@override final  double? bodyFatMass;
/// 체지방률 (%)
@override final  double bodyFatPercent;
/// BMI (kg/m²)
@override final  double? bmi;
/// 기초대사량 (kcal)
@override final  double? basalMetabolicRate;
/// 체수분량 (L)
@override final  double? totalBodyWater;
/// 단백질량 (kg)
@override final  double? protein;
/// 무기질량 (kg)
@override final  double? minerals;
/// 내장지방 레벨
@override final  int? visceralFatLevel;
/// 인바디 점수
@override final  int? inbodyScore;
/// 데이터 소스
@override@JsonKey() final  InbodySource source;
/// 메모
@override final  String? memo;
/// 생성 일시
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of InbodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InbodyRecordModelCopyWith<_InbodyRecordModel> get copyWith => __$InbodyRecordModelCopyWithImpl<_InbodyRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InbodyRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InbodyRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.measuredAt, measuredAt) || other.measuredAt == measuredAt)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.skeletalMuscleMass, skeletalMuscleMass) || other.skeletalMuscleMass == skeletalMuscleMass)&&(identical(other.bodyFatMass, bodyFatMass) || other.bodyFatMass == bodyFatMass)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.basalMetabolicRate, basalMetabolicRate) || other.basalMetabolicRate == basalMetabolicRate)&&(identical(other.totalBodyWater, totalBodyWater) || other.totalBodyWater == totalBodyWater)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.minerals, minerals) || other.minerals == minerals)&&(identical(other.visceralFatLevel, visceralFatLevel) || other.visceralFatLevel == visceralFatLevel)&&(identical(other.inbodyScore, inbodyScore) || other.inbodyScore == inbodyScore)&&(identical(other.source, source) || other.source == source)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,measuredAt,weight,skeletalMuscleMass,bodyFatMass,bodyFatPercent,bmi,basalMetabolicRate,totalBodyWater,protein,minerals,visceralFatLevel,inbodyScore,source,memo,createdAt);

@override
String toString() {
  return 'InbodyRecordModel(id: $id, memberId: $memberId, measuredAt: $measuredAt, weight: $weight, skeletalMuscleMass: $skeletalMuscleMass, bodyFatMass: $bodyFatMass, bodyFatPercent: $bodyFatPercent, bmi: $bmi, basalMetabolicRate: $basalMetabolicRate, totalBodyWater: $totalBodyWater, protein: $protein, minerals: $minerals, visceralFatLevel: $visceralFatLevel, inbodyScore: $inbodyScore, source: $source, memo: $memo, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$InbodyRecordModelCopyWith<$Res> implements $InbodyRecordModelCopyWith<$Res> {
  factory _$InbodyRecordModelCopyWith(_InbodyRecordModel value, $Res Function(_InbodyRecordModel) _then) = __$InbodyRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime measuredAt, double weight, double skeletalMuscleMass, double? bodyFatMass, double bodyFatPercent, double? bmi, double? basalMetabolicRate, double? totalBodyWater, double? protein, double? minerals, int? visceralFatLevel, int? inbodyScore, InbodySource source, String? memo,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$InbodyRecordModelCopyWithImpl<$Res>
    implements _$InbodyRecordModelCopyWith<$Res> {
  __$InbodyRecordModelCopyWithImpl(this._self, this._then);

  final _InbodyRecordModel _self;
  final $Res Function(_InbodyRecordModel) _then;

/// Create a copy of InbodyRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? measuredAt = null,Object? weight = null,Object? skeletalMuscleMass = null,Object? bodyFatMass = freezed,Object? bodyFatPercent = null,Object? bmi = freezed,Object? basalMetabolicRate = freezed,Object? totalBodyWater = freezed,Object? protein = freezed,Object? minerals = freezed,Object? visceralFatLevel = freezed,Object? inbodyScore = freezed,Object? source = null,Object? memo = freezed,Object? createdAt = null,}) {
  return _then(_InbodyRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,measuredAt: null == measuredAt ? _self.measuredAt : measuredAt // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,skeletalMuscleMass: null == skeletalMuscleMass ? _self.skeletalMuscleMass : skeletalMuscleMass // ignore: cast_nullable_to_non_nullable
as double,bodyFatMass: freezed == bodyFatMass ? _self.bodyFatMass : bodyFatMass // ignore: cast_nullable_to_non_nullable
as double?,bodyFatPercent: null == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,basalMetabolicRate: freezed == basalMetabolicRate ? _self.basalMetabolicRate : basalMetabolicRate // ignore: cast_nullable_to_non_nullable
as double?,totalBodyWater: freezed == totalBodyWater ? _self.totalBodyWater : totalBodyWater // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,minerals: freezed == minerals ? _self.minerals : minerals // ignore: cast_nullable_to_non_nullable
as double?,visceralFatLevel: freezed == visceralFatLevel ? _self.visceralFatLevel : visceralFatLevel // ignore: cast_nullable_to_non_nullable
as int?,inbodyScore: freezed == inbodyScore ? _self.inbodyScore : inbodyScore // ignore: cast_nullable_to_non_nullable
as int?,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as InbodySource,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
