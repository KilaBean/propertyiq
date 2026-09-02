import 'package:freezed_annotation/freezed_annotation.dart';

import 'rent_cycle.dart';
import 'tenancy_status.dart';

part 'tenancy.freezed.dart';
part 'tenancy.g.dart';

/// A lease: links a unit to a tenant with rent terms. Mirrors
/// `public.tenancies`. `tenantId` is null until the invited tenant signs up.
@freezed
abstract class Tenancy with _$Tenancy {
  const factory Tenancy({
    required String id,
    @JsonKey(name: 'unit_id') required String unitId,
    @JsonKey(name: 'tenant_id') String? tenantId,
    @JsonKey(name: 'tenant_email') required String tenantEmail,
    @JsonKey(name: 'rent_amount') @Default(0) num rentAmount,
    @JsonKey(name: 'utility_amount') @Default(0) num utilityAmount,
    @JsonKey(name: 'deposit_amount') @Default(0) num depositAmount,
    @JsonKey(name: 'emergency_contact') String? emergencyContact,
    @JsonKey(name: 'rent_cycle') @Default(RentCycle.monthly) RentCycle rentCycle,
    @JsonKey(name: 'start_date') DateTime? startDate,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @Default(TenancyStatus.active) TenancyStatus status,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Tenancy;

  factory Tenancy.fromJson(Map<String, dynamic> json) =>
      _$TenancyFromJson(json);
}
