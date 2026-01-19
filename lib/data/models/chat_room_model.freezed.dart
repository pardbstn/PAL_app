// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatRoomModel {

/// 채팅방 ID
 String get id;/// 트레이너 ID
 String get trainerId;/// 회원 ID
 String get memberId;/// 트레이너 이름
 String get trainerName;/// 회원 이름
 String get memberName;/// 트레이너 프로필 URL
 String? get trainerProfileUrl;/// 회원 프로필 URL
 String? get memberProfileUrl;/// 마지막 메시지
 String? get lastMessage;/// 마지막 메시지 시간
@NullableTimestampConverter() DateTime? get lastMessageAt;/// 트레이너 안읽은 메시지 수
 int get unreadCountTrainer;/// 회원 안읽은 메시지 수
 int get unreadCountMember;/// 생성 시간
@TimestampConverter() DateTime get createdAt;
/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatRoomModelCopyWith<ChatRoomModel> get copyWith => _$ChatRoomModelCopyWithImpl<ChatRoomModel>(this as ChatRoomModel, _$identity);

  /// Serializes this ChatRoomModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatRoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.trainerProfileUrl, trainerProfileUrl) || other.trainerProfileUrl == trainerProfileUrl)&&(identical(other.memberProfileUrl, memberProfileUrl) || other.memberProfileUrl == memberProfileUrl)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCountTrainer, unreadCountTrainer) || other.unreadCountTrainer == unreadCountTrainer)&&(identical(other.unreadCountMember, unreadCountMember) || other.unreadCountMember == unreadCountMember)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,trainerName,memberName,trainerProfileUrl,memberProfileUrl,lastMessage,lastMessageAt,unreadCountTrainer,unreadCountMember,createdAt);

@override
String toString() {
  return 'ChatRoomModel(id: $id, trainerId: $trainerId, memberId: $memberId, trainerName: $trainerName, memberName: $memberName, trainerProfileUrl: $trainerProfileUrl, memberProfileUrl: $memberProfileUrl, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCountTrainer: $unreadCountTrainer, unreadCountMember: $unreadCountMember, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ChatRoomModelCopyWith<$Res>  {
  factory $ChatRoomModelCopyWith(ChatRoomModel value, $Res Function(ChatRoomModel) _then) = _$ChatRoomModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String memberId, String trainerName, String memberName, String? trainerProfileUrl, String? memberProfileUrl, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt, int unreadCountTrainer, int unreadCountMember,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$ChatRoomModelCopyWithImpl<$Res>
    implements $ChatRoomModelCopyWith<$Res> {
  _$ChatRoomModelCopyWithImpl(this._self, this._then);

  final ChatRoomModel _self;
  final $Res Function(ChatRoomModel) _then;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? trainerName = null,Object? memberName = null,Object? trainerProfileUrl = freezed,Object? memberProfileUrl = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? unreadCountTrainer = null,Object? unreadCountMember = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,trainerProfileUrl: freezed == trainerProfileUrl ? _self.trainerProfileUrl : trainerProfileUrl // ignore: cast_nullable_to_non_nullable
as String?,memberProfileUrl: freezed == memberProfileUrl ? _self.memberProfileUrl : memberProfileUrl // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCountTrainer: null == unreadCountTrainer ? _self.unreadCountTrainer : unreadCountTrainer // ignore: cast_nullable_to_non_nullable
as int,unreadCountMember: null == unreadCountMember ? _self.unreadCountMember : unreadCountMember // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatRoomModel].
extension ChatRoomModelPatterns on ChatRoomModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatRoomModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatRoomModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatRoomModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatRoomModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  String trainerName,  String memberName,  String? trainerProfileUrl,  String? memberProfileUrl,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  int unreadCountTrainer,  int unreadCountMember, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.trainerName,_that.memberName,_that.trainerProfileUrl,_that.memberProfileUrl,_that.lastMessage,_that.lastMessageAt,_that.unreadCountTrainer,_that.unreadCountMember,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String memberId,  String trainerName,  String memberName,  String? trainerProfileUrl,  String? memberProfileUrl,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  int unreadCountTrainer,  int unreadCountMember, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ChatRoomModel():
return $default(_that.id,_that.trainerId,_that.memberId,_that.trainerName,_that.memberName,_that.trainerProfileUrl,_that.memberProfileUrl,_that.lastMessage,_that.lastMessageAt,_that.unreadCountTrainer,_that.unreadCountMember,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String memberId,  String trainerName,  String memberName,  String? trainerProfileUrl,  String? memberProfileUrl,  String? lastMessage, @NullableTimestampConverter()  DateTime? lastMessageAt,  int unreadCountTrainer,  int unreadCountMember, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ChatRoomModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.memberId,_that.trainerName,_that.memberName,_that.trainerProfileUrl,_that.memberProfileUrl,_that.lastMessage,_that.lastMessageAt,_that.unreadCountTrainer,_that.unreadCountMember,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatRoomModel implements ChatRoomModel {
  const _ChatRoomModel({required this.id, required this.trainerId, required this.memberId, required this.trainerName, required this.memberName, this.trainerProfileUrl, this.memberProfileUrl, this.lastMessage, @NullableTimestampConverter() this.lastMessageAt, this.unreadCountTrainer = 0, this.unreadCountMember = 0, @TimestampConverter() required this.createdAt});
  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) => _$ChatRoomModelFromJson(json);

/// 채팅방 ID
@override final  String id;
/// 트레이너 ID
@override final  String trainerId;
/// 회원 ID
@override final  String memberId;
/// 트레이너 이름
@override final  String trainerName;
/// 회원 이름
@override final  String memberName;
/// 트레이너 프로필 URL
@override final  String? trainerProfileUrl;
/// 회원 프로필 URL
@override final  String? memberProfileUrl;
/// 마지막 메시지
@override final  String? lastMessage;
/// 마지막 메시지 시간
@override@NullableTimestampConverter() final  DateTime? lastMessageAt;
/// 트레이너 안읽은 메시지 수
@override@JsonKey() final  int unreadCountTrainer;
/// 회원 안읽은 메시지 수
@override@JsonKey() final  int unreadCountMember;
/// 생성 시간
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatRoomModelCopyWith<_ChatRoomModel> get copyWith => __$ChatRoomModelCopyWithImpl<_ChatRoomModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatRoomModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatRoomModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerName, trainerName) || other.trainerName == trainerName)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.trainerProfileUrl, trainerProfileUrl) || other.trainerProfileUrl == trainerProfileUrl)&&(identical(other.memberProfileUrl, memberProfileUrl) || other.memberProfileUrl == memberProfileUrl)&&(identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.unreadCountTrainer, unreadCountTrainer) || other.unreadCountTrainer == unreadCountTrainer)&&(identical(other.unreadCountMember, unreadCountMember) || other.unreadCountMember == unreadCountMember)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,memberId,trainerName,memberName,trainerProfileUrl,memberProfileUrl,lastMessage,lastMessageAt,unreadCountTrainer,unreadCountMember,createdAt);

