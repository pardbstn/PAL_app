// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_badge_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BadgeItem {

 String get type; String get name; String get icon;@BadgeTimestampConverter() DateTime get earnedAt;@NullableBadgeTimestampConverter() DateTime? get revokedAt;
/// Create a copy of BadgeItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BadgeItemCopyWith<BadgeItem> get copyWith => _$BadgeItemCopyWithImpl<BadgeItem>(this as BadgeItem, _$identity);

  /// Serializes this BadgeItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BadgeItem&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,icon,earnedAt,revokedAt);

@override
String toString() {
  return 'BadgeItem(type: $type, name: $name, icon: $icon, earnedAt: $earnedAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class $BadgeItemCopyWith<$Res>  {
  factory $BadgeItemCopyWith(BadgeItem value, $Res Function(BadgeItem) _then) = _$BadgeItemCopyWithImpl;
@useResult
$Res call({
 String type, String name, String icon,@BadgeTimestampConverter() DateTime earnedAt,@NullableBadgeTimestampConverter() DateTime? revokedAt
});




}
/// @nodoc
class _$BadgeItemCopyWithImpl<$Res>
    implements $BadgeItemCopyWith<$Res> {
  _$BadgeItemCopyWithImpl(this._self, this._then);

  final BadgeItem _self;
  final $Res Function(BadgeItem) _then;

/// Create a copy of BadgeItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? name = null,Object? icon = null,Object? earnedAt = null,Object? revokedAt = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BadgeItem].
extension BadgeItemPatterns on BadgeItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BadgeItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BadgeItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BadgeItem value)  $default,){
final _that = this;
switch (_that) {
case _BadgeItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BadgeItem value)?  $default,){
final _that = this;
switch (_that) {
case _BadgeItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String name,  String icon, @BadgeTimestampConverter()  DateTime earnedAt, @NullableBadgeTimestampConverter()  DateTime? revokedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BadgeItem() when $default != null:
return $default(_that.type,_that.name,_that.icon,_that.earnedAt,_that.revokedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String name,  String icon, @BadgeTimestampConverter()  DateTime earnedAt, @NullableBadgeTimestampConverter()  DateTime? revokedAt)  $default,) {final _that = this;
switch (_that) {
case _BadgeItem():
return $default(_that.type,_that.name,_that.icon,_that.earnedAt,_that.revokedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String name,  String icon, @BadgeTimestampConverter()  DateTime earnedAt, @NullableBadgeTimestampConverter()  DateTime? revokedAt)?  $default,) {final _that = this;
switch (_that) {
case _BadgeItem() when $default != null:
return $default(_that.type,_that.name,_that.icon,_that.earnedAt,_that.revokedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BadgeItem implements BadgeItem {
  const _BadgeItem({required this.type, required this.name, required this.icon, @BadgeTimestampConverter() required this.earnedAt, @NullableBadgeTimestampConverter() this.revokedAt});
  factory _BadgeItem.fromJson(Map<String, dynamic> json) => _$BadgeItemFromJson(json);

@override final  String type;
@override final  String name;
@override final  String icon;
@override@BadgeTimestampConverter() final  DateTime earnedAt;
@override@NullableBadgeTimestampConverter() final  DateTime? revokedAt;

/// Create a copy of BadgeItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BadgeItemCopyWith<_BadgeItem> get copyWith => __$BadgeItemCopyWithImpl<_BadgeItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BadgeItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadgeItem&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.earnedAt, earnedAt) || other.earnedAt == earnedAt)&&(identical(other.revokedAt, revokedAt) || other.revokedAt == revokedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,name,icon,earnedAt,revokedAt);

@override
String toString() {
  return 'BadgeItem(type: $type, name: $name, icon: $icon, earnedAt: $earnedAt, revokedAt: $revokedAt)';
}


}

/// @nodoc
abstract mixin class _$BadgeItemCopyWith<$Res> implements $BadgeItemCopyWith<$Res> {
  factory _$BadgeItemCopyWith(_BadgeItem value, $Res Function(_BadgeItem) _then) = __$BadgeItemCopyWithImpl;
@override @useResult
$Res call({
 String type, String name, String icon,@BadgeTimestampConverter() DateTime earnedAt,@NullableBadgeTimestampConverter() DateTime? revokedAt
});




}
/// @nodoc
class __$BadgeItemCopyWithImpl<$Res>
    implements _$BadgeItemCopyWith<$Res> {
  __$BadgeItemCopyWithImpl(this._self, this._then);

  final _BadgeItem _self;
  final $Res Function(_BadgeItem) _then;

/// Create a copy of BadgeItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? name = null,Object? icon = null,Object? earnedAt = null,Object? revokedAt = freezed,}) {
  return _then(_BadgeItem(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,earnedAt: null == earnedAt ? _self.earnedAt : earnedAt // ignore: cast_nullable_to_non_nullable
as DateTime,revokedAt: freezed == revokedAt ? _self.revokedAt : revokedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TrainerBadgeModel {

 String get id; List<BadgeItem> get activeBadges; List<BadgeItem> get badgeHistory;
/// Create a copy of TrainerBadgeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrainerBadgeModelCopyWith<TrainerBadgeModel> get copyWith => _$TrainerBadgeModelCopyWithImpl<TrainerBadgeModel>(this as TrainerBadgeModel, _$identity);

  /// Serializes this TrainerBadgeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrainerBadgeModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.activeBadges, activeBadges)&&const DeepCollectionEquality().equals(other.badgeHistory, badgeHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(activeBadges),const DeepCollectionEquality().hash(badgeHistory));

@override
String toString() {
  return 'TrainerBadgeModel(id: $id, activeBadges: $activeBadges, badgeHistory: $badgeHistory)';
}


}

/// @nodoc
abstract mixin class $TrainerBadgeModelCopyWith<$Res>  {
  factory $TrainerBadgeModelCopyWith(TrainerBadgeModel value, $Res Function(TrainerBadgeModel) _then) = _$TrainerBadgeModelCopyWithImpl;
@useResult
$Res call({
 String id, List<BadgeItem> activeBadges, List<BadgeItem> badgeHistory
});




}
/// @nodoc
class _$TrainerBadgeModelCopyWithImpl<$Res>
    implements $TrainerBadgeModelCopyWith<$Res> {
  _$TrainerBadgeModelCopyWithImpl(this._self, this._then);

  final TrainerBadgeModel _self;
  final $Res Function(TrainerBadgeModel) _then;

/// Create a copy of TrainerBadgeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activeBadges = null,Object? badgeHistory = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activeBadges: null == activeBadges ? _self.activeBadges : activeBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeItem>,badgeHistory: null == badgeHistory ? _self.badgeHistory : badgeHistory // ignore: cast_nullable_to_non_nullable
as List<BadgeItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrainerBadgeModel].
extension TrainerBadgeModelPatterns on TrainerBadgeModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrainerBadgeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrainerBadgeModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrainerBadgeModel value)  $default,){
final _that = this;
switch (_that) {
case _TrainerBadgeModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrainerBadgeModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrainerBadgeModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  List<BadgeItem> activeBadges,  List<BadgeItem> badgeHistory)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrainerBadgeModel() when $default != null:
return $default(_that.id,_that.activeBadges,_that.badgeHistory);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  List<BadgeItem> activeBadges,  List<BadgeItem> badgeHistory)  $default,) {final _that = this;
switch (_that) {
case _TrainerBadgeModel():
return $default(_that.id,_that.activeBadges,_that.badgeHistory);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  List<BadgeItem> activeBadges,  List<BadgeItem> badgeHistory)?  $default,) {final _that = this;
switch (_that) {
case _TrainerBadgeModel() when $default != null:
return $default(_that.id,_that.activeBadges,_that.badgeHistory);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrainerBadgeModel implements TrainerBadgeModel {
  const _TrainerBadgeModel({this.id = '', final  List<BadgeItem> activeBadges = const [], final  List<BadgeItem> badgeHistory = const []}): _activeBadges = activeBadges,_badgeHistory = badgeHistory;
  factory _TrainerBadgeModel.fromJson(Map<String, dynamic> json) => _$TrainerBadgeModelFromJson(json);

@override@JsonKey() final  String id;
 final  List<BadgeItem> _activeBadges;
@override@JsonKey() List<BadgeItem> get activeBadges {
  if (_activeBadges is EqualUnmodifiableListView) return _activeBadges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeBadges);
}

 final  List<BadgeItem> _badgeHistory;
@override@JsonKey() List<BadgeItem> get badgeHistory {
  if (_badgeHistory is EqualUnmodifiableListView) return _badgeHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_badgeHistory);
}


/// Create a copy of TrainerBadgeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrainerBadgeModelCopyWith<_TrainerBadgeModel> get copyWith => __$TrainerBadgeModelCopyWithImpl<_TrainerBadgeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrainerBadgeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrainerBadgeModel&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._activeBadges, _activeBadges)&&const DeepCollectionEquality().equals(other._badgeHistory, _badgeHistory));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_activeBadges),const DeepCollectionEquality().hash(_badgeHistory));

@override
String toString() {
  return 'TrainerBadgeModel(id: $id, activeBadges: $activeBadges, badgeHistory: $badgeHistory)';
}


}

/// @nodoc
abstract mixin class _$TrainerBadgeModelCopyWith<$Res> implements $TrainerBadgeModelCopyWith<$Res> {
  factory _$TrainerBadgeModelCopyWith(_TrainerBadgeModel value, $Res Function(_TrainerBadgeModel) _then) = __$TrainerBadgeModelCopyWithImpl;
@override @useResult
$Res call({
 String id, List<BadgeItem> activeBadges, List<BadgeItem> badgeHistory
});




}
/// @nodoc
class __$TrainerBadgeModelCopyWithImpl<$Res>
    implements _$TrainerBadgeModelCopyWith<$Res> {
  __$TrainerBadgeModelCopyWithImpl(this._self, this._then);

  final _TrainerBadgeModel _self;
  final $Res Function(_TrainerBadgeModel) _then;

/// Create a copy of TrainerBadgeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activeBadges = null,Object? badgeHistory = null,}) {
  return _then(_TrainerBadgeModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activeBadges: null == activeBadges ? _self._activeBadges : activeBadges // ignore: cast_nullable_to_non_nullable
as List<BadgeItem>,badgeHistory: null == badgeHistory ? _self._badgeHistory : badgeHistory // ignore: cast_nullable_to_non_nullable
as List<BadgeItem>,
  ));
}


}

// dart format on
