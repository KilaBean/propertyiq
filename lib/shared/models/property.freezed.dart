// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'property.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Property {

 String get id;@JsonKey(name: 'manager_id') String get managerId; String get name; String? get address; String get currency;@JsonKey(name: 'photo_path') String? get photoPath;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertyCopyWith<Property> get copyWith => _$PropertyCopyWithImpl<Property>(this as Property, _$identity);

  /// Serializes this Property to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Property&&(identical(other.id, id) || other.id == id)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,managerId,name,address,currency,photoPath,createdAt,updatedAt);

@override
String toString() {
  return 'Property(id: $id, managerId: $managerId, name: $name, address: $address, currency: $currency, photoPath: $photoPath, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PropertyCopyWith<$Res>  {
  factory $PropertyCopyWith(Property value, $Res Function(Property) _then) = _$PropertyCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'manager_id') String managerId, String name, String? address, String currency,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$PropertyCopyWithImpl<$Res>
    implements $PropertyCopyWith<$Res> {
  _$PropertyCopyWithImpl(this._self, this._then);

  final Property _self;
  final $Res Function(Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? managerId = null,Object? name = null,Object? address = freezed,Object? currency = null,Object? photoPath = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,managerId: null == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Property].
extension PropertyPatterns on Property {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Property value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Property value)  $default,){
final _that = this;
switch (_that) {
case _Property():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Property value)?  $default,){
final _that = this;
switch (_that) {
case _Property() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'manager_id')  String managerId,  String name,  String? address,  String currency, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.managerId,_that.name,_that.address,_that.currency,_that.photoPath,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'manager_id')  String managerId,  String name,  String? address,  String currency, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Property():
return $default(_that.id,_that.managerId,_that.name,_that.address,_that.currency,_that.photoPath,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'manager_id')  String managerId,  String name,  String? address,  String currency, @JsonKey(name: 'photo_path')  String? photoPath, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Property() when $default != null:
return $default(_that.id,_that.managerId,_that.name,_that.address,_that.currency,_that.photoPath,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Property implements Property {
  const _Property({required this.id, @JsonKey(name: 'manager_id') required this.managerId, required this.name, this.address, this.currency = 'GHS', @JsonKey(name: 'photo_path') this.photoPath, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);

@override final  String id;
@override@JsonKey(name: 'manager_id') final  String managerId;
@override final  String name;
@override final  String? address;
@override@JsonKey() final  String currency;
@override@JsonKey(name: 'photo_path') final  String? photoPath;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertyCopyWith<_Property> get copyWith => __$PropertyCopyWithImpl<_Property>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Property&&(identical(other.id, id) || other.id == id)&&(identical(other.managerId, managerId) || other.managerId == managerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.photoPath, photoPath) || other.photoPath == photoPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,managerId,name,address,currency,photoPath,createdAt,updatedAt);

@override
String toString() {
  return 'Property(id: $id, managerId: $managerId, name: $name, address: $address, currency: $currency, photoPath: $photoPath, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PropertyCopyWith<$Res> implements $PropertyCopyWith<$Res> {
  factory _$PropertyCopyWith(_Property value, $Res Function(_Property) _then) = __$PropertyCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'manager_id') String managerId, String name, String? address, String currency,@JsonKey(name: 'photo_path') String? photoPath,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$PropertyCopyWithImpl<$Res>
    implements _$PropertyCopyWith<$Res> {
  __$PropertyCopyWithImpl(this._self, this._then);

  final _Property _self;
  final $Res Function(_Property) _then;

/// Create a copy of Property
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? managerId = null,Object? name = null,Object? address = freezed,Object? currency = null,Object? photoPath = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Property(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,managerId: null == managerId ? _self.managerId : managerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,photoPath: freezed == photoPath ? _self.photoPath : photoPath // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
