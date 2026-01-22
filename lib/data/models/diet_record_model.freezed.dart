// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diet_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AiAnalysis {

/// AI가 인식한 음식명
 String? get foodName;/// 칼로리 (kcal)
 double? get calories;/// 단백질 (g)
 double? get protein;/// 탄수화물 (g)
 double? get carbs;/// 지방 (g)
 double? get fat;/// 분석 신뢰도 (0.0 ~ 1.0)
 double? get confidence;/// AI 피드백 메시지
 String? get feedback;
/// Create a copy of AiAnalysis
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiAnalysisCopyWith<AiAnalysis> get copyWith => _$AiAnalysisCopyWithImpl<AiAnalysis>(this as AiAnalysis, _$identity);

  /// Serializes this AiAnalysis to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiAnalysis&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,calories,protein,carbs,fat,confidence,feedback);

@override
String toString() {
  return 'AiAnalysis(foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, confidence: $confidence, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class $AiAnalysisCopyWith<$Res>  {
  factory $AiAnalysisCopyWith(AiAnalysis value, $Res Function(AiAnalysis) _then) = _$AiAnalysisCopyWithImpl;
@useResult
$Res call({
 String? foodName, double? calories, double? protein, double? carbs, double? fat, double? confidence, String? feedback
});




}
/// @nodoc
class _$AiAnalysisCopyWithImpl<$Res>
    implements $AiAnalysisCopyWith<$Res> {
  _$AiAnalysisCopyWithImpl(this._self, this._then);

  final AiAnalysis _self;
  final $Res Function(AiAnalysis) _then;

/// Create a copy of AiAnalysis
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? foodName = freezed,Object? calories = freezed,Object? protein = freezed,Object? carbs = freezed,Object? fat = freezed,Object? confidence = freezed,Object? feedback = freezed,}) {
  return _then(_self.copyWith(
foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AiAnalysis].
extension AiAnalysisPatterns on AiAnalysis {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiAnalysis value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiAnalysis() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiAnalysis value)  $default,){
final _that = this;
switch (_that) {
case _AiAnalysis():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiAnalysis value)?  $default,){
final _that = this;
switch (_that) {
case _AiAnalysis() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? foodName,  double? calories,  double? protein,  double? carbs,  double? fat,  double? confidence,  String? feedback)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiAnalysis() when $default != null:
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.feedback);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? foodName,  double? calories,  double? protein,  double? carbs,  double? fat,  double? confidence,  String? feedback)  $default,) {final _that = this;
switch (_that) {
case _AiAnalysis():
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.feedback);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? foodName,  double? calories,  double? protein,  double? carbs,  double? fat,  double? confidence,  String? feedback)?  $default,) {final _that = this;
switch (_that) {
case _AiAnalysis() when $default != null:
return $default(_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.feedback);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AiAnalysis implements AiAnalysis {
  const _AiAnalysis({this.foodName, this.calories, this.protein, this.carbs, this.fat, this.confidence, this.feedback});
  factory _AiAnalysis.fromJson(Map<String, dynamic> json) => _$AiAnalysisFromJson(json);

/// AI가 인식한 음식명
@override final  String? foodName;
/// 칼로리 (kcal)
@override final  double? calories;
/// 단백질 (g)
@override final  double? protein;
/// 탄수화물 (g)
@override final  double? carbs;
/// 지방 (g)
@override final  double? fat;
/// 분석 신뢰도 (0.0 ~ 1.0)
@override final  double? confidence;
/// AI 피드백 메시지
@override final  String? feedback;

/// Create a copy of AiAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiAnalysisCopyWith<_AiAnalysis> get copyWith => __$AiAnalysisCopyWithImpl<_AiAnalysis>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AiAnalysisToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiAnalysis&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.feedback, feedback) || other.feedback == feedback));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,foodName,calories,protein,carbs,fat,confidence,feedback);

@override
String toString() {
  return 'AiAnalysis(foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, confidence: $confidence, feedback: $feedback)';
}


}

/// @nodoc
abstract mixin class _$AiAnalysisCopyWith<$Res> implements $AiAnalysisCopyWith<$Res> {
  factory _$AiAnalysisCopyWith(_AiAnalysis value, $Res Function(_AiAnalysis) _then) = __$AiAnalysisCopyWithImpl;
@override @useResult
$Res call({
 String? foodName, double? calories, double? protein, double? carbs, double? fat, double? confidence, String? feedback
});




}
/// @nodoc
class __$AiAnalysisCopyWithImpl<$Res>
    implements _$AiAnalysisCopyWith<$Res> {
  __$AiAnalysisCopyWithImpl(this._self, this._then);

  final _AiAnalysis _self;
  final $Res Function(_AiAnalysis) _then;

/// Create a copy of AiAnalysis
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? foodName = freezed,Object? calories = freezed,Object? protein = freezed,Object? carbs = freezed,Object? fat = freezed,Object? confidence = freezed,Object? feedback = freezed,}) {
  return _then(_AiAnalysis(
foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,confidence: freezed == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double?,feedback: freezed == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$DietRecordModel {

/// 기록 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 기록 날짜
@TimestampConverter() DateTime get recordDate;/// 식사 타입 ('breakfast'|'lunch'|'dinner'|'snack')
 MealType get mealType;/// 식단 사진 URL (Supabase)
 String? get imageUrl;/// 음식 설명 (수동 입력)
 String? get description;/// AI 분석 결과
 AiAnalysis? get aiAnalysis;/// 메모
 String? get note;/// 로컬 DB 음식 ID (음식 검색으로 추가된 경우)
 String? get foodId;/// 수량 배수 (기본 1.0, 예: 0.5 = 반 인분)
 double get servingMultiplier;/// 입력 방식 (search: 검색, ai: AI분석, manual: 수동입력)
 String get inputType;/// 음식명 (검색으로 추가된 경우 저장)
 String? get foodName;/// 칼로리 (검색/수동 입력 시 직접 저장)
 double? get calories;/// 탄수화물 (g)
 double? get carbs;/// 단백질 (g)
 double? get protein;/// 지방 (g)
 double? get fat;/// 생성일
@TimestampConverter() DateTime get createdAt;/// 수정일
@TimestampConverter() DateTime get updatedAt;
/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DietRecordModelCopyWith<DietRecordModel> get copyWith => _$DietRecordModelCopyWithImpl<DietRecordModel>(this as DietRecordModel, _$identity);

  /// Serializes this DietRecordModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DietRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.aiAnalysis, aiAnalysis) || other.aiAnalysis == aiAnalysis)&&(identical(other.note, note) || other.note == note)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.servingMultiplier, servingMultiplier) || other.servingMultiplier == servingMultiplier)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,recordDate,mealType,imageUrl,description,aiAnalysis,note,foodId,servingMultiplier,inputType,foodName,calories,carbs,protein,fat,createdAt,updatedAt);

@override
String toString() {
  return 'DietRecordModel(id: $id, memberId: $memberId, recordDate: $recordDate, mealType: $mealType, imageUrl: $imageUrl, description: $description, aiAnalysis: $aiAnalysis, note: $note, foodId: $foodId, servingMultiplier: $servingMultiplier, inputType: $inputType, foodName: $foodName, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DietRecordModelCopyWith<$Res>  {
  factory $DietRecordModelCopyWith(DietRecordModel value, $Res Function(DietRecordModel) _then) = _$DietRecordModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime recordDate, MealType mealType, String? imageUrl, String? description, AiAnalysis? aiAnalysis, String? note, String? foodId, double servingMultiplier, String inputType, String? foodName, double? calories, double? carbs, double? protein, double? fat,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


$AiAnalysisCopyWith<$Res>? get aiAnalysis;

}
/// @nodoc
class _$DietRecordModelCopyWithImpl<$Res>
    implements $DietRecordModelCopyWith<$Res> {
  _$DietRecordModelCopyWithImpl(this._self, this._then);

  final DietRecordModel _self;
  final $Res Function(DietRecordModel) _then;

/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? recordDate = null,Object? mealType = null,Object? imageUrl = freezed,Object? description = freezed,Object? aiAnalysis = freezed,Object? note = freezed,Object? foodId = freezed,Object? servingMultiplier = null,Object? inputType = null,Object? foodName = freezed,Object? calories = freezed,Object? carbs = freezed,Object? protein = freezed,Object? fat = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,aiAnalysis: freezed == aiAnalysis ? _self.aiAnalysis : aiAnalysis // ignore: cast_nullable_to_non_nullable
as AiAnalysis?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,servingMultiplier: null == servingMultiplier ? _self.servingMultiplier : servingMultiplier // ignore: cast_nullable_to_non_nullable
as double,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as String,foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiAnalysisCopyWith<$Res>? get aiAnalysis {
    if (_self.aiAnalysis == null) {
    return null;
  }

  return $AiAnalysisCopyWith<$Res>(_self.aiAnalysis!, (value) {
    return _then(_self.copyWith(aiAnalysis: value));
  });
}
}


/// Adds pattern-matching-related methods to [DietRecordModel].
extension DietRecordModelPatterns on DietRecordModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DietRecordModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DietRecordModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DietRecordModel value)  $default,){
final _that = this;
switch (_that) {
case _DietRecordModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DietRecordModel value)?  $default,){
final _that = this;
switch (_that) {
case _DietRecordModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  MealType mealType,  String? imageUrl,  String? description,  AiAnalysis? aiAnalysis,  String? note,  String? foodId,  double servingMultiplier,  String inputType,  String? foodName,  double? calories,  double? carbs,  double? protein,  double? fat, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DietRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.recordDate,_that.mealType,_that.imageUrl,_that.description,_that.aiAnalysis,_that.note,_that.foodId,_that.servingMultiplier,_that.inputType,_that.foodName,_that.calories,_that.carbs,_that.protein,_that.fat,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  MealType mealType,  String? imageUrl,  String? description,  AiAnalysis? aiAnalysis,  String? note,  String? foodId,  double servingMultiplier,  String inputType,  String? foodName,  double? calories,  double? carbs,  double? protein,  double? fat, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DietRecordModel():
return $default(_that.id,_that.memberId,_that.recordDate,_that.mealType,_that.imageUrl,_that.description,_that.aiAnalysis,_that.note,_that.foodId,_that.servingMultiplier,_that.inputType,_that.foodName,_that.calories,_that.carbs,_that.protein,_that.fat,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId, @TimestampConverter()  DateTime recordDate,  MealType mealType,  String? imageUrl,  String? description,  AiAnalysis? aiAnalysis,  String? note,  String? foodId,  double servingMultiplier,  String inputType,  String? foodName,  double? calories,  double? carbs,  double? protein,  double? fat, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DietRecordModel() when $default != null:
return $default(_that.id,_that.memberId,_that.recordDate,_that.mealType,_that.imageUrl,_that.description,_that.aiAnalysis,_that.note,_that.foodId,_that.servingMultiplier,_that.inputType,_that.foodName,_that.calories,_that.carbs,_that.protein,_that.fat,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DietRecordModel implements DietRecordModel {
  const _DietRecordModel({required this.id, required this.memberId, @TimestampConverter() required this.recordDate, required this.mealType, this.imageUrl, this.description, this.aiAnalysis, this.note, this.foodId, this.servingMultiplier = 1.0, this.inputType = 'manual', this.foodName, this.calories, this.carbs, this.protein, this.fat, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt});
  factory _DietRecordModel.fromJson(Map<String, dynamic> json) => _$DietRecordModelFromJson(json);

/// 기록 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 기록 날짜
@override@TimestampConverter() final  DateTime recordDate;
/// 식사 타입 ('breakfast'|'lunch'|'dinner'|'snack')
@override final  MealType mealType;
/// 식단 사진 URL (Supabase)
@override final  String? imageUrl;
/// 음식 설명 (수동 입력)
@override final  String? description;
/// AI 분석 결과
@override final  AiAnalysis? aiAnalysis;
/// 메모
@override final  String? note;
/// 로컬 DB 음식 ID (음식 검색으로 추가된 경우)
@override final  String? foodId;
/// 수량 배수 (기본 1.0, 예: 0.5 = 반 인분)
@override@JsonKey() final  double servingMultiplier;
/// 입력 방식 (search: 검색, ai: AI분석, manual: 수동입력)
@override@JsonKey() final  String inputType;
/// 음식명 (검색으로 추가된 경우 저장)
@override final  String? foodName;
/// 칼로리 (검색/수동 입력 시 직접 저장)
@override final  double? calories;
/// 탄수화물 (g)
@override final  double? carbs;
/// 단백질 (g)
@override final  double? protein;
/// 지방 (g)
@override final  double? fat;
/// 생성일
@override@TimestampConverter() final  DateTime createdAt;
/// 수정일
@override@TimestampConverter() final  DateTime updatedAt;

/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DietRecordModelCopyWith<_DietRecordModel> get copyWith => __$DietRecordModelCopyWithImpl<_DietRecordModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DietRecordModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DietRecordModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.recordDate, recordDate) || other.recordDate == recordDate)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.aiAnalysis, aiAnalysis) || other.aiAnalysis == aiAnalysis)&&(identical(other.note, note) || other.note == note)&&(identical(other.foodId, foodId) || other.foodId == foodId)&&(identical(other.servingMultiplier, servingMultiplier) || other.servingMultiplier == servingMultiplier)&&(identical(other.inputType, inputType) || other.inputType == inputType)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,recordDate,mealType,imageUrl,description,aiAnalysis,note,foodId,servingMultiplier,inputType,foodName,calories,carbs,protein,fat,createdAt,updatedAt);

@override
String toString() {
  return 'DietRecordModel(id: $id, memberId: $memberId, recordDate: $recordDate, mealType: $mealType, imageUrl: $imageUrl, description: $description, aiAnalysis: $aiAnalysis, note: $note, foodId: $foodId, servingMultiplier: $servingMultiplier, inputType: $inputType, foodName: $foodName, calories: $calories, carbs: $carbs, protein: $protein, fat: $fat, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DietRecordModelCopyWith<$Res> implements $DietRecordModelCopyWith<$Res> {
  factory _$DietRecordModelCopyWith(_DietRecordModel value, $Res Function(_DietRecordModel) _then) = __$DietRecordModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId,@TimestampConverter() DateTime recordDate, MealType mealType, String? imageUrl, String? description, AiAnalysis? aiAnalysis, String? note, String? foodId, double servingMultiplier, String inputType, String? foodName, double? calories, double? carbs, double? protein, double? fat,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt
});


@override $AiAnalysisCopyWith<$Res>? get aiAnalysis;

}
/// @nodoc
class __$DietRecordModelCopyWithImpl<$Res>
    implements _$DietRecordModelCopyWith<$Res> {
  __$DietRecordModelCopyWithImpl(this._self, this._then);

  final _DietRecordModel _self;
  final $Res Function(_DietRecordModel) _then;

/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? recordDate = null,Object? mealType = null,Object? imageUrl = freezed,Object? description = freezed,Object? aiAnalysis = freezed,Object? note = freezed,Object? foodId = freezed,Object? servingMultiplier = null,Object? inputType = null,Object? foodName = freezed,Object? calories = freezed,Object? carbs = freezed,Object? protein = freezed,Object? fat = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_DietRecordModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,recordDate: null == recordDate ? _self.recordDate : recordDate // ignore: cast_nullable_to_non_nullable
as DateTime,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,aiAnalysis: freezed == aiAnalysis ? _self.aiAnalysis : aiAnalysis // ignore: cast_nullable_to_non_nullable
as AiAnalysis?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,foodId: freezed == foodId ? _self.foodId : foodId // ignore: cast_nullable_to_non_nullable
as String?,servingMultiplier: null == servingMultiplier ? _self.servingMultiplier : servingMultiplier // ignore: cast_nullable_to_non_nullable
as double,inputType: null == inputType ? _self.inputType : inputType // ignore: cast_nullable_to_non_nullable
as String,foodName: freezed == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String?,calories: freezed == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as double?,carbs: freezed == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double?,protein: freezed == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double?,fat: freezed == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of DietRecordModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AiAnalysisCopyWith<$Res>? get aiAnalysis {
    if (_self.aiAnalysis == null) {
    return null;
  }

  return $AiAnalysisCopyWith<$Res>(_self.aiAnalysis!, (value) {
    return _then(_self.copyWith(aiAnalysis: value));
  });
}
}

// dart format on
