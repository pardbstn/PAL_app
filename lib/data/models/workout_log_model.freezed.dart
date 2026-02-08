// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutExercise {

/// 운동 이름
 String get name;/// 운동 부위
 WorkoutCategory get category;/// 세트 수
 int get sets;/// 반복 횟수
 int get reps;/// 무게 (kg)
 double get weight;/// 휴식 시간 (초)
 int get restSeconds;/// 메모
 String get note;
/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutExerciseCopyWith<WorkoutExercise> get copyWith => _$WorkoutExerciseCopyWithImpl<WorkoutExercise>(this as WorkoutExercise, _$identity);

  /// Serializes this WorkoutExercise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutExercise&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,sets,reps,weight,restSeconds,note);

@override
String toString() {
  return 'WorkoutExercise(name: $name, category: $category, sets: $sets, reps: $reps, weight: $weight, restSeconds: $restSeconds, note: $note)';
}


}

/// @nodoc
abstract mixin class $WorkoutExerciseCopyWith<$Res>  {
  factory $WorkoutExerciseCopyWith(WorkoutExercise value, $Res Function(WorkoutExercise) _then) = _$WorkoutExerciseCopyWithImpl;
@useResult
$Res call({
 String name, WorkoutCategory category, int sets, int reps, double weight, int restSeconds, String note
});




}
/// @nodoc
class _$WorkoutExerciseCopyWithImpl<$Res>
    implements $WorkoutExerciseCopyWith<$Res> {
  _$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final WorkoutExercise _self;
  final $Res Function(WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? category = null,Object? sets = null,Object? reps = null,Object? weight = null,Object? restSeconds = null,Object? note = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WorkoutCategory,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutExercise].
extension WorkoutExercisePatterns on WorkoutExercise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutExercise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutExercise value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutExercise value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  WorkoutCategory category,  int sets,  int reps,  double weight,  int restSeconds,  String note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.name,_that.category,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  WorkoutCategory category,  int sets,  int reps,  double weight,  int restSeconds,  String note)  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise():
return $default(_that.name,_that.category,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  WorkoutCategory category,  int sets,  int reps,  double weight,  int restSeconds,  String note)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutExercise() when $default != null:
return $default(_that.name,_that.category,_that.sets,_that.reps,_that.weight,_that.restSeconds,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutExercise implements WorkoutExercise {
  const _WorkoutExercise({required this.name, required this.category, required this.sets, required this.reps, this.weight = 0.0, this.restSeconds = 60, this.note = ''});
  factory _WorkoutExercise.fromJson(Map<String, dynamic> json) => _$WorkoutExerciseFromJson(json);

/// 운동 이름
@override final  String name;
/// 운동 부위
@override final  WorkoutCategory category;
/// 세트 수
@override final  int sets;
/// 반복 횟수
@override final  int reps;
/// 무게 (kg)
@override@JsonKey() final  double weight;
/// 휴식 시간 (초)
@override@JsonKey() final  int restSeconds;
/// 메모
@override@JsonKey() final  String note;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutExerciseCopyWith<_WorkoutExercise> get copyWith => __$WorkoutExerciseCopyWithImpl<_WorkoutExercise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutExerciseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutExercise&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.sets, sets) || other.sets == sets)&&(identical(other.reps, reps) || other.reps == reps)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.restSeconds, restSeconds) || other.restSeconds == restSeconds)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,category,sets,reps,weight,restSeconds,note);

@override
String toString() {
  return 'WorkoutExercise(name: $name, category: $category, sets: $sets, reps: $reps, weight: $weight, restSeconds: $restSeconds, note: $note)';
}


}

