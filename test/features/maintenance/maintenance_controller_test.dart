import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:propertyiq/features/maintenance/presentation/providers/maintenance_controller.dart';
import 'package:propertyiq/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:propertyiq/shared/models/maintenance_category.dart';
import 'package:propertyiq/shared/models/maintenance_priority.dart';
import 'package:propertyiq/shared/models/maintenance_request.dart';
import 'package:propertyiq/shared/models/maintenance_status.dart';

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

const _triage = MaintenanceTriage(
  category: MaintenanceCategory.plumbing,
  priority: MaintenancePriority.high,
  recommendation: 'Isolate the supply and book a plumber.',
  aiGenerated: true,
);

XFile _photo(String name) => XFile.fromData(
      Uint8List.fromList([1, 2, 3]),
      name: name,
      mimeType: 'image/jpeg',
    );

void main() {
  late MockMaintenanceRepository repo;

  setUpAll(() {
    // mocktail needs a concrete instance of every non-nullable type used with
    // `any()`, so it can build a matcher without tripping null safety.
    registerFallbackValue(MaintenanceStatus.open);
    registerFallbackValue(MaintenanceCategory.other);
    registerFallbackValue(MaintenancePriority.medium);
  });

  setUp(() {
    repo = MockMaintenanceRepository();
    when(() => repo.triage(
          title: any(named: 'title'),
          description: any(named: 'description'),
        )).thenAnswer((_) async => _triage);
    when(() => repo.create(
          unitId: any(named: 'unitId'),
          tenantId: any(named: 'tenantId'),
          title: any(named: 'title'),
          description: any(named: 'description'),
          category: any(named: 'category'),
          priority: any(named: 'priority'),
          aiRecommendation: any(named: 'aiRecommendation'),
          aiGenerated: any(named: 'aiGenerated'),
        )).thenAnswer((_) async => 'request-1');
    // setStatus patches the paginated managerRequestsProvider in place
    // (see maintenance_providers.dart), which builds it against this same
    // mocked repository the first time it's read.
    when(() => repo.fetchForManager(
          offset: any(named: 'offset'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const []);
  });

  /// A container with the repository mocked, plus a listener that keeps the
  /// controller alive — Riverpod disposes an unlistened provider as soon as the
  /// read completes, which would tear it down before the state assertion.
  ProviderContainer build() {
    final container = ProviderContainer(
      overrides: [maintenanceRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(maintenanceControllerProvider, (_, _) {});
    addTearDown(sub.close);
    return container;
  }

  group('MaintenanceController.submit', () {
    test('persists the triage result alongside the request', () async {
      final container = build();

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .submit(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'Leaking sink',
            description: 'Water under the cupboard',
          );

      expect(ok, isTrue);
      verify(() => repo.triage(
            title: 'Leaking sink',
            description: 'Water under the cupboard',
          )).called(1);
      verify(() => repo.create(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'Leaking sink',
            description: 'Water under the cupboard',
            category: MaintenanceCategory.plumbing,
            priority: MaintenancePriority.high,
            aiRecommendation: 'Isolate the supply and book a plumber.',
            aiGenerated: true,
          )).called(1);
    });

    test('sends a null description rather than an empty string', () async {
      // The column is nullable; '' would render as an empty paragraph in the
      // detail view instead of being omitted.
      final container = build();

      await container.read(maintenanceControllerProvider.notifier).submit(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'No hot water',
            description: '',
          );

      verify(() => repo.create(
            unitId: any(named: 'unitId'),
            tenantId: any(named: 'tenantId'),
            title: any(named: 'title'),
            description: null,
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            aiRecommendation: any(named: 'aiRecommendation'),
            aiGenerated: any(named: 'aiGenerated'),
          )).called(1);
    });

    test('uploads photos into the new request and records their paths',
        () async {
      when(() => repo.uploadPhotos(any(), any()))
          .thenAnswer((_) async => ['request-1/0.jpg', 'request-1/1.jpg']);
      when(() => repo.setPhotoPaths(any(), any())).thenAnswer((_) async {});

      final container = build();

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .submit(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'Cracked window',
            description: '',
            photos: [_photo('a.jpg'), _photo('b.jpg')],
          );

      expect(ok, isTrue);
      // The paths are keyed by the id the insert returned, so the upload has to
      // happen after the insert, not before.
      verifyInOrder([
        () => repo.create(
              unitId: any(named: 'unitId'),
              tenantId: any(named: 'tenantId'),
              title: any(named: 'title'),
              description: any(named: 'description'),
              category: any(named: 'category'),
              priority: any(named: 'priority'),
              aiRecommendation: any(named: 'aiRecommendation'),
              aiGenerated: any(named: 'aiGenerated'),
            ),
        () => repo.uploadPhotos('request-1', any()),
        () => repo.setPhotoPaths('request-1', [
              'request-1/0.jpg',
              'request-1/1.jpg',
            ]),
      ]);
    });

    test('skips the photo round trip when there are none', () async {
      final container = build();

      await container.read(maintenanceControllerProvider.notifier).submit(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'Door handle loose',
            description: '',
          );

      verifyNever(() => repo.uploadPhotos(any(), any()));
      verifyNever(() => repo.setPhotoPaths(any(), any()));
    });

    test('reports failure and surfaces the error in state', () async {
      when(() => repo.triage(
            title: any(named: 'title'),
            description: any(named: 'description'),
          )).thenThrow(Exception('edge function down'));

      final container = build();

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .submit(
            unitId: 'unit-1',
            tenantId: 'tenant-1',
            title: 'Leak',
            description: '',
          );

      expect(ok, isFalse);
      expect(container.read(maintenanceControllerProvider).hasError, isTrue);
      // Nothing should have been written if triage blew up.
      verifyNever(() => repo.create(
            unitId: any(named: 'unitId'),
            tenantId: any(named: 'tenantId'),
            title: any(named: 'title'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            priority: any(named: 'priority'),
            aiRecommendation: any(named: 'aiRecommendation'),
            aiGenerated: any(named: 'aiGenerated'),
          ));
    });
  });

  group('MaintenanceController.setStatus', () {
    test('forwards the new status to the repository', () async {
      when(() => repo.updateStatus(any(), any())).thenAnswer((_) async {});

      final container = build();

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .setStatus('request-1', MaintenanceStatus.resolved);

      expect(ok, isTrue);
      verify(() => repo.updateStatus('request-1', MaintenanceStatus.resolved))
          .called(1);
    });

    test('patches the row already loaded, rather than re-fetching the list',
        () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [
            MaintenanceView(
              request: const MaintenanceRequest(
                id: 'request-1',
                unitId: 'unit-1',
                tenantId: 'tenant-1',
                title: 'Leaking sink',
                status: MaintenanceStatus.open,
              ),
              unitLabel: 'Flat 2B',
              propertyName: 'Lekki Court',
              propertyAddress: '',
              tenantName: 'Ada',
            ),
          ]);
      when(() => repo.updateStatus(any(), any())).thenAnswer((_) async {});

      final container = build();
      // Loads the first (only) page before the status change, matching the
      // list screen having already rendered it.
      await container.read(managerRequestsProvider.future);

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .setStatus('request-1', MaintenanceStatus.resolved);

      expect(ok, isTrue);
      final page = container.read(managerRequestsProvider).requireValue;
      expect(page.items, hasLength(1));
      expect(page.items.single.request.status, MaintenanceStatus.resolved);
      // One fetch to load the page, and no second one triggered by the
      // status change -- the point of patching in place.
      verify(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).called(1);
    });

    test('returns false when the update fails', () async {
      when(() => repo.updateStatus(any(), any()))
          .thenThrow(Exception('rls denied'));

      final container = build();

      final ok = await container
          .read(maintenanceControllerProvider.notifier)
          .setStatus('request-1', MaintenanceStatus.resolved);

      expect(ok, isFalse);
      expect(container.read(maintenanceControllerProvider).hasError, isTrue);
    });
  });
}
