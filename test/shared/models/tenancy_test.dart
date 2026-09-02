import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/shared/models/rent_cycle.dart';
import 'package:propertyiq/shared/models/tenancy.dart';
import 'package:propertyiq/shared/models/tenancy_status.dart';

void main() {
  group('Tenancy JSON', () {
    test('maps columns, enums and dates', () {
      final t = Tenancy.fromJson({
        'id': 't1',
        'unit_id': 'u1',
        'tenant_id': null,
        'tenant_email': 'jane@example.com',
        'rent_amount': 250000,
        'rent_cycle': 'quarterly',
        'start_date': '2026-07-01',
        'end_date': null,
        'status': 'active',
      });

      expect(t.unitId, 'u1');
      expect(t.tenantId, isNull);
      expect(t.tenantEmail, 'jane@example.com');
      expect(t.rentAmount, 250000);
      expect(t.rentCycle, RentCycle.quarterly);
      expect(t.status, TenancyStatus.active);
      expect(t.startDate, DateTime.parse('2026-07-01'));
      expect(t.endDate, isNull);
    });

    test('applies defaults (monthly, active) when absent', () {
      final t = Tenancy.fromJson({
        'id': 't2',
        'unit_id': 'u1',
        'tenant_email': 'a@b.com',
      });
      expect(t.rentCycle, RentCycle.monthly);
      expect(t.status, TenancyStatus.active);
      expect(t.rentAmount, 0);
    });

    test('enum labels are human-readable', () {
      expect(RentCycle.yearly.label, 'Yearly');
      expect(TenancyStatus.ended.label, 'Ended');
    });
  });
}
