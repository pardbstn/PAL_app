// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_composition_prediction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MetricPrediction {

/// 현재 값
 double get current;/// 4주 후 예측 값
 double get predicted;/// 주간 변화 추세
 double get weeklyTrend;/// 예측 신뢰도 (0.0 ~ 1.0)
 double get confidence;/// 목표 값 (nullable)
 double? get targetValue;/// 목표 도달 예상 주 수 (nullable)
 int? get estimatedWeeksToTarget;
/// Create a copy of MetricPrediction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<MetricPrediction> get copyWith => _$MetricPredictionCopyWithImpl<MetricPrediction>(this as MetricPrediction, _$identity);

  /// Serializes this MetricPrediction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetricPrediction&&(identical(other.current, current) || other.current == current)&&(identical(other.predicted, predicted) || other.predicted == predicted)&&(identical(other.weeklyTrend, weeklyTrend) || other.weeklyTrend == weeklyTrend)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.estimatedWeeksToTarget, estimatedWeeksToTarget) || other.estimatedWeeksToTarget == estimatedWeeksToTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,predicted,weeklyTrend,confidence,targetValue,estimatedWeeksToTarget);

@override
String toString() {
  return 'MetricPrediction(current: $current, predicted: $predicted, weeklyTrend: $weeklyTrend, confidence: $confidence, targetValue: $targetValue, estimatedWeeksToTarget: $estimatedWeeksToTarget)';
}


}

