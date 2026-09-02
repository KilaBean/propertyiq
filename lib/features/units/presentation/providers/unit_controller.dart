import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/unit_status.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/unit_repository.dart';

part 'unit_controller.g.dart';

/// Create / update / delete for units. Returns `true` on success.
@riverpod
class UnitController extends _$UnitController {
  @override
  FutureOr<void> build() {}

  Future<bool> save({
    String? id,
    required String propertyId,
    required String label,
    required int bedrooms,
    required num baseRent,
    required UnitStatus status,
  }) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() async {
      final repo = ref.read(unitRepositoryProvider);
      if (id == null) {
        await repo.create(
          propertyId: propertyId,
          label: label,
          bedrooms: bedrooms,
          baseRent: baseRent,
          status: status,
        );
      } else {
        await repo.update(
          id: id,
          label: label,
          bedrooms: bedrooms,
          baseRent: baseRent,
          status: status,
        );
      }
    });

    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(occupancyTrendProvider);
      }
    }
    return !guarded.hasError;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(
      () => ref.read(unitRepositoryProvider).delete(id),
    );
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(occupancyTrendProvider);
      }
    }
    return !guarded.hasError;
  }
}
