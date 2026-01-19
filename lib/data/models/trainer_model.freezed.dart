// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiUsage {

/// 이번 달 커리큘럼 생성 횟수
 int get curriculumCount;/// 이번 달 예측 횟수
 int get predictionCount;/// 월별 리셋 날짜
@TimestampConverter() DateTime get resetDate;
/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiUsageCopyWith<AiUsage> get copyWith => _$AiUsageCopyWithImpl<AiUsage>(this as AiUsage, _$identity);

  /// Serializes this AiUsage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiUsage&&(identical(other.curriculumCount, curriculumCount) || other.curriculumCount == curriculumCount)&&(identical(other.predictionCount, predictionCount) || other.predictionCount == predictionCount)&&(identical(other.resetDate, resetDate) || other.resetDate == resetDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,curriculumCount,predictionCount,resetDate);

@override
String toString() {
  return 'AiUsage(curriculumCount: $curriculumCount, predictionCount: $predictionCount, resetDate: $resetDate)';
}


}

/// @nodoc
abstract mixin class $AiUsageCopyWith<$Res>  {
  factory $AiUsageCopyWith(AiUsage value, $Res Function(AiUsage) _then) = _$AiUsageCopyWithImpl;
@useResult
$Res call({
 int curriculumCount, int predictionCount,@TimestampConverter() DateTime resetDate
});




}
/// @nodoc
class _$AiUsageCopyWithImpl<$Res>
    implements $AiUsageCopyWith<$Res> {
  _$AiUsageCopyWithImpl(this._self, this._then);

  final AiUsage _self;
  final $Res Function(AiUsage) _then;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? curriculumCount = null,Object? predictionCount = null,Object? resetDate = null,}) {
  return _then(_self.copyWith(
curriculumCount: null == curriculumCount ? _self.curriculumCount : curriculumCount // ignore: cast_nullable_to_non_nullable
as int,predictionCount: null == predictionCount ? _self.predictionCount : predictionCount // ignore: cast_nullable_to_non_nullable
as int,resetDate: null == resetDate ? _self.resetDate : resetDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AiUsage].
extension AiUsagePatterns on AiUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiUsage value)  $default,){
final _that = this;
switch (_that) {
case _AiUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiUsage value)?  $default,){
final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int curriculumCount,  int predictionCount, @TimestampConverter()  DateTime resetDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
return $default(_that.curriculumCount,_that.predictionCount,_that.resetDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int curriculumCount,  int predictionCount, @TimestampConverter()  DateTime resetDate)  $default,) {final _that = this;
switch (_that) {
case _AiUsage():
return $default(_that.curriculumCount,_that.predictionCount,_that.resetDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int curriculumCount,  int predictionCount, @TimestampConverter()  DateTime resetDate)?  $default,) {final _that = this;
switch (_that) {
case _AiUsage() when $default != null:
return $default(_that.curriculumCount,_that.predictionCount,_that.resetDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiUsage implements AiUsage {
  const _AiUsage({this.curriculumCount = 0, this.predictionCount = 0, @TimestampConverter() required this.resetDate});
  factory _AiUsage.fromJson(Map<String, dynamic> json) => _$AiUsageFromJson(json);

/// 이번 달 커리큘럼 생성 횟수
@override@JsonKey() final  int curriculumCount;
/// 이번 달 예측 횟수
@override@JsonKey() final  int predictionCount;
/// 월별 리셋 날짜
@override@TimestampConverter() final  DateTime resetDate;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiUsageCopyWith<_AiUsage> get copyWith => __$AiUsageCopyWithImpl<_AiUsage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiUsageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiUsage&&(identical(other.curriculumCount, curriculumCount) || other.curriculumCount == curriculumCount)&&(identical(other.predictionCount, predictionCount) || other.predictionCount == predictionCount)&&(identical(other.resetDate, resetDate) || other.resetDate == resetDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,curriculumCount,predictionCount,resetDate);

@override
String toString() {
  return 'AiUsage(curriculumCount: $curriculumCount, predictionCount: $predictionCount, resetDate: $resetDate)';
}


}

/// @nodoc
abstract mixin class _$AiUsageCopyWith<$Res> implements $AiUsageCopyWith<$Res> {
  factory _$AiUsageCopyWith(_AiUsage value, $Res Function(_AiUsage) _then) = __$AiUsageCopyWithImpl;
@override @useResult
$Res call({
 int curriculumCount, int predictionCount,@TimestampConverter() DateTime resetDate
});




}
/// @nodoc
class __$AiUsageCopyWithImpl<$Res>
    implements _$AiUsageCopyWith<$Res> {
  __$AiUsageCopyWithImpl(this._self, this._then);

  final _AiUsage _self;
  final $Res Function(_AiUsage) _then;

/// Create a copy of AiUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? curriculumCount = null,Object? predictionCount = null,Object? resetDate = null,}) {
  return _then(_AiUsage(
curriculumCount: null == curriculumCount ? _self.curriculumCount : curriculumCount // ignore: cast_nullable_to_non_nullable
as int,predictionCount: null == predictionCount ? _self.predictionCount : predictionCount // ignore: cast_nullable_to_non_nullable
as int,resetDate: null == resetDate ? _self.resetDate : resetDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$TrainerModel {

/// 트레이너 문서 ID
 String get id;/// users 컬렉션 참조
 String get userId;/// 구독 티어 ('free' | 'basic' | 'pro')
 SubscriptionTier get subscriptionTier;/// 담당 회원 ID 목록
 List<String> get memberIds;/// AI 사용량 정보
 AiUsage get aiUsage;
/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerModelCopyWith<TrainerModel> get copyWith => _$TrainerModelCopyWithImpl<TrainerModel>(this as TrainerModel, _$identity);

  /// Serializes this TrainerModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subscriptionTier, subscriptionTier) || other.subscriptionTier == subscriptionTier)&&const DeepCollectionEquality().equals(other.memberIds, memberIds)&&(identical(other.aiUsage, aiUsage) || other.aiUsage == aiUsage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subscriptionTier,const DeepCollectionEquality().hash(memberIds),aiUsage);

@override
String toString() {
  return 'TrainerModel(id: $id, userId: $userId, subscriptionTier: $subscriptionTier, memberIds: $memberIds, aiUsage: $aiUsage)';
}


}

/// @nodoc
abstract mixin class $TrainerModelCopyWith<$Res>  {
  factory $TrainerModelCopyWith(TrainerModel value, $Res Function(TrainerModel) _then) = _$TrainerModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, SubscriptionTier subscriptionTier, List<String> memberIds, AiUsage aiUsage
});


$AiUsageCopyWith<$Res> get aiUsage;

}
/// @nodoc
class _$TrainerModelCopyWithImpl<$Res>
    implements $TrainerModelCopyWith<$Res> {
  _$TrainerModelCopyWithImpl(this._self, this._then);

  final TrainerModel _self;
  final $Res Function(TrainerModel) _then;

/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? subscriptionTier = null,Object? memberIds = null,Object? aiUsage = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,subscriptionTier: null == subscriptionTier ? _self.subscriptionTier : subscriptionTier // ignore: cast_nullable_to_non_nullable
as SubscriptionTier,memberIds: null == memberIds ? _self.memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,aiUsage: null == aiUsage ? _self.aiUsage : aiUsage // ignore: cast_nullable_to_non_nullable
as AiUsage,
  ));
}
/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiUsageCopyWith<$Res> get aiUsage {
  
  return $AiUsageCopyWith<$Res>(_self.aiUsage, (value) {
    return _then(_self.copyWith(aiUsage: value));
  });
}
}


/// Adds pattern-matching-related methods to [TrainerModel].
extension TrainerModelPatterns on TrainerModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  SubscriptionTier subscriptionTier,  List<String> memberIds,  AiUsage aiUsage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerModel() when $default != null:
return $default(_that.id,_that.userId,_that.subscriptionTier,_that.memberIds,_that.aiUsage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  SubscriptionTier subscriptionTier,  List<String> memberIds,  AiUsage aiUsage)  $default,) {final _that = this;
switch (_that) {
case _TrainerModel():
return $default(_that.id,_that.userId,_that.subscriptionTier,_that.memberIds,_that.aiUsage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  SubscriptionTier subscriptionTier,  List<String> memberIds,  AiUsage aiUsage)?  $default,) {final _that = this;
switch (_that) {
case _TrainerModel() when $default != null:
return $default(_that.id,_that.userId,_that.subscriptionTier,_that.memberIds,_that.aiUsage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerModel implements TrainerModel {
  const _TrainerModel({required this.id, required this.userId, this.subscriptionTier = SubscriptionTier.free, final  List<String> memberIds = const [], required this.aiUsage}): _memberIds = memberIds;
  factory _TrainerModel.fromJson(Map<String, dynamic> json) => _$TrainerModelFromJson(json);

/// 트레이너 문서 ID
@override final  String id;
/// users 컬렉션 참조
@override final  String userId;
/// 구독 티어 ('free' | 'basic' | 'pro')
@override@JsonKey() final  SubscriptionTier subscriptionTier;
/// 담당 회원 ID 목록
 final  List<String> _memberIds;
/// 담당 회원 ID 목록
@override@JsonKey() List<String> get memberIds {
  if (_memberIds is EqualUnmodifiableListView) return _memberIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberIds);
}

/// AI 사용량 정보
@override final  AiUsage aiUsage;

/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerModelCopyWith<_TrainerModel> get copyWith => __$TrainerModelCopyWithImpl<_TrainerModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.subscriptionTier, subscriptionTier) || other.subscriptionTier == subscriptionTier)&&const DeepCollectionEquality().equals(other._memberIds, _memberIds)&&(identical(other.aiUsage, aiUsage) || other.aiUsage == aiUsage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,subscriptionTier,const DeepCollectionEquality().hash(_memberIds),aiUsage);

@override
String toString() {
  return 'TrainerModel(id: $id, userId: $userId, subscriptionTier: $subscriptionTier, memberIds: $memberIds, aiUsage: $aiUsage)';
}


}

/// @nodoc
abstract mixin class _$TrainerModelCopyWith<$Res> implements $TrainerModelCopyWith<$Res> {
  factory _$TrainerModelCopyWith(_TrainerModel value, $Res Function(_TrainerModel) _then) = __$TrainerModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, SubscriptionTier subscriptionTier, List<String> memberIds, AiUsage aiUsage
});


@override $AiUsageCopyWith<$Res> get aiUsage;

}
/// @nodoc
class __$TrainerModelCopyWithImpl<$Res>
    implements _$TrainerModelCopyWith<$Res> {
  __$TrainerModelCopyWithImpl(this._self, this._then);

  final _TrainerModel _self;
  final $Res Function(_TrainerModel) _then;

/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? subscriptionTier = null,Object? memberIds = null,Object? aiUsage = null,}) {
  return _then(_TrainerModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,subscriptionTier: null == subscriptionTier ? _self.subscriptionTier : subscriptionTier // ignore: cast_nullable_to_non_nullable
as SubscriptionTier,memberIds: null == memberIds ? _self._memberIds : memberIds // ignore: cast_nullable_to_non_nullable
as List<String>,aiUsage: null == aiUsage ? _self.aiUsage : aiUsage // ignore: cast_nullable_to_non_nullable
as AiUsage,
  ));
}

/// Create a copy of TrainerModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiUsageCopyWith<$Res> get aiUsage {
  
  return $AiUsageCopyWith<$Res>(_self.aiUsage, (value) {
    return _then(_self.copyWith(aiUsage: value));
  });
}
}

// dart format on