/// @nodoc
abstract mixin class $MetricPredictionCopyWith<$Res>  {
  factory $MetricPredictionCopyWith(MetricPrediction value, $Res Function(MetricPrediction) _then) = _$MetricPredictionCopyWithImpl;
@useResult
$Res call({
 double current, double predicted, double weeklyTrend, double confidence, double? targetValue, int? estimatedWeeksToTarget
});




}
/// @nodoc
class _$MetricPredictionCopyWithImpl<$Res>
    implements $MetricPredictionCopyWith<$Res> {
  _$MetricPredictionCopyWithImpl(this._self, this._then);

  final MetricPrediction _self;
  final $Res Function(MetricPrediction) _then;

/// Create a copy of MetricPrediction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? predicted = null,Object? weeklyTrend = null,Object? confidence = null,Object? targetValue = freezed,Object? estimatedWeeksToTarget = freezed,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,predicted: null == predicted ? _self.predicted : predicted // ignore: cast_nullable_to_non_nullable
as double,weeklyTrend: null == weeklyTrend ? _self.weeklyTrend : weeklyTrend // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeeksToTarget: freezed == estimatedWeeksToTarget ? _self.estimatedWeeksToTarget : estimatedWeeksToTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MetricPrediction].
extension MetricPredictionPatterns on MetricPrediction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MetricPrediction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MetricPrediction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MetricPrediction value)  $default,){
final _that = this;
switch (_that) {
case _MetricPrediction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MetricPrediction value)?  $default,){
final _that = this;
switch (_that) {
case _MetricPrediction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double current,  double predicted,  double weeklyTrend,  double confidence,  double? targetValue,  int? estimatedWeeksToTarget)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MetricPrediction() when $default != null:
return $default(_that.current,_that.predicted,_that.weeklyTrend,_that.confidence,_that.targetValue,_that.estimatedWeeksToTarget);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double current,  double predicted,  double weeklyTrend,  double confidence,  double? targetValue,  int? estimatedWeeksToTarget)  $default,) {final _that = this;
switch (_that) {
case _MetricPrediction():
return $default(_that.current,_that.predicted,_that.weeklyTrend,_that.confidence,_that.targetValue,_that.estimatedWeeksToTarget);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double current,  double predicted,  double weeklyTrend,  double confidence,  double? targetValue,  int? estimatedWeeksToTarget)?  $default,) {final _that = this;
switch (_that) {
case _MetricPrediction() when $default != null:
return $default(_that.current,_that.predicted,_that.weeklyTrend,_that.confidence,_that.targetValue,_that.estimatedWeeksToTarget);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MetricPrediction implements MetricPrediction {
  const _MetricPrediction({required this.current, required this.predicted, required this.weeklyTrend, required this.confidence, this.targetValue, this.estimatedWeeksToTarget});
  factory _MetricPrediction.fromJson(Map<String, dynamic> json) => _$MetricPredictionFromJson(json);

/// 현재 값
@override final  double current;
/// 4주 후 예측 값
@override final  double predicted;
/// 주간 변화 추세
@override final  double weeklyTrend;
/// 예측 신뢰도 (0.0 ~ 1.0)
@override final  double confidence;
/// 목표 값 (nullable)
@override final  double? targetValue;
/// 목표 도달 예상 주 수 (nullable)
@override final  int? estimatedWeeksToTarget;

/// Create a copy of MetricPrediction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MetricPredictionCopyWith<_MetricPrediction> get copyWith => __$MetricPredictionCopyWithImpl<_MetricPrediction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MetricPredictionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MetricPrediction&&(identical(other.current, current) || other.current == current)&&(identical(other.predicted, predicted) || other.predicted == predicted)&&(identical(other.weeklyTrend, weeklyTrend) || other.weeklyTrend == weeklyTrend)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.targetValue, targetValue) || other.targetValue == targetValue)&&(identical(other.estimatedWeeksToTarget, estimatedWeeksToTarget) || other.estimatedWeeksToTarget == estimatedWeeksToTarget));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,current,predicted,weeklyTrend,confidence,targetValue,estimatedWeeksToTarget);

@override
String toString() {
  return 'MetricPrediction(current: $current, predicted: $predicted, weeklyTrend: $weeklyTrend, confidence: $confidence, targetValue: $targetValue, estimatedWeeksToTarget: $estimatedWeeksToTarget)';
}


}

/// @nodoc
abstract mixin class _$MetricPredictionCopyWith<$Res> implements $MetricPredictionCopyWith<$Res> {
  factory _$MetricPredictionCopyWith(_MetricPrediction value, $Res Function(_MetricPrediction) _then) = __$MetricPredictionCopyWithImpl;
@override @useResult
$Res call({
 double current, double predicted, double weeklyTrend, double confidence, double? targetValue, int? estimatedWeeksToTarget
});




}
/// @nodoc
class __$MetricPredictionCopyWithImpl<$Res>
    implements _$MetricPredictionCopyWith<$Res> {
  __$MetricPredictionCopyWithImpl(this._self, this._then);

  final _MetricPrediction _self;
  final $Res Function(_MetricPrediction) _then;

/// Create a copy of MetricPrediction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? predicted = null,Object? weeklyTrend = null,Object? confidence = null,Object? targetValue = freezed,Object? estimatedWeeksToTarget = freezed,}) {
  return _then(_MetricPrediction(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as double,predicted: null == predicted ? _self.predicted : predicted // ignore: cast_nullable_to_non_nullable
as double,weeklyTrend: null == weeklyTrend ? _self.weeklyTrend : weeklyTrend // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,targetValue: freezed == targetValue ? _self.targetValue : targetValue // ignore: cast_nullable_to_non_nullable
as double?,estimatedWeeksToTarget: freezed == estimatedWeeksToTarget ? _self.estimatedWeeksToTarget : estimatedWeeksToTarget // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$BodyCompositionPredictionModel {

/// 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 트레이너 ID
 String get trainerId;/// 체중 예측 (nullable)
 MetricPrediction? get weightPrediction;/// 골격근량 예측 (nullable)
 MetricPrediction? get musclePrediction;/// 체지방률 예측 (nullable)
 MetricPrediction? get bodyFatPrediction;/// AI 분석 메시지
 String get analysisMessage;/// 각 지표별 사용된 데이터 포인트 수
 Map<String, int> get dataPointsUsed;/// 생성일
@TimestampConverter() DateTime get createdAt;
/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BodyCompositionPredictionModelCopyWith<BodyCompositionPredictionModel> get copyWith => _$BodyCompositionPredictionModelCopyWithImpl<BodyCompositionPredictionModel>(this as BodyCompositionPredictionModel, _$identity);

  /// Serializes this BodyCompositionPredictionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BodyCompositionPredictionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.weightPrediction, weightPrediction) || other.weightPrediction == weightPrediction)&&(identical(other.musclePrediction, musclePrediction) || other.musclePrediction == musclePrediction)&&(identical(other.bodyFatPrediction, bodyFatPrediction) || other.bodyFatPrediction == bodyFatPrediction)&&(identical(other.analysisMessage, analysisMessage) || other.analysisMessage == analysisMessage)&&const DeepCollectionEquality().equals(other.dataPointsUsed, dataPointsUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,weightPrediction,musclePrediction,bodyFatPrediction,analysisMessage,const DeepCollectionEquality().hash(dataPointsUsed),createdAt);

@override
String toString() {
  return 'BodyCompositionPredictionModel(id: $id, memberId: $memberId, trainerId: $trainerId, weightPrediction: $weightPrediction, musclePrediction: $musclePrediction, bodyFatPrediction: $bodyFatPrediction, analysisMessage: $analysisMessage, dataPointsUsed: $dataPointsUsed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BodyCompositionPredictionModelCopyWith<$Res>  {
  factory $BodyCompositionPredictionModelCopyWith(BodyCompositionPredictionModel value, $Res Function(BodyCompositionPredictionModel) _then) = _$BodyCompositionPredictionModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, MetricPrediction? weightPrediction, MetricPrediction? musclePrediction, MetricPrediction? bodyFatPrediction, String analysisMessage, Map<String, int> dataPointsUsed,@TimestampConverter() DateTime createdAt
});


$MetricPredictionCopyWith<$Res>? get weightPrediction;$MetricPredictionCopyWith<$Res>? get musclePrediction;$MetricPredictionCopyWith<$Res>? get bodyFatPrediction;

}
/// @nodoc
class _$BodyCompositionPredictionModelCopyWithImpl<$Res>
    implements $BodyCompositionPredictionModelCopyWith<$Res> {
  _$BodyCompositionPredictionModelCopyWithImpl(this._self, this._then);

  final BodyCompositionPredictionModel _self;
  final $Res Function(BodyCompositionPredictionModel) _then;

/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? weightPrediction = freezed,Object? musclePrediction = freezed,Object? bodyFatPrediction = freezed,Object? analysisMessage = null,Object? dataPointsUsed = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,weightPrediction: freezed == weightPrediction ? _self.weightPrediction : weightPrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,musclePrediction: freezed == musclePrediction ? _self.musclePrediction : musclePrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,bodyFatPrediction: freezed == bodyFatPrediction ? _self.bodyFatPrediction : bodyFatPrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,analysisMessage: null == analysisMessage ? _self.analysisMessage : analysisMessage // ignore: cast_nullable_to_non_nullable
as String,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get weightPrediction {
    if (_self.weightPrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.weightPrediction!, (value) {
    return _then(_self.copyWith(weightPrediction: value));
  });
}/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get musclePrediction {
    if (_self.musclePrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.musclePrediction!, (value) {
    return _then(_self.copyWith(musclePrediction: value));
  });
}/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get bodyFatPrediction {
    if (_self.bodyFatPrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.bodyFatPrediction!, (value) {
    return _then(_self.copyWith(bodyFatPrediction: value));
  });
}
}


/// Adds pattern-matching-related methods to [BodyCompositionPredictionModel].
extension BodyCompositionPredictionModelPatterns on BodyCompositionPredictionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BodyCompositionPredictionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BodyCompositionPredictionModel value)  $default,){
final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BodyCompositionPredictionModel value)?  $default,){
final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  MetricPrediction? weightPrediction,  MetricPrediction? musclePrediction,  MetricPrediction? bodyFatPrediction,  String analysisMessage,  Map<String, int> dataPointsUsed, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.weightPrediction,_that.musclePrediction,_that.bodyFatPrediction,_that.analysisMessage,_that.dataPointsUsed,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  MetricPrediction? weightPrediction,  MetricPrediction? musclePrediction,  MetricPrediction? bodyFatPrediction,  String analysisMessage,  Map<String, int> dataPointsUsed, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.weightPrediction,_that.musclePrediction,_that.bodyFatPrediction,_that.analysisMessage,_that.dataPointsUsed,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  MetricPrediction? weightPrediction,  MetricPrediction? musclePrediction,  MetricPrediction? bodyFatPrediction,  String analysisMessage,  Map<String, int> dataPointsUsed, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _BodyCompositionPredictionModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.weightPrediction,_that.musclePrediction,_that.bodyFatPrediction,_that.analysisMessage,_that.dataPointsUsed,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BodyCompositionPredictionModel extends BodyCompositionPredictionModel {
  const _BodyCompositionPredictionModel({required this.id, required this.memberId, required this.trainerId, this.weightPrediction, this.musclePrediction, this.bodyFatPrediction, required this.analysisMessage, required final  Map<String, int> dataPointsUsed, @TimestampConverter() required this.createdAt}): _dataPointsUsed = dataPointsUsed,super._();
  factory _BodyCompositionPredictionModel.fromJson(Map<String, dynamic> json) => _$BodyCompositionPredictionModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 트레이너 ID
@override final  String trainerId;
/// 체중 예측 (nullable)
@override final  MetricPrediction? weightPrediction;
/// 골격근량 예측 (nullable)
@override final  MetricPrediction? musclePrediction;
/// 체지방률 예측 (nullable)
@override final  MetricPrediction? bodyFatPrediction;
/// AI 분석 메시지
@override final  String analysisMessage;
/// 각 지표별 사용된 데이터 포인트 수
 final  Map<String, int> _dataPointsUsed;
/// 각 지표별 사용된 데이터 포인트 수
@override Map<String, int> get dataPointsUsed {
  if (_dataPointsUsed is EqualUnmodifiableMapView) return _dataPointsUsed;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_dataPointsUsed);
}

/// 생성일
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BodyCompositionPredictionModelCopyWith<_BodyCompositionPredictionModel> get copyWith => __$BodyCompositionPredictionModelCopyWithImpl<_BodyCompositionPredictionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BodyCompositionPredictionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BodyCompositionPredictionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.weightPrediction, weightPrediction) || other.weightPrediction == weightPrediction)&&(identical(other.musclePrediction, musclePrediction) || other.musclePrediction == musclePrediction)&&(identical(other.bodyFatPrediction, bodyFatPrediction) || other.bodyFatPrediction == bodyFatPrediction)&&(identical(other.analysisMessage, analysisMessage) || other.analysisMessage == analysisMessage)&&const DeepCollectionEquality().equals(other._dataPointsUsed, _dataPointsUsed)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,weightPrediction,musclePrediction,bodyFatPrediction,analysisMessage,const DeepCollectionEquality().hash(_dataPointsUsed),createdAt);

