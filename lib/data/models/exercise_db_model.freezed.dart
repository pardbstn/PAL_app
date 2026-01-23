// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_db_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExerciseDbModel {

/// 문서 ID
 String get id;/// 한글 운동명 (예: "바벨 벤치프레스")
 String get nameKo;/// 영문 운동명
 String get nameEn;/// 장비 (바벨, 덤벨, 케이블, 머신, 맨몸)
 String get equipment;/// 영문 장비명
 String get equipmentEn;/// 주요 근육군 (가슴, 등, 하체, 어깨, 팔, 복근)
 String get primaryMuscle;/// 보조 근육군
 List<String> get secondaryMuscles;/// 난이도 (초급, 중급, 고급)
 String get level;/// 힘 방향 (push, pull, static)
 String? get force;/// 운동 유형 (compound, isolation)
 String? get mechanic;/// 운동 설명
 List<String> get instructions;/// 이미지 URL
 String? get imageUrl;/// 검색용 태그
 List<String> get tags;
/// Create a copy of ExerciseDbModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExerciseDbModelCopyWith<ExerciseDbModel> get copyWith => _$ExerciseDbModelCopyWithImpl<ExerciseDbModel>(this as ExerciseDbModel, _$identity);

  /// Serializes this ExerciseDbModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExerciseDbModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKo, nameKo) || other.nameKo == nameKo)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.equipmentEn, equipmentEn) || other.equipmentEn == equipmentEn)&&(identical(other.primaryMuscle, primaryMuscle) || other.primaryMuscle == primaryMuscle)&&const DeepCollectionEquality().equals(other.secondaryMuscles, secondaryMuscles)&&(identical(other.level, level) || other.level == level)&&(identical(other.force, force) || other.force == force)&&(identical(other.mechanic, mechanic) || other.mechanic == mechanic)&&const DeepCollectionEquality().equals(other.instructions, instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameKo,nameEn,equipment,equipmentEn,primaryMuscle,const DeepCollectionEquality().hash(secondaryMuscles),level,force,mechanic,const DeepCollectionEquality().hash(instructions),imageUrl,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'ExerciseDbModel(id: $id, nameKo: $nameKo, nameEn: $nameEn, equipment: $equipment, equipmentEn: $equipmentEn, primaryMuscle: $primaryMuscle, secondaryMuscles: $secondaryMuscles, level: $level, force: $force, mechanic: $mechanic, instructions: $instructions, imageUrl: $imageUrl, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ExerciseDbModelCopyWith<$Res>  {
  factory $ExerciseDbModelCopyWith(ExerciseDbModel value, $Res Function(ExerciseDbModel) _then) = _$ExerciseDbModelCopyWithImpl;
