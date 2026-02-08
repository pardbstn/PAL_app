// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inbody_ocr_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InbodyOcrResult {

/// 체중 (kg)
 double? get weight;/// 골격근량 (kg)
@JsonKey(name: 'skeletalMuscleMass') double? get skeletalMuscle;/// 체지방량 (kg)
@JsonKey(name: 'bodyFatMass') double? get bodyFat;/// 체지방률 (%)
 double? get bodyFatPercent;/// BMI
 double? get bmi;/// 기초대사량 (kcal)
 double? get basalMetabolicRate;/// 측정 날짜 (문자열)
 String? get measureDate;/// OCR 신뢰도 (0.0~1.0)
 double get confidence;/// 원본 텍스트
 String get rawText;/// 오류 메시지
 String? get errorMessage;
/// Create a copy of InbodyOcrResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InbodyOcrResultCopyWith<InbodyOcrResult> get copyWith => _$InbodyOcrResultCopyWithImpl<InbodyOcrResult>(this as InbodyOcrResult, _$identity);

  /// Serializes this InbodyOcrResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InbodyOcrResult&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.skeletalMuscle, skeletalMuscle) || other.skeletalMuscle == skeletalMuscle)&&(identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.basalMetabolicRate, basalMetabolicRate) || other.basalMetabolicRate == basalMetabolicRate)&&(identical(other.measureDate, measureDate) || other.measureDate == measureDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,skeletalMuscle,bodyFat,bodyFatPercent,bmi,basalMetabolicRate,measureDate,confidence,rawText,errorMessage);

