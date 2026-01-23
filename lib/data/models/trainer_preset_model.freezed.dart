// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_preset_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrainerPresetModel {

/// 문서 ID (= trainerId)
 String get id;/// 트레이너 ID
 String get trainerId;/// 체육관 이름
 String? get gymName;/// 자주 제외하는 운동 ID
 List<String> get excludedExerciseIds;/// 기본 종목 수 (1-10)
 int get defaultExerciseCount;/// 기본 세트 수 (1-10)
 int get defaultSetCount;/// 선호 운동 스타일
 List<String> get preferredStyles;/// 제외 부위 (부상)
 List<String> get excludedBodyParts;/// 생성 일시
@TimestampConverter() DateTime get createdAt;/// 수정 일시
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of TrainerPresetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerPresetModelCopyWith<TrainerPresetModel> get copyWith => _$TrainerPresetModelCopyWithImpl<TrainerPresetModel>(this as TrainerPresetModel, _$identity);

  /// Serializes this TrainerPresetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerPresetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&const DeepCollectionEquality().equals(other.excludedExerciseIds, excludedExerciseIds)&&(identical(other.defaultExerciseCount, defaultExerciseCount) || other.defaultExerciseCount == defaultExerciseCount)&&(identical(other.defaultSetCount, defaultSetCount) || other.defaultSetCount == defaultSetCount)&&const DeepCollectionEquality().equals(other.preferredStyles, preferredStyles)&&const DeepCollectionEquality().equals(other.excludedBodyParts, excludedBodyParts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,gymName,const DeepCollectionEquality().hash(excludedExerciseIds),defaultExerciseCount,defaultSetCount,const DeepCollectionEquality().hash(preferredStyles),const DeepCollectionEquality().hash(excludedBodyParts),createdAt,updatedAt);

@override
String toString() {
  return 'TrainerPresetModel(id: $id, trainerId: $trainerId, gymName: $gymName, excludedExerciseIds: $excludedExerciseIds, defaultExerciseCount: $defaultExerciseCount, defaultSetCount: $defaultSetCount, preferredStyles: $preferredStyles, excludedBodyParts: $excludedBodyParts, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TrainerPresetModelCopyWith<$Res>  {
  factory $TrainerPresetModelCopyWith(TrainerPresetModel value, $Res Function(TrainerPresetModel) _then) = _$TrainerPresetModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String? gymName, List<String> excludedExerciseIds, int defaultExerciseCount, int defaultSetCount, List<String> preferredStyles, List<String> excludedBodyParts,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$TrainerPresetModelCopyWithImpl<$Res>
    implements $TrainerPresetModelCopyWith<$Res> {
  _$TrainerPresetModelCopyWithImpl(this._self, this._then);

  final TrainerPresetModel _self;
  final $Res Function(TrainerPresetModel) _then;

/// Create a copy of TrainerPresetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? gymName = freezed,Object? excludedExerciseIds = null,Object? defaultExerciseCount = null,Object? defaultSetCount = null,Object? preferredStyles = null,Object? excludedBodyParts = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,excludedExerciseIds: null == excludedExerciseIds ? _self.excludedExerciseIds : excludedExerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,defaultExerciseCount: null == defaultExerciseCount ? _self.defaultExerciseCount : defaultExerciseCount // ignore: cast_nullable_to_non_nullable
as int,defaultSetCount: null == defaultSetCount ? _self.defaultSetCount : defaultSetCount // ignore: cast_nullable_to_non_nullable
as int,preferredStyles: null == preferredStyles ? _self.preferredStyles : preferredStyles // ignore: cast_nullable_to_non_nullable
as List<String>,excludedBodyParts: null == excludedBodyParts ? _self.excludedBodyParts : excludedBodyParts // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerPresetModel].
extension TrainerPresetModelPatterns on TrainerPresetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerPresetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerPresetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerPresetModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerPresetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerPresetModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerPresetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String? gymName,  List<String> excludedExerciseIds,  int defaultExerciseCount,  int defaultSetCount,  List<String> preferredStyles,  List<String> excludedBodyParts, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerPresetModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.gymName,_that.excludedExerciseIds,_that.defaultExerciseCount,_that.defaultSetCount,_that.preferredStyles,_that.excludedBodyParts,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String? gymName,  List<String> excludedExerciseIds,  int defaultExerciseCount,  int defaultSetCount,  List<String> preferredStyles,  List<String> excludedBodyParts, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _TrainerPresetModel():
return $default(_that.id,_that.trainerId,_that.gymName,_that.excludedExerciseIds,_that.defaultExerciseCount,_that.defaultSetCount,_that.preferredStyles,_that.excludedBodyParts,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String? gymName,  List<String> excludedExerciseIds,  int defaultExerciseCount,  int defaultSetCount,  List<String> preferredStyles,  List<String> excludedBodyParts, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrainerPresetModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.gymName,_that.excludedExerciseIds,_that.defaultExerciseCount,_that.defaultSetCount,_that.preferredStyles,_that.excludedBodyParts,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerPresetModel implements TrainerPresetModel {
  const _TrainerPresetModel({required this.id, required this.trainerId, this.gymName, final  List<String> excludedExerciseIds = const [], this.defaultExerciseCount = 5, this.defaultSetCount = 3, final  List<String> preferredStyles = const [], final  List<String> excludedBodyParts = const [], @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _excludedExerciseIds = excludedExerciseIds,_preferredStyles = preferredStyles,_excludedBodyParts = excludedBodyParts;
  factory _TrainerPresetModel.fromJson(Map<String, dynamic> json) => _$TrainerPresetModelFromJson(json);

/// 문서 ID (= trainerId)
@override final  String id;
/// 트레이너 ID
@override final  String trainerId;
/// 체육관 이름
@override final  String? gymName;
/// 자주 제외하는 운동 ID
 final  List<String> _excludedExerciseIds;
/// 자주 제외하는 운동 ID
@override@JsonKey() List<String> get excludedExerciseIds {
  if (_excludedExerciseIds is EqualUnmodifiableListView) return _excludedExerciseIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedExerciseIds);
}

/// 기본 종목 수 (1-10)
@override@JsonKey() final  int defaultExerciseCount;
/// 기본 세트 수 (1-10)
@override@JsonKey() final  int defaultSetCount;
/// 선호 운동 스타일
 final  List<String> _preferredStyles;
/// 선호 운동 스타일
@override@JsonKey() List<String> get preferredStyles {
  if (_preferredStyles is EqualUnmodifiableListView) return _preferredStyles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredStyles);
}

/// 제외 부위 (부상)
 final  List<String> _excludedBodyParts;
/// 제외 부위 (부상)
@override@JsonKey() List<String> get excludedBodyParts {
  if (_excludedBodyParts is EqualUnmodifiableListView) return _excludedBodyParts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_excludedBodyParts);
}

/// 생성 일시
@override@TimestampConverter() final  DateTime createdAt;
/// 수정 일시
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of TrainerPresetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerPresetModelCopyWith<_TrainerPresetModel> get copyWith => __$TrainerPresetModelCopyWithImpl<_TrainerPresetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerPresetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerPresetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.gymName, gymName) || other.gymName == gymName)&&const DeepCollectionEquality().equals(other._excludedExerciseIds, _excludedExerciseIds)&&(identical(other.defaultExerciseCount, defaultExerciseCount) || other.defaultExerciseCount == defaultExerciseCount)&&(identical(other.defaultSetCount, defaultSetCount) || other.defaultSetCount == defaultSetCount)&&const DeepCollectionEquality().equals(other._preferredStyles, _preferredStyles)&&const DeepCollectionEquality().equals(other._excludedBodyParts, _excludedBodyParts)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,gymName,const DeepCollectionEquality().hash(_excludedExerciseIds),defaultExerciseCount,defaultSetCount,const DeepCollectionEquality().hash(_preferredStyles),const DeepCollectionEquality().hash(_excludedBodyParts),createdAt,updatedAt);

