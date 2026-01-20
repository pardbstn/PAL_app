// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_prediction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PredictedWeightPoint {

/// 예측 날짜
@TimestampConverter() DateTime get date;/// 예측 체중 (kg)
 double get weight;/// 신뢰구간 상한 (kg)
 double get upperBound;/// 신뢰구간 하한 (kg)
 double get lowerBound;
/// Create a copy of PredictedWeightPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PredictedWeightPointCopyWith<PredictedWeightPoint> get copyWith => _$PredictedWeightPointCopyWithImpl<PredictedWeightPoint>(this as PredictedWeightPoint, _$identity);

  /// Serializes this PredictedWeightPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PredictedWeightPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,weight,upperBound,lowerBound);

@override
String toString() {
  return 'PredictedWeightPoint(date: $date, weight: $weight, upperBound: $upperBound, lowerBound: $lowerBound)';
}


}

/// @nodoc
abstract mixin class $PredictedWeightPointCopyWith<$Res>  {
  factory $PredictedWeightPointCopyWith(PredictedWeightPoint value, $Res Function(PredictedWeightPoint) _then) = _$PredictedWeightPointCopyWithImpl;
@useResult
$Res call({
@TimestampConverter() DateTime date, double weight, double upperBound, double lowerBound
});




}
/// @nodoc
class _$PredictedWeightPointCopyWithImpl<$Res>
    implements $PredictedWeightPointCopyWith<$Res> {
  _$PredictedWeightPointCopyWithImpl(this._self, this._then);

  final PredictedWeightPoint _self;
  final $Res Function(PredictedWeightPoint) _then;

/// Create a copy of PredictedWeightPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? weight = null,Object? upperBound = null,Object? lowerBound = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PredictedWeightPoint].
extension PredictedWeightPointPatterns on PredictedWeightPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PredictedWeightPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PredictedWeightPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PredictedWeightPoint value)  $default,){
final _that = this;
switch (_that) {
case _PredictedWeightPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PredictedWeightPoint value)?  $default,){
final _that = this;
switch (_that) {
case _PredictedWeightPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime date,  double weight,  double upperBound,  double lowerBound)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PredictedWeightPoint() when $default != null:
return $default(_that.date,_that.weight,_that.upperBound,_that.lowerBound);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@TimestampConverter()  DateTime date,  double weight,  double upperBound,  double lowerBound)  $default,) {final _that = this;
switch (_that) {
case _PredictedWeightPoint():
return $default(_that.date,_that.weight,_that.upperBound,_that.lowerBound);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@TimestampConverter()  DateTime date,  double weight,  double upperBound,  double lowerBound)?  $default,) {final _that = this;
switch (_that) {
case _PredictedWeightPoint() when $default != null:
return $default(_that.date,_that.weight,_that.upperBound,_that.lowerBound);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PredictedWeightPoint implements PredictedWeightPoint {
  const _PredictedWeightPoint({@TimestampConverter() required this.date, required this.weight, required this.upperBound, required this.lowerBound});
  factory _PredictedWeightPoint.fromJson(Map<String, dynamic> json) => _$PredictedWeightPointFromJson(json);

/// 예측 날짜
@override@TimestampConverter() final  DateTime date;
/// 예측 체중 (kg)
@override final  double weight;
/// 신뢰구간 상한 (kg)
@override final  double upperBound;
/// 신뢰구간 하한 (kg)
@override final  double lowerBound;

/// Create a copy of PredictedWeightPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PredictedWeightPointCopyWith<_PredictedWeightPoint> get copyWith => __$PredictedWeightPointCopyWithImpl<_PredictedWeightPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PredictedWeightPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PredictedWeightPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.upperBound, upperBound) || other.upperBound == upperBound)&&(identical(other.lowerBound, lowerBound) || other.lowerBound == lowerBound));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,weight,upperBound,lowerBound);

@override
String toString() {
  return 'PredictedWeightPoint(date: $date, weight: $weight, upperBound: $upperBound, lowerBound: $lowerBound)';
}


}

/// @nodoc
abstract mixin class _$PredictedWeightPointCopyWith<$Res> implements $PredictedWeightPointCopyWith<$Res> {
  factory _$PredictedWeightPointCopyWith(_PredictedWeightPoint value, $Res Function(_PredictedWeightPoint) _then) = __$PredictedWeightPointCopyWithImpl;
@override @useResult
$Res call({
@TimestampConverter() DateTime date, double weight, double upperBound, double lowerBound
});




}
/// @nodoc
class __$PredictedWeightPointCopyWithImpl<$Res>
    implements _$PredictedWeightPointCopyWith<$Res> {
  __$PredictedWeightPointCopyWithImpl(this._self, this._then);

  final _PredictedWeightPoint _self;
  final $Res Function(_PredictedWeightPoint) _then;

/// Create a copy of PredictedWeightPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? weight = null,Object? upperBound = null,Object? lowerBound = null,}) {
  return _then(_PredictedWeightPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,upperBound: null == upperBound ? _self.upperBound : upperBound // ignore: cast_nullable_to_non_nullable
as double,lowerBound: null == lowerBound ? _self.lowerBound : lowerBound // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$DataSummary {

/// 최근 1주 변화량 (kg)
 double get recentWeekChange;/// 최근 1개월 변화량 (kg)
 double get recentMonthChange;/// 전체 기간 변화량 (kg)
 double get totalChange;/// 최저 체중 (kg)
 double get minWeight;/// 최고 체중 (kg)
 double get maxWeight;/// 평균 체중 (kg)
 double get avgWeight;/// 체중 변동폭 (kg)
 double get weightRange;/// 기록 기간 (일)
 int get recordDays;/// 일관성 점수 (0~100)
 int get consistencyScore;
/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataSummaryCopyWith<DataSummary> get copyWith => _$DataSummaryCopyWithImpl<DataSummary>(this as DataSummary, _$identity);

  /// Serializes this DataSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataSummary&&(identical(other.recentWeekChange, recentWeekChange) || other.recentWeekChange == recentWeekChange)&&(identical(other.recentMonthChange, recentMonthChange) || other.recentMonthChange == recentMonthChange)&&(identical(other.totalChange, totalChange) || other.totalChange == totalChange)&&(identical(other.minWeight, minWeight) || other.minWeight == minWeight)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.avgWeight, avgWeight) || other.avgWeight == avgWeight)&&(identical(other.weightRange, weightRange) || other.weightRange == weightRange)&&(identical(other.recordDays, recordDays) || other.recordDays == recordDays)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recentWeekChange,recentMonthChange,totalChange,minWeight,maxWeight,avgWeight,weightRange,recordDays,consistencyScore);

@override
String toString() {
  return 'DataSummary(recentWeekChange: $recentWeekChange, recentMonthChange: $recentMonthChange, totalChange: $totalChange, minWeight: $minWeight, maxWeight: $maxWeight, avgWeight: $avgWeight, weightRange: $weightRange, recordDays: $recordDays, consistencyScore: $consistencyScore)';
}


}

/// @nodoc
abstract mixin class $DataSummaryCopyWith<$Res>  {
  factory $DataSummaryCopyWith(DataSummary value, $Res Function(DataSummary) _then) = _$DataSummaryCopyWithImpl;
@useResult
$Res call({
 double recentWeekChange, double recentMonthChange, double totalChange, double minWeight, double maxWeight, double avgWeight, double weightRange, int recordDays, int consistencyScore
});




}
/// @nodoc
class _$DataSummaryCopyWithImpl<$Res>
    implements $DataSummaryCopyWith<$Res> {
  _$DataSummaryCopyWithImpl(this._self, this._then);

  final DataSummary _self;
  final $Res Function(DataSummary) _then;

/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recentWeekChange = null,Object? recentMonthChange = null,Object? totalChange = null,Object? minWeight = null,Object? maxWeight = null,Object? avgWeight = null,Object? weightRange = null,Object? recordDays = null,Object? consistencyScore = null,}) {
  return _then(_self.copyWith(
recentWeekChange: null == recentWeekChange ? _self.recentWeekChange : recentWeekChange // ignore: cast_nullable_to_non_nullable
as double,recentMonthChange: null == recentMonthChange ? _self.recentMonthChange : recentMonthChange // ignore: cast_nullable_to_non_nullable
as double,totalChange: null == totalChange ? _self.totalChange : totalChange // ignore: cast_nullable_to_non_nullable
as double,minWeight: null == minWeight ? _self.minWeight : minWeight // ignore: cast_nullable_to_non_nullable
as double,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,avgWeight: null == avgWeight ? _self.avgWeight : avgWeight // ignore: cast_nullable_to_non_nullable
as double,weightRange: null == weightRange ? _self.weightRange : weightRange // ignore: cast_nullable_to_non_nullable
as double,recordDays: null == recordDays ? _self.recordDays : recordDays // ignore: cast_nullable_to_non_nullable
as int,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DataSummary].
extension DataSummaryPatterns on DataSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataSummary value)  $default,){
final _that = this;
switch (_that) {
case _DataSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double recentWeekChange,  double recentMonthChange,  double totalChange,  double minWeight,  double maxWeight,  double avgWeight,  double weightRange,  int recordDays,  int consistencyScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
return $default(_that.recentWeekChange,_that.recentMonthChange,_that.totalChange,_that.minWeight,_that.maxWeight,_that.avgWeight,_that.weightRange,_that.recordDays,_that.consistencyScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double recentWeekChange,  double recentMonthChange,  double totalChange,  double minWeight,  double maxWeight,  double avgWeight,  double weightRange,  int recordDays,  int consistencyScore)  $default,) {final _that = this;
switch (_that) {
case _DataSummary():
return $default(_that.recentWeekChange,_that.recentMonthChange,_that.totalChange,_that.minWeight,_that.maxWeight,_that.avgWeight,_that.weightRange,_that.recordDays,_that.consistencyScore);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double recentWeekChange,  double recentMonthChange,  double totalChange,  double minWeight,  double maxWeight,  double avgWeight,  double weightRange,  int recordDays,  int consistencyScore)?  $default,) {final _that = this;
switch (_that) {
case _DataSummary() when $default != null:
return $default(_that.recentWeekChange,_that.recentMonthChange,_that.totalChange,_that.minWeight,_that.maxWeight,_that.avgWeight,_that.weightRange,_that.recordDays,_that.consistencyScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DataSummary implements DataSummary {
  const _DataSummary({this.recentWeekChange = 0, this.recentMonthChange = 0, this.totalChange = 0, this.minWeight = 0, this.maxWeight = 0, this.avgWeight = 0, this.weightRange = 0, this.recordDays = 0, this.consistencyScore = 0});
  factory _DataSummary.fromJson(Map<String, dynamic> json) => _$DataSummaryFromJson(json);

/// 최근 1주 변화량 (kg)
@override@JsonKey() final  double recentWeekChange;
/// 최근 1개월 변화량 (kg)
@override@JsonKey() final  double recentMonthChange;
/// 전체 기간 변화량 (kg)
@override@JsonKey() final  double totalChange;
/// 최저 체중 (kg)
@override@JsonKey() final  double minWeight;
/// 최고 체중 (kg)
@override@JsonKey() final  double maxWeight;
/// 평균 체중 (kg)
@override@JsonKey() final  double avgWeight;
/// 체중 변동폭 (kg)
@override@JsonKey() final  double weightRange;
/// 기록 기간 (일)
@override@JsonKey() final  int recordDays;
/// 일관성 점수 (0~100)
@override@JsonKey() final  int consistencyScore;

/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataSummaryCopyWith<_DataSummary> get copyWith => __$DataSummaryCopyWithImpl<_DataSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DataSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataSummary&&(identical(other.recentWeekChange, recentWeekChange) || other.recentWeekChange == recentWeekChange)&&(identical(other.recentMonthChange, recentMonthChange) || other.recentMonthChange == recentMonthChange)&&(identical(other.totalChange, totalChange) || other.totalChange == totalChange)&&(identical(other.minWeight, minWeight) || other.minWeight == minWeight)&&(identical(other.maxWeight, maxWeight) || other.maxWeight == maxWeight)&&(identical(other.avgWeight, avgWeight) || other.avgWeight == avgWeight)&&(identical(other.weightRange, weightRange) || other.weightRange == weightRange)&&(identical(other.recordDays, recordDays) || other.recordDays == recordDays)&&(identical(other.consistencyScore, consistencyScore) || other.consistencyScore == consistencyScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recentWeekChange,recentMonthChange,totalChange,minWeight,maxWeight,avgWeight,weightRange,recordDays,consistencyScore);

@override
String toString() {
  return 'DataSummary(recentWeekChange: $recentWeekChange, recentMonthChange: $recentMonthChange, totalChange: $totalChange, minWeight: $minWeight, maxWeight: $maxWeight, avgWeight: $avgWeight, weightRange: $weightRange, recordDays: $recordDays, consistencyScore: $consistencyScore)';
}


}

/// @nodoc
abstract mixin class _$DataSummaryCopyWith<$Res> implements $DataSummaryCopyWith<$Res> {
  factory _$DataSummaryCopyWith(_DataSummary value, $Res Function(_DataSummary) _then) = __$DataSummaryCopyWithImpl;
@override @useResult
$Res call({
 double recentWeekChange, double recentMonthChange, double totalChange, double minWeight, double maxWeight, double avgWeight, double weightRange, int recordDays, int consistencyScore
});




}
/// @nodoc
class __$DataSummaryCopyWithImpl<$Res>
    implements _$DataSummaryCopyWith<$Res> {
  __$DataSummaryCopyWithImpl(this._self, this._then);

  final _DataSummary _self;
  final $Res Function(_DataSummary) _then;

/// Create a copy of DataSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recentWeekChange = null,Object? recentMonthChange = null,Object? totalChange = null,Object? minWeight = null,Object? maxWeight = null,Object? avgWeight = null,Object? weightRange = null,Object? recordDays = null,Object? consistencyScore = null,}) {
  return _then(_DataSummary(
recentWeekChange: null == recentWeekChange ? _self.recentWeekChange : recentWeekChange // ignore: cast_nullable_to_non_nullable
as double,recentMonthChange: null == recentMonthChange ? _self.recentMonthChange : recentMonthChange // ignore: cast_nullable_to_non_nullable
as double,totalChange: null == totalChange ? _self.totalChange : totalChange // ignore: cast_nullable_to_non_nullable
as double,minWeight: null == minWeight ? _self.minWeight : minWeight // ignore: cast_nullable_to_non_nullable
as double,maxWeight: null == maxWeight ? _self.maxWeight : maxWeight // ignore: cast_nullable_to_non_nullable
as double,avgWeight: null == avgWeight ? _self.avgWeight : avgWeight // ignore: cast_nullable_to_non_nullable
as double,weightRange: null == weightRange ? _self.weightRange : weightRange // ignore: cast_nullable_to_non_nullable
as double,recordDays: null == recordDays ? _self.recordDays : recordDays // ignore: cast_nullable_to_non_nullable
as int,consistencyScore: null == consistencyScore ? _self.consistencyScore : consistencyScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$GoalScenario {

/// 시나리오 이름
 String get name;/// 주당 필요 변화량 (kg)
 double get weeklyChange;/// 예상 소요 주 수
 int get weeksNeeded;/// 난이도 (easy/moderate/hard/achieved)
 String get difficulty;/// 설명
 String get description;
/// Create a copy of GoalScenario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GoalScenarioCopyWith<GoalScenario> get copyWith => _$GoalScenarioCopyWithImpl<GoalScenario>(this as GoalScenario, _$identity);

  /// Serializes this GoalScenario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GoalScenario&&(identical(other.name, name) || other.name == name)&&(identical(other.weeklyChange, weeklyChange) || other.weeklyChange == weeklyChange)&&(identical(other.weeksNeeded, weeksNeeded) || other.weeksNeeded == weeksNeeded)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,weeklyChange,weeksNeeded,difficulty,description);

@override
String toString() {
  return 'GoalScenario(name: $name, weeklyChange: $weeklyChange, weeksNeeded: $weeksNeeded, difficulty: $difficulty, description: $description)';
}


}

/// @nodoc
abstract mixin class $GoalScenarioCopyWith<$Res>  {
  factory $GoalScenarioCopyWith(GoalScenario value, $Res Function(GoalScenario) _then) = _$GoalScenarioCopyWithImpl;
@useResult
$Res call({
 String name, double weeklyChange, int weeksNeeded, String difficulty, String description
});




}
/// @nodoc
class _$GoalScenarioCopyWithImpl<$Res>
    implements $GoalScenarioCopyWith<$Res> {
  _$GoalScenarioCopyWithImpl(this._self, this._then);

  final GoalScenario _self;
  final $Res Function(GoalScenario) _then;

/// Create a copy of GoalScenario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? weeklyChange = null,Object? weeksNeeded = null,Object? difficulty = null,Object? description = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,weeklyChange: null == weeklyChange ? _self.weeklyChange : weeklyChange // ignore: cast_nullable_to_non_nullable
as double,weeksNeeded: null == weeksNeeded ? _self.weeksNeeded : weeksNeeded // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GoalScenario].
extension GoalScenarioPatterns on GoalScenario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GoalScenario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GoalScenario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GoalScenario value)  $default,){
final _that = this;
switch (_that) {
case _GoalScenario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GoalScenario value)?  $default,){
final _that = this;
switch (_that) {
case _GoalScenario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double weeklyChange,  int weeksNeeded,  String difficulty,  String description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GoalScenario() when $default != null:
return $default(_that.name,_that.weeklyChange,_that.weeksNeeded,_that.difficulty,_that.description);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double weeklyChange,  int weeksNeeded,  String difficulty,  String description)  $default,) {final _that = this;
switch (_that) {
case _GoalScenario():
return $default(_that.name,_that.weeklyChange,_that.weeksNeeded,_that.difficulty,_that.description);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double weeklyChange,  int weeksNeeded,  String difficulty,  String description)?  $default,) {final _that = this;
switch (_that) {
case _GoalScenario() when $default != null:
return $default(_that.name,_that.weeklyChange,_that.weeksNeeded,_that.difficulty,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GoalScenario implements GoalScenario {
  const _GoalScenario({required this.name, required this.weeklyChange, required this.weeksNeeded, required this.difficulty, required this.description});
  factory _GoalScenario.fromJson(Map<String, dynamic> json) => _$GoalScenarioFromJson(json);

/// 시나리오 이름
@override final  String name;
/// 주당 필요 변화량 (kg)
@override final  double weeklyChange;
/// 예상 소요 주 수
@override final  int weeksNeeded;
/// 난이도 (easy/moderate/hard/achieved)
@override final  String difficulty;
/// 설명
@override final  String description;

/// Create a copy of GoalScenario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GoalScenarioCopyWith<_GoalScenario> get copyWith => __$GoalScenarioCopyWithImpl<_GoalScenario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GoalScenarioToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GoalScenario&&(identical(other.name, name) || other.name == name)&&(identical(other.weeklyChange, weeklyChange) || other.weeklyChange == weeklyChange)&&(identical(other.weeksNeeded, weeksNeeded) || other.weeksNeeded == weeksNeeded)&&(identical(other.difficulty, difficulty) || other.difficulty == difficulty)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,weeklyChange,weeksNeeded,difficulty,description);

@override
String toString() {
  return 'GoalScenario(name: $name, weeklyChange: $weeklyChange, weeksNeeded: $weeksNeeded, difficulty: $difficulty, description: $description)';
}


}

/// @nodoc
abstract mixin class _$GoalScenarioCopyWith<$Res> implements $GoalScenarioCopyWith<$Res> {
  factory _$GoalScenarioCopyWith(_GoalScenario value, $Res Function(_GoalScenario) _then) = __$GoalScenarioCopyWithImpl;
@override @useResult
$Res call({
 String name, double weeklyChange, int weeksNeeded, String difficulty, String description
});




}
/// @nodoc
class __$GoalScenarioCopyWithImpl<$Res>
    implements _$GoalScenarioCopyWith<$Res> {
  __$GoalScenarioCopyWithImpl(this._self, this._then);

  final _GoalScenario _self;
  final $Res Function(_GoalScenario) _then;

/// Create a copy of GoalScenario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? weeklyChange = null,Object? weeksNeeded = null,Object? difficulty = null,Object? description = null,}) {
  return _then(_GoalScenario(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,weeklyChange: null == weeklyChange ? _self.weeklyChange : weeklyChange // ignore: cast_nullable_to_non_nullable
as double,weeksNeeded: null == weeksNeeded ? _self.weeksNeeded : weeksNeeded // ignore: cast_nullable_to_non_nullable
as int,difficulty: null == difficulty ? _self.difficulty : difficulty // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CoachingMessage {

/// 메시지 유형 (success/warning/info/tip)
 String get type;/// 제목
 String get title;/// 내용
 String get content;
/// Create a copy of CoachingMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoachingMessageCopyWith<CoachingMessage> get copyWith => _$CoachingMessageCopyWithImpl<CoachingMessage>(this as CoachingMessage, _$identity);

  /// Serializes this CoachingMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CoachingMessage&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,content);

@override
String toString() {
  return 'CoachingMessage(type: $type, title: $title, content: $content)';
}


}

/// @nodoc
abstract mixin class $CoachingMessageCopyWith<$Res>  {
  factory $CoachingMessageCopyWith(CoachingMessage value, $Res Function(CoachingMessage) _then) = _$CoachingMessageCopyWithImpl;
@useResult
$Res call({
 String type, String title, String content
});




}
/// @nodoc
class _$CoachingMessageCopyWithImpl<$Res>
    implements $CoachingMessageCopyWith<$Res> {
  _$CoachingMessageCopyWithImpl(this._self, this._then);

  final CoachingMessage _self;
  final $Res Function(CoachingMessage) _then;

/// Create a copy of CoachingMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? title = null,Object? content = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CoachingMessage].
extension CoachingMessagePatterns on CoachingMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CoachingMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CoachingMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CoachingMessage value)  $default,){
final _that = this;
switch (_that) {
case _CoachingMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CoachingMessage value)?  $default,){
final _that = this;
switch (_that) {
case _CoachingMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String title,  String content)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CoachingMessage() when $default != null:
return $default(_that.type,_that.title,_that.content);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String title,  String content)  $default,) {final _that = this;
switch (_that) {
case _CoachingMessage():
return $default(_that.type,_that.title,_that.content);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String title,  String content)?  $default,) {final _that = this;
switch (_that) {
case _CoachingMessage() when $default != null:
return $default(_that.type,_that.title,_that.content);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CoachingMessage implements CoachingMessage {
  const _CoachingMessage({required this.type, required this.title, required this.content});
  factory _CoachingMessage.fromJson(Map<String, dynamic> json) => _$CoachingMessageFromJson(json);

/// 메시지 유형 (success/warning/info/tip)
@override final  String type;
/// 제목
@override final  String title;
/// 내용
@override final  String content;

/// Create a copy of CoachingMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoachingMessageCopyWith<_CoachingMessage> get copyWith => __$CoachingMessageCopyWithImpl<_CoachingMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoachingMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CoachingMessage&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,title,content);

@override
String toString() {
  return 'CoachingMessage(type: $type, title: $title, content: $content)';
}


}

/// @nodoc
abstract mixin class _$CoachingMessageCopyWith<$Res> implements $CoachingMessageCopyWith<$Res> {
  factory _$CoachingMessageCopyWith(_CoachingMessage value, $Res Function(_CoachingMessage) _then) = __$CoachingMessageCopyWithImpl;
@override @useResult
$Res call({
 String type, String title, String content
});




}
/// @nodoc
class __$CoachingMessageCopyWithImpl<$Res>
    implements _$CoachingMessageCopyWith<$Res> {
  __$CoachingMessageCopyWithImpl(this._self, this._then);

  final _CoachingMessage _self;
  final $Res Function(_CoachingMessage) _then;

/// Create a copy of CoachingMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? title = null,Object? content = null,}) {
  return _then(_CoachingMessage(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GeminiAnalysis {

/// AI 생성 심층 분석 메시지
 String get aiInsight;/// AI 추천 액션 아이템
 List<String> get actionItems;/// AI 생성 동기부여 메시지
 String get motivationalMessage;
/// Create a copy of GeminiAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeminiAnalysisCopyWith<GeminiAnalysis> get copyWith => _$GeminiAnalysisCopyWithImpl<GeminiAnalysis>(this as GeminiAnalysis, _$identity);

  /// Serializes this GeminiAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeminiAnalysis&&(identical(other.aiInsight, aiInsight) || other.aiInsight == aiInsight)&&const DeepCollectionEquality().equals(other.actionItems, actionItems)&&(identical(other.motivationalMessage, motivationalMessage) || other.motivationalMessage == motivationalMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aiInsight,const DeepCollectionEquality().hash(actionItems),motivationalMessage);

@override
String toString() {
  return 'GeminiAnalysis(aiInsight: $aiInsight, actionItems: $actionItems, motivationalMessage: $motivationalMessage)';
}


}

/// @nodoc
abstract mixin class $GeminiAnalysisCopyWith<$Res>  {
  factory $GeminiAnalysisCopyWith(GeminiAnalysis value, $Res Function(GeminiAnalysis) _then) = _$GeminiAnalysisCopyWithImpl;
@useResult
$Res call({
 String aiInsight, List<String> actionItems, String motivationalMessage
});




}
/// @nodoc
class _$GeminiAnalysisCopyWithImpl<$Res>
    implements $GeminiAnalysisCopyWith<$Res> {
  _$GeminiAnalysisCopyWithImpl(this._self, this._then);

  final GeminiAnalysis _self;
  final $Res Function(GeminiAnalysis) _then;

/// Create a copy of GeminiAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? aiInsight = null,Object? actionItems = null,Object? motivationalMessage = null,}) {
  return _then(_self.copyWith(
aiInsight: null == aiInsight ? _self.aiInsight : aiInsight // ignore: cast_nullable_to_non_nullable
as String,actionItems: null == actionItems ? _self.actionItems : actionItems // ignore: cast_nullable_to_non_nullable
as List<String>,motivationalMessage: null == motivationalMessage ? _self.motivationalMessage : motivationalMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GeminiAnalysis].
extension GeminiAnalysisPatterns on GeminiAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeminiAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeminiAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeminiAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _GeminiAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeminiAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _GeminiAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String aiInsight,  List<String> actionItems,  String motivationalMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeminiAnalysis() when $default != null:
return $default(_that.aiInsight,_that.actionItems,_that.motivationalMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String aiInsight,  List<String> actionItems,  String motivationalMessage)  $default,) {final _that = this;
switch (_that) {
case _GeminiAnalysis():
return $default(_that.aiInsight,_that.actionItems,_that.motivationalMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String aiInsight,  List<String> actionItems,  String motivationalMessage)?  $default,) {final _that = this;
switch (_that) {
case _GeminiAnalysis() when $default != null:
return $default(_that.aiInsight,_that.actionItems,_that.motivationalMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeminiAnalysis implements GeminiAnalysis {
  const _GeminiAnalysis({this.aiInsight = '', final  List<String> actionItems = const [], this.motivationalMessage = ''}): _actionItems = actionItems;
  factory _GeminiAnalysis.fromJson(Map<String, dynamic> json) => _$GeminiAnalysisFromJson(json);

/// AI 생성 심층 분석 메시지
@override@JsonKey() final  String aiInsight;
/// AI 추천 액션 아이템
 final  List<String> _actionItems;
/// AI 추천 액션 아이템
@override@JsonKey() List<String> get actionItems {
  if (_actionItems is EqualUnmodifiableListView) return _actionItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_actionItems);
}

/// AI 생성 동기부여 메시지
@override@JsonKey() final  String motivationalMessage;

/// Create a copy of GeminiAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeminiAnalysisCopyWith<_GeminiAnalysis> get copyWith => __$GeminiAnalysisCopyWithImpl<_GeminiAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeminiAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeminiAnalysis&&(identical(other.aiInsight, aiInsight) || other.aiInsight == aiInsight)&&const DeepCollectionEquality().equals(other._actionItems, _actionItems)&&(identical(other.motivationalMessage, motivationalMessage) || other.motivationalMessage == motivationalMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aiInsight,const DeepCollectionEquality().hash(_actionItems),motivationalMessage);

@override
String toString() {
  return 'GeminiAnalysis(aiInsight: $aiInsight, actionItems: $actionItems, motivationalMessage: $motivationalMessage)';
}


}

/// @nodoc
abstract mixin class _$GeminiAnalysisCopyWith<$Res> implements $GeminiAnalysisCopyWith<$Res> {
  factory _$GeminiAnalysisCopyWith(_GeminiAnalysis value, $Res Function(_GeminiAnalysis) _then) = __$GeminiAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String aiInsight, List<String> actionItems, String motivationalMessage
});




}
/// @nodoc
class __$GeminiAnalysisCopyWithImpl<$Res>
    implements _$GeminiAnalysisCopyWith<$Res> {
  __$GeminiAnalysisCopyWithImpl(this._self, this._then);

  final _GeminiAnalysis _self;
  final $Res Function(_GeminiAnalysis) _then;

/// Create a copy of GeminiAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? aiInsight = null,Object? actionItems = null,Object? motivationalMessage = null,}) {
  return _then(_GeminiAnalysis(
aiInsight: null == aiInsight ? _self.aiInsight : aiInsight // ignore: cast_nullable_to_non_nullable
as String,actionItems: null == actionItems ? _self._actionItems : actionItems // ignore: cast_nullable_to_non_nullable
as List<String>,motivationalMessage: null == motivationalMessage ? _self.motivationalMessage : motivationalMessage // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WeightPredictionModel {

/// 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 트레이너 ID
 String get trainerId;/// 현재 체중 (kg)
 double get currentWeight;/// 목표 체중 (kg, nullable)
 double? get targetWeight;/// 예측 데이터 포인트들
 List<PredictedWeightPoint> get predictedWeights;/// 주간 변화량 (kg/week, 음수면 감량 중)
 double get weeklyTrend;/// 목표 도달 예상 주 수 (nullable)
 int? get estimatedWeeksToTarget;/// 예측 신뢰도 (0.0 ~ 1.0)
 double get confidence;/// 예측에 사용된 데이터 포인트 수
 int get dataPointsUsed;/// AI 분석 메시지
 String? get analysisMessage;/// 데이터 요약
 DataSummary? get dataSummary;/// 목표 달성 시나리오들
 List<GoalScenario> get goalScenarios;/// AI 코칭 메시지들
 List<CoachingMessage> get coachingMessages;/// Gemini AI 심층 분석 (Pro 전용)
 GeminiAnalysis? get geminiAnalysis;/// 생성일
@TimestampConverter() DateTime get createdAt;
/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightPredictionModelCopyWith<WeightPredictionModel> get copyWith => _$WeightPredictionModelCopyWithImpl<WeightPredictionModel>(this as WeightPredictionModel, _$identity);

  /// Serializes this WeightPredictionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeightPredictionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&const DeepCollectionEquality().equals(other.predictedWeights, predictedWeights)&&(identical(other.weeklyTrend, weeklyTrend) || other.weeklyTrend == weeklyTrend)&&(identical(other.estimatedWeeksToTarget, estimatedWeeksToTarget) || other.estimatedWeeksToTarget == estimatedWeeksToTarget)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed)&&(identical(other.analysisMessage, analysisMessage) || other.analysisMessage == analysisMessage)&&(identical(other.dataSummary, dataSummary) || other.dataSummary == dataSummary)&&const DeepCollectionEquality().equals(other.goalScenarios, goalScenarios)&&const DeepCollectionEquality().equals(other.coachingMessages, coachingMessages)&&(identical(other.geminiAnalysis, geminiAnalysis) || other.geminiAnalysis == geminiAnalysis)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,currentWeight,targetWeight,const DeepCollectionEquality().hash(predictedWeights),weeklyTrend,estimatedWeeksToTarget,confidence,dataPointsUsed,analysisMessage,dataSummary,const DeepCollectionEquality().hash(goalScenarios),const DeepCollectionEquality().hash(coachingMessages),geminiAnalysis,createdAt);

@override
String toString() {
  return 'WeightPredictionModel(id: $id, memberId: $memberId, trainerId: $trainerId, currentWeight: $currentWeight, targetWeight: $targetWeight, predictedWeights: $predictedWeights, weeklyTrend: $weeklyTrend, estimatedWeeksToTarget: $estimatedWeeksToTarget, confidence: $confidence, dataPointsUsed: $dataPointsUsed, analysisMessage: $analysisMessage, dataSummary: $dataSummary, goalScenarios: $goalScenarios, coachingMessages: $coachingMessages, geminiAnalysis: $geminiAnalysis, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WeightPredictionModelCopyWith<$Res>  {
  factory $WeightPredictionModelCopyWith(WeightPredictionModel value, $Res Function(WeightPredictionModel) _then) = _$WeightPredictionModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, double currentWeight, double? targetWeight, List<PredictedWeightPoint> predictedWeights, double weeklyTrend, int? estimatedWeeksToTarget, double confidence, int dataPointsUsed, String? analysisMessage, DataSummary? dataSummary, List<GoalScenario> goalScenarios, List<CoachingMessage> coachingMessages, GeminiAnalysis? geminiAnalysis,@TimestampConverter() DateTime createdAt
});


$DataSummaryCopyWith<$Res>? get dataSummary;$GeminiAnalysisCopyWith<$Res>? get geminiAnalysis;

}
/// @nodoc
class _$WeightPredictionModelCopyWithImpl<$Res>
    implements $WeightPredictionModelCopyWith<$Res> {
  _$WeightPredictionModelCopyWithImpl(this._self, this._then);

  final WeightPredictionModel _self;
  final $Res Function(WeightPredictionModel) _then;

/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? currentWeight = null,Object? targetWeight = freezed,Object? predictedWeights = null,Object? weeklyTrend = null,Object? estimatedWeeksToTarget = freezed,Object? confidence = null,Object? dataPointsUsed = null,Object? analysisMessage = freezed,Object? dataSummary = freezed,Object? goalScenarios = null,Object? coachingMessages = null,Object? geminiAnalysis = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,targetWeight: freezed == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double?,predictedWeights: null == predictedWeights ? _self.predictedWeights : predictedWeights // ignore: cast_nullable_to_non_nullable
as List<PredictedWeightPoint>,weeklyTrend: null == weeklyTrend ? _self.weeklyTrend : weeklyTrend // ignore: cast_nullable_to_non_nullable
as double,estimatedWeeksToTarget: freezed == estimatedWeeksToTarget ? _self.estimatedWeeksToTarget : estimatedWeeksToTarget // ignore: cast_nullable_to_non_nullable
as int?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,analysisMessage: freezed == analysisMessage ? _self.analysisMessage : analysisMessage // ignore: cast_nullable_to_non_nullable
as String?,dataSummary: freezed == dataSummary ? _self.dataSummary : dataSummary // ignore: cast_nullable_to_non_nullable
as DataSummary?,goalScenarios: null == goalScenarios ? _self.goalScenarios : goalScenarios // ignore: cast_nullable_to_non_nullable
as List<GoalScenario>,coachingMessages: null == coachingMessages ? _self.coachingMessages : coachingMessages // ignore: cast_nullable_to_non_nullable
as List<CoachingMessage>,geminiAnalysis: freezed == geminiAnalysis ? _self.geminiAnalysis : geminiAnalysis // ignore: cast_nullable_to_non_nullable
as GeminiAnalysis?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataSummaryCopyWith<$Res>? get dataSummary {
    if (_self.dataSummary == null) {
    return null;
  }

  return $DataSummaryCopyWith<$Res>(_self.dataSummary!, (value) {
    return _then(_self.copyWith(dataSummary: value));
  });
}/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeminiAnalysisCopyWith<$Res>? get geminiAnalysis {
    if (_self.geminiAnalysis == null) {
    return null;
  }

  return $GeminiAnalysisCopyWith<$Res>(_self.geminiAnalysis!, (value) {
    return _then(_self.copyWith(geminiAnalysis: value));
  });
}
}


/// Adds pattern-matching-related methods to [WeightPredictionModel].
extension WeightPredictionModelPatterns on WeightPredictionModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeightPredictionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeightPredictionModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeightPredictionModel value)  $default,){
final _that = this;
switch (_that) {
case _WeightPredictionModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeightPredictionModel value)?  $default,){
final _that = this;
switch (_that) {
case _WeightPredictionModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  double currentWeight,  double? targetWeight,  List<PredictedWeightPoint> predictedWeights,  double weeklyTrend,  int? estimatedWeeksToTarget,  double confidence,  int dataPointsUsed,  String? analysisMessage,  DataSummary? dataSummary,  List<GoalScenario> goalScenarios,  List<CoachingMessage> coachingMessages,  GeminiAnalysis? geminiAnalysis, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeightPredictionModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.currentWeight,_that.targetWeight,_that.predictedWeights,_that.weeklyTrend,_that.estimatedWeeksToTarget,_that.confidence,_that.dataPointsUsed,_that.analysisMessage,_that.dataSummary,_that.goalScenarios,_that.coachingMessages,_that.geminiAnalysis,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  double currentWeight,  double? targetWeight,  List<PredictedWeightPoint> predictedWeights,  double weeklyTrend,  int? estimatedWeeksToTarget,  double confidence,  int dataPointsUsed,  String? analysisMessage,  DataSummary? dataSummary,  List<GoalScenario> goalScenarios,  List<CoachingMessage> coachingMessages,  GeminiAnalysis? geminiAnalysis, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _WeightPredictionModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.currentWeight,_that.targetWeight,_that.predictedWeights,_that.weeklyTrend,_that.estimatedWeeksToTarget,_that.confidence,_that.dataPointsUsed,_that.analysisMessage,_that.dataSummary,_that.goalScenarios,_that.coachingMessages,_that.geminiAnalysis,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  double currentWeight,  double? targetWeight,  List<PredictedWeightPoint> predictedWeights,  double weeklyTrend,  int? estimatedWeeksToTarget,  double confidence,  int dataPointsUsed,  String? analysisMessage,  DataSummary? dataSummary,  List<GoalScenario> goalScenarios,  List<CoachingMessage> coachingMessages,  GeminiAnalysis? geminiAnalysis, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WeightPredictionModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.currentWeight,_that.targetWeight,_that.predictedWeights,_that.weeklyTrend,_that.estimatedWeeksToTarget,_that.confidence,_that.dataPointsUsed,_that.analysisMessage,_that.dataSummary,_that.goalScenarios,_that.coachingMessages,_that.geminiAnalysis,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeightPredictionModel implements WeightPredictionModel {
  const _WeightPredictionModel({required this.id, required this.memberId, required this.trainerId, required this.currentWeight, this.targetWeight, final  List<PredictedWeightPoint> predictedWeights = const [], required this.weeklyTrend, this.estimatedWeeksToTarget, required this.confidence, required this.dataPointsUsed, this.analysisMessage, this.dataSummary, final  List<GoalScenario> goalScenarios = const [], final  List<CoachingMessage> coachingMessages = const [], this.geminiAnalysis, @TimestampConverter() required this.createdAt}): _predictedWeights = predictedWeights,_goalScenarios = goalScenarios,_coachingMessages = coachingMessages;
  factory _WeightPredictionModel.fromJson(Map<String, dynamic> json) => _$WeightPredictionModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 트레이너 ID
@override final  String trainerId;
/// 현재 체중 (kg)
@override final  double currentWeight;
/// 목표 체중 (kg, nullable)
@override final  double? targetWeight;
/// 예측 데이터 포인트들
 final  List<PredictedWeightPoint> _predictedWeights;
/// 예측 데이터 포인트들
@override@JsonKey() List<PredictedWeightPoint> get predictedWeights {
  if (_predictedWeights is EqualUnmodifiableListView) return _predictedWeights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_predictedWeights);
}

/// 주간 변화량 (kg/week, 음수면 감량 중)
@override final  double weeklyTrend;
/// 목표 도달 예상 주 수 (nullable)
@override final  int? estimatedWeeksToTarget;
/// 예측 신뢰도 (0.0 ~ 1.0)
@override final  double confidence;
/// 예측에 사용된 데이터 포인트 수
@override final  int dataPointsUsed;
/// AI 분석 메시지
@override final  String? analysisMessage;
/// 데이터 요약
@override final  DataSummary? dataSummary;
/// 목표 달성 시나리오들
 final  List<GoalScenario> _goalScenarios;
/// 목표 달성 시나리오들
@override@JsonKey() List<GoalScenario> get goalScenarios {
  if (_goalScenarios is EqualUnmodifiableListView) return _goalScenarios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_goalScenarios);
}

/// AI 코칭 메시지들
 final  List<CoachingMessage> _coachingMessages;
/// AI 코칭 메시지들
@override@JsonKey() List<CoachingMessage> get coachingMessages {
  if (_coachingMessages is EqualUnmodifiableListView) return _coachingMessages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_coachingMessages);
}

/// Gemini AI 심층 분석 (Pro 전용)
@override final  GeminiAnalysis? geminiAnalysis;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightPredictionModelCopyWith<_WeightPredictionModel> get copyWith => __$WeightPredictionModelCopyWithImpl<_WeightPredictionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeightPredictionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeightPredictionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.currentWeight, currentWeight) || other.currentWeight == currentWeight)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&const DeepCollectionEquality().equals(other._predictedWeights, _predictedWeights)&&(identical(other.weeklyTrend, weeklyTrend) || other.weeklyTrend == weeklyTrend)&&(identical(other.estimatedWeeksToTarget, estimatedWeeksToTarget) || other.estimatedWeeksToTarget == estimatedWeeksToTarget)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.dataPointsUsed, dataPointsUsed) || other.dataPointsUsed == dataPointsUsed)&&(identical(other.analysisMessage, analysisMessage) || other.analysisMessage == analysisMessage)&&(identical(other.dataSummary, dataSummary) || other.dataSummary == dataSummary)&&const DeepCollectionEquality().equals(other._goalScenarios, _goalScenarios)&&const DeepCollectionEquality().equals(other._coachingMessages, _coachingMessages)&&(identical(other.geminiAnalysis, geminiAnalysis) || other.geminiAnalysis == geminiAnalysis)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,currentWeight,targetWeight,const DeepCollectionEquality().hash(_predictedWeights),weeklyTrend,estimatedWeeksToTarget,confidence,dataPointsUsed,analysisMessage,dataSummary,const DeepCollectionEquality().hash(_goalScenarios),const DeepCollectionEquality().hash(_coachingMessages),geminiAnalysis,createdAt);

@override
String toString() {
  return 'WeightPredictionModel(id: $id, memberId: $memberId, trainerId: $trainerId, currentWeight: $currentWeight, targetWeight: $targetWeight, predictedWeights: $predictedWeights, weeklyTrend: $weeklyTrend, estimatedWeeksToTarget: $estimatedWeeksToTarget, confidence: $confidence, dataPointsUsed: $dataPointsUsed, analysisMessage: $analysisMessage, dataSummary: $dataSummary, goalScenarios: $goalScenarios, coachingMessages: $coachingMessages, geminiAnalysis: $geminiAnalysis, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WeightPredictionModelCopyWith<$Res> implements $WeightPredictionModelCopyWith<$Res> {
  factory _$WeightPredictionModelCopyWith(_WeightPredictionModel value, $Res Function(_WeightPredictionModel) _then) = __$WeightPredictionModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, double currentWeight, double? targetWeight, List<PredictedWeightPoint> predictedWeights, double weeklyTrend, int? estimatedWeeksToTarget, double confidence, int dataPointsUsed, String? analysisMessage, DataSummary? dataSummary, List<GoalScenario> goalScenarios, List<CoachingMessage> coachingMessages, GeminiAnalysis? geminiAnalysis,@TimestampConverter() DateTime createdAt
});


@override $DataSummaryCopyWith<$Res>? get dataSummary;@override $GeminiAnalysisCopyWith<$Res>? get geminiAnalysis;

}
/// @nodoc
class __$WeightPredictionModelCopyWithImpl<$Res>
    implements _$WeightPredictionModelCopyWith<$Res> {
  __$WeightPredictionModelCopyWithImpl(this._self, this._then);

  final _WeightPredictionModel _self;
  final $Res Function(_WeightPredictionModel) _then;

/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? currentWeight = null,Object? targetWeight = freezed,Object? predictedWeights = null,Object? weeklyTrend = null,Object? estimatedWeeksToTarget = freezed,Object? confidence = null,Object? dataPointsUsed = null,Object? analysisMessage = freezed,Object? dataSummary = freezed,Object? goalScenarios = null,Object? coachingMessages = null,Object? geminiAnalysis = freezed,Object? createdAt = null,}) {
  return _then(_WeightPredictionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,currentWeight: null == currentWeight ? _self.currentWeight : currentWeight // ignore: cast_nullable_to_non_nullable
as double,targetWeight: freezed == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double?,predictedWeights: null == predictedWeights ? _self._predictedWeights : predictedWeights // ignore: cast_nullable_to_non_nullable
as List<PredictedWeightPoint>,weeklyTrend: null == weeklyTrend ? _self.weeklyTrend : weeklyTrend // ignore: cast_nullable_to_non_nullable
as double,estimatedWeeksToTarget: freezed == estimatedWeeksToTarget ? _self.estimatedWeeksToTarget : estimatedWeeksToTarget // ignore: cast_nullable_to_non_nullable
as int?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,dataPointsUsed: null == dataPointsUsed ? _self.dataPointsUsed : dataPointsUsed // ignore: cast_nullable_to_non_nullable
as int,analysisMessage: freezed == analysisMessage ? _self.analysisMessage : analysisMessage // ignore: cast_nullable_to_non_nullable
as String?,dataSummary: freezed == dataSummary ? _self.dataSummary : dataSummary // ignore: cast_nullable_to_non_nullable
as DataSummary?,goalScenarios: null == goalScenarios ? _self._goalScenarios : goalScenarios // ignore: cast_nullable_to_non_nullable
as List<GoalScenario>,coachingMessages: null == coachingMessages ? _self._coachingMessages : coachingMessages // ignore: cast_nullable_to_non_nullable
as List<CoachingMessage>,geminiAnalysis: freezed == geminiAnalysis ? _self.geminiAnalysis : geminiAnalysis // ignore: cast_nullable_to_non_nullable
as GeminiAnalysis?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DataSummaryCopyWith<$Res>? get dataSummary {
    if (_self.dataSummary == null) {
    return null;
  }

  return $DataSummaryCopyWith<$Res>(_self.dataSummary!, (value) {
    return _then(_self.copyWith(dataSummary: value));
  });
}/// Create a copy of WeightPredictionModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeminiAnalysisCopyWith<$Res>? get geminiAnalysis {
    if (_self.geminiAnalysis == null) {
    return null;
  }

  return $GeminiAnalysisCopyWith<$Res>(_self.geminiAnalysis!, (value) {
    return _then(_self.copyWith(geminiAnalysis: value));
  });
}
}

// dart format on
