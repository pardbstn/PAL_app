// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_rating_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerRatingModel {

 String get id; double get overall; double get memberRating; double get aiRating; int get reviewCount;@RatingTimestampConverter() DateTime get lastUpdated;
/// Create a copy of TrainerRatingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerRatingModelCopyWith<TrainerRatingModel> get copyWith => _$TrainerRatingModelCopyWithImpl<TrainerRatingModel>(this as TrainerRatingModel, _$identity);

  /// Serializes this TrainerRatingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerRatingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.memberRating, memberRating) || other.memberRating == memberRating)&&(identical(other.aiRating, aiRating) || other.aiRating == aiRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,overall,memberRating,aiRating,reviewCount,lastUpdated);

@override
String toString() {
  return 'TrainerRatingModel(id: $id, overall: $overall, memberRating: $memberRating, aiRating: $aiRating, reviewCount: $reviewCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $TrainerRatingModelCopyWith<$Res>  {
  factory $TrainerRatingModelCopyWith(TrainerRatingModel value, $Res Function(TrainerRatingModel) _then) = _$TrainerRatingModelCopyWithImpl;
@useResult
$Res call({
 String id, double overall, double memberRating, double aiRating, int reviewCount,@RatingTimestampConverter() DateTime lastUpdated
});




}
/// @nodoc
class _$TrainerRatingModelCopyWithImpl<$Res>
    implements $TrainerRatingModelCopyWith<$Res> {
  _$TrainerRatingModelCopyWithImpl(this._self, this._then);

  final TrainerRatingModel _self;
  final $Res Function(TrainerRatingModel) _then;

/// Create a copy of TrainerRatingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? overall = null,Object? memberRating = null,Object? aiRating = null,Object? reviewCount = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as double,memberRating: null == memberRating ? _self.memberRating : memberRating // ignore: cast_nullable_to_non_nullable
as double,aiRating: null == aiRating ? _self.aiRating : aiRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerRatingModel].
extension TrainerRatingModelPatterns on TrainerRatingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerRatingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerRatingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerRatingModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerRatingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerRatingModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerRatingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double overall,  double memberRating,  double aiRating,  int reviewCount, @RatingTimestampConverter()  DateTime lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerRatingModel() when $default != null:
return $default(_that.id,_that.overall,_that.memberRating,_that.aiRating,_that.reviewCount,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double overall,  double memberRating,  double aiRating,  int reviewCount, @RatingTimestampConverter()  DateTime lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _TrainerRatingModel():
return $default(_that.id,_that.overall,_that.memberRating,_that.aiRating,_that.reviewCount,_that.lastUpdated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double overall,  double memberRating,  double aiRating,  int reviewCount, @RatingTimestampConverter()  DateTime lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _TrainerRatingModel() when $default != null:
return $default(_that.id,_that.overall,_that.memberRating,_that.aiRating,_that.reviewCount,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerRatingModel implements TrainerRatingModel {
  const _TrainerRatingModel({this.id = '', this.overall = 0.0, this.memberRating = 0.0, this.aiRating = 0.0, this.reviewCount = 0, @RatingTimestampConverter() required this.lastUpdated});
  factory _TrainerRatingModel.fromJson(Map<String, dynamic> json) => _$TrainerRatingModelFromJson(json);

@override@JsonKey() final  String id;
@override@JsonKey() final  double overall;
@override@JsonKey() final  double memberRating;
@override@JsonKey() final  double aiRating;
@override@JsonKey() final  int reviewCount;
@override@RatingTimestampConverter() final  DateTime lastUpdated;

/// Create a copy of TrainerRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerRatingModelCopyWith<_TrainerRatingModel> get copyWith => __$TrainerRatingModelCopyWithImpl<_TrainerRatingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerRatingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerRatingModel&&(identical(other.id, id) || other.id == id)&&(identical(other.overall, overall) || other.overall == overall)&&(identical(other.memberRating, memberRating) || other.memberRating == memberRating)&&(identical(other.aiRating, aiRating) || other.aiRating == aiRating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,overall,memberRating,aiRating,reviewCount,lastUpdated);

@override
String toString() {
  return 'TrainerRatingModel(id: $id, overall: $overall, memberRating: $memberRating, aiRating: $aiRating, reviewCount: $reviewCount, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$TrainerRatingModelCopyWith<$Res> implements $TrainerRatingModelCopyWith<$Res> {
  factory _$TrainerRatingModelCopyWith(_TrainerRatingModel value, $Res Function(_TrainerRatingModel) _then) = __$TrainerRatingModelCopyWithImpl;
@override @useResult
$Res call({
 String id, double overall, double memberRating, double aiRating, int reviewCount,@RatingTimestampConverter() DateTime lastUpdated
});




}
/// @nodoc
class __$TrainerRatingModelCopyWithImpl<$Res>
    implements _$TrainerRatingModelCopyWith<$Res> {
  __$TrainerRatingModelCopyWithImpl(this._self, this._then);

  final _TrainerRatingModel _self;
  final $Res Function(_TrainerRatingModel) _then;

/// Create a copy of TrainerRatingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? overall = null,Object? memberRating = null,Object? aiRating = null,Object? reviewCount = null,Object? lastUpdated = null,}) {
  return _then(_TrainerRatingModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,overall: null == overall ? _self.overall : overall // ignore: cast_nullable_to_non_nullable
as double,memberRating: null == memberRating ? _self.memberRating : memberRating // ignore: cast_nullable_to_non_nullable
as double,aiRating: null == aiRating ? _self.aiRating : aiRating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
