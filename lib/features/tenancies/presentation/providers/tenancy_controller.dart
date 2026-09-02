import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/rent_cycle.dart';
import '../../../../shared/models/tenancy_status.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/tenancy_repository.dart';
import 'tenancy_providers.dart';

part 'tenancy_controller.g.dart';

/// Assign / update / end / delete tenancies. Returns `true` on success.
/// The realtime [tenanciesByUnit] stream reflects changes automatically;
/// derived one-shot providers (dashboard stats, occupancy trend, the tenant's
/// lease view) are invalidated explicitly since they don't watch the table.
@riverpod
class TenancyController extends _$TenancyController {
  @override
  FutureOr<void> build() {}

  TenancyRepository get _repo => ref.read(tenancyRepositoryProvider);

  void _refreshDerived() {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(occupancyTrendProvider);
    ref.invalidate(tenantLeaseProvider);
  }

  /// Invites + assigns a tenant. Returns the invite outcome, or null on
  /// failure.
  Future<TenantInvite?> assign({
    required String unitId,
    required String tenantEmail,
    required String fullName,
    required String phone,
    required num rentAmount,
    required num utilityAmount,
    required num depositAmount,
    required String emergencyContact,
    required RentCycle rentCycle,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncLoading();
    TenantInvite? result;
    final guarded = await AsyncValue.guard(() async {
      result = await _repo.create(
        unitId: unitId,
        tenantEmail: tenantEmail,
        fullName: fullName,
        phone: phone,
        rentAmount: rentAmount,
        utilityAmount: utilityAmount,
        depositAmount: depositAmount,
        emergencyContact: emergencyContact,
        rentCycle: rentCycle,
        startDate: startDate,
        endDate: endDate,
      );
    });
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) _refreshDerived();
    }
    return guarded.hasError ? null : result;
  }

  Future<bool> edit({
    required String id,
    required num rentAmount,
    required num utilityAmount,
    required num depositAmount,
    required String emergencyContact,
    required RentCycle rentCycle,
    required DateTime startDate,
    DateTime? endDate,
    required TenancyStatus status,
  }) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(
      () => _repo.update(
        id: id,
        rentAmount: rentAmount,
        utilityAmount: utilityAmount,
        depositAmount: depositAmount,
        emergencyContact: emergencyContact,
        rentCycle: rentCycle,
        startDate: startDate,
        endDate: endDate,
        status: status,
      ),
    );
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) _refreshDerived();
    }
    return !guarded.hasError;
  }

  Future<bool> end(String id) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _repo.endTenancy(id));
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) _refreshDerived();
    }
    return !guarded.hasError;
  }

  /// Emails the tenant a password-reset link. Returns the address it went to,
  /// or null on failure.
  Future<String?> sendPasswordReset({
    required String unitId,
    required String tenantId,
  }) async {
    state = const AsyncLoading();
    String? email;
    final guarded = await AsyncValue.guard(() async {
      email = await _repo.sendTenantPasswordReset(
        unitId: unitId,
        tenantId: tenantId,
      );
    });
    if (ref.mounted) state = guarded;
    return guarded.hasError ? null : email;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _repo.delete(id));
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) _refreshDerived();
    }
    return !guarded.hasError;
  }
}