@override
String toString() {
  return 'TrainerPresetModel(id: $id, trainerId: $trainerId, gymName: $gymName, excludedExerciseIds: $excludedExerciseIds, defaultExerciseCount: $defaultExerciseCount, defaultSetCount: $defaultSetCount, preferredStyles: $preferredStyles, excludedBodyParts: $excludedBodyParts, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TrainerPresetModelCopyWith<$Res> implements $TrainerPresetModelCopyWith<$Res> {
  factory _$TrainerPresetModelCopyWith(_TrainerPresetModel value, $Res Function(_TrainerPresetModel) _then) = __$TrainerPresetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String? gymName, List<String> excludedExerciseIds, int defaultExerciseCount, int defaultSetCount, List<String> preferredStyles, List<String> excludedBodyParts,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$TrainerPresetModelCopyWithImpl<$Res>
    implements _$TrainerPresetModelCopyWith<$Res> {
  __$TrainerPresetModelCopyWithImpl(this._self, this._then);

  final _TrainerPresetModel _self;
  final $Res Function(_TrainerPresetModel) _then;

/// Create a copy of TrainerPresetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? gymName = freezed,Object? excludedExerciseIds = null,Object? defaultExerciseCount = null,Object? defaultSetCount = null,Object? preferredStyles = null,Object? excludedBodyParts = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_TrainerPresetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,gymName: freezed == gymName ? _self.gymName : gymName // ignore: cast_nullable_to_non_nullable
as String?,excludedExerciseIds: null == excludedExerciseIds ? _self._excludedExerciseIds : excludedExerciseIds // ignore: cast_nullable_to_non_nullable
as List<String>,defaultExerciseCount: null == defaultExerciseCount ? _self.defaultExerciseCount : defaultExerciseCount // ignore: cast_nullable_to_non_nullable
as int,defaultSetCount: null == defaultSetCount ? _self.defaultSetCount : defaultSetCount // ignore: cast_nullable_to_non_nullable
as int,preferredStyles: null == preferredStyles ? _self._preferredStyles : preferredStyles // ignore: cast_nullable_to_non_nullable
as List<String>,excludedBodyParts: null == excludedBodyParts ? _self._excludedBodyParts : excludedBodyParts // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
