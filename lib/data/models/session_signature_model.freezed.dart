// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_signature_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionSignatureModel {

/// 서명 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 트레이너 ID
 String get trainerId;/// 커리큘럼 ID (연결된 회차)
 String get curriculumId;/// 회차 번호
 int get sessionNumber;/// 서명 이미지 URL (Supabase Storage)
 String get signatureImageUrl;/// 서명 일시
@TimestampConverter() DateTime get signedAt;/// 수업 메모 (선택)
 String? get memo;/// 생성일
@TimestampConverter() DateTime get createdAt;/// 수정일
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of SessionSignatureModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionSignatureModelCopyWith<SessionSignatureModel> get copyWith => _$SessionSignatureModelCopyWithImpl<SessionSignatureModel>(this as SessionSignatureModel, _$identity);

  /// Serializes this SessionSignatureModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionSignatureModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.signatureImageUrl, signatureImageUrl) || other.signatureImageUrl == signatureImageUrl)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,curriculumId,sessionNumber,signatureImageUrl,signedAt,memo,createdAt,updatedAt);

@override
String toString() {
  return 'SessionSignatureModel(id: $id, memberId: $memberId, trainerId: $trainerId, curriculumId: $curriculumId, sessionNumber: $sessionNumber, signatureImageUrl: $signatureImageUrl, signedAt: $signedAt, memo: $memo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SessionSignatureModelCopyWith<$Res>  {
  factory $SessionSignatureModelCopyWith(SessionSignatureModel value, $Res Function(SessionSignatureModel) _then) = _$SessionSignatureModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, String curriculumId, int sessionNumber, String signatureImageUrl,@TimestampConverter() DateTime signedAt, String? memo,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$SessionSignatureModelCopyWithImpl<$Res>
    implements $SessionSignatureModelCopyWith<$Res> {
  _$SessionSignatureModelCopyWithImpl(this._self, this._then);

  final SessionSignatureModel _self;
  final $Res Function(SessionSignatureModel) _then;

/// Create a copy of SessionSignatureModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? curriculumId = null,Object? sessionNumber = null,Object? signatureImageUrl = null,Object? signedAt = null,Object? memo = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,signatureImageUrl: null == signatureImageUrl ? _self.signatureImageUrl : signatureImageUrl // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SessionSignatureModel].
extension SessionSignatureModelPatterns on SessionSignatureModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SessionSignatureModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SessionSignatureModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SessionSignatureModel value)  $default,){
final _that = this;
switch (_that) {
case _SessionSignatureModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SessionSignatureModel value)?  $default,){
final _that = this;
switch (_that) {
case _SessionSignatureModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  String curriculumId,  int sessionNumber,  String signatureImageUrl, @TimestampConverter()  DateTime signedAt,  String? memo, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SessionSignatureModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.curriculumId,_that.sessionNumber,_that.signatureImageUrl,_that.signedAt,_that.memo,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  String curriculumId,  int sessionNumber,  String signatureImageUrl, @TimestampConverter()  DateTime signedAt,  String? memo, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SessionSignatureModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.curriculumId,_that.sessionNumber,_that.signatureImageUrl,_that.signedAt,_that.memo,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  String curriculumId,  int sessionNumber,  String signatureImageUrl, @TimestampConverter()  DateTime signedAt,  String? memo, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SessionSignatureModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.curriculumId,_that.sessionNumber,_that.signatureImageUrl,_that.signedAt,_that.memo,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SessionSignatureModel implements SessionSignatureModel {
  const _SessionSignatureModel({required this.id, required this.memberId, required this.trainerId, required this.curriculumId, required this.sessionNumber, required this.signatureImageUrl, @TimestampConverter() required this.signedAt, this.memo, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt});
  factory _SessionSignatureModel.fromJson(Map<String, dynamic> json) => _$SessionSignatureModelFromJson(json);

/// 서명 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 트레이너 ID
@override final  String trainerId;
/// 커리큘럼 ID (연결된 회차)
@override final  String curriculumId;
/// 회차 번호
@override final  int sessionNumber;
/// 서명 이미지 URL (Supabase Storage)
@override final  String signatureImageUrl;
/// 서명 일시
@override@TimestampConverter() final  DateTime signedAt;
/// 수업 메모 (선택)
@override final  String? memo;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;
/// 수정일
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of SessionSignatureModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionSignatureModelCopyWith<_SessionSignatureModel> get copyWith => __$SessionSignatureModelCopyWithImpl<_SessionSignatureModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SessionSignatureModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SessionSignatureModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.curriculumId, curriculumId) || other.curriculumId == curriculumId)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.signatureImageUrl, signatureImageUrl) || other.signatureImageUrl == signatureImageUrl)&&(identical(other.signedAt, signedAt) || other.signedAt == signedAt)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,curriculumId,sessionNumber,signatureImageUrl,signedAt,memo,createdAt,updatedAt);

@override
String toString() {
  return 'SessionSignatureModel(id: $id, memberId: $memberId, trainerId: $trainerId, curriculumId: $curriculumId, sessionNumber: $sessionNumber, signatureImageUrl: $signatureImageUrl, signedAt: $signedAt, memo: $memo, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionSignatureModelCopyWith<$Res> implements $SessionSignatureModelCopyWith<$Res> {
  factory _$SessionSignatureModelCopyWith(_SessionSignatureModel value, $Res Function(_SessionSignatureModel) _then) = __$SessionSignatureModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, String curriculumId, int sessionNumber, String signatureImageUrl,@TimestampConverter() DateTime signedAt, String? memo,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$SessionSignatureModelCopyWithImpl<$Res>
    implements _$SessionSignatureModelCopyWith<$Res> {
  __$SessionSignatureModelCopyWithImpl(this._self, this._then);

  final _SessionSignatureModel _self;
  final $Res Function(_SessionSignatureModel) _then;

/// Create a copy of SessionSignatureModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? curriculumId = null,Object? sessionNumber = null,Object? signatureImageUrl = null,Object? signedAt = null,Object? memo = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SessionSignatureModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,curriculumId: null == curriculumId ? _self.curriculumId : curriculumId // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,signatureImageUrl: null == signatureImageUrl ? _self.signatureImageUrl : signatureImageUrl // ignore: cast_nullable_to_non_nullable
as String,signedAt: null == signedAt ? _self.signedAt : signedAt // ignore: cast_nullable_to_non_nullable
as DateTime,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
