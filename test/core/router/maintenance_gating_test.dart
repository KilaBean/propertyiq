import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/router/app_routes.dart';
import 'package:propertyiq/core/router/redirect_logic.dart';
import 'package:propertyiq/shared/models/user_role.dart';

void main() {
  group('resolveRedirect — maintenance gating', () {
    test('tenant cannot open the manager maintenance list', () {
      expect(
        resolveRedirect(
          location: AppRoutes.maintenance,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('manager cannot open the tenant maintenance area', () {
      expect(
        resolveRedirect(
          location: AppRoutes.tenantMaintenance,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        AppRoutes.dashboard,
      );
    });

    test('manager can open the manager maintenance list', () {
      expect(
        resolveRedirect(
          location: AppRoutes.maintenance,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        isNull,
      );
    });

    test('tenant can open their maintenance area', () {
      expect(
        resolveRedirect(
          location: AppRoutes.tenantMaintenanceNew,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        isNull,
      );
    });
  });
}
