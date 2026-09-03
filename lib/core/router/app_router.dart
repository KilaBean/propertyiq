import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/set_password_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/common/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_detail_screen.dart';
import '../../features/maintenance/presentation/screens/maintenance_form_screen.dart';
import '../../features/maintenance/presentation/screens/manager_maintenance_list_screen.dart';
import '../../features/maintenance/presentation/screens/tenant_maintenance_list_screen.dart';
import '../../features/payments/presentation/screens/rent_payment_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/properties/presentation/screens/properties_list_screen.dart';
import '../../features/properties/presentation/screens/property_detail_screen.dart';
import '../../features/properties/presentation/screens/property_form_screen.dart';
import '../../features/tenancies/presentation/screens/tenancy_form_screen.dart';
import '../../features/tenant_home/presentation/screens/my_unit_screen.dart';
import '../../features/tenants/presentation/screens/tenant_profile_screen.dart';
import '../../features/units/presentation/screens/unit_detail_screen.dart';
import '../../features/units/presentation/screens/unit_form_screen.dart';
import '../../app/app_shell.dart';
import '../../shared/models/tenancy.dart';
import '../../shared/models/unit.dart';
import 'app_routes.dart';
import 'redirect_logic.dart';

part 'app_router.g.dart';

/// A fade transition for every route. Nothing customized this before, so
/// every push and every bottom-nav tab switch was an instant cut; CLAUDE.md's
/// MOTION section calls for 150-250ms fade/slide/scale, never a hard cut.
/// Fade rather than the platform-default slide: it reads as calmer across a
/// bottom-nav app where most navigation is lateral (tabs), not a strict
/// forward/back stack.
CustomTransitionPage<void> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// The app's GoRouter. Auth + role gating live entirely in [resolveRedirect];
/// the router just re-evaluates it whenever the session or profile changes.
@riverpod
GoRouter goRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final profileAsync = ref.read(currentProfileProvider);
      return resolveRedirect(
        location: state.matchedLocation,
        hasSession: session != null,
        role: profileAsync.value?.role,
        profileLoading: session != null && profileAsync.isLoading,
        needsPassword: ref.read(passwordRecoveryProvider),
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, state) => _fadePage(const SplashScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) => _fadePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (_, state) => _fadePage(const SignupScreen(), state),
      ),
      GoRoute(
        path: AppRoutes.setPassword,
        pageBuilder: (_, state) =>
            _fadePage(const SetPasswordScreen(), state),
      ),
      // Tab roots — wrapped in the persistent bottom-nav shell.
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, state) =>
                _fadePage(const DashboardScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.properties,
            pageBuilder: (_, state) =>
                _fadePage(const PropertiesListScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.maintenance,
            pageBuilder: (_, state) =>
                _fadePage(const ManagerMaintenanceListScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.myUnit,
            pageBuilder: (_, state) => _fadePage(const MyUnitScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.tenantMaintenance,
            pageBuilder: (_, state) =>
                _fadePage(const TenantMaintenanceListScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.tenantPayments,
            pageBuilder: (_, state) =>
                _fadePage(const RentPaymentScreen(), state),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (_, state) => _fadePage(const ProfileScreen(), state),
          ),
        ],
      ),
      // Full-screen routes pushed over the shell.
      GoRoute(
        path: AppRoutes.propertyNew,
        pageBuilder: (_, state) =>
            _fadePage(const PropertyFormScreen(), state),
      ),
      GoRoute(
        path: '/properties/:id',
        pageBuilder: (_, state) => _fadePage(
          PropertyDetailScreen(propertyId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/edit',
        pageBuilder: (_, state) => _fadePage(
          PropertyFormScreen(propertyId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/new',
        pageBuilder: (_, state) => _fadePage(
          UnitFormScreen(propertyId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/edit',
        pageBuilder: (_, state) => _fadePage(
          UnitFormScreen(
            propertyId: state.pathParameters['id']!,
            initial: state.extra as Unit?,
          ),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId',
        pageBuilder: (_, state) => _fadePage(
          UnitDetailScreen(
            propertyId: state.pathParameters['id']!,
            unitId: state.pathParameters['unitId']!,
          ),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId/tenancy/new',
        pageBuilder: (_, state) => _fadePage(
          TenancyFormScreen(unitId: state.pathParameters['unitId']!),
          state,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId/tenancy/edit',
        pageBuilder: (_, state) => _fadePage(
          TenancyFormScreen(
            unitId: state.pathParameters['unitId']!,
            initial: state.extra as Tenancy?,
          ),
          state,
        ),
      ),
      GoRoute(
        path: AppRoutes.tenantProfile,
        pageBuilder: (_, state) => _fadePage(
          TenantProfileScreen(args: state.extra! as TenantProfileArgs),
          state,
        ),
      ),
      // Maintenance detail (manager) — full screen over the shell.
      GoRoute(
        path: '/maintenance/:id',
        pageBuilder: (_, state) => _fadePage(
          MaintenanceDetailScreen(requestId: state.pathParameters['id']!),
          state,
        ),
      ),
      // Maintenance — tenant. `new` before `:id`.
      GoRoute(
        path: AppRoutes.tenantMaintenanceNew,
        pageBuilder: (_, state) =>
            _fadePage(const MaintenanceFormScreen(), state),
      ),
      GoRoute(
        path: '/my-unit/maintenance/:id',
        pageBuilder: (_, state) => _fadePage(
          MaintenanceDetailScreen(requestId: state.pathParameters['id']!),
          state,
        ),
      ),
    ],
  );

  // Re-run redirects on any auth/profile transition.
  ref
    ..listen(sessionProvider, (_, _) => router.refresh())
    ..listen(currentProfileProvider, (_, _) => router.refresh())
    ..listen(passwordRecoveryProvider, (_, _) => router.refresh())
    ..onDispose(router.dispose);

  return router;
}
