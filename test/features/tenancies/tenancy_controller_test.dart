import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/tenancies/data/repositories/tenancy_repository.dart';
import 'package:propertyiq/features/tenancies/presentation/providers/tenancy_controller.dart';
import 'package:propertyiq/shared/models/rent_cycle.dart';
import 'package:propertyiq/shared/models/tenancy_status.dart';

class MockTenancyRepository extends Mock implements TenancyRepository {}

void main() {
  late MockTenancyRepository repo;

  setUpAll(() {
    registerFallbackValue(RentCycle.monthly);
    registerFallbackValue(TenancyStatus.active);
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    repo = MockTenancyRepository();
    when(() => repo.endTenancy(any())).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
  });

  ProviderContainer build() {
    final container = ProviderContainer(
      overrides: [tenancyRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(tenancyControllerProvider, (_, _) {});
    addTearDown(sub.close);
    return container;
  }

  group('TenancyController.assign', () {
    test('returns the credentials for the manager to hand over', () async {
      when(() => repo.create(
            unitId: any(named: 'unitId'),
            tenantEmail: any(named: 'tenantEmail'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            rentAmount: any(named: 'rentAmount'),
            utilityAmount: any(named: 'utilityAmount'),
            depositAmount: any(named: 'depositAmount'),
            emergencyContact: any(named: 'emergencyContact'),
            rentCycle: any(named: 'rentCycle'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenAnswer(
        (_) async => const TenantInvite(
          email: 'ada@example.com',
          password: 'Kp7mQr2xTz9w',
          invited: true,
        ),
      );

      final container = build();

      final invite =
          await container.read(tenancyControllerProvider.notifier).assign(
                unitId: 'unit-1',
                tenantEmail: 'ada@example.com',
                fullName: 'Ada Obi',
                phone: '+2348000000000',
                rentAmount: 450000,
                utilityAmount: 20000,
                depositAmount: 450000,
                emergencyContact: 'Chidi 08000000000',
                rentCycle: RentCycle.monthly,
                startDate: DateTime(2026, 9, 1),
              );

      expect(invite, isNotNull);
      expect(invite!.email, 'ada@example.com');
      expect(invite.invited, isTrue);
      // Handed back for the manager to pass on. It only works until the tenant
      // signs in and replaces it (must_change_password, migration 0017).
      expect(invite.password, 'Kp7mQr2xTz9w');
    });

    test('returns null when the invite fails', () async {
      when(() => repo.create(
            unitId: any(named: 'unitId'),
            tenantEmail: any(named: 'tenantEmail'),
            fullName: any(named: 'fullName'),
            phone: any(named: 'phone'),
            rentAmount: any(named: 'rentAmount'),
            utilityAmount: any(named: 'utilityAmount'),
            depositAmount: any(named: 'depositAmount'),
            emergencyContact: any(named: 'emergencyContact'),
            rentCycle: any(named: 'rentCycle'),
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('not authorized for this unit'));

      final container = build();

      final invite =
          await container.read(tenancyControllerProvider.notifier).assign(
                unitId: 'unit-1',
                tenantEmail: 'ada@example.com',
                fullName: 'Ada Obi',
                phone: '',
                rentAmount: 0,
                utilityAmount: 0,
                depositAmount: 0,
                emergencyContact: '',
                rentCycle: RentCycle.monthly,
                startDate: DateTime(2026, 9, 1),
              );

      expect(invite, isNull);
      expect(container.read(tenancyControllerProvider).hasError, isTrue);
    });
  });

  group('TenancyController.resetPassword', () {
    test('returns the new password to hand over', () async {
      when(() => repo.resetTenantPassword(
            unitId: any(named: 'unitId'),
            tenantId: any(named: 'tenantId'),
          )).thenAnswer((_) async => 'Kp7mQr2xTz9w');

      final container = build();

      final password = await container
          .read(tenancyControllerProvider.notifier)
          .resetPassword(unitId: 'unit-1', tenantId: 'tenant-1');

      expect(password, 'Kp7mQr2xTz9w');
    });

    test('returns null when the reset fails', () async {
      when(() => repo.resetTenantPassword(
            unitId: any(named: 'unitId'),
            tenantId: any(named: 'tenantId'),
          )).thenThrow(Exception('not authorized for this tenant'));

      final container = build();

      final password = await container
          .read(tenancyControllerProvider.notifier)
          .resetPassword(unitId: 'unit-1', tenantId: 'tenant-1');

      expect(password, isNull);
    });
  });

  group('TenancyController.end', () {
    test('ends the tenancy by id', () async {
      final container = build();

      final ok =
          await container.read(tenancyControllerProvider.notifier).end('t-1');

      expect(ok, isTrue);
      verify(() => repo.endTenancy('t-1')).called(1);
    });

    test('returns false when it fails', () async {
      when(() => repo.endTenancy(any())).thenThrow(Exception('denied'));
      final container = build();

      expect(
        await container.read(tenancyControllerProvider.notifier).end('t-1'),
        isFalse,
      );
    });
  });
}
