import 'package:flutter_test/flutter_test.dart';
import 'package:propertyiq/core/router/app_routes.dart';
import 'package:propertyiq/core/router/redirect_logic.dart';
import 'package:propertyiq/shared/models/user_role.dart';

/// A tenant arriving from an invite link has a real session but has never
/// chosen a password. Until they do, nothing else may be reachable — otherwise
/// they are using the app on a credential someone else picked.
void main() {
  group('resolveRedirect — password recovery gating', () {
    test('a user who has not set a password is pinned to /set-password', () {
      for (final location in [
        AppRoutes.dashboard,
        AppRoutes.myUnit,
        AppRoutes.profile,
        AppRoutes.properties,
        AppRoutes.tenantMaintenance,
      ]) {
        expect(
          resolveRedirect(
            location: location,
            hasSession: true,
            role: UserRole.tenant,
            profileLoading: false,
            needsPassword: true,
          ),
          AppRoutes.setPassword,
          reason: '$location should redirect while a password is outstanding',
        );
      }
    });

    test('/set-password itself is allowed while outstanding', () {
      expect(
        resolveRedirect(
          location: AppRoutes.setPassword,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
          needsPassword: true,
        ),
        isNull,
      );
    });

    test('the gate applies to managers too, not just invited tenants', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
          needsPassword: true,
        ),
        AppRoutes.setPassword,
      );
    });

    test('it outranks the still-loading-profile hold on splash', () {
      // Otherwise a slow profile fetch would park the user on the splash screen
      // instead of the screen that unblocks them.
      expect(
        resolveRedirect(
          location: AppRoutes.splash,
          hasSession: true,
          role: null,
          profileLoading: true,
          needsPassword: true,
        ),
        AppRoutes.setPassword,
      );
    });

    test('a logged-out user still goes to login, not set-password', () {
      expect(
        resolveRedirect(
          location: AppRoutes.dashboard,
          hasSession: false,
          role: null,
          profileLoading: false,
          needsPassword: true,
        ),
        AppRoutes.login,
      );
    });

    test('once resolved, /set-password sends the user to their home', () {
      expect(
        resolveRedirect(
          location: AppRoutes.setPassword,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
          needsPassword: false,
        ),
        AppRoutes.myUnit,
      );
      expect(
        resolveRedirect(
          location: AppRoutes.setPassword,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
          needsPassword: false,
        ),
        AppRoutes.dashboard,
      );
    });

    test('defaults to not gating when the flag is omitted', () {
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
  });

  group('resolveRedirect — tenant profile gating', () {
    test('a tenant cannot open the manager-facing tenant profile', () {
      expect(
        resolveRedirect(
          location: AppRoutes.tenantProfile,
          hasSession: true,
          role: UserRole.tenant,
          profileLoading: false,
        ),
        AppRoutes.myUnit,
      );
    });

    test('a manager can', () {
      expect(
        resolveRedirect(
          location: AppRoutes.tenantProfile,
          hasSession: true,
          role: UserRole.manager,
          profileLoading: false,
        ),
        isNull,
      );
    });
  });
}
