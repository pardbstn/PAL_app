// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PtInfo {

/// 총 PT 회차 (예: 30)
 int get totalSessions;/// 완료 회차 (예: 12)
 int get completedSessions;/// PT 시작일
@TimestampConverter() DateTime get startDate;
/// Create a copy of PtInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PtInfoCopyWith<PtInfo> get copyWith => _$PtInfoCopyWithImpl<PtInfo>(this as PtInfo, _$identity);

  /// Serializes this PtInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PtInfo&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.startDate, startDate) || other.startDate == startDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSessions,completedSessions,startDate);

@override
String toString() {
  return 'PtInfo(totalSessions: $totalSessions, completedSessions: $completedSessions, startDate: $startDate)';
}


}

/// @nodoc
abstract mixin class $PtInfoCopyWith<$Res>  {
  factory $PtInfoCopyWith(PtInfo value, $Res Function(PtInfo) _then) = _$PtInfoCopyWithImpl;
@useResult
$Res call({
 int totalSessions, int completedSessions,@TimestampConverter() DateTime startDate
});




}
/// @nodoc
class _$PtInfoCopyWithImpl<$Res>
    implements $PtInfoCopyWith<$Res> {
  _$PtInfoCopyWithImpl(this._self, this._then);

  final PtInfo _self;
  final $Res Function(PtInfo) _then;

/// Create a copy of PtInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSessions = null,Object? completedSessions = null,Object? startDate = null,}) {
  return _then(_self.copyWith(
totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PtInfo].
extension PtInfoPatterns on PtInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PtInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PtInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PtInfo value)  $default,){
final _that = this;
switch (_that) {
case _PtInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PtInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PtInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSessions,  int completedSessions, @TimestampConverter()  DateTime startDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PtInfo() when $default != null:
return $default(_that.totalSessions,_that.completedSessions,_that.startDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSessions,  int completedSessions, @TimestampConverter()  DateTime startDate)  $default,) {final _that = this;
switch (_that) {
case _PtInfo():
return $default(_that.totalSessions,_that.completedSessions,_that.startDate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSessions,  int completedSessions, @TimestampConverter()  DateTime startDate)?  $default,) {final _that = this;
switch (_that) {
case _PtInfo() when $default != null:
return $default(_that.totalSessions,_that.completedSessions,_that.startDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PtInfo implements PtInfo {
  const _PtInfo({required this.totalSessions, this.completedSessions = 0, @TimestampConverter() required this.startDate});
  factory _PtInfo.fromJson(Map<String, dynamic> json) => _$PtInfoFromJson(json);

/// 총 PT 회차 (예: 30)
@override final  int totalSessions;
/// 완료 회차 (예: 12)
@override@JsonKey() final  int completedSessions;
/// PT 시작일
@override@TimestampConverter() final  DateTime startDate;

/// Create a copy of PtInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PtInfoCopyWith<_PtInfo> get copyWith => __$PtInfoCopyWithImpl<_PtInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PtInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PtInfo&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.completedSessions, completedSessions) || other.completedSessions == completedSessions)&&(identical(other.startDate, startDate) || other.startDate == startDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSessions,completedSessions,startDate);

@override
String toString() {
  return 'PtInfo(totalSessions: $totalSessions, completedSessions: $completedSessions, startDate: $startDate)';
}


}

/// @nodoc
abstract mixin class _$PtInfoCopyWith<$Res> implements $PtInfoCopyWith<$Res> {
  factory _$PtInfoCopyWith(_PtInfo value, $Res Function(_PtInfo) _then) = __$PtInfoCopyWithImpl;
@override @useResult
$Res call({
 int totalSessions, int completedSessions,@TimestampConverter() DateTime startDate
});




}
/// @nodoc
class __$PtInfoCopyWithImpl<$Res>
    implements _$PtInfoCopyWith<$Res> {
  __$PtInfoCopyWithImpl(this._self, this._then);

  final _PtInfo _self;
  final $Res Function(_PtInfo) _then;

/// Create a copy of PtInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSessions = null,Object? completedSessions = null,Object? startDate = null,}) {
  return _then(_PtInfo(
totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,completedSessions: null == completedSessions ? _self.completedSessions : completedSessions // ignore: cast_nullable_to_non_nullable
as int,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$MemberModel {

/// 회원 문서 ID
 String get id;/// users 컬렉션 참조
 String get userId;/// 담당 트레이너 ID
 String get trainerId;/// 운동 목표 ('diet'|'bulk'|'fitness'|'rehab')
 FitnessGoal get goal;/// 운동 경험 수준 ('beginner'|'intermediate'|'advanced')
 ExperienceLevel get experience;/// PT 정보
 PtInfo get ptInfo;/// 목표 체중 (kg)
 double? get targetWeight;/// 트레이너 메모 (부상, 제한사항)
 String? get memo;
/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MemberModelCopyWith<MemberModel> get copyWith => _$MemberModelCopyWithImpl<MemberModel>(this as MemberModel, _$identity);

  /// Serializes this MemberModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.ptInfo, ptInfo) || other.ptInfo == ptInfo)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,trainerId,goal,experience,ptInfo,targetWeight,memo);

@override
String toString() {
  return 'MemberModel(id: $id, userId: $userId, trainerId: $trainerId, goal: $goal, experience: $experience, ptInfo: $ptInfo, targetWeight: $targetWeight, memo: $memo)';
}


}

/// @nodoc
abstract mixin class $MemberModelCopyWith<$Res>  {
  factory $MemberModelCopyWith(MemberModel value, $Res Function(MemberModel) _then) = _$MemberModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String trainerId, FitnessGoal goal, ExperienceLevel experience, PtInfo ptInfo, double? targetWeight, String? memo
});


$PtInfoCopyWith<$Res> get ptInfo;

}
/// @nodoc
class _$MemberModelCopyWithImpl<$Res>
    implements $MemberModelCopyWith<$Res> {
  _$MemberModelCopyWithImpl(this._self, this._then);

  final MemberModel _self;
  final $Res Function(MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? trainerId = null,Object? goal = null,Object? experience = null,Object? ptInfo = null,Object? targetWeight = freezed,Object? memo = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as FitnessGoal,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,ptInfo: null == ptInfo ? _self.ptInfo : ptInfo // ignore: cast_nullable_to_non_nullable
as PtInfo,targetWeight: freezed == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PtInfoCopyWith<$Res> get ptInfo {
  
  return $PtInfoCopyWith<$Res>(_self.ptInfo, (value) {
    return _then(_self.copyWith(ptInfo: value));
  });
}
}


/// Adds pattern-matching-related methods to [MemberModel].
extension MemberModelPatterns on MemberModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MemberModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MemberModel value)  $default,){
final _that = this;
switch (_that) {
case _MemberModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MemberModel value)?  $default,){
final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String trainerId,  FitnessGoal goal,  ExperienceLevel experience,  PtInfo ptInfo,  double? targetWeight,  String? memo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.id,_that.userId,_that.trainerId,_that.goal,_that.experience,_that.ptInfo,_that.targetWeight,_that.memo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String trainerId,  FitnessGoal goal,  ExperienceLevel experience,  PtInfo ptInfo,  double? targetWeight,  String? memo)  $default,) {final _that = this;
switch (_that) {
case _MemberModel():
return $default(_that.id,_that.userId,_that.trainerId,_that.goal,_that.experience,_that.ptInfo,_that.targetWeight,_that.memo);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String trainerId,  FitnessGoal goal,  ExperienceLevel experience,  PtInfo ptInfo,  double? targetWeight,  String? memo)?  $default,) {final _that = this;
switch (_that) {
case _MemberModel() when $default != null:
return $default(_that.id,_that.userId,_that.trainerId,_that.goal,_that.experience,_that.ptInfo,_that.targetWeight,_that.memo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MemberModel implements MemberModel {
  const _MemberModel({required this.id, required this.userId, required this.trainerId, required this.goal, required this.experience, required this.ptInfo, this.targetWeight, this.memo});
  factory _MemberModel.fromJson(Map<String, dynamic> json) => _$MemberModelFromJson(json);

/// 회원 문서 ID
@override final  String id;
/// users 컬렉션 참조
@override final  String userId;
/// 담당 트레이너 ID
@override final  String trainerId;
/// 운동 목표 ('diet'|'bulk'|'fitness'|'rehab')
@override final  FitnessGoal goal;
/// 운동 경험 수준 ('beginner'|'intermediate'|'advanced')
@override final  ExperienceLevel experience;
/// PT 정보
@override final  PtInfo ptInfo;
/// 목표 체중 (kg)
@override final  double? targetWeight;
/// 트레이너 메모 (부상, 제한사항)
@override final  String? memo;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MemberModelCopyWith<_MemberModel> get copyWith => __$MemberModelCopyWithImpl<_MemberModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MemberModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MemberModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.ptInfo, ptInfo) || other.ptInfo == ptInfo)&&(identical(other.targetWeight, targetWeight) || other.targetWeight == targetWeight)&&(identical(other.memo, memo) || other.memo == memo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,trainerId,goal,experience,ptInfo,targetWeight,memo);

@override
String toString() {
  return 'MemberModel(id: $id, userId: $userId, trainerId: $trainerId, goal: $goal, experience: $experience, ptInfo: $ptInfo, targetWeight: $targetWeight, memo: $memo)';
}


}

/// @nodoc
abstract mixin class _$MemberModelCopyWith<$Res> implements $MemberModelCopyWith<$Res> {
  factory _$MemberModelCopyWith(_MemberModel value, $Res Function(_MemberModel) _then) = __$MemberModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String trainerId, FitnessGoal goal, ExperienceLevel experience, PtInfo ptInfo, double? targetWeight, String? memo
});


@override $PtInfoCopyWith<$Res> get ptInfo;

}
/// @nodoc
class __$MemberModelCopyWithImpl<$Res>
    implements _$MemberModelCopyWith<$Res> {
  __$MemberModelCopyWithImpl(this._self, this._then);

  final _MemberModel _self;
  final $Res Function(_MemberModel) _then;

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? trainerId = null,Object? goal = null,Object? experience = null,Object? ptInfo = null,Object? targetWeight = freezed,Object? memo = freezed,}) {
  return _then(_MemberModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as FitnessGoal,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,ptInfo: null == ptInfo ? _self.ptInfo : ptInfo // ignore: cast_nullable_to_non_nullable
as PtInfo,targetWeight: freezed == targetWeight ? _self.targetWeight : targetWeight // ignore: cast_nullable_to_non_nullable
as double?,memo: freezed == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of MemberModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PtInfoCopyWith<$Res> get ptInfo {
  
  return $PtInfoCopyWith<$Res>(_self.ptInfo, (value) {
    return _then(_self.copyWith(ptInfo: value));
  });
}
}

// dart format on
