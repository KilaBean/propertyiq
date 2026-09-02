import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/repositories/property_repository.dart';
import 'property_providers.dart';

part 'property_controller.g.dart';

/// Create / update / delete for properties. Surfaces loading/error via
/// [AsyncValue].
@riverpod
class PropertyController extends _$PropertyController {
  @override
  FutureOr<void> build() {}

  /// Creates or updates the property; returns its id on success (so a cover
  /// photo can be uploaded right after a create), or null on failure.
  Future<String?> save({
    String? id,
    required String name,
    String? address,
    required String currency,
  }) async {
    final uid = ref.read(sessionProvider)?.user.id;
    if (uid == null) return null;

    state = const AsyncLoading();
    String? resultId = id;
    final guarded = await AsyncValue.guard(() async {
      final repo = ref.read(propertyRepositoryProvider);
      if (id == null) {
        resultId = await repo.create(
          managerId: uid,
          name: name,
          address: address,
          currency: currency,
        );
      } else {
        await repo.update(
          id: id,
          name: name,
          address: address,
          currency: currency,
        );
      }
    });

    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) {
        ref.invalidate(dashboardStatsProvider);
        // The property-detail screen fetches once; on an edit it must be told
        // to refetch, or it keeps showing the pre-edit values until the
        // provider happens to be invalidated some other way.
        if (id != null) ref.invalidate(propertyDetailProvider(id));
      }
    }
    return guarded.hasError ? null : resultId;
  }

  Future<bool> uploadPhoto(String propertyId, XFile file) async {
    state = const AsyncLoading();
    String? path;
    final guarded = await AsyncValue.guard(() async {
      path = await ref
          .read(propertyRepositoryProvider)
          .uploadPhoto(propertyId, file);
    });
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError && path != null) {
        // The path is stable across re-uploads (same filename, upserted), so
        // the cached signed URL must be invalidated or the old image sticks.
        ref.invalidate(propertyPhotoUrlProvider(path!));
      }
    }
    return !guarded.hasError;
  }

  Future<bool> delete(String id) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(
      () => ref.read(propertyRepositoryProvider).delete(id),
    );
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) ref.invalidate(dashboardStatsProvider);
    }
    return !guarded.hasError;
  }
}
