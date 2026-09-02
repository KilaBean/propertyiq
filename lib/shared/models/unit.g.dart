// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Unit _$UnitFromJson(Map<String, dynamic> json) => _Unit(
  id: json['id'] as String,
  propertyId: json['property_id'] as String,
  label: json['label'] as String,
  bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
  baseRent: json['base_rent'] as num? ?? 0,
  status:
      $enumDecodeNullable(_$UnitStatusEnumMap, json['status']) ??
      UnitStatus.vacant,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UnitToJson(_Unit instance) => <String, dynamic>{
  'id': instance.id,
  'property_id': instance.propertyId,
  'label': instance.label,
  'bedrooms': instance.bedrooms,
  'base_rent': instance.baseRent,
  'status': _$UnitStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$UnitStatusEnumMap = {
  UnitStatus.vacant: 'vacant',
  UnitStatus.occupied: 'occupied',
};
