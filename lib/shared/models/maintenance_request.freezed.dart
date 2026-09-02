// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'maintenance_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MaintenanceRequest {

 String get id;@JsonKey(name: 'unit_id') String get unitId;@JsonKey(name: 'tenant_id') String get tenantId; String get title; String? get description; MaintenanceCategory get category; MaintenancePriority get priority; MaintenanceStatus get status;@JsonKey(name: 'ai_recommendation') String? get aiRecommendation;@JsonKey(name: 'ai_generated') bool get aiGenerated;@JsonKey(name: 'photo_paths') List<String> get photoPaths;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'updated_at') DateTime? get updatedAt;
/// Create a copy of MaintenanceRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaintenanceRequestCopyWith<MaintenanceRequest> get copyWith => _$MaintenanceRequestCopyWithImpl<MaintenanceRequest>(this as MaintenanceRequest, _$identity);

  /// Serializes this MaintenanceRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaintenanceRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.aiRecommendation, aiRecommendation) || other.aiRecommendation == aiRecommendation)&&(identical(other.aiGenerated, aiGenerated) || other.aiGenerated == aiGenerated)&&const DeepCollectionEquality().equals(other.photoPaths, photoPaths)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,tenantId,title,description,category,priority,status,aiRecommendation,aiGenerated,const DeepCollectionEquality().hash(photoPaths),createdAt,updatedAt);

