// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationSettingsModel {

/// 사용자 ID
 String get userId;/// FCM 토큰
 String get fcmToken;/// DM 메시지 알림
 bool get dmMessages;/// PT 리마인더 알림
 bool get ptReminders;/// AI 인사이트 알림
 bool get aiInsights;/// 트레이너 전환 요청 알림
 bool get trainerTransfer;/// 주간 리포트 알림
 bool get weeklyReport;/// 수정일
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of NotificationSettingsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationSettingsModelCopyWith<NotificationSettingsModel> get copyWith => _$NotificationSettingsModelCopyWithImpl<NotificationSettingsModel>(this as NotificationSettingsModel, _$identity);

  /// Serializes this NotificationSettingsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSettingsModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.dmMessages, dmMessages) || other.dmMessages == dmMessages)&&(identical(other.ptReminders, ptReminders) || other.ptReminders == ptReminders)&&(identical(other.aiInsights, aiInsights) || other.aiInsights == aiInsights)&&(identical(other.trainerTransfer, trainerTransfer) || other.trainerTransfer == trainerTransfer)&&(identical(other.weeklyReport, weeklyReport) || other.weeklyReport == weeklyReport)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,fcmToken,dmMessages,ptReminders,aiInsights,trainerTransfer,weeklyReport,updatedAt);

