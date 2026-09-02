// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MaintenanceRequest _$MaintenanceRequestFromJson(Map<String, dynamic> json) =>
    _MaintenanceRequest(
      id: json['id'] as String,
      unitId: json['unit_id'] as String,
      tenantId: json['tenant_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category:
          $enumDecodeNullable(_$MaintenanceCategoryEnumMap, json['category']) ??
          MaintenanceCategory.other,
      priority:
          $enumDecodeNullable(_$MaintenancePriorityEnumMap, json['priority']) ??
          MaintenancePriority.medium,
      status:
          $enumDecodeNullable(_$MaintenanceStatusEnumMap, json['status']) ??
          MaintenanceStatus.open,
      aiRecommendation: json['ai_recommendation'] as String?,
      aiGenerated: json['ai_generated'] as bool? ?? false,
      photoPaths:
          (json['photo_paths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$MaintenanceRequestToJson(_MaintenanceRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'unit_id': instance.unitId,
      'tenant_id': instance.tenantId,
      'title': instance.title,
      'description': instance.description,
      'category': _$MaintenanceCategoryEnumMap[instance.category]!,
      'priority': _$MaintenancePriorityEnumMap[instance.priority]!,
      'status': _$MaintenanceStatusEnumMap[instance.status]!,
      'ai_recommendation': instance.aiRecommendation,
      'ai_generated': instance.aiGenerated,
      'photo_paths': instance.photoPaths,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$MaintenanceCategoryEnumMap = {
  MaintenanceCategory.plumbing: 'plumbing',
  MaintenanceCategory.electrical: 'electrical',
  MaintenanceCategory.structural: 'structural',
  MaintenanceCategory.hvac: 'hvac',
  MaintenanceCategory.appliance: 'appliance',
  MaintenanceCategory.pest: 'pest',
  MaintenanceCategory.other: 'other',
};

const _$MaintenancePriorityEnumMap = {
  MaintenancePriority.low: 'low',
  MaintenancePriority.medium: 'medium',
  MaintenancePriority.high: 'high',
  MaintenancePriority.urgent: 'urgent',
};

const _$MaintenanceStatusEnumMap = {
  MaintenanceStatus.open: 'open',
  MaintenanceStatus.inProgress: 'in_progress',
  MaintenanceStatus.resolved: 'resolved',
};
