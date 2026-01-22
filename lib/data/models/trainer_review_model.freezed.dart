// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_review_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerReviewModel {

 String get id; String get trainerId; String get memberId;/// 전문성 (1-5)
 int get professionalism;/// 소통력 (1-5)
 int get communication;/// 시간준수 (1-5)
 int get punctuality;/// 변화만족도 (1-5)
 int get satisfaction;/// 재등록의향 (1-5)
 int get reregistrationIntent; String? get comment; bool get isPublic;@ReviewTimestampConverter() DateTime get createdAt;
/// Create a copy of TrainerReviewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerReviewModelCopyWith<TrainerReviewModel> get copyWith => _$TrainerReviewModelCopyWithImpl<TrainerReviewModel>(this as TrainerReviewModel, _$identity);

  /// Serializes this TrainerReviewModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.professionalism, professionalism) || other.professionalism == professionalism)&&(identical(other.communication, communication) || other.communication == communication)&&(identical(other.punctuality, punctuality) || other.punctuality == punctuality)&&(identical(other.satisfaction, satisfaction) || other.satisfaction == satisfaction)&&(identical(other.reregistrationIntent, reregistrationIntent) || other.reregistrationIntent == reregistrationIntent)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,professionalism,communication,punctuality,satisfaction,reregistrationIntent,comment,isPublic,createdAt);

