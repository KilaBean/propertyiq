// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenancy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tenancy _$TenancyFromJson(Map<String, dynamic> json) => _Tenancy(
  id: json['id'] as String,
  unitId: json['unit_id'] as String,
  tenantId: json['tenant_id'] as String?,
  tenantEmail: json['tenant_email'] as String,
  rentAmount: json['rent_amount'] as num? ?? 0,
  utilityAmount: json['utility_amount'] as num? ?? 0,
  depositAmount: json['deposit_amount'] as num? ?? 0,
  emergencyContact: json['emergency_contact'] as String?,
  rentCycle:
      $enumDecodeNullable(_$RentCycleEnumMap, json['rent_cycle']) ??
      RentCycle.monthly,
  startDate: json['start_date'] == null
      ? null
      : DateTime.parse(json['start_date'] as String),
  endDate: json['end_date'] == null
      ? null
      : DateTime.parse(json['end_date'] as String),
  status:
      $enumDecodeNullable(_$TenancyStatusEnumMap, json['status']) ??
      TenancyStatus.active,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$TenancyToJson(_Tenancy instance) => <String, dynamic>{
  'id': instance.id,
  'unit_id': instance.unitId,
  'tenant_id': instance.tenantId,
  'tenant_email': instance.tenantEmail,
  'rent_amount': instance.rentAmount,
  'utility_amount': instance.utilityAmount,
  'deposit_amount': instance.depositAmount,
  'emergency_contact': instance.emergencyContact,
  'rent_cycle': _$RentCycleEnumMap[instance.rentCycle]!,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'status': _$TenancyStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$RentCycleEnumMap = {
  RentCycle.monthly: 'monthly',
  RentCycle.quarterly: 'quarterly',
  RentCycle.yearly: 'yearly',
};

const _$TenancyStatusEnumMap = {
  TenancyStatus.pending: 'pending',
  TenancyStatus.active: 'active',
  TenancyStatus.ended: 'ended',
};
