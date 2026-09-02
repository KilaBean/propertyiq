import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/router/app_routes.dart';
import 'package:propertyiq/core/router/redirect_logic.dart';
import 'package:propertyiq/shared/models/user_role.dart';

void main() {
  group('resolveRedirect', () {
    test('logged out on a protected route -> login', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: false,
          role: null,
          profileLoading: false,
        ),
        AppRoutes.login,
      );
    });

    test('logged out on the login route -> allowed', () {
      expect(
        resolveRedirect(
          location: AppRoutes.login,
          hasSession: false,
          role: null,
          profileLoading: false,
        ),
        isNull,
      );
    });

    test('session present but profile still loading -> splash', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: true,
          role: null,
          profileLoading: true,
        ),
        AppRoutes.splash,
      );
    });

    test('manager landing on login is sent to dashboard', () {
      expect(
        resolveRedirect(
          location: AppRoutes.login,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        AppRoutes.dashboard,
      );
    });

    test('tenant landing on login is sent to my-unit', () {
      expect(
        resolveRedirect(
          location: AppRoutes.login,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('tenant cannot open the manager dashboard', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('manager cannot open the tenant home', () {
      expect(
        resolveRedirect(
          location: AppRoutes.myUnit,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        AppRoutes.dashboard,
      );
    });

    test('manager on the dashboard is allowed', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        isNull,
      );
    });

    test('the shared profile route is allowed for any authed role', () {
      expect(
        resolveRedirect(
          location: AppRoutes.profile,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        isNull,
      );
    });
  });
}