@override
String toString() {
  return 'TrainerReviewModel(id: $id, trainerId: $trainerId, memberId: $memberId, professionalism: $professionalism, communication: $communication, punctuality: $punctuality, satisfaction: $satisfaction, reregistrationIntent: $reregistrationIntent, comment: $comment, isPublic: $isPublic, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TrainerReviewModelCopyWith<$Res>  {
  factory $TrainerReviewModelCopyWith(TrainerReviewModel value, $Res Function(TrainerReviewModel) _then) = _$TrainerReviewModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String memberId, int professionalism, int communication, int punctuality, int satisfaction, int reregistrationIntent, String? comment, bool isPublic,@ReviewTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$TrainerReviewModelCopyWithImpl<$Res>
    implements $TrainerReviewModelCopyWith<$Res> {
  _$TrainerReviewModelCopyWithImpl(this._self, this._then);

  final TrainerReviewModel _self;
  final $Res Function(TrainerReviewModel) _then;

/// Create a copy of TrainerReviewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? professionalism = null,Object? communication = null,Object? punctuality = null,Object? satisfaction = null,Object? reregistrationIntent = null,Object? comment = freezed,Object? isPublic = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,professionalism: null == professionalism ? _self.professionalism : professionalism // ignore: cast_nullable_to_non_nullable
as int,communication: null == communication ? _self.communication : communication // ignore: cast_nullable_to_non_nullable
as int,punctuality: null == punctuality ? _self.punctuality : punctuality // ignore: cast_nullable_to_non_nullable
as int,satisfaction: null == satisfaction ? _self.satisfaction : satisfaction // ignore: cast_nullable_to_non_nullable
as int,reregistrationIntent: null == reregistrationIntent ? _self.reregistrationIntent : reregistrationIntent // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerReviewModel].
extension TrainerReviewModelPatterns on TrainerReviewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerReviewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerReviewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerReviewModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerReviewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerReviewModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerReviewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  int professionalism,  int communication,  int punctuality,  int satisfaction,  int reregistrationIntent,  String? comment,  bool isPublic, @ReviewTimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerReviewModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.professionalism,_that.communication,_that.punctuality,_that.satisfaction,_that.reregistrationIntent,_that.comment,_that.isPublic,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  int professionalism,  int communication,  int punctuality,  int satisfaction,  int reregistrationIntent,  String? comment,  bool isPublic, @ReviewTimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerReviewModel():
return $default(_that.id,_that.trainerId,_that.memberId,_that.professionalism,_that.communication,_that.punctuality,_that.satisfaction,_that.reregistrationIntent,_that.comment,_that.isPublic,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String memberId,  int professionalism,  int communication,  int punctuality,  int satisfaction,  int reregistrationIntent,  String? comment,  bool isPublic, @ReviewTimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerReviewModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.professionalism,_that.communication,_that.punctuality,_that.satisfaction,_that.reregistrationIntent,_that.comment,_that.isPublic,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerReviewModel implements TrainerReviewModel {
  const _TrainerReviewModel({required this.id, required this.trainerId, required this.memberId, required this.professionalism, required this.communication, required this.punctuality, required this.satisfaction, required this.reregistrationIntent, this.comment, this.isPublic = false, @ReviewTimestampConverter() required this.createdAt});
  factory _TrainerReviewModel.fromJson(Map<String, dynamic> json) => _$TrainerReviewModelFromJson(json);

@override final  String id;
@override final  String trainerId;
@override final  String memberId;
/// 전문성 (1-5)
@override final  int professionalism;
/// 소통력 (1-5)
@override final  int communication;
/// 시간준수 (1-5)
@override final  int punctuality;
/// 변화만족도 (1-5)
@override final  int satisfaction;
/// 재등록의향 (1-5)
@override final  int reregistrationIntent;
@override final  String? comment;
@override@JsonKey() final  bool isPublic;
@override@ReviewTimestampConverter() final  DateTime createdAt;

/// Create a copy of TrainerReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerReviewModelCopyWith<_TrainerReviewModel> get copyWith => __$TrainerReviewModelCopyWithImpl<_TrainerReviewModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerReviewModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerReviewModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.professionalism, professionalism) || other.professionalism == professionalism)&&(identical(other.communication, communication) || other.communication == communication)&&(identical(other.punctuality, punctuality) || other.punctuality == punctuality)&&(identical(other.satisfaction, satisfaction) || other.satisfaction == satisfaction)&&(identical(other.reregistrationIntent, reregistrationIntent) || other.reregistrationIntent == reregistrationIntent)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,professionalism,communication,punctuality,satisfaction,reregistrationIntent,comment,isPublic,createdAt);

@override
String toString() {
  return 'TrainerReviewModel(id: $id, trainerId: $trainerId, memberId: $memberId, professionalism: $professionalism, communication: $communication, punctuality: $punctuality, satisfaction: $satisfaction, reregistrationIntent: $reregistrationIntent, comment: $comment, isPublic: $isPublic, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerReviewModelCopyWith<$Res> implements $TrainerReviewModelCopyWith<$Res> {
  factory _$TrainerReviewModelCopyWith(_TrainerReviewModel value, $Res Function(_TrainerReviewModel) _then) = __$TrainerReviewModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String memberId, int professionalism, int communication, int punctuality, int satisfaction, int reregistrationIntent, String? comment, bool isPublic,@ReviewTimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$TrainerReviewModelCopyWithImpl<$Res>
    implements _$TrainerReviewModelCopyWith<$Res> {
  __$TrainerReviewModelCopyWithImpl(this._self, this._then);

  final _TrainerReviewModel _self;
  final $Res Function(_TrainerReviewModel) _then;

/// Create a copy of TrainerReviewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? professionalism = null,Object? communication = null,Object? punctuality = null,Object? satisfaction = null,Object? reregistrationIntent = null,Object? comment = freezed,Object? isPublic = null,Object? createdAt = null,}) {
  return _then(_TrainerReviewModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,professionalism: null == professionalism ? _self.professionalism : professionalism // ignore: cast_nullable_to_non_nullable
as int,communication: null == communication ? _self.communication : communication // ignore: cast_nullable_to_non_nullable
as int,punctuality: null == punctuality ? _self.punctuality : punctuality // ignore: cast_nullable_to_non_nullable
as int,satisfaction: null == satisfaction ? _self.satisfaction : satisfaction // ignore: cast_nullable_to_non_nullable
as int,reregistrationIntent: null == reregistrationIntent ? _self.reregistrationIntent : reregistrationIntent // ignore: cast_nullable_to_non_nullable
as int,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
