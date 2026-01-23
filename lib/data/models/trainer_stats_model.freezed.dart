// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerStatsModel {

 String get id; double get avgResponseTimeMinutes; int get proactiveMessageCount; double get memberGoalAchievementRate; double get avgMemberBodyFatChange; double get avgMemberAttendanceRate; double get reRegistrationRate; int get longTermMemberCount; double get trainerNoShowRate; double get aiInsightViewRate; int get weeklyMemberDataViewCount; int get dietFeedbackCount;@StatsTimestampConverter() DateTime get lastCalculated;
/// Create a copy of TrainerStatsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerStatsModelCopyWith<TrainerStatsModel> get copyWith => _$TrainerStatsModelCopyWithImpl<TrainerStatsModel>(this as TrainerStatsModel, _$identity);

  /// Serializes this TrainerStatsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerStatsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.avgResponseTimeMinutes, avgResponseTimeMinutes) || other.avgResponseTimeMinutes == avgResponseTimeMinutes)&&(identical(other.proactiveMessageCount, proactiveMessageCount) || other.proactiveMessageCount == proactiveMessageCount)&&(identical(other.memberGoalAchievementRate, memberGoalAchievementRate) || other.memberGoalAchievementRate == memberGoalAchievementRate)&&(identical(other.avgMemberBodyFatChange, avgMemberBodyFatChange) || other.avgMemberBodyFatChange == avgMemberBodyFatChange)&&(identical(other.avgMemberAttendanceRate, avgMemberAttendanceRate) || other.avgMemberAttendanceRate == avgMemberAttendanceRate)&&(identical(other.reRegistrationRate, reRegistrationRate) || other.reRegistrationRate == reRegistrationRate)&&(identical(other.longTermMemberCount, longTermMemberCount) || other.longTermMemberCount == longTermMemberCount)&&(identical(other.trainerNoShowRate, trainerNoShowRate) || other.trainerNoShowRate == trainerNoShowRate)&&(identical(other.aiInsightViewRate, aiInsightViewRate) || other.aiInsightViewRate == aiInsightViewRate)&&(identical(other.weeklyMemberDataViewCount, weeklyMemberDataViewCount) || other.weeklyMemberDataViewCount == weeklyMemberDataViewCount)&&(identical(other.dietFeedbackCount, dietFeedbackCount) || other.dietFeedbackCount == dietFeedbackCount)&&(identical(other.lastCalculated, lastCalculated) || other.lastCalculated == lastCalculated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,avgResponseTimeMinutes,proactiveMessageCount,memberGoalAchievementRate,avgMemberBodyFatChange,avgMemberAttendanceRate,reRegistrationRate,longTermMemberCount,trainerNoShowRate,aiInsightViewRate,weeklyMemberDataViewCount,dietFeedbackCount,lastCalculated);

@override
String toString() {
  return 'TrainerStatsModel(id: $id, avgResponseTimeMinutes: $avgResponseTimeMinutes, proactiveMessageCount: $proactiveMessageCount, memberGoalAchievementRate: $memberGoalAchievementRate, avgMemberBodyFatChange: $avgMemberBodyFatChange, avgMemberAttendanceRate: $avgMemberAttendanceRate, reRegistrationRate: $reRegistrationRate, longTermMemberCount: $longTermMemberCount, trainerNoShowRate: $trainerNoShowRate, aiInsightViewRate: $aiInsightViewRate, weeklyMemberDataViewCount: $weeklyMemberDataViewCount, dietFeedbackCount: $dietFeedbackCount, lastCalculated: $lastCalculated)';
}


}

