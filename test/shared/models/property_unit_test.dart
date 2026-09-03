import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/shared/models/property.dart';
import 'package:propertyiq/shared/models/unit.dart';
import 'package:propertyiq/shared/models/unit_status.dart';

void main() {
  group('Property JSON', () {
    test('maps snake_case columns', () {
      final p = Property.fromJson({
        'id': 'p1',
        'manager_id': 'm1',
        'name': 'Sunrise Court',
        'address': '12 Palm St',
        'currency': 'GHS',
        'created_at': '2026-06-28T10:00:00.000Z',
      });
      expect(p.id, 'p1');
      expect(p.managerId, 'm1');
      expect(p.name, 'Sunrise Court');
      expect(p.address, '12 Palm St');
      expect(p.currency, 'GHS');
    });

    test('defaults currency to GHS when absent', () {
      final p = Property.fromJson({'id': 'p2', 'manager_id': 'm1', 'name': 'X'});
      expect(p.currency, 'GHS');
      expect(p.address, isNull);
    });
  });

  group('Unit JSON', () {
    test('maps columns and status enum', () {
      final u = Unit.fromJson({
        'id': 'u1',
        'property_id': 'p1',
        'label': 'Flat 2B',
        'bedrooms': 3,
        'base_rent': 250000,
        'status': 'occupied',
      });
      expect(u.propertyId, 'p1');
      expect(u.label, 'Flat 2B');
      expect(u.bedrooms, 3);
      expect(u.baseRent, 250000);
      expect(u.status, UnitStatus.occupied);
    });

    test('applies defaults (vacant, 0 bedrooms/rent)', () {
      final u = Unit.fromJson({
        'id': 'u2',
        'property_id': 'p1',
        'label': 'Studio',
      });
      expect(u.status, UnitStatus.vacant);
      expect(u.bedrooms, 0);
      expect(u.baseRent, 0);
    });

    test('round-trips through toJson', () {
      const u = Unit(id: 'u3', propertyId: 'p1', label: 'A1');
      expect(Unit.fromJson(u.toJson()), u);
    });
  });
}