@useResult
$Res call({
 String id, String nameKo, String nameEn, String equipment, String equipmentEn, String primaryMuscle, List<String> secondaryMuscles, String level, String? force, String? mechanic, List<String> instructions, String? imageUrl, List<String> tags
});




}
/// @nodoc
class _$ExerciseDbModelCopyWithImpl<$Res>
    implements $ExerciseDbModelCopyWith<$Res> {
  _$ExerciseDbModelCopyWithImpl(this._self, this._then);

  final ExerciseDbModel _self;
  final $Res Function(ExerciseDbModel) _then;

/// Create a copy of ExerciseDbModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameKo = null,Object? nameEn = null,Object? equipment = null,Object? equipmentEn = null,Object? primaryMuscle = null,Object? secondaryMuscles = null,Object? level = null,Object? force = freezed,Object? mechanic = freezed,Object? instructions = null,Object? imageUrl = freezed,Object? tags = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKo: null == nameKo ? _self.nameKo : nameKo // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,equipmentEn: null == equipmentEn ? _self.equipmentEn : equipmentEn // ignore: cast_nullable_to_non_nullable
as String,primaryMuscle: null == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as String,secondaryMuscles: null == secondaryMuscles ? _self.secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as String?,mechanic: freezed == mechanic ? _self.mechanic : mechanic // ignore: cast_nullable_to_non_nullable
as String?,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExerciseDbModel].
extension ExerciseDbModelPatterns on ExerciseDbModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExerciseDbModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExerciseDbModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExerciseDbModel value)  $default,){
final _that = this;
switch (_that) {
case _ExerciseDbModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExerciseDbModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExerciseDbModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nameKo,  String nameEn,  String equipment,  String equipmentEn,  String primaryMuscle,  List<String> secondaryMuscles,  String level,  String? force,  String? mechanic,  List<String> instructions,  String? imageUrl,  List<String> tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExerciseDbModel() when $default != null:
return $default(_that.id,_that.nameKo,_that.nameEn,_that.equipment,_that.equipmentEn,_that.primaryMuscle,_that.secondaryMuscles,_that.level,_that.force,_that.mechanic,_that.instructions,_that.imageUrl,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nameKo,  String nameEn,  String equipment,  String equipmentEn,  String primaryMuscle,  List<String> secondaryMuscles,  String level,  String? force,  String? mechanic,  List<String> instructions,  String? imageUrl,  List<String> tags)  $default,) {final _that = this;
switch (_that) {
case _ExerciseDbModel():
return $default(_that.id,_that.nameKo,_that.nameEn,_that.equipment,_that.equipmentEn,_that.primaryMuscle,_that.secondaryMuscles,_that.level,_that.force,_that.mechanic,_that.instructions,_that.imageUrl,_that.tags);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nameKo,  String nameEn,  String equipment,  String equipmentEn,  String primaryMuscle,  List<String> secondaryMuscles,  String level,  String? force,  String? mechanic,  List<String> instructions,  String? imageUrl,  List<String> tags)?  $default,) {final _that = this;
switch (_that) {
case _ExerciseDbModel() when $default != null:
return $default(_that.id,_that.nameKo,_that.nameEn,_that.equipment,_that.equipmentEn,_that.primaryMuscle,_that.secondaryMuscles,_that.level,_that.force,_that.mechanic,_that.instructions,_that.imageUrl,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExerciseDbModel implements ExerciseDbModel {
  const _ExerciseDbModel({required this.id, required this.nameKo, this.nameEn = '', required this.equipment, this.equipmentEn = '', required this.primaryMuscle, final  List<String> secondaryMuscles = const [], this.level = '초급', this.force, this.mechanic, final  List<String> instructions = const [], this.imageUrl, final  List<String> tags = const []}): _secondaryMuscles = secondaryMuscles,_instructions = instructions,_tags = tags;
  factory _ExerciseDbModel.fromJson(Map<String, dynamic> json) => _$ExerciseDbModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 한글 운동명 (예: "바벨 벤치프레스")
@override final  String nameKo;
/// 영문 운동명
@override@JsonKey() final  String nameEn;
/// 장비 (바벨, 덤벨, 케이블, 머신, 맨몸)
@override final  String equipment;
/// 영문 장비명
@override@JsonKey() final  String equipmentEn;
/// 주요 근육군 (가슴, 등, 하체, 어깨, 팔, 복근)
@override final  String primaryMuscle;
/// 보조 근육군
 final  List<String> _secondaryMuscles;
/// 보조 근육군
@override@JsonKey() List<String> get secondaryMuscles {
  if (_secondaryMuscles is EqualUnmodifiableListView) return _secondaryMuscles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_secondaryMuscles);
}

/// 난이도 (초급, 중급, 고급)
@override@JsonKey() final  String level;
/// 힘 방향 (push, pull, static)
@override final  String? force;
/// 운동 유형 (compound, isolation)
@override final  String? mechanic;
/// 운동 설명
 final  List<String> _instructions;
/// 운동 설명
@override@JsonKey() List<String> get instructions {
  if (_instructions is EqualUnmodifiableListView) return _instructions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_instructions);
}

/// 이미지 URL
@override final  String? imageUrl;
/// 검색용 태그
 final  List<String> _tags;
/// 검색용 태그
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}


/// Create a copy of ExerciseDbModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExerciseDbModelCopyWith<_ExerciseDbModel> get copyWith => __$ExerciseDbModelCopyWithImpl<_ExerciseDbModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExerciseDbModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExerciseDbModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nameKo, nameKo) || other.nameKo == nameKo)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.equipment, equipment) || other.equipment == equipment)&&(identical(other.equipmentEn, equipmentEn) || other.equipmentEn == equipmentEn)&&(identical(other.primaryMuscle, primaryMuscle) || other.primaryMuscle == primaryMuscle)&&const DeepCollectionEquality().equals(other._secondaryMuscles, _secondaryMuscles)&&(identical(other.level, level) || other.level == level)&&(identical(other.force, force) || other.force == force)&&(identical(other.mechanic, mechanic) || other.mechanic == mechanic)&&const DeepCollectionEquality().equals(other._instructions, _instructions)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameKo,nameEn,equipment,equipmentEn,primaryMuscle,const DeepCollectionEquality().hash(_secondaryMuscles),level,force,mechanic,const DeepCollectionEquality().hash(_instructions),imageUrl,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'ExerciseDbModel(id: $id, nameKo: $nameKo, nameEn: $nameEn, equipment: $equipment, equipmentEn: $equipmentEn, primaryMuscle: $primaryMuscle, secondaryMuscles: $secondaryMuscles, level: $level, force: $force, mechanic: $mechanic, instructions: $instructions, imageUrl: $imageUrl, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ExerciseDbModelCopyWith<$Res> implements $ExerciseDbModelCopyWith<$Res> {
  factory _$ExerciseDbModelCopyWith(_ExerciseDbModel value, $Res Function(_ExerciseDbModel) _then) = __$ExerciseDbModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nameKo, String nameEn, String equipment, String equipmentEn, String primaryMuscle, List<String> secondaryMuscles, String level, String? force, String? mechanic, List<String> instructions, String? imageUrl, List<String> tags
});




}
/// @nodoc
class __$ExerciseDbModelCopyWithImpl<$Res>
    implements _$ExerciseDbModelCopyWith<$Res> {
  __$ExerciseDbModelCopyWithImpl(this._self, this._then);

  final _ExerciseDbModel _self;
  final $Res Function(_ExerciseDbModel) _then;

/// Create a copy of ExerciseDbModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameKo = null,Object? nameEn = null,Object? equipment = null,Object? equipmentEn = null,Object? primaryMuscle = null,Object? secondaryMuscles = null,Object? level = null,Object? force = freezed,Object? mechanic = freezed,Object? instructions = null,Object? imageUrl = freezed,Object? tags = null,}) {
  return _then(_ExerciseDbModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nameKo: null == nameKo ? _self.nameKo : nameKo // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,equipment: null == equipment ? _self.equipment : equipment // ignore: cast_nullable_to_non_nullable
as String,equipmentEn: null == equipmentEn ? _self.equipmentEn : equipmentEn // ignore: cast_nullable_to_non_nullable
as String,primaryMuscle: null == primaryMuscle ? _self.primaryMuscle : primaryMuscle // ignore: cast_nullable_to_non_nullable
as String,secondaryMuscles: null == secondaryMuscles ? _self._secondaryMuscles : secondaryMuscles // ignore: cast_nullable_to_non_nullable
as List<String>,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,force: freezed == force ? _self.force : force // ignore: cast_nullable_to_non_nullable
as String?,mechanic: freezed == mechanic ? _self.mechanic : mechanic // ignore: cast_nullable_to_non_nullable
as String?,instructions: null == instructions ? _self._instructions : instructions // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
