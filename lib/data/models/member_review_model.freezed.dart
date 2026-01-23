// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MemberReviewModel {

 String get id; String get memberId; String get memberName; int get coachingSatisfaction; int get communication; int get kindness; String get comment;@ReviewTimestampConverter() DateTime get createdAt;
/// Create a copy of MemberReviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberReviewModelCopyWith<MemberReviewModel> get copyWith => _$MemberReviewModelCopyWithImpl<MemberReviewModel>(this as MemberReviewModel, _$identity);

  /// Serializes this MemberReviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.coachingSatisfaction, coachingSatisfaction) || other.coachingSatisfaction == coachingSatisfaction)&&(identical(other.communication, communication) || other.communication == communication)&&(identical(other.kindness, kindness) || other.kindness == kindness)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,coachingSatisfaction,communication,kindness,comment,createdAt);

@override
String toString() {
  return 'MemberReviewModel(id: $id, memberId: $memberId, memberName: $memberName, coachingSatisfaction: $coachingSatisfaction, communication: $communication, kindness: $kindness, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MemberReviewModelCopyWith<$Res>  {
  factory $MemberReviewModelCopyWith(MemberReviewModel value, $Res Function(MemberReviewModel) _then) = _$MemberReviewModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String memberName, int coachingSatisfaction, int communication, int kindness, String comment,@ReviewTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$MemberReviewModelCopyWithImpl<$Res>
    implements $MemberReviewModelCopyWith<$Res> {
  _$MemberReviewModelCopyWithImpl(this._self, this._then);

  final MemberReviewModel _self;
  final $Res Function(MemberReviewModel) _then;

/// Create a copy of MemberReviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? coachingSatisfaction = null,Object? communication = null,Object? kindness = null,Object? comment = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,coachingSatisfaction: null == coachingSatisfaction ? _self.coachingSatisfaction : coachingSatisfaction // ignore: cast_nullable_to_non_nullable
as int,communication: null == communication ? _self.communication : communication // ignore: cast_nullable_to_non_nullable
as int,kindness: null == kindness ? _self.kindness : kindness // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MemberReviewModel].
extension MemberReviewModelPatterns on MemberReviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberReviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberReviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberReviewModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberReviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberReviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberReviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  int coachingSatisfaction,  int communication,  int kindness,  String comment, @ReviewTimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberReviewModel() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.coachingSatisfaction,_that.communication,_that.kindness,_that.comment,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String memberName,  int coachingSatisfaction,  int communication,  int kindness,  String comment, @ReviewTimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _MemberReviewModel():
return $default(_that.id,_that.memberId,_that.memberName,_that.coachingSatisfaction,_that.communication,_that.kindness,_that.comment,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String memberName,  int coachingSatisfaction,  int communication,  int kindness,  String comment, @ReviewTimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MemberReviewModel() when $default != null:
return $default(_that.id,_that.memberId,_that.memberName,_that.coachingSatisfaction,_that.communication,_that.kindness,_that.comment,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberReviewModel implements MemberReviewModel {
  const _MemberReviewModel({this.id = '', required this.memberId, required this.memberName, this.coachingSatisfaction = 5, this.communication = 5, this.kindness = 5, this.comment = '', @ReviewTimestampConverter() required this.createdAt});
  factory _MemberReviewModel.fromJson(Map<String, dynamic> json) => _$MemberReviewModelFromJson(json);

@override@JsonKey() final  String id;
@override final  String memberId;
@override final  String memberName;
@override@JsonKey() final  int coachingSatisfaction;
@override@JsonKey() final  int communication;
@override@JsonKey() final  int kindness;
@override@JsonKey() final  String comment;
@override@ReviewTimestampConverter() final  DateTime createdAt;

/// Create a copy of MemberReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberReviewModelCopyWith<_MemberReviewModel> get copyWith => __$MemberReviewModelCopyWithImpl<_MemberReviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberReviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.coachingSatisfaction, coachingSatisfaction) || other.coachingSatisfaction == coachingSatisfaction)&&(identical(other.communication, communication) || other.communication == communication)&&(identical(other.kindness, kindness) || other.kindness == kindness)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,memberName,coachingSatisfaction,communication,kindness,comment,createdAt);

@override
String toString() {
  return 'MemberReviewModel(id: $id, memberId: $memberId, memberName: $memberName, coachingSatisfaction: $coachingSatisfaction, communication: $communication, kindness: $kindness, comment: $comment, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MemberReviewModelCopyWith<$Res> implements $MemberReviewModelCopyWith<$Res> {
  factory _$MemberReviewModelCopyWith(_MemberReviewModel value, $Res Function(_MemberReviewModel) _then) = __$MemberReviewModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String memberName, int coachingSatisfaction, int communication, int kindness, String comment,@ReviewTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$MemberReviewModelCopyWithImpl<$Res>
    implements _$MemberReviewModelCopyWith<$Res> {
  __$MemberReviewModelCopyWithImpl(this._self, this._then);

  final _MemberReviewModel _self;
  final $Res Function(_MemberReviewModel) _then;

/// Create a copy of MemberReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? memberName = null,Object? coachingSatisfaction = null,Object? communication = null,Object? kindness = null,Object? comment = null,Object? createdAt = null,}) {
  return _then(_MemberReviewModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,coachingSatisfaction: null == coachingSatisfaction ? _self.coachingSatisfaction : coachingSatisfaction // ignore: cast_nullable_to_non_nullable
as int,communication: null == communication ? _self.communication : communication // ignore: cast_nullable_to_non_nullable
as int,kindness: null == kindness ? _self.kindness : kindness // ignore: cast_nullable_to_non_nullable
as int,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