@override
String toString() {
  return 'BodyCompositionPredictionModel(id: $id, memberId: $memberId, trainerId: $trainerId, weightPrediction: $weightPrediction, musclePrediction: $musclePrediction, bodyFatPrediction: $bodyFatPrediction, analysisMessage: $analysisMessage, dataPointsUsed: $dataPointsUsed, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BodyCompositionPredictionModelCopyWith<$Res> implements $BodyCompositionPredictionModelCopyWith<$Res> {
  factory _$BodyCompositionPredictionModelCopyWith(_BodyCompositionPredictionModel value, $Res Function(_BodyCompositionPredictionModel) _then) = __$BodyCompositionPredictionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, MetricPrediction? weightPrediction, MetricPrediction? musclePrediction, MetricPrediction? bodyFatPrediction, String analysisMessage, Map<String, int> dataPointsUsed,@TimestampConverter() DateTime createdAt
});


@override $MetricPredictionCopyWith<$Res>? get weightPrediction;@override $MetricPredictionCopyWith<$Res>? get musclePrediction;@override $MetricPredictionCopyWith<$Res>? get bodyFatPrediction;

}
/// @nodoc
class __$BodyCompositionPredictionModelCopyWithImpl<$Res>
    implements _$BodyCompositionPredictionModelCopyWith<$Res> {
  __$BodyCompositionPredictionModelCopyWithImpl(this._self, this._then);

  final _BodyCompositionPredictionModel _self;
  final $Res Function(_BodyCompositionPredictionModel) _then;

/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? weightPrediction = freezed,Object? musclePrediction = freezed,Object? bodyFatPrediction = freezed,Object? analysisMessage = null,Object? dataPointsUsed = null,Object? createdAt = null,}) {
  return _then(_BodyCompositionPredictionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,weightPrediction: freezed == weightPrediction ? _self.weightPrediction : weightPrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,musclePrediction: freezed == musclePrediction ? _self.musclePrediction : musclePrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,bodyFatPrediction: freezed == bodyFatPrediction ? _self.bodyFatPrediction : bodyFatPrediction // ignore: cast_nullable_to_non_nullable
as MetricPrediction?,analysisMessage: null == analysisMessage ? _self.analysisMessage : analysisMessage // ignore: cast_nullable_to_non_nullable
as String,dataPointsUsed: null == dataPointsUsed ? _self._dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as Map<String, int>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get weightPrediction {
    if (_self.weightPrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.weightPrediction!, (value) {
    return _then(_self.copyWith(weightPrediction: value));
  });
}/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get musclePrediction {
    if (_self.musclePrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.musclePrediction!, (value) {
    return _then(_self.copyWith(musclePrediction: value));
  });
}/// Create a copy of BodyCompositionPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MetricPredictionCopyWith<$Res>? get bodyFatPrediction {
    if (_self.bodyFatPrediction == null) {
    return null;
  }

  return $MetricPredictionCopyWith<$Res>(_self.bodyFatPrediction!, (value) {
    return _then(_self.copyWith(bodyFatPrediction: value));
  });
}
}

// dart format on
