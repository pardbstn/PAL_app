// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'curriculum_template_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TemplateSession {

/// 회차 번호 (1, 2, 3...)
 int get sessionNumber;/// 제목 (예: '상체 운동')
 String get title;/// 설명
 String? get description;/// 운동 목록
 List<Exercise> get exercises;
/// Create a copy of TemplateSession
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TemplateSessionCopyWith<TemplateSession> get copyWith => _$TemplateSessionCopyWithImpl<TemplateSession>(this as TemplateSession, _$identity);

  /// Serializes this TemplateSession to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TemplateSession&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.exercises, exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionNumber,title,description,const DeepCollectionEquality().hash(exercises));

@override
String toString() {
  return 'TemplateSession(sessionNumber: $sessionNumber, title: $title, description: $description, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class $TemplateSessionCopyWith<$Res>  {
  factory $TemplateSessionCopyWith(TemplateSession value, $Res Function(TemplateSession) _then) = _$TemplateSessionCopyWithImpl;
@useResult
$Res call({
 int sessionNumber, String title, String? description, List<Exercise> exercises
});




}
/// @nodoc
class _$TemplateSessionCopyWithImpl<$Res>
    implements $TemplateSessionCopyWith<$Res> {
  _$TemplateSessionCopyWithImpl(this._self, this._then);

  final TemplateSession _self;
  final $Res Function(TemplateSession) _then;

/// Create a copy of TemplateSession
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sessionNumber = null,Object? title = null,Object? description = freezed,Object? exercises = null,}) {
  return _then(_self.copyWith(
sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self.exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,
  ));
}

}


/// Adds pattern-matching-related methods to [TemplateSession].
extension TemplateSessionPatterns on TemplateSession {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TemplateSession value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TemplateSession() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TemplateSession value)  $default,){
final _that = this;
switch (_that) {
case _TemplateSession():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TemplateSession value)?  $default,){
final _that = this;
switch (_that) {
case _TemplateSession() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int sessionNumber,  String title,  String? description,  List<Exercise> exercises)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TemplateSession() when $default != null:
return $default(_that.sessionNumber,_that.title,_that.description,_that.exercises);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int sessionNumber,  String title,  String? description,  List<Exercise> exercises)  $default,) {final _that = this;
switch (_that) {
case _TemplateSession():
return $default(_that.sessionNumber,_that.title,_that.description,_that.exercises);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int sessionNumber,  String title,  String? description,  List<Exercise> exercises)?  $default,) {final _that = this;
switch (_that) {
case _TemplateSession() when $default != null:
return $default(_that.sessionNumber,_that.title,_that.description,_that.exercises);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TemplateSession implements TemplateSession {
  const _TemplateSession({required this.sessionNumber, required this.title, this.description, final  List<Exercise> exercises = const []}): _exercises = exercises;
  factory _TemplateSession.fromJson(Map<String, dynamic> json) => _$TemplateSessionFromJson(json);

/// 회차 번호 (1, 2, 3...)
@override final  int sessionNumber;
/// 제목 (예: '상체 운동')
@override final  String title;
/// 설명
@override final  String? description;
/// 운동 목록
 final  List<Exercise> _exercises;
/// 운동 목록
@override@JsonKey() List<Exercise> get exercises {
  if (_exercises is EqualUnmodifiableListView) return _exercises;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_exercises);
}


/// Create a copy of TemplateSession
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateSessionCopyWith<_TemplateSession> get copyWith => __$TemplateSessionCopyWithImpl<_TemplateSession>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TemplateSessionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateSession&&(identical(other.sessionNumber, sessionNumber) || other.sessionNumber == sessionNumber)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._exercises, _exercises));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionNumber,title,description,const DeepCollectionEquality().hash(_exercises));

@override
String toString() {
  return 'TemplateSession(sessionNumber: $sessionNumber, title: $title, description: $description, exercises: $exercises)';
}


}

