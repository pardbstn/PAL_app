// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Exercise {

/// 운동명 (예: '벤치프레스')
 String get name;/// 세트 수
 int get sets;/// 반복 횟수
 int get reps;/// 중량 (kg)
 double? get weight;/// 휴식 시간 (초)
 int? get restSeconds;/// 메모
 String? get note;
/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseCopyWith<Exercise> get copyWith => _$ExerciseCopyWithImpl<Exercise>(this as Exercise, _$identity);

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Exercise&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sets,reps,weight,restSeconds,note);

@override
String toString() {
  return 'Exercise(name: $name, sets: $sets, reps: $reps, weight: $weight, restSeconds: $restSeconds, note: $note)';
}


}

/// @nodoc
abstract mixin class $ExerciseCopyWith<$Res>  {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) _then) = _$ExerciseCopyWithImpl;
@useResult
$Res call({
 String name, int sets, int reps, double? weight, int? restSeconds, String? note
});




}
/// @nodoc
class _$ExerciseCopyWithImpl<$Res>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._self, this._then);

  final Exercise _self;
  final $Res Function(Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? sets = null,Object? reps = null,Object? weight = freezed,Object? restSeconds = freezed,Object? note = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Exercise].
extension ExercisePatterns on Exercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Exercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Exercise value)  $default,){
final _that = this;
switch (_that) {
case _Exercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Exercise value)?  $default,){
final _that = this;
switch (_that) {
case _Exercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int sets,  int reps,  double? weight,  int? restSeconds,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.name,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int sets,  int reps,  double? weight,  int? restSeconds,  String? note)  $default,) {final _that = this;
switch (_that) {
case _Exercise():
return $default(_that.name,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int sets,  int reps,  double? weight,  int? restSeconds,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _Exercise() when $default != null:
return $default(_that.name,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Exercise implements Exercise {
  const _Exercise({required this.name, required this.sets, required this.reps, this.weight, this.restSeconds, this.note});
  factory _Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

/// 운동명 (예: '벤치프레스')
@override final  String name;
/// 세트 수
@override final  int sets;
/// 반복 횟수
@override final  int reps;
/// 중량 (kg)
@override final  double? weight;
/// 휴식 시간 (초)
@override final  int? restSeconds;
/// 메모
@override final  String? note;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseCopyWith<_Exercise> get copyWith => __$ExerciseCopyWithImpl<_Exercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Exercise&&(identical(other.name, name) || other.name == name)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,sets,reps,weight,restSeconds,note);

@override
String toString() {
  return 'Exercise(name: $name, sets: $sets, reps: $reps, weight: $weight, restSeconds: $restSeconds, note: $note)';
}


}

/// @nodoc
abstract mixin class _$ExerciseCopyWith<$Res> implements $ExerciseCopyWith<$Res> {
  factory _$ExerciseCopyWith(_Exercise value, $Res Function(_Exercise) _then) = __$ExerciseCopyWithImpl;
@override @useResult
$Res call({
 String name, int sets, int reps, double? weight, int? restSeconds, String? note
});




}
/// @nodoc
class __$ExerciseCopyWithImpl<$Res>
    implements _$ExerciseCopyWith<$Res> {
  __$ExerciseCopyWithImpl(this._self, this._then);

  final _Exercise _self;
  final $Res Function(_Exercise) _then;

/// Create a copy of Exercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? sets = null,Object? reps = null,Object? weight = freezed,Object? restSeconds = freezed,Object? note = freezed,}) {
  return _then(_Exercise(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: freezed == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double?,restSeconds: freezed == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CurriculumModel {

/// 커리큘럼 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 트레이너 ID
 String get trainerId;/// 회차 번호 (1, 2, 3...)
 int get sessionNumber;/// 제목 (예: '상체 운동')
 String get title;/// 운동 목록
 List<Exercise> get exercises;/// 완료 여부
 bool get isCompleted;/// 예정 날짜
@NullableTimestampConverter() DateTime? get scheduledDate;/// 완료 날짜
@NullableTimestampConverter() DateTime? get completedDate;/// AI 생성 여부
 bool get isAiGenerated;/// 생성일
@TimestampConverter() DateTime get createdAt;/// 수정일
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of CurriculumModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurriculumModelCopyWith<CurriculumModel> get copyWith => _$CurriculumModelCopyWithImpl<CurriculumModel>(this as CurriculumModel, _$identity);

  /// Serializes this CurriculumModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurriculumModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.completedDate, completedDate) || other.completedDate == completedDate)&&(identical(other.isAiGenerated, isAiGenerated) || other.isAiGenerated == isAiGenerated)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,sessionNumber,title,const DeepCollectionEquality().hash(exercises),isCompleted,scheduledDate,completedDate,isAiGenerated,createdAt,updatedAt);

@override
String toString() {
  return 'CurriculumModel(id: $id, memberId: $memberId, trainerId: $trainerId, sessionNumber: $sessionNumber, title: $title, exercises: $exercises, isCompleted: $isCompleted, scheduledDate: $scheduledDate, completedDate: $completedDate, isAiGenerated: $isAiGenerated, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CurriculumModelCopyWith<$Res>  {
  factory $CurriculumModelCopyWith(CurriculumModel value, $Res Function(CurriculumModel) _then) = _$CurriculumModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, String trainerId, int sessionNumber, String title, List<Exercise> exercises, bool isCompleted,@NullableTimestampConverter() DateTime? scheduledDate,@NullableTimestampConverter() DateTime? completedDate, bool isAiGenerated,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$CurriculumModelCopyWithImpl<$Res>
    implements $CurriculumModelCopyWith<$Res> {
  _$CurriculumModelCopyWithImpl(this._self, this._then);

  final CurriculumModel _self;
  final $Res Function(CurriculumModel) _then;

/// Create a copy of CurriculumModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? sessionNumber = null,Object? title = null,Object? exercises = null,Object? isCompleted = null,Object? scheduledDate = freezed,Object? completedDate = freezed,Object? isAiGenerated = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedDate: freezed == completedDate ? _self.completedDate : completedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isAiGenerated: null == isAiGenerated ? _self.isAiGenerated : isAiGenerated // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CurriculumModel].
extension CurriculumModelPatterns on CurriculumModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurriculumModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurriculumModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurriculumModel value)  $default,){
final _that = this;
switch (_that) {
case _CurriculumModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurriculumModel value)?  $default,){
final _that = this;
switch (_that) {
case _CurriculumModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  int sessionNumber,  String title,  List<Exercise> exercises,  bool isCompleted, @NullableTimestampConverter()  DateTime? scheduledDate, @NullableTimestampConverter()  DateTime? completedDate,  bool isAiGenerated, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurriculumModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.sessionNumber,_that.title,_that.exercises,_that.isCompleted,_that.scheduledDate,_that.completedDate,_that.isAiGenerated,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  String trainerId,  int sessionNumber,  String title,  List<Exercise> exercises,  bool isCompleted, @NullableTimestampConverter()  DateTime? scheduledDate, @NullableTimestampConverter()  DateTime? completedDate,  bool isAiGenerated, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CurriculumModel():
return $default(_that.id,_that.memberId,_that.trainerId,_that.sessionNumber,_that.title,_that.exercises,_that.isCompleted,_that.scheduledDate,_that.completedDate,_that.isAiGenerated,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  String trainerId,  int sessionNumber,  String title,  List<Exercise> exercises,  bool isCompleted, @NullableTimestampConverter()  DateTime? scheduledDate, @NullableTimestampConverter()  DateTime? completedDate,  bool isAiGenerated, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CurriculumModel() when $default != null:
return $default(_that.id,_that.memberId,_that.trainerId,_that.sessionNumber,_that.title,_that.exercises,_that.isCompleted,_that.scheduledDate,_that.completedDate,_that.isAiGenerated,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurriculumModel implements CurriculumModel {
  const _CurriculumModel({required this.id, required this.memberId, required this.trainerId, required this.sessionNumber, required this.title, final  List<Exercise> exercises = const [], this.isCompleted = false, @NullableTimestampConverter() this.scheduledDate, @NullableTimestampConverter() this.completedDate, this.isAiGenerated = false, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _exercises = exercises;
  factory _CurriculumModel.fromJson(Map<String, dynamic> json) => _$CurriculumModelFromJson(json);

/// 커리큘럼 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 트레이너 ID
@override final  String trainerId;
/// 회차 번호 (1, 2, 3...)
@override final  int sessionNumber;
/// 제목 (예: '상체 운동')
@override final  String title;
/// 운동 목록
 final  List<Exercise> _exercises;
/// 운동 목록
@override@JsonKey() List<Exercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

/// 완료 여부
@override@JsonKey() final  bool isCompleted;
/// 예정 날짜
@override@NullableTimestampConverter() final  DateTime? scheduledDate;
/// 완료 날짜
@override@NullableTimestampConverter() final  DateTime? completedDate;
/// AI 생성 여부
@override@JsonKey() final  bool isAiGenerated;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;
/// 수정일
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of CurriculumModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurriculumModelCopyWith<_CurriculumModel> get copyWith => __$CurriculumModelCopyWithImpl<_CurriculumModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurriculumModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurriculumModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.scheduledDate, scheduledDate) || other.scheduledDate == scheduledDate)&&(identical(other.completedDate, completedDate) || other.completedDate == completedDate)&&(identical(other.isAiGenerated, isAiGenerated) || other.isAiGenerated == isAiGenerated)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,trainerId,sessionNumber,title,const DeepCollectionEquality().hash(_exercises),isCompleted,scheduledDate,completedDate,isAiGenerated,createdAt,updatedAt);

@override
String toString() {
  return 'CurriculumModel(id: $id, memberId: $memberId, trainerId: $trainerId, sessionNumber: $sessionNumber, title: $title, exercises: $exercises, isCompleted: $isCompleted, scheduledDate: $scheduledDate, completedDate: $completedDate, isAiGenerated: $isAiGenerated, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CurriculumModelCopyWith<$Res> implements $CurriculumModelCopyWith<$Res> {
  factory _$CurriculumModelCopyWith(_CurriculumModel value, $Res Function(_CurriculumModel) _then) = __$CurriculumModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, String trainerId, int sessionNumber, String title, List<Exercise> exercises, bool isCompleted,@NullableTimestampConverter() DateTime? scheduledDate,@NullableTimestampConverter() DateTime? completedDate, bool isAiGenerated,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$CurriculumModelCopyWithImpl<$Res>
    implements _$CurriculumModelCopyWith<$Res> {
  __$CurriculumModelCopyWithImpl(this._self, this._then);

  final _CurriculumModel _self;
  final $Res Function(_CurriculumModel) _then;

/// Create a copy of CurriculumModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? trainerId = null,Object? sessionNumber = null,Object? title = null,Object? exercises = null,Object? isCompleted = null,Object? scheduledDate = freezed,Object? completedDate = freezed,Object? isAiGenerated = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CurriculumModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,scheduledDate: freezed == scheduledDate ? _self.scheduledDate : scheduledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,completedDate: freezed == completedDate ? _self.completedDate : completedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isAiGenerated: null == isAiGenerated ? _self.isAiGenerated : isAiGenerated // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