@override
String toString() {
  return 'MaintenanceRequest(id: $id, unitId: $unitId, tenantId: $tenantId, title: $title, description: $description, category: $category, priority: $priority, status: $status, aiRecommendation: $aiRecommendation, aiGenerated: $aiGenerated, photoPaths: $photoPaths, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $MaintenanceRequestCopyWith<$Res>  {
  factory $MaintenanceRequestCopyWith(MaintenanceRequest value, $Res Function(MaintenanceRequest) _then) = _$MaintenanceRequestCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'tenant_id') String tenantId, String title, String? description, MaintenanceCategory category, MaintenancePriority priority, MaintenanceStatus status,@JsonKey(name: 'ai_recommendation') String? aiRecommendation,@JsonKey(name: 'ai_generated') bool aiGenerated,@JsonKey(name: 'photo_paths') List<String> photoPaths,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class _$MaintenanceRequestCopyWithImpl<$Res>
    implements $MaintenanceRequestCopyWith<$Res> {
  _$MaintenanceRequestCopyWithImpl(this._self, this._then);

  final MaintenanceRequest _self;
  final $Res Function(MaintenanceRequest) _then;

/// Create a copy of MaintenanceRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? unitId = null,Object? tenantId = null,Object? title = null,Object? description = freezed,Object? category = null,Object? priority = null,Object? status = null,Object? aiRecommendation = freezed,Object? aiGenerated = null,Object? photoPaths = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaintenanceCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as MaintenancePriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MaintenanceStatus,aiRecommendation: freezed == aiRecommendation ? _self.aiRecommendation : aiRecommendation // ignore: cast_nullable_to_non_nullable
as String?,aiGenerated: null == aiGenerated ? _self.aiGenerated : aiGenerated // ignore: cast_nullable_to_non_nullable
as bool,photoPaths: null == photoPaths ? _self.photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaintenanceRequest].
extension MaintenanceRequestPatterns on MaintenanceRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaintenanceRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaintenanceRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaintenanceRequest value)  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaintenanceRequest value)?  $default,){
final _that = this;
switch (_that) {
case _MaintenanceRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String tenantId,  String title,  String? description,  MaintenanceCategory category,  MaintenancePriority priority,  MaintenanceStatus status, @JsonKey(name: 'ai_recommendation')  String? aiRecommendation, @JsonKey(name: 'ai_generated')  bool aiGenerated, @JsonKey(name: 'photo_paths')  List<String> photoPaths, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaintenanceRequest() when $default != null:
return $default(_that.id,_that.unitId,_that.tenantId,_that.title,_that.description,_that.category,_that.priority,_that.status,_that.aiRecommendation,_that.aiGenerated,_that.photoPaths,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String tenantId,  String title,  String? description,  MaintenanceCategory category,  MaintenancePriority priority,  MaintenanceStatus status, @JsonKey(name: 'ai_recommendation')  String? aiRecommendation, @JsonKey(name: 'ai_generated')  bool aiGenerated, @JsonKey(name: 'photo_paths')  List<String> photoPaths, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRequest():
return $default(_that.id,_that.unitId,_that.tenantId,_that.title,_that.description,_that.category,_that.priority,_that.status,_that.aiRecommendation,_that.aiGenerated,_that.photoPaths,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'unit_id')  String unitId, @JsonKey(name: 'tenant_id')  String tenantId,  String title,  String? description,  MaintenanceCategory category,  MaintenancePriority priority,  MaintenanceStatus status, @JsonKey(name: 'ai_recommendation')  String? aiRecommendation, @JsonKey(name: 'ai_generated')  bool aiGenerated, @JsonKey(name: 'photo_paths')  List<String> photoPaths, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'updated_at')  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _MaintenanceRequest() when $default != null:
return $default(_that.id,_that.unitId,_that.tenantId,_that.title,_that.description,_that.category,_that.priority,_that.status,_that.aiRecommendation,_that.aiGenerated,_that.photoPaths,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaintenanceRequest implements MaintenanceRequest {
  const _MaintenanceRequest({required this.id, @JsonKey(name: 'unit_id') required this.unitId, @JsonKey(name: 'tenant_id') required this.tenantId, required this.title, this.description, this.category = MaintenanceCategory.other, this.priority = MaintenancePriority.medium, this.status = MaintenanceStatus.open, @JsonKey(name: 'ai_recommendation') this.aiRecommendation, @JsonKey(name: 'ai_generated') this.aiGenerated = false, @JsonKey(name: 'photo_paths') final  List<String> photoPaths = const <String>[], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _photoPaths = photoPaths;
  factory _MaintenanceRequest.fromJson(Map<String, dynamic> json) => _$MaintenanceRequestFromJson(json);

@override final  String id;
@override@JsonKey(name: 'unit_id') final  String unitId;
@override@JsonKey(name: 'tenant_id') final  String tenantId;
@override final  String title;
@override final  String? description;
@override@JsonKey() final  MaintenanceCategory category;
@override@JsonKey() final  MaintenancePriority priority;
@override@JsonKey() final  MaintenanceStatus status;
@override@JsonKey(name: 'ai_recommendation') final  String? aiRecommendation;
@override@JsonKey(name: 'ai_generated') final  bool aiGenerated;
 final  List<String> _photoPaths;
@override@JsonKey(name: 'photo_paths') List<String> get photoPaths {
  if (_photoPaths is EqualUnmodifiableListView) return _photoPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPaths);
}

@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;

/// Create a copy of MaintenanceRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaintenanceRequestCopyWith<_MaintenanceRequest> get copyWith => __$MaintenanceRequestCopyWithImpl<_MaintenanceRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaintenanceRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaintenanceRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.unitId, unitId) || other.unitId == unitId)&&(identical(other.tenantId, tenantId) || other.tenantId == tenantId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.status, status) || other.status == status)&&(identical(other.aiRecommendation, aiRecommendation) || other.aiRecommendation == aiRecommendation)&&(identical(other.aiGenerated, aiGenerated) || other.aiGenerated == aiGenerated)&&const DeepCollectionEquality().equals(other._photoPaths, _photoPaths)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,unitId,tenantId,title,description,category,priority,status,aiRecommendation,aiGenerated,const DeepCollectionEquality().hash(_photoPaths),createdAt,updatedAt);

@override
String toString() {
  return 'MaintenanceRequest(id: $id, unitId: $unitId, tenantId: $tenantId, title: $title, description: $description, category: $category, priority: $priority, status: $status, aiRecommendation: $aiRecommendation, aiGenerated: $aiGenerated, photoPaths: $photoPaths, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$MaintenanceRequestCopyWith<$Res> implements $MaintenanceRequestCopyWith<$Res> {
  factory _$MaintenanceRequestCopyWith(_MaintenanceRequest value, $Res Function(_MaintenanceRequest) _then) = __$MaintenanceRequestCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'unit_id') String unitId,@JsonKey(name: 'tenant_id') String tenantId, String title, String? description, MaintenanceCategory category, MaintenancePriority priority, MaintenanceStatus status,@JsonKey(name: 'ai_recommendation') String? aiRecommendation,@JsonKey(name: 'ai_generated') bool aiGenerated,@JsonKey(name: 'photo_paths') List<String> photoPaths,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'updated_at') DateTime? updatedAt
});




}
/// @nodoc
class __$MaintenanceRequestCopyWithImpl<$Res>
    implements _$MaintenanceRequestCopyWith<$Res> {
  __$MaintenanceRequestCopyWithImpl(this._self, this._then);

  final _MaintenanceRequest _self;
  final $Res Function(_MaintenanceRequest) _then;

/// Create a copy of MaintenanceRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? unitId = null,Object? tenantId = null,Object? title = null,Object? description = freezed,Object? category = null,Object? priority = null,Object? status = null,Object? aiRecommendation = freezed,Object? aiGenerated = null,Object? photoPaths = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_MaintenanceRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,unitId: null == unitId ? _self.unitId : unitId // ignore: cast_nullable_to_non_nullable
as String,tenantId: null == tenantId ? _self.tenantId : tenantId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as MaintenanceCategory,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as MaintenancePriority,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MaintenanceStatus,aiRecommendation: freezed == aiRecommendation ? _self.aiRecommendation : aiRecommendation // ignore: cast_nullable_to_non_nullable
as String?,aiGenerated: null == aiGenerated ? _self.aiGenerated : aiGenerated // ignore: cast_nullable_to_non_nullable
as bool,photoPaths: null == photoPaths ? _self._photoPaths : photoPaths // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