/// @nodoc
abstract mixin class $TrainerStatsModelCopyWith<$Res>  {
  factory $TrainerStatsModelCopyWith(TrainerStatsModel value, $Res Function(TrainerStatsModel) _then) = _$TrainerStatsModelCopyWithImpl;
@useResult
$Res call({
 String id, double avgResponseTimeMinutes, int proactiveMessageCount, double memberGoalAchievementRate, double avgMemberBodyFatChange, double avgMemberAttendanceRate, double reRegistrationRate, int longTermMemberCount, double trainerNoShowRate, double aiInsightViewRate, int weeklyMemberDataViewCount, int dietFeedbackCount,@StatsTimestampConverter() DateTime lastCalculated
});




}
/// @nodoc
class _$TrainerStatsModelCopyWithImpl<$Res>
    implements $TrainerStatsModelCopyWith<$Res> {
  _$TrainerStatsModelCopyWithImpl(this._self, this._then);

  final TrainerStatsModel _self;
  final $Res Function(TrainerStatsModel) _then;

/// Create a copy of TrainerStatsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? avgResponseTimeMinutes = null,Object? proactiveMessageCount = null,Object? memberGoalAchievementRate = null,Object? avgMemberBodyFatChange = null,Object? avgMemberAttendanceRate = null,Object? reRegistrationRate = null,Object? longTermMemberCount = null,Object? trainerNoShowRate = null,Object? aiInsightViewRate = null,Object? weeklyMemberDataViewCount = null,Object? dietFeedbackCount = null,Object? lastCalculated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,avgResponseTimeMinutes: null == avgResponseTimeMinutes ? _self.avgResponseTimeMinutes : avgResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
as double,proactiveMessageCount: null == proactiveMessageCount ? _self.proactiveMessageCount : proactiveMessageCount // ignore: cast_nullable_to_non_nullable
as int,memberGoalAchievementRate: null == memberGoalAchievementRate ? _self.memberGoalAchievementRate : memberGoalAchievementRate // ignore: cast_nullable_to_non_nullable
as double,avgMemberBodyFatChange: null == avgMemberBodyFatChange ? _self.avgMemberBodyFatChange : avgMemberBodyFatChange // ignore: cast_nullable_to_non_nullable
as double,avgMemberAttendanceRate: null == avgMemberAttendanceRate ? _self.avgMemberAttendanceRate : avgMemberAttendanceRate // ignore: cast_nullable_to_non_nullable
as double,reRegistrationRate: null == reRegistrationRate ? _self.reRegistrationRate : reRegistrationRate // ignore: cast_nullable_to_non_nullable
as double,longTermMemberCount: null == longTermMemberCount ? _self.longTermMemberCount : longTermMemberCount // ignore: cast_nullable_to_non_nullable
as int,trainerNoShowRate: null == trainerNoShowRate ? _self.trainerNoShowRate : trainerNoShowRate // ignore: cast_nullable_to_non_nullable
as double,aiInsightViewRate: null == aiInsightViewRate ? _self.aiInsightViewRate : aiInsightViewRate // ignore: cast_nullable_to_non_nullable
as double,weeklyMemberDataViewCount: null == weeklyMemberDataViewCount ? _self.weeklyMemberDataViewCount : weeklyMemberDataViewCount // ignore: cast_nullable_to_non_nullable
as int,dietFeedbackCount: null == dietFeedbackCount ? _self.dietFeedbackCount : dietFeedbackCount // ignore: cast_nullable_to_non_nullable
as int,lastCalculated: null == lastCalculated ? _self.lastCalculated : lastCalculated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerStatsModel].
extension TrainerStatsModelPatterns on TrainerStatsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerStatsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerStatsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerStatsModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerStatsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerStatsModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerStatsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double avgResponseTimeMinutes,  int proactiveMessageCount,  double memberGoalAchievementRate,  double avgMemberBodyFatChange,  double avgMemberAttendanceRate,  double reRegistrationRate,  int longTermMemberCount,  double trainerNoShowRate,  double aiInsightViewRate,  int weeklyMemberDataViewCount,  int dietFeedbackCount, @StatsTimestampConverter()  DateTime lastCalculated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerStatsModel() when $default != null:
return $default(_that.id,_that.avgResponseTimeMinutes,_that.proactiveMessageCount,_that.memberGoalAchievementRate,_that.avgMemberBodyFatChange,_that.avgMemberAttendanceRate,_that.reRegistrationRate,_that.longTermMemberCount,_that.trainerNoShowRate,_that.aiInsightViewRate,_that.weeklyMemberDataViewCount,_that.dietFeedbackCount,_that.lastCalculated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double avgResponseTimeMinutes,  int proactiveMessageCount,  double memberGoalAchievementRate,  double avgMemberBodyFatChange,  double avgMemberAttendanceRate,  double reRegistrationRate,  int longTermMemberCount,  double trainerNoShowRate,  double aiInsightViewRate,  int weeklyMemberDataViewCount,  int dietFeedbackCount, @StatsTimestampConverter()  DateTime lastCalculated)  $default,) {final _that = this;
switch (_that) {
case _TrainerStatsModel():
return $default(_that.id,_that.avgResponseTimeMinutes,_that.proactiveMessageCount,_that.memberGoalAchievementRate,_that.avgMemberBodyFatChange,_that.avgMemberAttendanceRate,_that.reRegistrationRate,_that.longTermMemberCount,_that.trainerNoShowRate,_that.aiInsightViewRate,_that.weeklyMemberDataViewCount,_that.dietFeedbackCount,_that.lastCalculated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double avgResponseTimeMinutes,  int proactiveMessageCount,  double memberGoalAchievementRate,  double avgMemberBodyFatChange,  double avgMemberAttendanceRate,  double reRegistrationRate,  int longTermMemberCount,  double trainerNoShowRate,  double aiInsightViewRate,  int weeklyMemberDataViewCount,  int dietFeedbackCount, @StatsTimestampConverter()  DateTime lastCalculated)?  $default,) {final _that = this;
switch (_that) {
case _TrainerStatsModel() when $default != null:
return $default(_that.id,_that.avgResponseTimeMinutes,_that.proactiveMessageCount,_that.memberGoalAchievementRate,_that.avgMemberBodyFatChange,_that.avgMemberAttendanceRate,_that.reRegistrationRate,_that.longTermMemberCount,_that.trainerNoShowRate,_that.aiInsightViewRate,_that.weeklyMemberDataViewCount,_that.dietFeedbackCount,_that.lastCalculated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerStatsModel implements TrainerStatsModel {
  const _TrainerStatsModel({this.id = '', this.avgResponseTimeMinutes = 0.0, this.proactiveMessageCount = 0, this.memberGoalAchievementRate = 0.0, this.avgMemberBodyFatChange = 0.0, this.avgMemberAttendanceRate = 0.0, this.reRegistrationRate = 0.0, this.longTermMemberCount = 0, this.trainerNoShowRate = 0.0, this.aiInsightViewRate = 0.0, this.weeklyMemberDataViewCount = 0, this.dietFeedbackCount = 0, @StatsTimestampConverter() required this.lastCalculated});
  factory _TrainerStatsModel.fromJson(Map<String, dynamic> json) => _$TrainerStatsModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  double avgResponseTimeMinutes;
@override@JsonKey() final  int proactiveMessageCount;
@override@JsonKey() final  double memberGoalAchievementRate;
@override@JsonKey() final  double avgMemberBodyFatChange;
@override@JsonKey() final  double avgMemberAttendanceRate;
@override@JsonKey() final  double reRegistrationRate;
@override@JsonKey() final  int longTermMemberCount;
@override@JsonKey() final  double trainerNoShowRate;
@override@JsonKey() final  double aiInsightViewRate;
@override@JsonKey() final  int weeklyMemberDataViewCount;
@override@JsonKey() final  int dietFeedbackCount;
@override@StatsTimestampConverter() final  DateTime lastCalculated;

/// Create a copy of TrainerStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerStatsModelCopyWith<_TrainerStatsModel> get copyWith => __$TrainerStatsModelCopyWithImpl<_TrainerStatsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerStatsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerStatsModel&&(identical(other.id, id) || other.id == id)&&(identical(other.avgResponseTimeMinutes, avgResponseTimeMinutes) || other.avgResponseTimeMinutes == avgResponseTimeMinutes)&&(identical(other.proactiveMessageCount, proactiveMessageCount) || other.proactiveMessageCount == proactiveMessageCount)&&(identical(other.memberGoalAchievementRate, memberGoalAchievementRate) || other.memberGoalAchievementRate == memberGoalAchievementRate)&&(identical(other.avgMemberBodyFatChange, avgMemberBodyFatChange) || other.avgMemberBodyFatChange == avgMemberBodyFatChange)&&(identical(other.avgMemberAttendanceRate, avgMemberAttendanceRate) || other.avgMemberAttendanceRate == avgMemberAttendanceRate)&&(identical(other.reRegistrationRate, reRegistrationRate) || other.reRegistrationRate == reRegistrationRate)&&(identical(other.longTermMemberCount, longTermMemberCount) || other.longTermMemberCount == longTermMemberCount)&&(identical(other.trainerNoShowRate, trainerNoShowRate) || other.trainerNoShowRate == trainerNoShowRate)&&(identical(other.aiInsightViewRate, aiInsightViewRate) || other.aiInsightViewRate == aiInsightViewRate)&&(identical(other.weeklyMemberDataViewCount, weeklyMemberDataViewCount) || other.weeklyMemberDataViewCount == weeklyMemberDataViewCount)&&(identical(other.dietFeedbackCount, dietFeedbackCount) || other.dietFeedbackCount == dietFeedbackCount)&&(identical(other.lastCalculated, lastCalculated) || other.lastCalculated == lastCalculated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,avgResponseTimeMinutes,proactiveMessageCount,memberGoalAchievementRate,avgMemberBodyFatChange,avgMemberAttendanceRate,reRegistrationRate,longTermMemberCount,trainerNoShowRate,aiInsightViewRate,weeklyMemberDataViewCount,dietFeedbackCount,lastCalculated);

@override
String toString() {
  return 'TrainerStatsModel(id: $id, avgResponseTimeMinutes: $avgResponseTimeMinutes, proactiveMessageCount: $proactiveMessageCount, memberGoalAchievementRate: $memberGoalAchievementRate, avgMemberBodyFatChange: $avgMemberBodyFatChange, avgMemberAttendanceRate: $avgMemberAttendanceRate, reRegistrationRate: $reRegistrationRate, longTermMemberCount: $longTermMemberCount, trainerNoShowRate: $trainerNoShowRate, aiInsightViewRate: $aiInsightViewRate, weeklyMemberDataViewCount: $weeklyMemberDataViewCount, dietFeedbackCount: $dietFeedbackCount, lastCalculated: $lastCalculated)';
}


}

/// @nodoc
abstract mixin class _$TrainerStatsModelCopyWith<$Res> implements $TrainerStatsModelCopyWith<$Res> {
  factory _$TrainerStatsModelCopyWith(_TrainerStatsModel value, $Res Function(_TrainerStatsModel) _then) = __$TrainerStatsModelCopyWithImpl;
@override @useResult
$Res call({
 String id, double avgResponseTimeMinutes, int proactiveMessageCount, double memberGoalAchievementRate, double avgMemberBodyFatChange, double avgMemberAttendanceRate, double reRegistrationRate, int longTermMemberCount, double trainerNoShowRate, double aiInsightViewRate, int weeklyMemberDataViewCount, int dietFeedbackCount,@StatsTimestampConverter() DateTime lastCalculated
});




}
/// @nodoc
class __$TrainerStatsModelCopyWithImpl<$Res>
    implements _$TrainerStatsModelCopyWith<$Res> {
  __$TrainerStatsModelCopyWithImpl(this._self, this._then);

  final _TrainerStatsModel _self;
  final $Res Function(_TrainerStatsModel) _then;

/// Create a copy of TrainerStatsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? avgResponseTimeMinutes = null,Object? proactiveMessageCount = null,Object? memberGoalAchievementRate = null,Object? avgMemberBodyFatChange = null,Object? avgMemberAttendanceRate = null,Object? reRegistrationRate = null,Object? longTermMemberCount = null,Object? trainerNoShowRate = null,Object? aiInsightViewRate = null,Object? weeklyMemberDataViewCount = null,Object? dietFeedbackCount = null,Object? lastCalculated = null,}) {
  return _then(_TrainerStatsModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,avgResponseTimeMinutes: null == avgResponseTimeMinutes ? _self.avgResponseTimeMinutes : avgResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
as double,proactiveMessageCount: null == proactiveMessageCount ? _self.proactiveMessageCount : proactiveMessageCount // ignore: cast_nullable_to_non_nullable
as int,memberGoalAchievementRate: null == memberGoalAchievementRate ? _self.memberGoalAchievementRate : memberGoalAchievementRate // ignore: cast_nullable_to_non_nullable
as double,avgMemberBodyFatChange: null == avgMemberBodyFatChange ? _self.avgMemberBodyFatChange : avgMemberBodyFatChange // ignore: cast_nullable_to_non_nullable
as double,avgMemberAttendanceRate: null == avgMemberAttendanceRate ? _self.avgMemberAttendanceRate : avgMemberAttendanceRate // ignore: cast_nullable_to_non_nullable
as double,reRegistrationRate: null == reRegistrationRate ? _self.reRegistrationRate : reRegistrationRate // ignore: cast_nullable_to_non_nullable
as double,longTermMemberCount: null == longTermMemberCount ? _self.longTermMemberCount : longTermMemberCount // ignore: cast_nullable_to_non_nullable
as int,trainerNoShowRate: null == trainerNoShowRate ? _self.trainerNoShowRate : trainerNoShowRate // ignore: cast_nullable_to_non_nullable
as double,aiInsightViewRate: null == aiInsightViewRate ? _self.aiInsightViewRate : aiInsightViewRate // ignore: cast_nullable_to_non_nullable
as double,weeklyMemberDataViewCount: null == weeklyMemberDataViewCount ? _self.weeklyMemberDataViewCount : weeklyMemberDataViewCount // ignore: cast_nullable_to_non_nullable
as int,dietFeedbackCount: null == dietFeedbackCount ? _self.dietFeedbackCount : dietFeedbackCount // ignore: cast_nullable_to_non_nullable
as int,lastCalculated: null == lastCalculated ? _self.lastCalculated : lastCalculated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
