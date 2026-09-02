// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Property _$PropertyFromJson(Map<String, dynamic> json) => _Property(
  id: json['id'] as String,
  managerId: json['manager_id'] as String,
  name: json['name'] as String,
  address: json['address'] as String?,
  currency: json['currency'] as String? ?? 'NGN',
  photoPath: json['photo_path'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PropertyToJson(_Property instance) => <String, dynamic>{
  'id': instance.id,
  'manager_id': instance.managerId,
  'name': instance.name,
  'address': instance.address,
  'currency': instance.currency,
  'photo_path': instance.photoPath,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
