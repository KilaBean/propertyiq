import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/property.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/property_repository.dart';

part 'property_providers.g.dart';

/// Live list of the signed-in manager's properties.
@riverpod
Stream<List<Property>> propertiesList(Ref ref) {
  final uid = ref.watch(sessionProvider)?.user.id;
  if (uid == null) return Stream.value(const []);
  return ref.watch(propertyRepositoryProvider).watchByManager(uid);
}

/// A single property by id (for the detail/edit screens).
@riverpod
Future<Property> propertyDetail(Ref ref, String id) =>
    ref.watch(propertyRepositoryProvider).fetch(id);

/// A short-lived signed URL for a stored property cover photo.
@riverpod
Future<String> propertyPhotoUrl(Ref ref, String path) =>
    ref.watch(propertyRepositoryProvider).signedPhotoUrl(path);
