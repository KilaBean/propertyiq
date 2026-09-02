// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tenancy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tenancy {

 String get id;@JsonKey(name: 'unit_id') String get unitId;@JsonKey(name: 'tenant_id') String? get tenantId;@JsonKey(name: 'tenant_email') String get tenantEmail;@JsonKey(name: 'rent_amount') num get rentAmount;@JsonKey(name: 'utility_amount') num get utilityAmount;@JsonKey(name: 'deposit_amount') num get depositAmount;@JsonKey(name: 'emergency_contact') String? get emergencyContact;@JsonKey(name: 'rent_cycle') RentCycle get rentCycle;@JsonKey(name: 'start_date') DateTime? get startDate;@JsonKey(name: 'end_date') DateTime? get endDate; TenancyStatus get status;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of Tenancy
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TenancyCopyWith<Tenancy> get copyWith => _$TenancyCopyWithImpl<Tenancy>(this as Tenancy, _$identity);

  /// Serializes this Tenancy to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tenancy&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantEmail, tenantEmail) || other.tenantEmail == tenantEmail)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.utilityAmount, utilityAmount) || other.utilityAmount == utilityAmount)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.rentCycle, rentCycle) || other.rentCycle == rentCycle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,tenantId,tenantEmail,rentAmount,utilityAmount,depositAmount,emergencyContact,rentCycle,startDate,endDate,status,createdAt,updatedAt);

