// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InsightModel {

/// 문서 ID
 String get id;/// 트레이너 ID
 String get trainerId;/// 회원 ID (nullable - 전체 대시보드 인사이트일 수 있음)
 String? get memberId;/// 회원 이름 (표시용)
 String? get memberName;/// 인사이트 유형
 InsightType get type;/// 우선순위
 InsightPriority get priority;/// 제목
 String get title;/// 메시지 내용
 String get message;/// 권장 조치 사항 (nullable)
 String? get actionSuggestion;/// 추가 데이터 (nullable)
 Map<String, dynamic>? get data;/// 읽음 여부
 bool get isRead;/// 조치 완료 여부
 bool get isActionTaken;/// 생성일
@TimestampConverter() DateTime get createdAt;/// 만료일 (nullable)
@NullableTimestampConverter() DateTime? get expiresAt;
/// Create a copy of InsightModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InsightModelCopyWith<InsightModel> get copyWith => _$InsightModelCopyWithImpl<InsightModel>(this as InsightModel, _$identity);

  /// Serializes this InsightModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InsightModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.actionSuggestion, actionSuggestion) || other.actionSuggestion == actionSuggestion)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isActionTaken, isActionTaken) || other.isActionTaken == isActionTaken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,memberName,type,priority,title,message,actionSuggestion,const DeepCollectionEquality().hash(data),isRead,isActionTaken,createdAt,expiresAt);

