import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/maintenance_repository.dart';

part 'maintenance_providers.g.dart';

/// All requests across the manager's units.
@riverpod
Future<List<MaintenanceView>> managerRequests(Ref ref) =>
    ref.watch(maintenanceRepositoryProvider).fetchForManager();

/// The signed-in tenant's own requests.
@riverpod
Future<List<MaintenanceView>> tenantRequests(Ref ref) {
  final uid = ref.watch(sessionProvider)?.user.id;
  if (uid == null) return Future.value(const []);
  return ref.watch(maintenanceRepositoryProvider).fetchForTenant(uid);
}

/// A single request (RLS scopes visibility to its tenant or managing manager).
@riverpod
Future<MaintenanceView> maintenanceDetail(Ref ref, String id) =>
    ref.watch(maintenanceRepositoryProvider).fetchDetail(id);

/// A short-lived signed URL for a stored maintenance photo (cached per path).
@riverpod
Future<String> maintenancePhotoUrl(Ref ref, String path) =>
    ref.watch(maintenanceRepositoryProvider).signedPhotoUrl(path);
