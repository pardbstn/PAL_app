// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diet_analysis_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DietAnalysisModel {

/// 문서 ID
 String get id;/// 회원 ID
 String get memberId;/// 식사 유형
 MealType get mealType;/// 이미지 URL
 String get imageUrl;/// 음식 이름
 String get foodName;/// 칼로리 (kcal)
 int get calories;/// 단백질 (g)
 double get protein;/// 탄수화물 (g)
 double get carbs;/// 지방 (g)
 double get fat;/// AI 분석 신뢰도 (0.0 ~ 1.0)
 double get confidence;/// 분석 일시
@TimestampConverter() DateTime get analyzedAt;/// 생성 일시
@TimestampConverter() DateTime? get createdAt;
/// Create a copy of DietAnalysisModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DietAnalysisModelCopyWith<DietAnalysisModel> get copyWith => _$DietAnalysisModelCopyWithImpl<DietAnalysisModel>(this as DietAnalysisModel, _$identity);

  /// Serializes this DietAnalysisModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DietAnalysisModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,mealType,imageUrl,foodName,calories,protein,carbs,fat,confidence,analyzedAt,createdAt);

@override
String toString() {
  return 'DietAnalysisModel(id: $id, memberId: $memberId, mealType: $mealType, imageUrl: $imageUrl, foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, confidence: $confidence, analyzedAt: $analyzedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DietAnalysisModelCopyWith<$Res>  {
  factory $DietAnalysisModelCopyWith(DietAnalysisModel value, $Res Function(DietAnalysisModel) _then) = _$DietAnalysisModelCopyWithImpl;
@useResult
$Res call({
 String id, String memberId, MealType mealType, String imageUrl, String foodName, int calories, double protein, double carbs, double fat, double confidence,@TimestampConverter() DateTime analyzedAt,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class _$DietAnalysisModelCopyWithImpl<$Res>
    implements $DietAnalysisModelCopyWith<$Res> {
  _$DietAnalysisModelCopyWithImpl(this._self, this._then);

  final DietAnalysisModel _self;
  final $Res Function(DietAnalysisModel) _then;

/// Create a copy of DietAnalysisModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? memberId = null,Object? mealType = null,Object? imageUrl = null,Object? foodName = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? confidence = null,Object? analyzedAt = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DietAnalysisModel].
extension DietAnalysisModelPatterns on DietAnalysisModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DietAnalysisModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DietAnalysisModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DietAnalysisModel value)  $default,){
final _that = this;
switch (_that) {
case _DietAnalysisModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DietAnalysisModel value)?  $default,){
final _that = this;
switch (_that) {
case _DietAnalysisModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String memberId,  MealType mealType,  String imageUrl,  String foodName,  int calories,  double protein,  double carbs,  double fat,  double confidence, @TimestampConverter()  DateTime analyzedAt, @TimestampConverter()  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DietAnalysisModel() when $default != null:
return $default(_that.id,_that.memberId,_that.mealType,_that.imageUrl,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.analyzedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String memberId,  MealType mealType,  String imageUrl,  String foodName,  int calories,  double protein,  double carbs,  double fat,  double confidence, @TimestampConverter()  DateTime analyzedAt, @TimestampConverter()  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DietAnalysisModel():
return $default(_that.id,_that.memberId,_that.mealType,_that.imageUrl,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.analyzedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String memberId,  MealType mealType,  String imageUrl,  String foodName,  int calories,  double protein,  double carbs,  double fat,  double confidence, @TimestampConverter()  DateTime analyzedAt, @TimestampConverter()  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DietAnalysisModel() when $default != null:
return $default(_that.id,_that.memberId,_that.mealType,_that.imageUrl,_that.foodName,_that.calories,_that.protein,_that.carbs,_that.fat,_that.confidence,_that.analyzedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DietAnalysisModel implements DietAnalysisModel {
  const _DietAnalysisModel({required this.id, required this.memberId, required this.mealType, required this.imageUrl, required this.foodName, required this.calories, required this.protein, required this.carbs, required this.fat, this.confidence = 0.5, @TimestampConverter() required this.analyzedAt, @TimestampConverter() this.createdAt});
  factory _DietAnalysisModel.fromJson(Map<String, dynamic> json) => _$DietAnalysisModelFromJson(json);

/// 문서 ID
@override final  String id;
/// 회원 ID
@override final  String memberId;
/// 식사 유형
@override final  MealType mealType;
/// 이미지 URL
@override final  String imageUrl;
/// 음식 이름
@override final  String foodName;
/// 칼로리 (kcal)
@override final  int calories;
/// 단백질 (g)
@override final  double protein;
/// 탄수화물 (g)
@override final  double carbs;
/// 지방 (g)
@override final  double fat;
/// AI 분석 신뢰도 (0.0 ~ 1.0)
@override@JsonKey() final  double confidence;
/// 분석 일시
@override@TimestampConverter() final  DateTime analyzedAt;
/// 생성 일시
@override@TimestampConverter() final  DateTime? createdAt;

/// Create a copy of DietAnalysisModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DietAnalysisModelCopyWith<_DietAnalysisModel> get copyWith => __$DietAnalysisModelCopyWithImpl<_DietAnalysisModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DietAnalysisModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DietAnalysisModel&&(identical(other.id, id) || other.id == id)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.mealType, mealType) || other.mealType == mealType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.foodName, foodName) || other.foodName == foodName)&&(identical(other.calories, calories) || other.calories == calories)&&(identical(other.protein, protein) || other.protein == protein)&&(identical(other.carbs, carbs) || other.carbs == carbs)&&(identical(other.fat, fat) || other.fat == fat)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,memberId,mealType,imageUrl,foodName,calories,protein,carbs,fat,confidence,analyzedAt,createdAt);

@override
String toString() {
  return 'DietAnalysisModel(id: $id, memberId: $memberId, mealType: $mealType, imageUrl: $imageUrl, foodName: $foodName, calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, confidence: $confidence, analyzedAt: $analyzedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DietAnalysisModelCopyWith<$Res> implements $DietAnalysisModelCopyWith<$Res> {
  factory _$DietAnalysisModelCopyWith(_DietAnalysisModel value, $Res Function(_DietAnalysisModel) _then) = __$DietAnalysisModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String memberId, MealType mealType, String imageUrl, String foodName, int calories, double protein, double carbs, double fat, double confidence,@TimestampConverter() DateTime analyzedAt,@TimestampConverter() DateTime? createdAt
});




}
/// @nodoc
class __$DietAnalysisModelCopyWithImpl<$Res>
    implements _$DietAnalysisModelCopyWith<$Res> {
  __$DietAnalysisModelCopyWithImpl(this._self, this._then);

  final _DietAnalysisModel _self;
  final $Res Function(_DietAnalysisModel) _then;

/// Create a copy of DietAnalysisModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? memberId = null,Object? mealType = null,Object? imageUrl = null,Object? foodName = null,Object? calories = null,Object? protein = null,Object? carbs = null,Object? fat = null,Object? confidence = null,Object? analyzedAt = null,Object? createdAt = freezed,}) {
  return _then(_DietAnalysisModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,mealType: null == mealType ? _self.mealType : mealType // ignore: cast_nullable_to_non_nullable
as MealType,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,foodName: null == foodName ? _self.foodName : foodName // ignore: cast_nullable_to_non_nullable
as String,calories: null == calories ? _self.calories : calories // ignore: cast_nullable_to_non_nullable
as int,protein: null == protein ? _self.protein : protein // ignore: cast_nullable_to_non_nullable
as double,carbs: null == carbs ? _self.carbs : carbs // ignore: cast_nullable_to_non_nullable
as double,fat: null == fat ? _self.fat : fat // ignore: cast_nullable_to_non_nullable
as double,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
mixin _$DailyNutritionSummary {

 DateTime get date; int get totalCalories; double get totalProtein; double get totalCarbs; double get totalFat; List<DietAnalysisModel> get records;
/// Create a copy of DailyNutritionSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailyNutritionSummaryCopyWith<DailyNutritionSummary> get copyWith => _$DailyNutritionSummaryCopyWithImpl<DailyNutritionSummary>(this as DailyNutritionSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailyNutritionSummary&&(identical(other.date, date) || other.date == date)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other.records, records));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalCalories,totalProtein,totalCarbs,totalFat,const DeepCollectionEquality().hash(records));

@override
String toString() {
  return 'DailyNutritionSummary(date: $date, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat, records: $records)';
}


}

/// @nodoc
abstract mixin class $DailyNutritionSummaryCopyWith<$Res>  {
  factory $DailyNutritionSummaryCopyWith(DailyNutritionSummary value, $Res Function(DailyNutritionSummary) _then) = _$DailyNutritionSummaryCopyWithImpl;
@useResult
$Res call({
 DateTime date, int totalCalories, double totalProtein, double totalCarbs, double totalFat, List<DietAnalysisModel> records
});




}
/// @nodoc
class _$DailyNutritionSummaryCopyWithImpl<$Res>
    implements $DailyNutritionSummaryCopyWith<$Res> {
  _$DailyNutritionSummaryCopyWithImpl(this._self, this._then);

  final DailyNutritionSummary _self;
  final $Res Function(DailyNutritionSummary) _then;

/// Create a copy of DailyNutritionSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? totalCalories = null,Object? totalProtein = null,Object? totalCarbs = null,Object? totalFat = null,Object? records = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as int,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,records: null == records ? _self.records : records // ignore: cast_nullable_to_non_nullable
as List<DietAnalysisModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [DailyNutritionSummary].
extension DailyNutritionSummaryPatterns on DailyNutritionSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailyNutritionSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailyNutritionSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailyNutritionSummary value)  $default,){
final _that = this;
switch (_that) {
case _DailyNutritionSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailyNutritionSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DailyNutritionSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  int totalCalories,  double totalProtein,  double totalCarbs,  double totalFat,  List<DietAnalysisModel> records)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailyNutritionSummary() when $default != null:
return $default(_that.date,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.records);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  int totalCalories,  double totalProtein,  double totalCarbs,  double totalFat,  List<DietAnalysisModel> records)  $default,) {final _that = this;
switch (_that) {
case _DailyNutritionSummary():
return $default(_that.date,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.records);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  int totalCalories,  double totalProtein,  double totalCarbs,  double totalFat,  List<DietAnalysisModel> records)?  $default,) {final _that = this;
switch (_that) {
case _DailyNutritionSummary() when $default != null:
return $default(_that.date,_that.totalCalories,_that.totalProtein,_that.totalCarbs,_that.totalFat,_that.records);case _:
  return null;

}
}

}

/// @nodoc


class _DailyNutritionSummary implements DailyNutritionSummary {
  const _DailyNutritionSummary({required this.date, this.totalCalories = 0, this.totalProtein = 0.0, this.totalCarbs = 0.0, this.totalFat = 0.0, final  List<DietAnalysisModel> records = const []}): _records = records;
  

@override final  DateTime date;
@override@JsonKey() final  int totalCalories;
@override@JsonKey() final  double totalProtein;
@override@JsonKey() final  double totalCarbs;
@override@JsonKey() final  double totalFat;
 final  List<DietAnalysisModel> _records;
@override@JsonKey() List<DietAnalysisModel> get records {
  if (_records is EqualUnmodifiableListView) return _records;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_records);
}


/// Create a copy of DailyNutritionSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailyNutritionSummaryCopyWith<_DailyNutritionSummary> get copyWith => __$DailyNutritionSummaryCopyWithImpl<_DailyNutritionSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailyNutritionSummary&&(identical(other.date, date) || other.date == date)&&(identical(other.totalCalories, totalCalories) || other.totalCalories == totalCalories)&&(identical(other.totalProtein, totalProtein) || other.totalProtein == totalProtein)&&(identical(other.totalCarbs, totalCarbs) || other.totalCarbs == totalCarbs)&&(identical(other.totalFat, totalFat) || other.totalFat == totalFat)&&const DeepCollectionEquality().equals(other._records, _records));
}


@override
int get hashCode => Object.hash(runtimeType,date,totalCalories,totalProtein,totalCarbs,totalFat,const DeepCollectionEquality().hash(_records));

@override
String toString() {
  return 'DailyNutritionSummary(date: $date, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat, records: $records)';
}


}

/// @nodoc
abstract mixin class _$DailyNutritionSummaryCopyWith<$Res> implements $DailyNutritionSummaryCopyWith<$Res> {
  factory _$DailyNutritionSummaryCopyWith(_DailyNutritionSummary value, $Res Function(_DailyNutritionSummary) _then) = __$DailyNutritionSummaryCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, int totalCalories, double totalProtein, double totalCarbs, double totalFat, List<DietAnalysisModel> records
});




}
/// @nodoc
class __$DailyNutritionSummaryCopyWithImpl<$Res>
    implements _$DailyNutritionSummaryCopyWith<$Res> {
  __$DailyNutritionSummaryCopyWithImpl(this._self, this._then);

  final _DailyNutritionSummary _self;
  final $Res Function(_DailyNutritionSummary) _then;

/// Create a copy of DailyNutritionSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? totalCalories = null,Object? totalProtein = null,Object? totalCarbs = null,Object? totalFat = null,Object? records = null,}) {
  return _then(_DailyNutritionSummary(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,totalCalories: null == totalCalories ? _self.totalCalories : totalCalories // ignore: cast_nullable_to_non_nullable
as int,totalProtein: null == totalProtein ? _self.totalProtein : totalProtein // ignore: cast_nullable_to_non_nullable
as double,totalCarbs: null == totalCarbs ? _self.totalCarbs : totalCarbs // ignore: cast_nullable_to_non_nullable
as double,totalFat: null == totalFat ? _self.totalFat : totalFat // ignore: cast_nullable_to_non_nullable
as double,records: null == records ? _self._records : records // ignore: cast_nullable_to_non_nullable
as List<DietAnalysisModel>,
  ));
}


}

// dart format on
