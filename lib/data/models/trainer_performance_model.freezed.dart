// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_performance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerPerformanceModel {

 String get id; String get trainerId;/// 재등록률 (0.0 ~ 1.0)
 double get reregistrationRate;/// 목표달성률 (0.0 ~ 1.0)
 double get goalAchievementRate;/// 평균 체성분 변화 (kg, 양수=증가, 음수=감소)
 double get avgBodyCompositionChange;/// 출석률 관리 (0.0 ~ 1.0)
 double get attendanceManagementRate;/// 총 평가 수
 int get totalReviews;/// 평균 평점 (1.0 ~ 5.0)
 double get averageRating;/// 총 회원 수
 int get totalMembers;/// 활성 회원 수
 int get activeMembers;@PerformanceTimestampConverter() DateTime get updatedAt;
/// Create a copy of TrainerPerformanceModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerPerformanceModelCopyWith<TrainerPerformanceModel> get copyWith => _$TrainerPerformanceModelCopyWithImpl<TrainerPerformanceModel>(this as TrainerPerformanceModel, _$identity);

  /// Serializes this TrainerPerformanceModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerPerformanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.reregistrationRate, reregistrationRate) || other.reregistrationRate == reregistrationRate)&&(identical(other.goalAchievementRate, goalAchievementRate) || other.goalAchievementRate == goalAchievementRate)&&(identical(other.avgBodyCompositionChange, avgBodyCompositionChange) || other.avgBodyCompositionChange == avgBodyCompositionChange)&&(identical(other.attendanceManagementRate, attendanceManagementRate) || other.attendanceManagementRate == attendanceManagementRate)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,reregistrationRate,goalAchievementRate,avgBodyCompositionChange,attendanceManagementRate,totalReviews,averageRating,totalMembers,activeMembers,updatedAt);

