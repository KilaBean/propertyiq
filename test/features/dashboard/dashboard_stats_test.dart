import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/features/dashboard/presentation/providers/dashboard_providers.dart';

void main() {
  group('DashboardStats', () {
    test('computes occupancy rate and vacant count', () {
      const s = DashboardStats(
        propertyCount: 2,
        unitCount: 4,
        occupiedCount: 3,
      );
      expect(s.vacantCount, 1);
      expect(s.occupancyRate, closeTo(0.75, 1e-9));
    });

    test('occupancy is 0 (not NaN) when there are no units', () {
      const s = DashboardStats(
        propertyCount: 1,
        unitCount: 0,
        occupiedCount: 0,
      );
      expect(s.occupancyRate, 0);
      expect(s.vacantCount, 0);
    });

    test('empty constant is all zeros', () {
      expect(DashboardStats.empty.propertyCount, 0);
      expect(DashboardStats.empty.unitCount, 0);
      expect(DashboardStats.empty.occupiedCount, 0);
    });
  });
}