@override
String toString() {
  return 'ChatRoomModel(id: $id, trainerId: $trainerId, memberId: $memberId, trainerName: $trainerName, memberName: $memberName, trainerProfileUrl: $trainerProfileUrl, memberProfileUrl: $memberProfileUrl, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCountTrainer: $unreadCountTrainer, unreadCountMember: $unreadCountMember, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ChatRoomModelCopyWith<$Res> implements $ChatRoomModelCopyWith<$Res> {
  factory _$ChatRoomModelCopyWith(_ChatRoomModel value, $Res Function(_ChatRoomModel) _then) = __$ChatRoomModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String memberId, String trainerName, String memberName, String? trainerProfileUrl, String? memberProfileUrl, String? lastMessage,@NullableTimestampConverter() DateTime? lastMessageAt, int unreadCountTrainer, int unreadCountMember,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$ChatRoomModelCopyWithImpl<$Res>
    implements _$ChatRoomModelCopyWith<$Res> {
  __$ChatRoomModelCopyWithImpl(this._self, this._then);

  final _ChatRoomModel _self;
  final $Res Function(_ChatRoomModel) _then;

/// Create a copy of ChatRoomModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? memberId = null,Object? trainerName = null,Object? memberName = null,Object? trainerProfileUrl = freezed,Object? memberProfileUrl = freezed,Object? lastMessage = freezed,Object? lastMessageAt = freezed,Object? unreadCountTrainer = null,Object? unreadCountMember = null,Object? createdAt = null,}) {
  return _then(_ChatRoomModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerName: null == trainerName ? _self.trainerName : trainerName // ignore: cast_nullable_to_non_nullable
as String,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,trainerProfileUrl: freezed == trainerProfileUrl ? _self.trainerProfileUrl : trainerProfileUrl // ignore: cast_nullable_to_non_nullable
as String?,memberProfileUrl: freezed == memberProfileUrl ? _self.memberProfileUrl : memberProfileUrl // ignore: cast_nullable_to_non_nullable
as String?,lastMessage: freezed == lastMessage ? _self.lastMessage : lastMessage // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,unreadCountTrainer: null == unreadCountTrainer ? _self.unreadCountTrainer : unreadCountTrainer // ignore: cast_nullable_to_non_nullable
as int,unreadCountMember: null == unreadCountMember ? _self.unreadCountMember : unreadCountMember // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
