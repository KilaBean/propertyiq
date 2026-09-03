// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  fullName: json['full_name'] as String? ?? '',
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.tenant,
  phone: json['phone'] as String?,
  avatarPath: json['avatar_path'] as String?,
  mustChangePassword: json['must_change_password'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'role': _$UserRoleEnumMap[instance.role]!,
  'phone': instance.phone,
  'avatar_path': instance.avatarPath,
  'must_change_password': instance.mustChangePassword,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$UserRoleEnumMap = {
  UserRole.manager: 'manager',
  UserRole.tenant: 'tenant',
};
