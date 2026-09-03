import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/maintenance_status.dart';
import '../../data/repositories/maintenance_repository.dart';
import 'maintenance_providers.dart';

part 'maintenance_controller.g.dart';

/// Orchestrates filing a request (AI triage → insert) and status updates.
@riverpod
class MaintenanceController extends _$MaintenanceController {
  @override
  FutureOr<void> build() {}

  /// Tenant files a request: triage via Gemini, then persist with the result.
  /// Triage failures fall back to safe defaults (handled in the function), so
  /// the request is always saved.
  Future<bool> submit({
    required String unitId,
    required String tenantId,
    required String title,
    required String description,
    List<XFile> photos = const [],
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final repo = ref.read(maintenanceRepositoryProvider);
      final triage = await repo.triage(title: title, description: description);
      final id = await repo.create(
        unitId: unitId,
        tenantId: tenantId,
        title: title,
        description: description.isEmpty ? null : description,
        category: triage.category,
        priority: triage.priority,
        aiRecommendation: triage.recommendation,
        aiGenerated: triage.aiGenerated,
      );
      if (photos.isNotEmpty) {
        final paths = await repo.uploadPhotos(id, photos);
        await repo.setPhotoPaths(id, paths);
      }
    });
    if (ref.mounted) {
      state = result;
      if (!result.hasError) {
        ref.invalidate(tenantRequestsProvider);
        ref.invalidate(managerRequestsProvider);
      }
    }
    return !result.hasError;
  }

  /// Manager updates the request status.
  Future<bool> setStatus(String id, MaintenanceStatus status) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(maintenanceRepositoryProvider).updateStatus(id, status),
    );
    if (ref.mounted) {
      state = result;
      if (!result.hasError) {
        // The new value is already known, so patch it into whatever pages
        // are currently loaded rather than invalidating and re-fetching all
        // of them (managerRequestsProvider is paginated -- see
        // maintenance_providers.dart) for a change to a single row.
        ref.read(managerRequestsProvider.notifier).patchStatus(id, status);
        ref.invalidate(maintenanceDetailProvider(id));
      }
    }
    return !result.hasError;
  }
}