/// @nodoc
abstract mixin class _$WorkoutExerciseCopyWith<$Res> implements $WorkoutExerciseCopyWith<$Res> {
  factory _$WorkoutExerciseCopyWith(_WorkoutExercise value, $Res Function(_WorkoutExercise) _then) = __$WorkoutExerciseCopyWithImpl;
@override @useResult
$Res call({
 String name, WorkoutCategory category, int sets, int reps, double weight, int restSeconds, String note
});




}
/// @nodoc
class __$WorkoutExerciseCopyWithImpl<$Res>
    implements _$WorkoutExerciseCopyWith<$Res> {
  __$WorkoutExerciseCopyWithImpl(this._self, this._then);

  final _WorkoutExercise _self;
  final $Res Function(_WorkoutExercise) _then;

/// Create a copy of WorkoutExercise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? category = null,Object? sets = null,Object? reps = null,Object? weight = null,Object? restSeconds = null,Object? note = null,}) {
  return _then(_WorkoutExercise(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as WorkoutCategory,sets: null == sets ? _self.sets : sets // ignore: cast_nullable_to_non_nullable
as int,reps: null == reps ? _self.reps : reps // ignore: cast_nullable_to_non_nullable
as int,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,restSeconds: null == restSeconds ? _self.restSeconds : restSeconds // ignore: cast_nullable_to_non_nullable
as int,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$WorkoutLogModel {

/// Firestore 문서 ID
 String get id;/// 사용자 ID
 String get userId;/// 트레이너 ID (개인모드면 빈 문자열)
 String get trainerId;/// 운동 제목 (예: '상체 운동', '등 데이')
 String get title;/// 운동 날짜
@TimestampConverter() DateTime get workoutDate;/// 운동 목록
 List<WorkoutExercise> get exercises;/// 총 운동 시간 (분)
 int get durationMinutes;/// 전체 메모
 String get memo;/// 오운완 사진 URL (Supabase Storage)
 String? get imageUrl;/// 생성일
@TimestampConverter() DateTime get createdAt;
/// Create a copy of WorkoutLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutLogModelCopyWith<WorkoutLogModel> get copyWith => _$WorkoutLogModelCopyWithImpl<WorkoutLogModel>(this as WorkoutLogModel, _$identity);

  /// Serializes this WorkoutLogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate)&&const DeepCollectionEquality().equals(other.exercises, exercises)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,trainerId,title,workoutDate,const DeepCollectionEquality().hash(exercises),durationMinutes,memo,imageUrl,createdAt);

@override
String toString() {
  return 'WorkoutLogModel(id: $id, userId: $userId, trainerId: $trainerId, title: $title, workoutDate: $workoutDate, exercises: $exercises, durationMinutes: $durationMinutes, memo: $memo, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutLogModelCopyWith<$Res>  {
  factory $WorkoutLogModelCopyWith(WorkoutLogModel value, $Res Function(WorkoutLogModel) _then) = _$WorkoutLogModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String trainerId, String title,@TimestampConverter() DateTime workoutDate, List<WorkoutExercise> exercises, int durationMinutes, String memo, String? imageUrl,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$WorkoutLogModelCopyWithImpl<$Res>
    implements $WorkoutLogModelCopyWith<$Res> {
  _$WorkoutLogModelCopyWithImpl(this._self, this._then);

  final WorkoutLogModel _self;
  final $Res Function(WorkoutLogModel) _then;

/// Create a copy of WorkoutLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? trainerId = null,Object? title = null,Object? workoutDate = null,Object? exercises = null,Object? durationMinutes = null,Object? memo = null,Object? imageUrl = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workoutDate: null == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutLogModel].
extension WorkoutLogModelPatterns on WorkoutLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutLogModel value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String trainerId,  String title, @TimestampConverter()  DateTime workoutDate,  List<WorkoutExercise> exercises,  int durationMinutes,  String memo,  String? imageUrl, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutLogModel() when $default != null:
return $default(_that.id,_that.userId,_that.trainerId,_that.title,_that.workoutDate,_that.exercises,_that.durationMinutes,_that.memo,_that.imageUrl,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String trainerId,  String title, @TimestampConverter()  DateTime workoutDate,  List<WorkoutExercise> exercises,  int durationMinutes,  String memo,  String? imageUrl, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutLogModel():
return $default(_that.id,_that.userId,_that.trainerId,_that.title,_that.workoutDate,_that.exercises,_that.durationMinutes,_that.memo,_that.imageUrl,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String trainerId,  String title, @TimestampConverter()  DateTime workoutDate,  List<WorkoutExercise> exercises,  int durationMinutes,  String memo,  String? imageUrl, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutLogModel() when $default != null:
return $default(_that.id,_that.userId,_that.trainerId,_that.title,_that.workoutDate,_that.exercises,_that.durationMinutes,_that.memo,_that.imageUrl,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutLogModel extends WorkoutLogModel {
  const _WorkoutLogModel({this.id = '', required this.userId, this.trainerId = '', this.title = '', @TimestampConverter() required this.workoutDate, required final  List<WorkoutExercise> exercises, this.durationMinutes = 0, this.memo = '', this.imageUrl, @TimestampConverter() required this.createdAt}): _exercises = exercises,super._();
  factory _WorkoutLogModel.fromJson(Map<String, dynamic> json) => _$WorkoutLogModelFromJson(json);

/// Firestore 문서 ID
@override@JsonKey() final  String id;
/// 사용자 ID
@override final  String userId;
/// 트레이너 ID (개인모드면 빈 문자열)
@override@JsonKey() final  String trainerId;
/// 운동 제목 (예: '상체 운동', '등 데이')
@override@JsonKey() final  String title;
/// 운동 날짜
@override@TimestampConverter() final  DateTime workoutDate;
/// 운동 목록
 final  List<WorkoutExercise> _exercises;
/// 운동 목록
@override List<WorkoutExercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}

/// 총 운동 시간 (분)
@override@JsonKey() final  int durationMinutes;
/// 전체 메모
@override@JsonKey() final  String memo;
/// 오운완 사진 URL (Supabase Storage)
@override final  String? imageUrl;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of WorkoutLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutLogModelCopyWith<_WorkoutLogModel> get copyWith => __$WorkoutLogModelCopyWithImpl<_WorkoutLogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutLogModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.workoutDate, workoutDate) || other.workoutDate == workoutDate)&&const DeepCollectionEquality().equals(other._exercises, _exercises)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.memo, memo) || other.memo == memo)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,trainerId,title,workoutDate,const DeepCollectionEquality().hash(_exercises),durationMinutes,memo,imageUrl,createdAt);

@override
String toString() {
  return 'WorkoutLogModel(id: $id, userId: $userId, trainerId: $trainerId, title: $title, workoutDate: $workoutDate, exercises: $exercises, durationMinutes: $durationMinutes, memo: $memo, imageUrl: $imageUrl, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutLogModelCopyWith<$Res> implements $WorkoutLogModelCopyWith<$Res> {
  factory _$WorkoutLogModelCopyWith(_WorkoutLogModel value, $Res Function(_WorkoutLogModel) _then) = __$WorkoutLogModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String trainerId, String title,@TimestampConverter() DateTime workoutDate, List<WorkoutExercise> exercises, int durationMinutes, String memo, String? imageUrl,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$WorkoutLogModelCopyWithImpl<$Res>
    implements _$WorkoutLogModelCopyWith<$Res> {
  __$WorkoutLogModelCopyWithImpl(this._self, this._then);

  final _WorkoutLogModel _self;
  final $Res Function(_WorkoutLogModel) _then;

/// Create a copy of WorkoutLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? trainerId = null,Object? title = null,Object? workoutDate = null,Object? exercises = null,Object? durationMinutes = null,Object? memo = null,Object? imageUrl = freezed,Object? createdAt = null,}) {
  return _then(_WorkoutLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,workoutDate: null == workoutDate ? _self.workoutDate : workoutDate // ignore: cast_nullable_to_non_nullable
as DateTime,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<WorkoutExercise>,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,memo: null == memo ? _self.memo : memo // ignore: cast_nullable_to_non_nullable
as String,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
