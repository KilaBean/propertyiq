import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:propertyiq/features/maintenance/data/repositories/maintenance_repository.dart';
import 'package:propertyiq/features/maintenance/presentation/providers/maintenance_providers.dart';
import 'package:propertyiq/shared/models/maintenance_request.dart';
import 'package:propertyiq/shared/models/maintenance_status.dart';

class MockMaintenanceRepository extends Mock implements MaintenanceRepository {}

/// `fetchForManager`/`fetchForTenant` are otherwise unbounded, growing for as
/// long as the portfolio exists. These providers page through them instead.
void main() {
  late MockMaintenanceRepository repo;

  MaintenanceView view(String id) => MaintenanceView(
        request: MaintenanceRequest(id: id, unitId: 'u1', tenantId: 't1', title: id),
        unitLabel: 'Flat 2B',
        propertyName: 'Lekki Court',
        propertyAddress: '',
        tenantName: 'Ada',
      );

  setUp(() {
    repo = MockMaintenanceRepository();
  });

  group('ManagerRequests', () {
    ProviderContainer build() {
      final container = ProviderContainer(
        overrides: [maintenanceRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('a full page implies more is available', () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((invocation) async {
        final limit = invocation.namedArguments[#limit] as int;
        return List.generate(limit, (i) => view('r$i'));
      });

      final container = build();
      final page = await container.read(managerRequestsProvider.future);

      expect(page.hasMore, isTrue);
      verify(() => repo.fetchForManager(offset: 0, limit: 20)).called(1);
    });

    test('a short page implies nothing more to load', () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [view('r0'), view('r1')]);

      final container = build();
      final page = await container.read(managerRequestsProvider.future);

      expect(page.items, hasLength(2));
      expect(page.hasMore, isFalse);
    });

    test('loadMore appends the next page at the current offset', () async {
      when(() => repo.fetchForManager(offset: 0, limit: 20))
          .thenAnswer((_) async => List.generate(20, (i) => view('page1-$i')));
      when(() => repo.fetchForManager(offset: 20, limit: 20))
          .thenAnswer((_) async => [view('page2-0')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      await container.read(managerRequestsProvider.notifier).loadMore();

      final page = container.read(managerRequestsProvider).requireValue;
      expect(page.items, hasLength(21));
      expect(page.items.last.request.id, 'page2-0');
      expect(page.hasMore, isFalse);
      verify(() => repo.fetchForManager(offset: 20, limit: 20)).called(1);
    });

    test('loadMore is a no-op once a short page has been seen', () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [view('r0')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      await container.read(managerRequestsProvider.notifier).loadMore();

      // Only the initial page fetch -- loadMore saw hasMore == false and
      // never called the repository again.
      verify(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).called(1);
    });

    test('patchStatus updates one row without a network call', () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [view('r0'), view('r1')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      container
          .read(managerRequestsProvider.notifier)
          .patchStatus('r1', MaintenanceStatus.resolved);

      final page = container.read(managerRequestsProvider).requireValue;
      expect(
        page.items.firstWhere((v) => v.request.id == 'r1').request.status,
        MaintenanceStatus.resolved,
      );
      // The other row is untouched.
      expect(
        page.items.firstWhere((v) => v.request.id == 'r0').request.status,
        MaintenanceStatus.open,
      );
      verify(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).called(1);
    });
  });

  group('TenantRequests', () {
    ProviderContainer build() {
      final container = ProviderContainer(
        overrides: [
          maintenanceRepositoryProvider.overrideWithValue(repo),
          sessionProvider.overrideWith((ref) => null),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('returns an empty, non-loading page when signed out', () async {
      final container = build();
      final page = await container.read(tenantRequestsProvider.future);

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
      verifyNever(() => repo.fetchForTenant(
            any(),
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          ));
    });
  });
}
