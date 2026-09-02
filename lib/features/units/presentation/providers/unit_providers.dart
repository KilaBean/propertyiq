import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/unit.dart';
import '../../data/repositories/unit_repository.dart';

part 'unit_providers.g.dart';

/// Live list of units within a property.
@riverpod
Stream<List<Unit>> unitsList(Ref ref, String propertyId) =>
    ref.watch(unitRepositoryProvider).watchByProperty(propertyId);
