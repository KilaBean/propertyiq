import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:propertyiq/features/units/data/repositories/unit_repository.dart';
import 'package:propertyiq/features/units/presentation/providers/unit_controller.dart';

class MockUnitRepository extends Mock implements UnitRepository {}

void main() {
  late MockUnitRepository repo;

  setUp(() {
    repo = MockUnitRepository();
    when(() => repo.create(
          propertyId: any(named: 'propertyId'),
          label: any(named: 'label'),
          bedrooms: any(named: 'bedrooms'),
          baseRent: any(named: 'baseRent'),
        )).thenAnswer((_) async {});
    when(() => repo.update(
          id: any(named: 'id'),
          label: any(named: 'label'),
          bedrooms: any(named: 'bedrooms'),
          baseRent: any(named: 'baseRent'),
        )).thenAnswer((_) async {});
    when(() => repo.delete(any())).thenAnswer((_) async {});
  });

  ProviderContainer build() {
    final container = ProviderContainer(
      overrides: [unitRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    final sub = container.listen(unitControllerProvider, (_, _) {});
    addTearDown(sub.close);
    return container;
  }

  group('UnitController.save', () {
    test('creates when no id is supplied', () async {
      final container = build();

      final ok = await container.read(unitControllerProvider.notifier).save(
            propertyId: 'property-1',
            label: 'Flat 2B',
            bedrooms: 2,
            baseRent: 450000,
          );

      expect(ok, isTrue);
      verify(() => repo.create(
            propertyId: 'property-1',
            label: 'Flat 2B',
            bedrooms: 2,
            baseRent: 450000,
          )).called(1);
      verifyNever(() => repo.update(
            id: any(named: 'id'),
            label: any(named: 'label'),
            bedrooms: any(named: 'bedrooms'),
            baseRent: any(named: 'baseRent'),
          ));
    });

    test('updates when an id is supplied', () async {
      final container = build();

      await container.read(unitControllerProvider.notifier).save(
            id: 'unit-1',
            propertyId: 'property-1',
            label: 'Flat 2B',
            bedrooms: 3,
            baseRent: 500000,
          );

      verify(() => repo.update(
            id: 'unit-1',
            label: 'Flat 2B',
            bedrooms: 3,
            baseRent: 500000,
          )).called(1);
      verifyNever(() => repo.create(
            propertyId: any(named: 'propertyId'),
            label: any(named: 'label'),
            bedrooms: any(named: 'bedrooms'),
            baseRent: any(named: 'baseRent'),
          ));
    });

    test('returns false and records the error when the write fails', () async {
      when(() => repo.create(
            propertyId: any(named: 'propertyId'),
            label: any(named: 'label'),
            bedrooms: any(named: 'bedrooms'),
            baseRent: any(named: 'baseRent'),
          )).thenThrow(Exception('rls denied'));

      final container = build();

      final ok = await container.read(unitControllerProvider.notifier).save(
            propertyId: 'property-1',
            label: 'Flat 2B',
            bedrooms: 2,
            baseRent: 450000,
          );

      expect(ok, isFalse);
      expect(container.read(unitControllerProvider).hasError, isTrue);
    });
  });

  group('UnitController.delete', () {
    test('forwards the id', () async {
      final container = build();

      final ok =
          await container.read(unitControllerProvider.notifier).delete('unit-1');

      expect(ok, isTrue);
      verify(() => repo.delete('unit-1')).called(1);
    });

    test('returns false when the delete fails', () async {
      when(() => repo.delete(any())).thenThrow(Exception('fk violation'));
      final container = build();

      final ok =
          await container.read(unitControllerProvider.notifier).delete('unit-1');

      expect(ok, isFalse);
    });
  });
}
