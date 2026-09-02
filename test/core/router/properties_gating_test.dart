import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/router/app_routes.dart';
import 'package:propertyiq/core/router/redirect_logic.dart';
import 'package:propertyiq/shared/models/user_role.dart';

void main() {
  group('resolveRedirect — property management gating', () {
    test('a tenant cannot open /properties (sent to my-unit)', () {
      expect(
        resolveRedirect(
          location: AppRoutes.properties,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('a tenant cannot open a property subroute', () {
      expect(
        resolveRedirect(
          location: AppRoutes.propertyDetail('abc'),
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('a manager can open /properties', () {
      expect(
        resolveRedirect(
          location: AppRoutes.properties,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        isNull,
      );
    });
  });
}