@override
String toString() {
  return 'TrainerPerformanceModel(id: $id, trainerId: $trainerId, reregistrationRate: $reregistrationRate, goalAchievementRate: $goalAchievementRate, avgBodyCompositionChange: $avgBodyCompositionChange, attendanceManagementRate: $attendanceManagementRate, totalReviews: $totalReviews, averageRating: $averageRating, totalMembers: $totalMembers, activeMembers: $activeMembers, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TrainerPerformanceModelCopyWith<$Res>  {
  factory $TrainerPerformanceModelCopyWith(TrainerPerformanceModel value, $Res Function(TrainerPerformanceModel) _then) = _$TrainerPerformanceModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, double reregistrationRate, double goalAchievementRate, double avgBodyCompositionChange, double attendanceManagementRate, int totalReviews, double averageRating, int totalMembers, int activeMembers,@PerformanceTimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$TrainerPerformanceModelCopyWithImpl<$Res>
    implements $TrainerPerformanceModelCopyWith<$Res> {
  _$TrainerPerformanceModelCopyWithImpl(this._self, this._then);

  final TrainerPerformanceModel _self;
  final $Res Function(TrainerPerformanceModel) _then;

/// Create a copy of TrainerPerformanceModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? reregistrationRate = null,Object? goalAchievementRate = null,Object? avgBodyCompositionChange = null,Object? attendanceManagementRate = null,Object? totalReviews = null,Object? averageRating = null,Object? totalMembers = null,Object? activeMembers = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,reregistrationRate: null == reregistrationRate ? _self.reregistrationRate : reregistrationRate // ignore: cast_nullable_to_non_nullable
as double,goalAchievementRate: null == goalAchievementRate ? _self.goalAchievementRate : goalAchievementRate // ignore: cast_nullable_to_non_nullable
as double,avgBodyCompositionChange: null == avgBodyCompositionChange ? _self.avgBodyCompositionChange : avgBodyCompositionChange // ignore: cast_nullable_to_non_nullable
as double,attendanceManagementRate: null == attendanceManagementRate ? _self.attendanceManagementRate : attendanceManagementRate // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerPerformanceModel].
extension TrainerPerformanceModelPatterns on TrainerPerformanceModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerPerformanceModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerPerformanceModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerPerformanceModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerPerformanceModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerPerformanceModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerPerformanceModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  double reregistrationRate,  double goalAchievementRate,  double avgBodyCompositionChange,  double attendanceManagementRate,  int totalReviews,  double averageRating,  int totalMembers,  int activeMembers, @PerformanceTimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerPerformanceModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.reregistrationRate,_that.goalAchievementRate,_that.avgBodyCompositionChange,_that.attendanceManagementRate,_that.totalReviews,_that.averageRating,_that.totalMembers,_that.activeMembers,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  double reregistrationRate,  double goalAchievementRate,  double avgBodyCompositionChange,  double attendanceManagementRate,  int totalReviews,  double averageRating,  int totalMembers,  int activeMembers, @PerformanceTimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerPerformanceModel():
return $default(_that.id,_that.trainerId,_that.reregistrationRate,_that.goalAchievementRate,_that.avgBodyCompositionChange,_that.attendanceManagementRate,_that.totalReviews,_that.averageRating,_that.totalMembers,_that.activeMembers,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  double reregistrationRate,  double goalAchievementRate,  double avgBodyCompositionChange,  double attendanceManagementRate,  int totalReviews,  double averageRating,  int totalMembers,  int activeMembers, @PerformanceTimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerPerformanceModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.reregistrationRate,_that.goalAchievementRate,_that.avgBodyCompositionChange,_that.attendanceManagementRate,_that.totalReviews,_that.averageRating,_that.totalMembers,_that.activeMembers,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerPerformanceModel implements TrainerPerformanceModel {
  const _TrainerPerformanceModel({required this.id, required this.trainerId, this.reregistrationRate = 0.0, this.goalAchievementRate = 0.0, this.avgBodyCompositionChange = 0.0, this.attendanceManagementRate = 0.0, this.totalReviews = 0, this.averageRating = 0.0, this.totalMembers = 0, this.activeMembers = 0, @PerformanceTimestampConverter() required this.updatedAt});
  factory _TrainerPerformanceModel.fromJson(Map<String, dynamic> json) => _$TrainerPerformanceModelFromJson(json);

@override final  String id;
@override final  String trainerId;
/// 재등록률 (0.0 ~ 1.0)
@override@JsonKey() final  double reregistrationRate;
/// 목표달성률 (0.0 ~ 1.0)
@override@JsonKey() final  double goalAchievementRate;
/// 평균 체성분 변화 (kg, 양수=증가, 음수=감소)
@override@JsonKey() final  double avgBodyCompositionChange;
/// 출석률 관리 (0.0 ~ 1.0)
@override@JsonKey() final  double attendanceManagementRate;
/// 총 평가 수
@override@JsonKey() final  int totalReviews;
/// 평균 평점 (1.0 ~ 5.0)
@override@JsonKey() final  double averageRating;
/// 총 회원 수
@override@JsonKey() final  int totalMembers;
/// 활성 회원 수
@override@JsonKey() final  int activeMembers;
@override@PerformanceTimestampConverter() final  DateTime updatedAt;

/// Create a copy of TrainerPerformanceModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerPerformanceModelCopyWith<_TrainerPerformanceModel> get copyWith => __$TrainerPerformanceModelCopyWithImpl<_TrainerPerformanceModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerPerformanceModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerPerformanceModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.reregistrationRate, reregistrationRate) || other.reregistrationRate == reregistrationRate)&&(identical(other.goalAchievementRate, goalAchievementRate) || other.goalAchievementRate == goalAchievementRate)&&(identical(other.avgBodyCompositionChange, avgBodyCompositionChange) || other.avgBodyCompositionChange == avgBodyCompositionChange)&&(identical(other.attendanceManagementRate, attendanceManagementRate) || other.attendanceManagementRate == attendanceManagementRate)&&(identical(other.totalReviews, totalReviews) || other.totalReviews == totalReviews)&&(identical(other.averageRating, averageRating) || other.averageRating == averageRating)&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,reregistrationRate,goalAchievementRate,avgBodyCompositionChange,attendanceManagementRate,totalReviews,averageRating,totalMembers,activeMembers,updatedAt);

@override
String toString() {
  return 'TrainerPerformanceModel(id: $id, trainerId: $trainerId, reregistrationRate: $reregistrationRate, goalAchievementRate: $goalAchievementRate, avgBodyCompositionChange: $avgBodyCompositionChange, attendanceManagementRate: $attendanceManagementRate, totalReviews: $totalReviews, averageRating: $averageRating, totalMembers: $totalMembers, activeMembers: $activeMembers, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerPerformanceModelCopyWith<$Res> implements $TrainerPerformanceModelCopyWith<$Res> {
  factory _$TrainerPerformanceModelCopyWith(_TrainerPerformanceModel value, $Res Function(_TrainerPerformanceModel) _then) = __$TrainerPerformanceModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, double reregistrationRate, double goalAchievementRate, double avgBodyCompositionChange, double attendanceManagementRate, int totalReviews, double averageRating, int totalMembers, int activeMembers,@PerformanceTimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$TrainerPerformanceModelCopyWithImpl<$Res>
    implements _$TrainerPerformanceModelCopyWith<$Res> {
  __$TrainerPerformanceModelCopyWithImpl(this._self, this._then);

  final _TrainerPerformanceModel _self;
  final $Res Function(_TrainerPerformanceModel) _then;

/// Create a copy of TrainerPerformanceModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? reregistrationRate = null,Object? goalAchievementRate = null,Object? avgBodyCompositionChange = null,Object? attendanceManagementRate = null,Object? totalReviews = null,Object? averageRating = null,Object? totalMembers = null,Object? activeMembers = null,Object? updatedAt = null,}) {
  return _then(_TrainerPerformanceModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,reregistrationRate: null == reregistrationRate ? _self.reregistrationRate : reregistrationRate // ignore: cast_nullable_to_non_nullable
as double,goalAchievementRate: null == goalAchievementRate ? _self.goalAchievementRate : goalAchievementRate // ignore: cast_nullable_to_non_nullable
as double,avgBodyCompositionChange: null == avgBodyCompositionChange ? _self.avgBodyCompositionChange : avgBodyCompositionChange // ignore: cast_nullable_to_non_nullable
as double,attendanceManagementRate: null == attendanceManagementRate ? _self.attendanceManagementRate : attendanceManagementRate // ignore: cast_nullable_to_non_nullable
as double,totalReviews: null == totalReviews ? _self.totalReviews : totalReviews // ignore: cast_nullable_to_non_nullable
as int,averageRating: null == averageRating ? _self.averageRating : averageRating // ignore: cast_nullable_to_non_nullable
as double,totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