@override
String toString() {
  return 'InbodyOcrResult(weight: $weight, skeletalMuscle: $skeletalMuscle, bodyFat: $bodyFat, bodyFatPercent: $bodyFatPercent, bmi: $bmi, basalMetabolicRate: $basalMetabolicRate, measureDate: $measureDate, confidence: $confidence, rawText: $rawText, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $InbodyOcrResultCopyWith<$Res>  {
  factory $InbodyOcrResultCopyWith(InbodyOcrResult value, $Res Function(InbodyOcrResult) _then) = _$InbodyOcrResultCopyWithImpl;
@useResult
$Res call({
 double? weight,@JsonKey(name: 'skeletalMuscleMass') double? skeletalMuscle,@JsonKey(name: 'bodyFatMass') double? bodyFat, double? bodyFatPercent, double? bmi, double? basalMetabolicRate, String? measureDate, double confidence, String rawText, String? errorMessage
});




}
/// @nodoc
class _$InbodyOcrResultCopyWithImpl<$Res>
    implements $InbodyOcrResultCopyWith<$Res> {
  _$InbodyOcrResultCopyWithImpl(this._self, this._then);

  final InbodyOcrResult _self;
  final $Res Function(InbodyOcrResult) _then;

/// Create a copy of InbodyOcrResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weight = freezed,Object? skeletalMuscle = freezed,Object? bodyFat = freezed,Object? bodyFatPercent = freezed,Object? bmi = freezed,Object? basalMetabolicRate = freezed,Object? measureDate = freezed,Object? confidence = null,Object? rawText = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,skeletalMuscle: freezed == skeletalMuscle ? _self.skeletalMuscle : skeletalMuscle // ignore: cast_nullable_to_non_nullable
as double?,bodyFat: freezed == bodyFat ? _self.bodyFat : bodyFat // ignore: cast_nullable_to_non_nullable
as double?,bodyFatPercent: freezed == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double?,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,basalMetabolicRate: freezed == basalMetabolicRate ? _self.basalMetabolicRate : basalMetabolicRate // ignore: cast_nullable_to_non_nullable
as double?,measureDate: freezed == measureDate ? _self.measureDate : measureDate // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InbodyOcrResult].
extension InbodyOcrResultPatterns on InbodyOcrResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InbodyOcrResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InbodyOcrResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InbodyOcrResult value)  $default,){
final _that = this;
switch (_that) {
case _InbodyOcrResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InbodyOcrResult value)?  $default,){
final _that = this;
switch (_that) {
case _InbodyOcrResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? weight, @JsonKey(name: 'skeletalMuscleMass')  double? skeletalMuscle, @JsonKey(name: 'bodyFatMass')  double? bodyFat,  double? bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  String? measureDate,  double confidence,  String rawText,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InbodyOcrResult() when $default != null:
return $default(_that.weight,_that.skeletalMuscle,_that.bodyFat,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.measureDate,_that.confidence,_that.rawText,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? weight, @JsonKey(name: 'skeletalMuscleMass')  double? skeletalMuscle, @JsonKey(name: 'bodyFatMass')  double? bodyFat,  double? bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  String? measureDate,  double confidence,  String rawText,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _InbodyOcrResult():
return $default(_that.weight,_that.skeletalMuscle,_that.bodyFat,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.measureDate,_that.confidence,_that.rawText,_that.errorMessage);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? weight, @JsonKey(name: 'skeletalMuscleMass')  double? skeletalMuscle, @JsonKey(name: 'bodyFatMass')  double? bodyFat,  double? bodyFatPercent,  double? bmi,  double? basalMetabolicRate,  String? measureDate,  double confidence,  String rawText,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _InbodyOcrResult() when $default != null:
return $default(_that.weight,_that.skeletalMuscle,_that.bodyFat,_that.bodyFatPercent,_that.bmi,_that.basalMetabolicRate,_that.measureDate,_that.confidence,_that.rawText,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InbodyOcrResult implements InbodyOcrResult {
  const _InbodyOcrResult({this.weight, @JsonKey(name: 'skeletalMuscleMass') this.skeletalMuscle, @JsonKey(name: 'bodyFatMass') this.bodyFat, this.bodyFatPercent, this.bmi, this.basalMetabolicRate, this.measureDate, this.confidence = 0.0, this.rawText = '', this.errorMessage});
  factory _InbodyOcrResult.fromJson(Map<String, dynamic> json) => _$InbodyOcrResultFromJson(json);

/// 체중 (kg)
@override final  double? weight;
/// 골격근량 (kg)
@override@JsonKey(name: 'skeletalMuscleMass') final  double? skeletalMuscle;
/// 체지방량 (kg)
@override@JsonKey(name: 'bodyFatMass') final  double? bodyFat;
/// 체지방률 (%)
@override final  double? bodyFatPercent;
/// BMI
@override final  double? bmi;
/// 기초대사량 (kcal)
@override final  double? basalMetabolicRate;
/// 측정 날짜 (문자열)
@override final  String? measureDate;
/// OCR 신뢰도 (0.0~1.0)
@override@JsonKey() final  double confidence;
/// 원본 텍스트
@override@JsonKey() final  String rawText;
/// 오류 메시지
@override final  String? errorMessage;

/// Create a copy of InbodyOcrResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InbodyOcrResultCopyWith<_InbodyOcrResult> get copyWith => __$InbodyOcrResultCopyWithImpl<_InbodyOcrResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InbodyOcrResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InbodyOcrResult&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.skeletalMuscle, skeletalMuscle) || other.skeletalMuscle == skeletalMuscle)&&(identical(other.bodyFat, bodyFat) || other.bodyFat == bodyFat)&&(identical(other.bodyFatPercent, bodyFatPercent) || other.bodyFatPercent == bodyFatPercent)&&(identical(other.bmi, bmi) || other.bmi == bmi)&&(identical(other.basalMetabolicRate, basalMetabolicRate) || other.basalMetabolicRate == basalMetabolicRate)&&(identical(other.measureDate, measureDate) || other.measureDate == measureDate)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.rawText, rawText) || other.rawText == rawText)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weight,skeletalMuscle,bodyFat,bodyFatPercent,bmi,basalMetabolicRate,measureDate,confidence,rawText,errorMessage);

@override
String toString() {
  return 'InbodyOcrResult(weight: $weight, skeletalMuscle: $skeletalMuscle, bodyFat: $bodyFat, bodyFatPercent: $bodyFatPercent, bmi: $bmi, basalMetabolicRate: $basalMetabolicRate, measureDate: $measureDate, confidence: $confidence, rawText: $rawText, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$InbodyOcrResultCopyWith<$Res> implements $InbodyOcrResultCopyWith<$Res> {
  factory _$InbodyOcrResultCopyWith(_InbodyOcrResult value, $Res Function(_InbodyOcrResult) _then) = __$InbodyOcrResultCopyWithImpl;
@override @useResult
$Res call({
 double? weight,@JsonKey(name: 'skeletalMuscleMass') double? skeletalMuscle,@JsonKey(name: 'bodyFatMass') double? bodyFat, double? bodyFatPercent, double? bmi, double? basalMetabolicRate, String? measureDate, double confidence, String rawText, String? errorMessage
});




}
/// @nodoc
class __$InbodyOcrResultCopyWithImpl<$Res>
    implements _$InbodyOcrResultCopyWith<$Res> {
  __$InbodyOcrResultCopyWithImpl(this._self, this._then);

  final _InbodyOcrResult _self;
  final $Res Function(_InbodyOcrResult) _then;

/// Create a copy of InbodyOcrResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weight = freezed,Object? skeletalMuscle = freezed,Object? bodyFat = freezed,Object? bodyFatPercent = freezed,Object? bmi = freezed,Object? basalMetabolicRate = freezed,Object? measureDate = freezed,Object? confidence = null,Object? rawText = null,Object? errorMessage = freezed,}) {
  return _then(_InbodyOcrResult(
weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,skeletalMuscle: freezed == skeletalMuscle ? _self.skeletalMuscle : skeletalMuscle // ignore: cast_nullable_to_non_nullable
as double?,bodyFat: freezed == bodyFat ? _self.bodyFat : bodyFat // ignore: cast_nullable_to_non_nullable
as double?,bodyFatPercent: freezed == bodyFatPercent ? _self.bodyFatPercent : bodyFatPercent // ignore: cast_nullable_to_non_nullable
as double?,bmi: freezed == bmi ? _self.bmi : bmi // ignore: cast_nullable_to_non_nullable
as double?,basalMetabolicRate: freezed == basalMetabolicRate ? _self.basalMetabolicRate : basalMetabolicRate // ignore: cast_nullable_to_non_nullable
as double?,measureDate: freezed == measureDate ? _self.measureDate : measureDate // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,rawText: null == rawText ? _self.rawText : rawText // ignore: cast_nullable_to_non_nullable
as String,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
