// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reregistration_alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReregistrationAlertModel {

 String get id; String get memberId; String get trainerId; int get totalSessions; int get completedSessions; double get progressRate;@ReregistrationTimestampConverter() DateTime? get alertSentAt; bool get reregistered;@ReregistrationRequiredTimestampConverter() DateTime get createdAt;
/// Create a copy of ReregistrationAlertModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReregistrationAlertModelCopyWith<ReregistrationAlertModel> get copyWith => _$ReregistrationAlertModelCopyWithImpl<ReregistrationAlertModel>(this as ReregistrationAlertModel, _$identity);

  /// Serializes this ReregistrationAlertModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReregistrationAlertModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.progressRate, progressRate) || other.progressRate == progressRate)&&(identical(other.alertSentAt, alertSentAt) || other.alertSentAt == alertSentAt)&&(identical(other.reregistered, reregistered) || other.reregistered == reregistered)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,totalSessions,completedSessions,progressRate,alertSentAt,reregistered,createdAt);

@override
String toString() {
  return 'ReregistrationAlertModel(id: $id, memberId: $memberId, trainerId: $trainerId, totalSessions: $totalSessions, completedSessions: $completedSessions, progressRate: $progressRate, alertSentAt: $alertSentAt, reregistered: $reregistered, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ReregistrationAlertModelCopyWith<$Res>  {
  factory $ReregistrationAlertModelCopyWith(ReregistrationAlertModel value, $Res Function(ReregistrationAlertModel) _then) = _$ReregistrationAlertModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, int totalSessions, int completedSessions, double progressRate,@ReregistrationTimestampConverter() DateTime? alertSentAt, bool reregistered,@ReregistrationRequiredTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$ReregistrationAlertModelCopyWithImpl<$Res>
    implements $ReregistrationAlertModelCopyWith<$Res> {
  _$ReregistrationAlertModelCopyWithImpl(this._self, this._then);

  final ReregistrationAlertModel _self;
  final $Res Function(ReregistrationAlertModel) _then;

/// Create a copy of ReregistrationAlertModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? totalSessions = null,Object? completedSessions = null,Object? progressRate = null,Object? alertSentAt = freezed,Object? reregistered = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,progressRate: null == progressRate ? _self.progressRate : progressRate // ignore: cast_nullable_to_non_nullable
as double,alertSentAt: freezed == alertSentAt ? _self.alertSentAt : alertSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reregistered: null == reregistered ? _self.reregistered : reregistered // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ReregistrationAlertModel].
extension ReregistrationAlertModelPatterns on ReregistrationAlertModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReregistrationAlertModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReregistrationAlertModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReregistrationAlertModel value)  $default,){
final _that = this;
switch (_that) {
case _ReregistrationAlertModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReregistrationAlertModel value)?  $default,){
final _that = this;
switch (_that) {
case _ReregistrationAlertModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  int totalSessions,  int completedSessions,  double progressRate, @ReregistrationTimestampConverter()  DateTime? alertSentAt,  bool reregistered, @ReregistrationRequiredTimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReregistrationAlertModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.totalSessions,_that.completedSessions,_that.progressRate,_that.alertSentAt,_that.reregistered,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  int totalSessions,  int completedSessions,  double progressRate, @ReregistrationTimestampConverter()  DateTime? alertSentAt,  bool reregistered, @ReregistrationRequiredTimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ReregistrationAlertModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.totalSessions,_that.completedSessions,_that.progressRate,_that.alertSentAt,_that.reregistered,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  int totalSessions,  int completedSessions,  double progressRate, @ReregistrationTimestampConverter()  DateTime? alertSentAt,  bool reregistered, @ReregistrationRequiredTimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ReregistrationAlertModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.totalSessions,_that.completedSessions,_that.progressRate,_that.alertSentAt,_that.reregistered,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReregistrationAlertModel implements ReregistrationAlertModel {
  const _ReregistrationAlertModel({required this.id, required this.memberId, required this.trainerId, required this.totalSessions, required this.completedSessions, required this.progressRate, @ReregistrationTimestampConverter() this.alertSentAt, this.reregistered = false, @ReregistrationRequiredTimestampConverter() required this.createdAt});
  factory _ReregistrationAlertModel.fromJson(Map<String, dynamic> json) => _$ReregistrationAlertModelFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  String trainerId;
@override final  int totalSessions;
@override final  int completedSessions;
@override final  double progressRate;
@override@ReregistrationTimestampConverter() final  DateTime? alertSentAt;
@override@JsonKey() final  bool reregistered;
@override@ReregistrationRequiredTimestampConverter() final  DateTime createdAt;

/// Create a copy of ReregistrationAlertModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReregistrationAlertModelCopyWith<_ReregistrationAlertModel> get copyWith => __$ReregistrationAlertModelCopyWithImpl<_ReregistrationAlertModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReregistrationAlertModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReregistrationAlertModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.progressRate, progressRate) || other.progressRate == progressRate)&&(identical(other.alertSentAt, alertSentAt) || other.alertSentAt == alertSentAt)&&(identical(other.reregistered, reregistered) || other.reregistered == reregistered)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,totalSessions,completedSessions,progressRate,alertSentAt,reregistered,createdAt);

@override
String toString() {
  return 'ReregistrationAlertModel(id: $id, memberId: $memberId, trainerId: $trainerId, totalSessions: $totalSessions, completedSessions: $completedSessions, progressRate: $progressRate, alertSentAt: $alertSentAt, reregistered: $reregistered, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ReregistrationAlertModelCopyWith<$Res> implements $ReregistrationAlertModelCopyWith<$Res> {
  factory _$ReregistrationAlertModelCopyWith(_ReregistrationAlertModel value, $Res Function(_ReregistrationAlertModel) _then) = __$ReregistrationAlertModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, int totalSessions, int completedSessions, double progressRate,@ReregistrationTimestampConverter() DateTime? alertSentAt, bool reregistered,@ReregistrationRequiredTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$ReregistrationAlertModelCopyWithImpl<$Res>
    implements _$ReregistrationAlertModelCopyWith<$Res> {
  __$ReregistrationAlertModelCopyWithImpl(this._self, this._then);

  final _ReregistrationAlertModel _self;
  final $Res Function(_ReregistrationAlertModel) _then;

/// Create a copy of ReregistrationAlertModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? totalSessions = null,Object? completedSessions = null,Object? progressRate = null,Object? alertSentAt = freezed,Object? reregistered = null,Object? createdAt = null,}) {
  return _then(_ReregistrationAlertModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,progressRate: null == progressRate ? _self.progressRate : progressRate // ignore: cast_nullable_to_non_nullable
as double,alertSentAt: freezed == alertSentAt ? _self.alertSentAt : alertSentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,reregistered: null == reregistered ? _self.reregistered : reregistered // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
