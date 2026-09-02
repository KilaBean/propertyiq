import 'package:freezed_annotation/freezed_annotation.dart';

import 'maintenance_category.dart';
import 'maintenance_priority.dart';
import 'maintenance_status.dart';

part 'maintenance_request.freezed.dart';
part 'maintenance_request.g.dart';

/// A maintenance request filed by a tenant on their unit. Mirrors
/// `public.maintenance_requests`. AI triage fills category/priority/
/// ai_recommendation at insert time.
@freezed
abstract class MaintenanceRequest with _$MaintenanceRequest {
  const factory MaintenanceRequest({
    required String id,
    @JsonKey(name: 'unit_id') required String unitId,
    @JsonKey(name: 'tenant_id') required String tenantId,
    required String title,
    String? description,
    @Default(MaintenanceCategory.other) MaintenanceCategory category,
    @Default(MaintenancePriority.medium) MaintenancePriority priority,
    @Default(MaintenanceStatus.open) MaintenanceStatus status,
    @JsonKey(name: 'ai_recommendation') String? aiRecommendation,
    @JsonKey(name: 'ai_generated') @Default(false) bool aiGenerated,
    @JsonKey(name: 'photo_paths') @Default(<String>[]) List<String> photoPaths,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _MaintenanceRequest;

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) =>
      _$MaintenanceRequestFromJson(json);
}