@override
String toString() {
  return 'Tenancy(id: $id, unitId: $unitId, tenantId: $tenantId, tenantEmail: $tenantEmail, rentAmount: $rentAmount, utilityAmount: $utilityAmount, depositAmount: $depositAmount, emergencyContact: $emergencyContact, rentCycle: $rentCycle, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $TenancyCopyWith<$Res>  {
  factory $TenancyCopyWith(Tenancy value, $Res Function(Tenancy) _then) = _$TenancyCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'tenant_id') String? tenantId,@JsonKey(name: 'tenant_email') String tenantEmail,@JsonKey(name: 'rent_amount') num rentAmount,@JsonKey(name: 'utility_amount') num utilityAmount,@JsonKey(name: 'deposit_amount') num depositAmount,@JsonKey(name: 'emergency_contact') String? emergencyContact,@JsonKey(name: 'rent_cycle') RentCycle rentCycle,@JsonKey(name: 'start_date') DateTime? startDate,@JsonKey(name: 'end_date') DateTime? endDate, TenancyStatus status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$TenancyCopyWithImpl<$Res>
    implements $TenancyCopyWith<$Res> {
  _$TenancyCopyWithImpl(this._self, this._then);

  final Tenancy _self;
  final $Res Function(Tenancy) _then;

/// Create a copy of Tenancy
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unitId = null,Object? tenantId = freezed,Object? tenantEmail = null,Object? rentAmount = null,Object? utilityAmount = null,Object? depositAmount = null,Object? emergencyContact = freezed,Object? rentCycle = null,Object? startDate = freezed,Object? endDate = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,tenantEmail: null == tenantEmail ? _self.tenantEmail : tenantEmail // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as num,utilityAmount: null == utilityAmount ? _self.utilityAmount : utilityAmount // ignore: cast_nullable_to_non_nullable
as num,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as num,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,rentCycle: null == rentCycle ? _self.rentCycle : rentCycle // ignore: cast_nullable_to_non_nullable
as RentCycle,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TenancyStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tenancy].
extension TenancyPatterns on Tenancy {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tenancy value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tenancy() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tenancy value)  $default,){
final _that = this;
switch (_that) {
case _Tenancy():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tenancy value)?  $default,){
final _that = this;
switch (_that) {
case _Tenancy() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_email')  String tenantEmail, @JsonKey(name: 'rent_amount')  num rentAmount, @JsonKey(name: 'utility_amount')  num utilityAmount, @JsonKey(name: 'deposit_amount')  num depositAmount, @JsonKey(name: 'emergency_contact')  String? emergencyContact, @JsonKey(name: 'rent_cycle')  RentCycle rentCycle, @JsonKey(name: 'start_date')  DateTime? startDate, @JsonKey(name: 'end_date')  DateTime? endDate,  TenancyStatus status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tenancy() when $default != null:
return $default(_that.id,_that.unitId,_that.tenantId,_that.tenantEmail,_that.rentAmount,_that.utilityAmount,_that.depositAmount,_that.emergencyContact,_that.rentCycle,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_email')  String tenantEmail, @JsonKey(name: 'rent_amount')  num rentAmount, @JsonKey(name: 'utility_amount')  num utilityAmount, @JsonKey(name: 'deposit_amount')  num depositAmount, @JsonKey(name: 'emergency_contact')  String? emergencyContact, @JsonKey(name: 'rent_cycle')  RentCycle rentCycle, @JsonKey(name: 'start_date')  DateTime? startDate, @JsonKey(name: 'end_date')  DateTime? endDate,  TenancyStatus status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Tenancy():
return $default(_that.id,_that.unitId,_that.tenantId,_that.tenantEmail,_that.rentAmount,_that.utilityAmount,_that.depositAmount,_that.emergencyContact,_that.rentCycle,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String? tenantId, @JsonKey(name: 'tenant_email')  String tenantEmail, @JsonKey(name: 'rent_amount')  num rentAmount, @JsonKey(name: 'utility_amount')  num utilityAmount, @JsonKey(name: 'deposit_amount')  num depositAmount, @JsonKey(name: 'emergency_contact')  String? emergencyContact, @JsonKey(name: 'rent_cycle')  RentCycle rentCycle, @JsonKey(name: 'start_date')  DateTime? startDate, @JsonKey(name: 'end_date')  DateTime? endDate,  TenancyStatus status, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Tenancy() when $default != null:
return $default(_that.id,_that.unitId,_that.tenantId,_that.tenantEmail,_that.rentAmount,_that.utilityAmount,_that.depositAmount,_that.emergencyContact,_that.rentCycle,_that.startDate,_that.endDate,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tenancy implements Tenancy {
  const _Tenancy({required this.id, @JsonKey(name: 'unit_id') required this.unitId, @JsonKey(name: 'tenant_id') this.tenantId, @JsonKey(name: 'tenant_email') required this.tenantEmail, @JsonKey(name: 'rent_amount') this.rentAmount = 0, @JsonKey(name: 'utility_amount') this.utilityAmount = 0, @JsonKey(name: 'deposit_amount') this.depositAmount = 0, @JsonKey(name: 'emergency_contact') this.emergencyContact, @JsonKey(name: 'rent_cycle') this.rentCycle = RentCycle.monthly, @JsonKey(name: 'start_date') this.startDate, @JsonKey(name: 'end_date') this.endDate, this.status = TenancyStatus.active, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _Tenancy.fromJson(Map<String, dynamic> json) => _$TenancyFromJson(json);

@override final  String id;
@override@JsonKey(name: 'unit_id') final  String unitId;
@override@JsonKey(name: 'tenant_id') final  String? tenantId;
@override@JsonKey(name: 'tenant_email') final  String tenantEmail;
@override@JsonKey(name: 'rent_amount') final  num rentAmount;
@override@JsonKey(name: 'utility_amount') final  num utilityAmount;
@override@JsonKey(name: 'deposit_amount') final  num depositAmount;
@override@JsonKey(name: 'emergency_contact') final  String? emergencyContact;
@override@JsonKey(name: 'rent_cycle') final  RentCycle rentCycle;
@override@JsonKey(name: 'start_date') final  DateTime? startDate;
@override@JsonKey(name: 'end_date') final  DateTime? endDate;
@override@JsonKey() final  TenancyStatus status;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of Tenancy
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TenancyCopyWith<_Tenancy> get copyWith => __$TenancyCopyWithImpl<_Tenancy>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TenancyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tenancy&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.tenantEmail, tenantEmail) || other.tenantEmail == tenantEmail)&&(identical(other.rentAmount, rentAmount) || other.rentAmount == rentAmount)&&(identical(other.utilityAmount, utilityAmount) || other.utilityAmount == utilityAmount)&&(identical(other.depositAmount, depositAmount) || other.depositAmount == depositAmount)&&(identical(other.emergencyContact, emergencyContact) || other.emergencyContact == emergencyContact)&&(identical(other.rentCycle, rentCycle) || other.rentCycle == rentCycle)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,tenantId,tenantEmail,rentAmount,utilityAmount,depositAmount,emergencyContact,rentCycle,startDate,endDate,status,createdAt,updatedAt);

@override
String toString() {
  return 'Tenancy(id: $id, unitId: $unitId, tenantId: $tenantId, tenantEmail: $tenantEmail, rentAmount: $rentAmount, utilityAmount: $utilityAmount, depositAmount: $depositAmount, emergencyContact: $emergencyContact, rentCycle: $rentCycle, startDate: $startDate, endDate: $endDate, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$TenancyCopyWith<$Res> implements $TenancyCopyWith<$Res> {
  factory _$TenancyCopyWith(_Tenancy value, $Res Function(_Tenancy) _then) = __$TenancyCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'tenant_id') String? tenantId,@JsonKey(name: 'tenant_email') String tenantEmail,@JsonKey(name: 'rent_amount') num rentAmount,@JsonKey(name: 'utility_amount') num utilityAmount,@JsonKey(name: 'deposit_amount') num depositAmount,@JsonKey(name: 'emergency_contact') String? emergencyContact,@JsonKey(name: 'rent_cycle') RentCycle rentCycle,@JsonKey(name: 'start_date') DateTime? startDate,@JsonKey(name: 'end_date') DateTime? endDate, TenancyStatus status,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$TenancyCopyWithImpl<$Res>
    implements _$TenancyCopyWith<$Res> {
  __$TenancyCopyWithImpl(this._self, this._then);

  final _Tenancy _self;
  final $Res Function(_Tenancy) _then;

/// Create a copy of Tenancy
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unitId = null,Object? tenantId = freezed,Object? tenantEmail = null,Object? rentAmount = null,Object? utilityAmount = null,Object? depositAmount = null,Object? emergencyContact = freezed,Object? rentCycle = null,Object? startDate = freezed,Object? endDate = freezed,Object? status = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Tenancy(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,tenantId: freezed == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String?,tenantEmail: null == tenantEmail ? _self.tenantEmail : tenantEmail // ignore: cast_nullable_to_non_nullable
as String,rentAmount: null == rentAmount ? _self.rentAmount : rentAmount // ignore: cast_nullable_to_non_nullable
as num,utilityAmount: null == utilityAmount ? _self.utilityAmount : utilityAmount // ignore: cast_nullable_to_non_nullable
as num,depositAmount: null == depositAmount ? _self.depositAmount : depositAmount // ignore: cast_nullable_to_non_nullable
as num,emergencyContact: freezed == emergencyContact ? _self.emergencyContact : emergencyContact // ignore: cast_nullable_to_non_nullable
as String?,rentCycle: null == rentCycle ? _self.rentCycle : rentCycle // ignore: cast_nullable_to_non_nullable
as RentCycle,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TenancyStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