/// @nodoc
abstract mixin class _$TemplateSessionCopyWith<$Res> implements $TemplateSessionCopyWith<$Res> {
  factory _$TemplateSessionCopyWith(_TemplateSession value, $Res Function(_TemplateSession) _then) = __$TemplateSessionCopyWithImpl;
@override @useResult
$Res call({
 int sessionNumber, String title, String? description, List<Exercise> exercises
});




}
/// @nodoc
class __$TemplateSessionCopyWithImpl<$Res>
    implements _$TemplateSessionCopyWith<$Res> {
  __$TemplateSessionCopyWithImpl(this._self, this._then);

  final _TemplateSession _self;
  final $Res Function(_TemplateSession) _then;

/// Create a copy of TemplateSession
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sessionNumber = null,Object? title = null,Object? description = freezed,Object? exercises = null,}) {
  return _then(_TemplateSession(
sessionNumber: null == sessionNumber ? _self.sessionNumber : sessionNumber // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,exercises: null == exercises ? _self._exercises : exercises // ignore: cast_nullable_to_non_nullable
as List<Exercise>,
  ));
}


}


/// @nodoc
mixin _$CurriculumTemplateModel {

/// 템플릿 문서 ID
 String get id;/// 생성한 트레이너 ID
 String get trainerId;/// 템플릿 이름 (예: '초보자 다이어트 12주')
 String get name;/// 대상 운동 목표
 FitnessGoal get goal;/// 대상 경험 수준
 ExperienceLevel get experience;/// 총 회차 수
 int get sessionCount;/// 회차별 운동 계획
 List<TemplateSession> get sessions;/// 사용 횟수
 int get usageCount;/// 생성일
@TimestampConverter() DateTime get createdAt;/// 수정일
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of CurriculumTemplateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CurriculumTemplateModelCopyWith<CurriculumTemplateModel> get copyWith => _$CurriculumTemplateModelCopyWithImpl<CurriculumTemplateModel>(this as CurriculumTemplateModel, _$identity);

  /// Serializes this CurriculumTemplateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CurriculumTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&const DeepCollectionEquality().equals(other.sessions, sessions)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,name,goal,experience,sessionCount,const DeepCollectionEquality().hash(sessions),usageCount,createdAt,updatedAt);

@override
String toString() {
  return 'CurriculumTemplateModel(id: $id, trainerId: $trainerId, name: $name, goal: $goal, experience: $experience, sessionCount: $sessionCount, sessions: $sessions, usageCount: $usageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CurriculumTemplateModelCopyWith<$Res>  {
  factory $CurriculumTemplateModelCopyWith(CurriculumTemplateModel value, $Res Function(CurriculumTemplateModel) _then) = _$CurriculumTemplateModelCopyWithImpl;
@useResult
$Res call({
 String id, String trainerId, String name, FitnessGoal goal, ExperienceLevel experience, int sessionCount, List<TemplateSession> sessions, int usageCount,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class _$CurriculumTemplateModelCopyWithImpl<$Res>
    implements $CurriculumTemplateModelCopyWith<$Res> {
  _$CurriculumTemplateModelCopyWithImpl(this._self, this._then);

  final CurriculumTemplateModel _self;
  final $Res Function(CurriculumTemplateModel) _then;

/// Create a copy of CurriculumTemplateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? trainerId = null,Object? name = null,Object? goal = null,Object? experience = null,Object? sessionCount = null,Object? sessions = null,Object? usageCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as FitnessGoal,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self.sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<TemplateSession>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CurriculumTemplateModel].
extension CurriculumTemplateModelPatterns on CurriculumTemplateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CurriculumTemplateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CurriculumTemplateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CurriculumTemplateModel value)  $default,){
final _that = this;
switch (_that) {
case _CurriculumTemplateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CurriculumTemplateModel value)?  $default,){
final _that = this;
switch (_that) {
case _CurriculumTemplateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String trainerId,  String name,  FitnessGoal goal,  ExperienceLevel experience,  int sessionCount,  List<TemplateSession> sessions,  int usageCount, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CurriculumTemplateModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.name,_that.goal,_that.experience,_that.sessionCount,_that.sessions,_that.usageCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String trainerId,  String name,  FitnessGoal goal,  ExperienceLevel experience,  int sessionCount,  List<TemplateSession> sessions,  int usageCount, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CurriculumTemplateModel():
return $default(_that.id,_that.trainerId,_that.name,_that.goal,_that.experience,_that.sessionCount,_that.sessions,_that.usageCount,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String trainerId,  String name,  FitnessGoal goal,  ExperienceLevel experience,  int sessionCount,  List<TemplateSession> sessions,  int usageCount, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CurriculumTemplateModel() when $default != null:
return $default(_that.id,_that.trainerId,_that.name,_that.goal,_that.experience,_that.sessionCount,_that.sessions,_that.usageCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CurriculumTemplateModel implements CurriculumTemplateModel {
  const _CurriculumTemplateModel({required this.id, required this.trainerId, required this.name, required this.goal, required this.experience, required this.sessionCount, final  List<TemplateSession> sessions = const [], this.usageCount = 0, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt}): _sessions = sessions;
  factory _CurriculumTemplateModel.fromJson(Map<String, dynamic> json) => _$CurriculumTemplateModelFromJson(json);

/// 템플릿 문서 ID
@override final  String id;
/// 생성한 트레이너 ID
@override final  String trainerId;
/// 템플릿 이름 (예: '초보자 다이어트 12주')
@override final  String name;
/// 대상 운동 목표
@override final  FitnessGoal goal;
/// 대상 경험 수준
@override final  ExperienceLevel experience;
/// 총 회차 수
@override final  int sessionCount;
/// 회차별 운동 계획
 final  List<TemplateSession> _sessions;
/// 회차별 운동 계획
@override@JsonKey() List<TemplateSession> get sessions {
  if (_sessions is EqualUnmodifiableListView) return _sessions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sessions);
}

/// 사용 횟수
@override@JsonKey() final  int usageCount;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;
/// 수정일
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of CurriculumTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CurriculumTemplateModelCopyWith<_CurriculumTemplateModel> get copyWith => __$CurriculumTemplateModelCopyWithImpl<_CurriculumTemplateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CurriculumTemplateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CurriculumTemplateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.trainerId, trainerId) || other.trainerId == trainerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.experience, experience) || other.experience == experience)&&(identical(other.sessionCount, sessionCount) || other.sessionCount == sessionCount)&&const DeepCollectionEquality().equals(other._sessions, _sessions)&&(identical(other.usageCount, usageCount) || other.usageCount == usageCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,trainerId,name,goal,experience,sessionCount,const DeepCollectionEquality().hash(_sessions),usageCount,createdAt,updatedAt);

@override
String toString() {
  return 'CurriculumTemplateModel(id: $id, trainerId: $trainerId, name: $name, goal: $goal, experience: $experience, sessionCount: $sessionCount, sessions: $sessions, usageCount: $usageCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CurriculumTemplateModelCopyWith<$Res> implements $CurriculumTemplateModelCopyWith<$Res> {
  factory _$CurriculumTemplateModelCopyWith(_CurriculumTemplateModel value, $Res Function(_CurriculumTemplateModel) _then) = __$CurriculumTemplateModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String trainerId, String name, FitnessGoal goal, ExperienceLevel experience, int sessionCount, List<TemplateSession> sessions, int usageCount,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});




}
/// @nodoc
class __$CurriculumTemplateModelCopyWithImpl<$Res>
    implements _$CurriculumTemplateModelCopyWith<$Res> {
  __$CurriculumTemplateModelCopyWithImpl(this._self, this._then);

  final _CurriculumTemplateModel _self;
  final $Res Function(_CurriculumTemplateModel) _then;

/// Create a copy of CurriculumTemplateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? trainerId = null,Object? name = null,Object? goal = null,Object? experience = null,Object? sessionCount = null,Object? sessions = null,Object? usageCount = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_CurriculumTemplateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,trainerId: null == trainerId ? _self.trainerId : trainerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,goal: null == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as FitnessGoal,experience: null == experience ? _self.experience : experience // ignore: cast_nullable_to_non_nullable
as ExperienceLevel,sessionCount: null == sessionCount ? _self.sessionCount : sessionCount // ignore: cast_nullable_to_non_nullable
as int,sessions: null == sessions ? _self._sessions : sessions // ignore: cast_nullable_to_non_nullable
as List<TemplateSession>,usageCount: null == usageCount ? _self.usageCount : usageCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
