// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerRequestModel {

 String get id; String get memberId; String get trainerId; RequestType get requestType; String get content; List<String> get attachmentUrls; String? get response; RequestStatus get status; int get price;@RequestTimestampConverter() DateTime get createdAt;@RequestNullableTimestampConverter() DateTime? get answeredAt;
/// Create a copy of TrainerRequestModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerRequestModelCopyWith<TrainerRequestModel> get copyWith => _$TrainerRequestModelCopyWithImpl<TrainerRequestModel>(this as TrainerRequestModel, _$identity);

  /// Serializes this TrainerRequestModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.attachmentUrls, attachmentUrls)&&(identical(other.response, response) || other.response == response)&&(identical(other.status, status) || other.status == status)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,requestType,content,const DeepCollectionEquality().hash(attachmentUrls),response,status,price,createdAt,answeredAt);

@override
String toString() {
  return 'TrainerRequestModel(id: $id, memberId: $memberId, trainerId: $trainerId, requestType: $requestType, content: $content, attachmentUrls: $attachmentUrls, response: $response, status: $status, price: $price, createdAt: $createdAt, answeredAt: $answeredAt)';
}


}

/// @nodoc
abstract mixin class $TrainerRequestModelCopyWith<$Res>  {
  factory $TrainerRequestModelCopyWith(TrainerRequestModel value, $Res Function(TrainerRequestModel) _then) = _$TrainerRequestModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, RequestType requestType, String content, List<String> attachmentUrls, String? response, RequestStatus status, int price,@RequestTimestampConverter() DateTime createdAt,@RequestNullableTimestampConverter() DateTime? answeredAt
});




}
/// @nodoc
class _$TrainerRequestModelCopyWithImpl<$Res>
    implements $TrainerRequestModelCopyWith<$Res> {
  _$TrainerRequestModelCopyWithImpl(this._self, this._then);

  final TrainerRequestModel _self;
  final $Res Function(TrainerRequestModel) _then;

/// Create a copy of TrainerRequestModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? requestType = null,Object? content = null,Object? attachmentUrls = null,Object? response = freezed,Object? status = null,Object? price = null,Object? createdAt = null,Object? answeredAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachmentUrls: null == attachmentUrls ? _self.attachmentUrls : attachmentUrls // ignore: cast_nullable_to_non_nullable
as List<String>,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerRequestModel].
extension TrainerRequestModelPatterns on TrainerRequestModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerRequestModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerRequestModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerRequestModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerRequestModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerRequestModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerRequestModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  RequestType requestType,  String content,  List<String> attachmentUrls,  String? response,  RequestStatus status,  int price, @RequestTimestampConverter()  DateTime createdAt, @RequestNullableTimestampConverter()  DateTime? answeredAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerRequestModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.requestType,_that.content,_that.attachmentUrls,_that.response,_that.status,_that.price,_that.createdAt,_that.answeredAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  RequestType requestType,  String content,  List<String> attachmentUrls,  String? response,  RequestStatus status,  int price, @RequestTimestampConverter()  DateTime createdAt, @RequestNullableTimestampConverter()  DateTime? answeredAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerRequestModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.requestType,_that.content,_that.attachmentUrls,_that.response,_that.status,_that.price,_that.createdAt,_that.answeredAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  RequestType requestType,  String content,  List<String> attachmentUrls,  String? response,  RequestStatus status,  int price, @RequestTimestampConverter()  DateTime createdAt, @RequestNullableTimestampConverter()  DateTime? answeredAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerRequestModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.requestType,_that.content,_that.attachmentUrls,_that.response,_that.status,_that.price,_that.createdAt,_that.answeredAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerRequestModel implements TrainerRequestModel {
  const _TrainerRequestModel({required this.id, required this.memberId, required this.trainerId, required this.requestType, required this.content, final  List<String> attachmentUrls = const [], this.response, this.status = RequestStatus.pending, required this.price, @RequestTimestampConverter() required this.createdAt, @RequestNullableTimestampConverter() this.answeredAt}): _attachmentUrls = attachmentUrls;
  factory _TrainerRequestModel.fromJson(Map<String, dynamic> json) => _$TrainerRequestModelFromJson(json);

@override final  String id;
@override final  String memberId;
@override final  String trainerId;
@override final  RequestType requestType;
@override final  String content;
 final  List<String> _attachmentUrls;
@override@JsonKey() List<String> get attachmentUrls {
  if (_attachmentUrls is EqualUnmodifiableListView) return _attachmentUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachmentUrls);
}

@override final  String? response;
@override@JsonKey() final  RequestStatus status;
@override final  int price;
@override@RequestTimestampConverter() final  DateTime createdAt;
@override@RequestNullableTimestampConverter() final  DateTime? answeredAt;

/// Create a copy of TrainerRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerRequestModelCopyWith<_TrainerRequestModel> get copyWith => __$TrainerRequestModelCopyWithImpl<_TrainerRequestModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerRequestModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerRequestModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.requestType, requestType) || other.requestType == requestType)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._attachmentUrls, _attachmentUrls)&&(identical(other.response, response) || other.response == response)&&(identical(other.status, status) || other.status == status)&&(identical(other.price, price) || other.price == price)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.answeredAt, answeredAt) || other.answeredAt == answeredAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,requestType,content,const DeepCollectionEquality().hash(_attachmentUrls),response,status,price,createdAt,answeredAt);

@override
String toString() {
  return 'TrainerRequestModel(id: $id, memberId: $memberId, trainerId: $trainerId, requestType: $requestType, content: $content, attachmentUrls: $attachmentUrls, response: $response, status: $status, price: $price, createdAt: $createdAt, answeredAt: $answeredAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerRequestModelCopyWith<$Res> implements $TrainerRequestModelCopyWith<$Res> {
  factory _$TrainerRequestModelCopyWith(_TrainerRequestModel value, $Res Function(_TrainerRequestModel) _then) = __$TrainerRequestModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, RequestType requestType, String content, List<String> attachmentUrls, String? response, RequestStatus status, int price,@RequestTimestampConverter() DateTime createdAt,@RequestNullableTimestampConverter() DateTime? answeredAt
});




}
/// @nodoc
class __$TrainerRequestModelCopyWithImpl<$Res>
    implements _$TrainerRequestModelCopyWith<$Res> {
  __$TrainerRequestModelCopyWithImpl(this._self, this._then);

  final _TrainerRequestModel _self;
  final $Res Function(_TrainerRequestModel) _then;

/// Create a copy of TrainerRequestModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? requestType = null,Object? content = null,Object? attachmentUrls = null,Object? response = freezed,Object? status = null,Object? price = null,Object? createdAt = null,Object? answeredAt = freezed,}) {
  return _then(_TrainerRequestModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,requestType: null == requestType ? _self.requestType : requestType // ignore: cast_nullable_to_non_nullable
as RequestType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachmentUrls: null == attachmentUrls ? _self._attachmentUrls : attachmentUrls // ignore: cast_nullable_to_non_nullable
as List<String>,response: freezed == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RequestStatus,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,answeredAt: freezed == answeredAt ? _self.answeredAt : answeredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
