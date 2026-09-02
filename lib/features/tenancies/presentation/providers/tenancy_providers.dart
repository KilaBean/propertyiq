import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/property.dart';
import '../../../../shared/models/tenancy.dart';
import '../../../../shared/models/unit.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/tenancy_repository.dart';

part 'tenancy_providers.g.dart';

/// A tenant's active lease joined with its unit + property, for the My Unit
/// screen.
class TenantLease {
  const TenantLease({
    required this.tenancy,
    required this.unit,
    required this.property,
  });

  final Tenancy tenancy;
  final Unit unit;
  final Property property;
}

/// Live list of tenancies on a unit (manager view).
@riverpod
Stream<List<Tenancy>> tenanciesByUnit(Ref ref, String unitId) =>
    ref.watch(tenancyRepositoryProvider).watchByUnit(unitId);

/// The signed-in tenant's active lease, or null if none.
@riverpod
Future<TenantLease?> tenantLease(Ref ref) async {
  final uid = ref.watch(sessionProvider)?.user.id;
  if (uid == null) return null;

  final row = await ref.watch(tenancyRepositoryProvider).fetchActiveLease(uid);
  if (row == null) return null;

  final unitMap = row['units'] as Map<String, dynamic>;
  final propertyMap = unitMap['properties'] as Map<String, dynamic>;
  return TenantLease(
    tenancy: Tenancy.fromJson(row),
    unit: Unit.fromJson(unitMap),
    property: Property.fromJson(propertyMap),
  );
}