@override
String toString() {
  return 'NotificationSettingsModel(userId: $userId, fcmToken: $fcmToken, dmMessages: $dmMessages, ptReminders: $ptReminders, aiInsights: $aiInsights, trainerTransfer: $trainerTransfer, weeklyReport: $weeklyReport, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NotificationSettingsModelCopyWith<$Res>  {
  factory $NotificationSettingsModelCopyWith(NotificationSettingsModel value, $Res Function(NotificationSettingsModel) _then) = _$NotificationSettingsModelCopyWithImpl;
@useResult
$Res call({
 String userId, String fcmToken, bool dmMessages, bool ptReminders, bool aiInsights, bool trainerTransfer, bool weeklyReport,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$NotificationSettingsModelCopyWithImpl<$Res>
    implements $NotificationSettingsModelCopyWith<$Res> {
  _$NotificationSettingsModelCopyWithImpl(this._self, this._then);

  final NotificationSettingsModel _self;
  final $Res Function(NotificationSettingsModel) _then;

/// Create a copy of NotificationSettingsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? fcmToken = null,Object? dmMessages = null,Object? ptReminders = null,Object? aiInsights = null,Object? trainerTransfer = null,Object? weeklyReport = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,dmMessages: null == dmMessages ? _self.dmMessages : dmMessages // ignore: cast_nullable_to_non_nullable
as bool,ptReminders: null == ptReminders ? _self.ptReminders : ptReminders // ignore: cast_nullable_to_non_nullable
as bool,aiInsights: null == aiInsights ? _self.aiInsights : aiInsights // ignore: cast_nullable_to_non_nullable
as bool,trainerTransfer: null == trainerTransfer ? _self.trainerTransfer : trainerTransfer // ignore: cast_nullable_to_non_nullable
as bool,weeklyReport: null == weeklyReport ? _self.weeklyReport : weeklyReport // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationSettingsModel].
extension NotificationSettingsModelPatterns on NotificationSettingsModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationSettingsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationSettingsModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationSettingsModel value)  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationSettingsModel value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationSettingsModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String fcmToken,  bool dmMessages,  bool ptReminders,  bool aiInsights,  bool trainerTransfer,  bool weeklyReport, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationSettingsModel() when $default != null:
return $default(_that.userId,_that.fcmToken,_that.dmMessages,_that.ptReminders,_that.aiInsights,_that.trainerTransfer,_that.weeklyReport,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String fcmToken,  bool dmMessages,  bool ptReminders,  bool aiInsights,  bool trainerTransfer,  bool weeklyReport, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsModel():
return $default(_that.userId,_that.fcmToken,_that.dmMessages,_that.ptReminders,_that.aiInsights,_that.trainerTransfer,_that.weeklyReport,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String fcmToken,  bool dmMessages,  bool ptReminders,  bool aiInsights,  bool trainerTransfer,  bool weeklyReport, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _NotificationSettingsModel() when $default != null:
return $default(_that.userId,_that.fcmToken,_that.dmMessages,_that.ptReminders,_that.aiInsights,_that.trainerTransfer,_that.weeklyReport,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationSettingsModel implements NotificationSettingsModel {
  const _NotificationSettingsModel({required this.userId, this.fcmToken = '', this.dmMessages = true, this.ptReminders = true, this.aiInsights = true, this.trainerTransfer = true, this.weeklyReport = true, @TimestampConverter() required this.updatedAt});
  factory _NotificationSettingsModel.fromJson(Map<String, dynamic> json) => _$NotificationSettingsModelFromJson(json);

/// 사용자 ID
@override final  String userId;
/// FCM 토큰
@override@JsonKey() final  String fcmToken;
/// DM 메시지 알림
@override@JsonKey() final  bool dmMessages;
/// PT 리마인더 알림
@override@JsonKey() final  bool ptReminders;
/// AI 인사이트 알림
@override@JsonKey() final  bool aiInsights;
/// 트레이너 전환 요청 알림
@override@JsonKey() final  bool trainerTransfer;
/// 주간 리포트 알림
@override@JsonKey() final  bool weeklyReport;
/// 수정일
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of NotificationSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationSettingsModelCopyWith<_NotificationSettingsModel> get copyWith => __$NotificationSettingsModelCopyWithImpl<_NotificationSettingsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationSettingsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationSettingsModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.fcmToken, fcmToken) || other.fcmToken == fcmToken)&&(identical(other.dmMessages, dmMessages) || other.dmMessages == dmMessages)&&(identical(other.ptReminders, ptReminders) || other.ptReminders == ptReminders)&&(identical(other.aiInsights, aiInsights) || other.aiInsights == aiInsights)&&(identical(other.trainerTransfer, trainerTransfer) || other.trainerTransfer == trainerTransfer)&&(identical(other.weeklyReport, weeklyReport) || other.weeklyReport == weeklyReport)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,fcmToken,dmMessages,ptReminders,aiInsights,trainerTransfer,weeklyReport,updatedAt);

@override
String toString() {
  return 'NotificationSettingsModel(userId: $userId, fcmToken: $fcmToken, dmMessages: $dmMessages, ptReminders: $ptReminders, aiInsights: $aiInsights, trainerTransfer: $trainerTransfer, weeklyReport: $weeklyReport, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NotificationSettingsModelCopyWith<$Res> implements $NotificationSettingsModelCopyWith<$Res> {
  factory _$NotificationSettingsModelCopyWith(_NotificationSettingsModel value, $Res Function(_NotificationSettingsModel) _then) = __$NotificationSettingsModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String fcmToken, bool dmMessages, bool ptReminders, bool aiInsights, bool trainerTransfer, bool weeklyReport,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$NotificationSettingsModelCopyWithImpl<$Res>
    implements _$NotificationSettingsModelCopyWith<$Res> {
  __$NotificationSettingsModelCopyWithImpl(this._self, this._then);

  final _NotificationSettingsModel _self;
  final $Res Function(_NotificationSettingsModel) _then;

/// Create a copy of NotificationSettingsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? fcmToken = null,Object? dmMessages = null,Object? ptReminders = null,Object? aiInsights = null,Object? trainerTransfer = null,Object? weeklyReport = null,Object? updatedAt = null,}) {
  return _then(_NotificationSettingsModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,fcmToken: null == fcmToken ? _self.fcmToken : fcmToken // ignore: cast_nullable_to_non_nullable
as String,dmMessages: null == dmMessages ? _self.dmMessages : dmMessages // ignore: cast_nullable_to_non_nullable
as bool,ptReminders: null == ptReminders ? _self.ptReminders : ptReminders // ignore: cast_nullable_to_non_nullable
as bool,aiInsights: null == aiInsights ? _self.aiInsights : aiInsights // ignore: cast_nullable_to_non_nullable
as bool,trainerTransfer: null == trainerTransfer ? _self.trainerTransfer : trainerTransfer // ignore: cast_nullable_to_non_nullable
as bool,weeklyReport: null == weeklyReport ? _self.weeklyReport : weeklyReport // ignore: cast_nullable_to_non_nullable
as bool,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
