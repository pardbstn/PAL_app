// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StreakModel {

 String get id; String get memberId; int get weightStreak; int get dietStreak; int get longestWeightStreak; int get longestDietStreak;@StreakTimestampConverter() DateTime? get lastWeightRecordDate;@StreakTimestampConverter() DateTime? get lastDietRecordDate; List<String> get badges;@StreakRequiredTimestampConverter() DateTime get updatedAt;
/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StreakModelCopyWith<StreakModel> get copyWith => _$StreakModelCopyWithImpl<StreakModel>(this as StreakModel, _$identity);

  /// Serializes this StreakModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreakModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.weightStreak, weightStreak) || other.weightStreak == weightStreak)&&(identical(other.dietStreak, dietStreak) || other.dietStreak == dietStreak)&&(identical(other.longestWeightStreak, longestWeightStreak) || other.longestWeightStreak == longestWeightStreak)&&(identical(other.longestDietStreak, longestDietStreak) || other.longestDietStreak == longestDietStreak)&&(identical(other.lastWeightRecordDate, lastWeightRecordDate) || other.lastWeightRecordDate == lastWeightRecordDate)&&(identical(other.lastDietRecordDate, lastDietRecordDate) || other.lastDietRecordDate == lastDietRecordDate)&&const DeepCollectionEquality().equals(other.badges, badges)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,weightStreak,dietStreak,longestWeightStreak,longestDietStreak,lastWeightRecordDate,lastDietRecordDate,const DeepCollectionEquality().hash(badges),updatedAt);

