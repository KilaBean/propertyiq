import 'dart:async';

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
      // loadMore() always passes `query` (the empty string when no search is
      // active -- see maintenance_providers.dart), so the stub has to match
      // that shape even though build() itself never passes one.
      when(() => repo.fetchForManager(
            offset: 0,
            limit: 20,
            query: any(named: 'query'),
          )).thenAnswer((_) async => List.generate(20, (i) => view('page1-$i')));
      when(() => repo.fetchForManager(
            offset: 20,
            limit: 20,
            query: any(named: 'query'),
          )).thenAnswer((_) async => [view('page2-0')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      await container.read(managerRequestsProvider.notifier).loadMore();

      final page = container.read(managerRequestsProvider).requireValue;
      expect(page.items, hasLength(21));
      expect(page.items.last.request.id, 'page2-0');
      expect(page.hasMore, isFalse);
      verify(() => repo.fetchForManager(
            offset: 20,
            limit: 20,
            query: any(named: 'query'),
          )).called(1);
    });

    test('search re-queries from the top and clears once results run out',
        () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [view('r0'), view('r1')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      when(() => repo.fetchForManager(
            offset: 0,
            limit: 20,
            query: 'leak',
          )).thenAnswer((_) async => [view('leaky-sink')]);

      await container.read(managerRequestsProvider.notifier).search('leak');

      final page = container.read(managerRequestsProvider).requireValue;
      // Replaced, not appended to the unfiltered r0/r1 page from build().
      expect(page.items, hasLength(1));
      expect(page.items.single.request.id, 'leaky-sink');
      // Short page (1 < the 20-row page size) -- nothing more to load for
      // this query, so loadMore() must not fire a further request.
      expect(page.hasMore, isFalse);

      await container.read(managerRequestsProvider.notifier).loadMore();
      // Exactly the two calls already made (build(), then search()) -- a
      // third would mean loadMore() ignored the short-page/hasMore signal.
      verify(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          )).called(2);
    });

    test('loadMore carries the active search query forward', () async {
      when(() => repo.fetchForManager(
            offset: 0,
            limit: 20,
            query: any(named: 'query'),
          )).thenAnswer((_) async => List.generate(20, (i) => view('leak-$i')));

      final container = build();
      await container.read(managerRequestsProvider.future);
      await container.read(managerRequestsProvider.notifier).search('leak');

      when(() => repo.fetchForManager(
            offset: 20,
            limit: 20,
            query: 'leak',
          )).thenAnswer((_) async => [view('leak-20')]);

      await container.read(managerRequestsProvider.notifier).loadMore();

      final page = container.read(managerRequestsProvider).requireValue;
      expect(page.items, hasLength(21));
      // If loadMore() dropped the query, this exact call would never have
      // been stubbed and the mock would have returned nothing for it.
      verify(() => repo.fetchForManager(offset: 20, limit: 20, query: 'leak'))
          .called(1);
    });

    test('search keeps the previous results visible while it loads',
        () async {
      when(() => repo.fetchForManager(
            offset: any(named: 'offset'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [view('r0')]);

      final container = build();
      await container.read(managerRequestsProvider.future);

      final searchStarted = Completer<void>();
      when(() => repo.fetchForManager(
            offset: 0,
            limit: 20,
            query: 'x',
          )).thenAnswer((_) async {
        searchStarted.complete();
        return [view('r0')];
      });

      final searching = container
          .read(managerRequestsProvider.notifier)
          .search('x');
      await searchStarted.future;

      // The old page is still the visible state mid-fetch -- no loading
      // state or blank flash while the query is in flight.
      expect(container.read(managerRequestsProvider).hasValue, isTrue);
      expect(container.read(managerRequestsProvider).isLoading, isFalse);

      await searching;
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