@override
String toString() {
  return 'InsightModel(id: $id, trainerId: $trainerId, memberId: $memberId, memberName: $memberName, type: $type, priority: $priority, title: $title, message: $message, actionSuggestion: $actionSuggestion, data: $data, isRead: $isRead, isActionTaken: $isActionTaken, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class $InsightModelCopyWith<$Res>  {
  factory $InsightModelCopyWith(InsightModel value, $Res Function(InsightModel) _then) = _$InsightModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String? memberId, String? memberName, InsightType type, InsightPriority priority, String title, String message, String? actionSuggestion, Map<String, dynamic>? data, bool isRead, bool isActionTaken,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class _$InsightModelCopyWithImpl<$Res>
    implements $InsightModelCopyWith<$Res> {
  _$InsightModelCopyWithImpl(this._self, this._then);

  final InsightModel _self;
  final $Res Function(InsightModel) _then;

/// Create a copy of InsightModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? memberId = freezed,Object? memberName = freezed,Object? type = null,Object? priority = null,Object? title = null,Object? message = null,Object? actionSuggestion = freezed,Object? data = freezed,Object? isRead = null,Object? isActionTaken = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as InsightPriority,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,actionSuggestion: freezed == actionSuggestion ? _self.actionSuggestion : actionSuggestion // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isActionTaken: null == isActionTaken ? _self.isActionTaken : isActionTaken // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [InsightModel].
extension InsightModelPatterns on InsightModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InsightModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InsightModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InsightModel value)  $default,){
final _that = this;
switch (_that) {
case _InsightModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InsightModel value)?  $default,){
final _that = this;
switch (_that) {
case _InsightModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String? memberId,  String? memberName,  InsightType type,  InsightPriority priority,  String title,  String message,  String? actionSuggestion,  Map<String, dynamic>? data,  bool isRead,  bool isActionTaken, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? expiresAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InsightModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.type,_that.priority,_that.title,_that.message,_that.actionSuggestion,_that.data,_that.isRead,_that.isActionTaken,_that.createdAt,_that.expiresAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String? memberId,  String? memberName,  InsightType type,  InsightPriority priority,  String title,  String message,  String? actionSuggestion,  Map<String, dynamic>? data,  bool isRead,  bool isActionTaken, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? expiresAt)  $default,) {final _that = this;
switch (_that) {
case _InsightModel():
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.type,_that.priority,_that.title,_that.message,_that.actionSuggestion,_that.data,_that.isRead,_that.isActionTaken,_that.createdAt,_that.expiresAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String? memberId,  String? memberName,  InsightType type,  InsightPriority priority,  String title,  String message,  String? actionSuggestion,  Map<String, dynamic>? data,  bool isRead,  bool isActionTaken, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? expiresAt)?  $default,) {final _that = this;
switch (_that) {
case _InsightModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.memberName,_that.type,_that.priority,_that.title,_that.message,_that.actionSuggestion,_that.data,_that.isRead,_that.isActionTaken,_that.createdAt,_that.expiresAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InsightModel implements InsightModel {
  const _InsightModel({required this.id, required this.trainerId, this.memberId, this.memberName, required this.type, required this.priority, required this.title, required this.message, this.actionSuggestion, final  Map<String, dynamic>? data, this.isRead = false, this.isActionTaken = false, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.expiresAt}): _data = data;
  factory _InsightModel.fromJson(Map<String, dynamic> json) => _$InsightModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 트레이너 ID
@override final  String trainerId;
/// 회원 ID (nullable - 전체 대시보드 인사이트일 수 있음)
@override final  String? memberId;
/// 회원 이름 (표시용)
@override final  String? memberName;
/// 인사이트 유형
@override final  InsightType type;
/// 우선순위
@override final  InsightPriority priority;
/// 제목
@override final  String title;
/// 메시지 내용
@override final  String message;
/// 권장 조치 사항 (nullable)
@override final  String? actionSuggestion;
/// 추가 데이터 (nullable)
 final  Map<String, dynamic>? _data;
/// 추가 데이터 (nullable)
@override Map<String, dynamic>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// 읽음 여부
@override@JsonKey() final  bool isRead;
/// 조치 완료 여부
@override@JsonKey() final  bool isActionTaken;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;
/// 만료일 (nullable)
@override@NullableTimestampConverter() final  DateTime? expiresAt;

/// Create a copy of InsightModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InsightModelCopyWith<_InsightModel> get copyWith => __$InsightModelCopyWithImpl<_InsightModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InsightModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InsightModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.type, type) || other.type == type)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.actionSuggestion, actionSuggestion) || other.actionSuggestion == actionSuggestion)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.isActionTaken, isActionTaken) || other.isActionTaken == isActionTaken)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,memberName,type,priority,title,message,actionSuggestion,const DeepCollectionEquality().hash(_data),isRead,isActionTaken,createdAt,expiresAt);

@override
String toString() {
  return 'InsightModel(id: $id, trainerId: $trainerId, memberId: $memberId, memberName: $memberName, type: $type, priority: $priority, title: $title, message: $message, actionSuggestion: $actionSuggestion, data: $data, isRead: $isRead, isActionTaken: $isActionTaken, createdAt: $createdAt, expiresAt: $expiresAt)';
}


}

/// @nodoc
abstract mixin class _$InsightModelCopyWith<$Res> implements $InsightModelCopyWith<$Res> {
  factory _$InsightModelCopyWith(_InsightModel value, $Res Function(_InsightModel) _then) = __$InsightModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String? memberId, String? memberName, InsightType type, InsightPriority priority, String title, String message, String? actionSuggestion, Map<String, dynamic>? data, bool isRead, bool isActionTaken,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? expiresAt
});




}
/// @nodoc
class __$InsightModelCopyWithImpl<$Res>
    implements _$InsightModelCopyWith<$Res> {
  __$InsightModelCopyWithImpl(this._self, this._then);

  final _InsightModel _self;
  final $Res Function(_InsightModel) _then;

/// Create a copy of InsightModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? memberId = freezed,Object? memberName = freezed,Object? type = null,Object? priority = null,Object? title = null,Object? message = null,Object? actionSuggestion = freezed,Object? data = freezed,Object? isRead = null,Object? isActionTaken = null,Object? createdAt = null,Object? expiresAt = freezed,}) {
  return _then(_InsightModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: freezed == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String?,memberName: freezed == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InsightType,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as InsightPriority,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,actionSuggestion: freezed == actionSuggestion ? _self.actionSuggestion : actionSuggestion // ignore: cast_nullable_to_non_nullable
as String?,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,isActionTaken: null == isActionTaken ? _self.isActionTaken : isActionTaken // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