@override
String toString() {
  return 'StreakModel(id: $id, memberId: $memberId, weightStreak: $weightStreak, dietStreak: $dietStreak, longestWeightStreak: $longestWeightStreak, longestDietStreak: $longestDietStreak, lastWeightRecordDate: $lastWeightRecordDate, lastDietRecordDate: $lastDietRecordDate, badges: $badges, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $StreakModelCopyWith<$Res>  {
  factory $StreakModelCopyWith(StreakModel value, $Res Function(StreakModel) _then) = _$StreakModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, int weightStreak, int dietStreak, int longestWeightStreak, int longestDietStreak,@StreakTimestampConverter() DateTime? lastWeightRecordDate,@StreakTimestampConverter() DateTime? lastDietRecordDate, List<String> badges,@StreakRequiredTimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$StreakModelCopyWithImpl<$Res>
    implements $StreakModelCopyWith<$Res> {
  _$StreakModelCopyWithImpl(this._self, this._then);

  final StreakModel _self;
  final $Res Function(StreakModel) _then;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? weightStreak = null,Object? dietStreak = null,Object? longestWeightStreak = null,Object? longestDietStreak = null,Object? lastWeightRecordDate = freezed,Object? lastDietRecordDate = freezed,Object? badges = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,weightStreak: null == weightStreak ? _self.weightStreak : weightStreak // ignore: cast_nullable_to_non_nullable
as int,dietStreak: null == dietStreak ? _self.dietStreak : dietStreak // ignore: cast_nullable_to_non_nullable
as int,longestWeightStreak: null == longestWeightStreak ? _self.longestWeightStreak : longestWeightStreak // ignore: cast_nullable_to_non_nullable
as int,longestDietStreak: null == longestDietStreak ? _self.longestDietStreak : longestDietStreak // ignore: cast_nullable_to_non_nullable
as int,lastWeightRecordDate: freezed == lastWeightRecordDate ? _self.lastWeightRecordDate : lastWeightRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDietRecordDate: freezed == lastDietRecordDate ? _self.lastDietRecordDate : lastDietRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,badges: null == badges ? _self.badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [StreakModel].
extension StreakModelPatterns on StreakModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StreakModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StreakModel value)  $default,){
final _that = this;
switch (_that) {
case _StreakModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StreakModel value)?  $default,){
final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  int weightStreak,  int dietStreak,  int longestWeightStreak,  int longestDietStreak, @StreakTimestampConverter()  DateTime? lastWeightRecordDate, @StreakTimestampConverter()  DateTime? lastDietRecordDate,  List<String> badges, @StreakRequiredTimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
return $default(_that.id,_that.memberId,_that.weightStreak,_that.dietStreak,_that.longestWeightStreak,_that.longestDietStreak,_that.lastWeightRecordDate,_that.lastDietRecordDate,_that.badges,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  int weightStreak,  int dietStreak,  int longestWeightStreak,  int longestDietStreak, @StreakTimestampConverter()  DateTime? lastWeightRecordDate, @StreakTimestampConverter()  DateTime? lastDietRecordDate,  List<String> badges, @StreakRequiredTimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _StreakModel():
return $default(_that.id,_that.memberId,_that.weightStreak,_that.dietStreak,_that.longestWeightStreak,_that.longestDietStreak,_that.lastWeightRecordDate,_that.lastDietRecordDate,_that.badges,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  int weightStreak,  int dietStreak,  int longestWeightStreak,  int longestDietStreak, @StreakTimestampConverter()  DateTime? lastWeightRecordDate, @StreakTimestampConverter()  DateTime? lastDietRecordDate,  List<String> badges, @StreakRequiredTimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _StreakModel() when $default != null:
return $default(_that.id,_that.memberId,_that.weightStreak,_that.dietStreak,_that.longestWeightStreak,_that.longestDietStreak,_that.lastWeightRecordDate,_that.lastDietRecordDate,_that.badges,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StreakModel implements StreakModel {
  const _StreakModel({required this.id, required this.memberId, this.weightStreak = 0, this.dietStreak = 0, this.longestWeightStreak = 0, this.longestDietStreak = 0, @StreakTimestampConverter() this.lastWeightRecordDate, @StreakTimestampConverter() this.lastDietRecordDate, final  List<String> badges = const [], @StreakRequiredTimestampConverter() required this.updatedAt}): _badges = badges;
  factory _StreakModel.fromJson(Map<String, dynamic> json) => _$StreakModelFromJson(json);

@override final  String id;
@override final  String memberId;
@override@JsonKey() final  int weightStreak;
@override@JsonKey() final  int dietStreak;
@override@JsonKey() final  int longestWeightStreak;
@override@JsonKey() final  int longestDietStreak;
@override@StreakTimestampConverter() final  DateTime? lastWeightRecordDate;
@override@StreakTimestampConverter() final  DateTime? lastDietRecordDate;
 final  List<String> _badges;
@override@JsonKey() List<String> get badges {
  if (_badges is EqualUnmodifiableListView) return _badges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badges);
}

@override@StreakRequiredTimestampConverter() final  DateTime updatedAt;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StreakModelCopyWith<_StreakModel> get copyWith => __$StreakModelCopyWithImpl<_StreakModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StreakModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StreakModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.weightStreak, weightStreak) || other.weightStreak == weightStreak)&&(identical(other.dietStreak, dietStreak) || other.dietStreak == dietStreak)&&(identical(other.longestWeightStreak, longestWeightStreak) || other.longestWeightStreak == longestWeightStreak)&&(identical(other.longestDietStreak, longestDietStreak) || other.longestDietStreak == longestDietStreak)&&(identical(other.lastWeightRecordDate, lastWeightRecordDate) || other.lastWeightRecordDate == lastWeightRecordDate)&&(identical(other.lastDietRecordDate, lastDietRecordDate) || other.lastDietRecordDate == lastDietRecordDate)&&const DeepCollectionEquality().equals(other._badges, _badges)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,weightStreak,dietStreak,longestWeightStreak,longestDietStreak,lastWeightRecordDate,lastDietRecordDate,const DeepCollectionEquality().hash(_badges),updatedAt);

@override
String toString() {
  return 'StreakModel(id: $id, memberId: $memberId, weightStreak: $weightStreak, dietStreak: $dietStreak, longestWeightStreak: $longestWeightStreak, longestDietStreak: $longestDietStreak, lastWeightRecordDate: $lastWeightRecordDate, lastDietRecordDate: $lastDietRecordDate, badges: $badges, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$StreakModelCopyWith<$Res> implements $StreakModelCopyWith<$Res> {
  factory _$StreakModelCopyWith(_StreakModel value, $Res Function(_StreakModel) _then) = __$StreakModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, int weightStreak, int dietStreak, int longestWeightStreak, int longestDietStreak,@StreakTimestampConverter() DateTime? lastWeightRecordDate,@StreakTimestampConverter() DateTime? lastDietRecordDate, List<String> badges,@StreakRequiredTimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$StreakModelCopyWithImpl<$Res>
    implements _$StreakModelCopyWith<$Res> {
  __$StreakModelCopyWithImpl(this._self, this._then);

  final _StreakModel _self;
  final $Res Function(_StreakModel) _then;

/// Create a copy of StreakModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? weightStreak = null,Object? dietStreak = null,Object? longestWeightStreak = null,Object? longestDietStreak = null,Object? lastWeightRecordDate = freezed,Object? lastDietRecordDate = freezed,Object? badges = null,Object? updatedAt = null,}) {
  return _then(_StreakModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,weightStreak: null == weightStreak ? _self.weightStreak : weightStreak // ignore: cast_nullable_to_non_nullable
as int,dietStreak: null == dietStreak ? _self.dietStreak : dietStreak // ignore: cast_nullable_to_non_nullable
as int,longestWeightStreak: null == longestWeightStreak ? _self.longestWeightStreak : longestWeightStreak // ignore: cast_nullable_to_non_nullable
as int,longestDietStreak: null == longestDietStreak ? _self.longestDietStreak : longestDietStreak // ignore: cast_nullable_to_non_nullable
as int,lastWeightRecordDate: freezed == lastWeightRecordDate ? _self.lastWeightRecordDate : lastWeightRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,lastDietRecordDate: freezed == lastDietRecordDate ? _self.lastDietRecordDate : lastDietRecordDate // ignore: cast_nullable_to_non_nullable
as DateTime?,badges: null == badges ? _self._badges : badges // ignore: cast_nullable_to_non_nullable
as List<String>,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
