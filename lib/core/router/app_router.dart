import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
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
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (_, _) => const SignupScreen(),
      ),
      // Tab roots — wrapped in the persistent bottom-nav shell.
      ShellRoute(
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, _) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.properties,
            builder: (_, _) => const PropertiesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.maintenance,
            builder: (_, _) => const ManagerMaintenanceListScreen(),
          ),
          GoRoute(
            path: AppRoutes.myUnit,
            builder: (_, _) => const MyUnitScreen(),
          ),
          GoRoute(
            path: AppRoutes.tenantMaintenance,
            builder: (_, _) => const TenantMaintenanceListScreen(),
          ),
          GoRoute(
            path: AppRoutes.tenantPayments,
            builder: (_, _) => const RentPaymentScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
      // Full-screen routes pushed over the shell.
      GoRoute(
        path: AppRoutes.propertyNew,
        builder: (_, _) => const PropertyFormScreen(),
      ),
      GoRoute(
        path: '/properties/:id',
        builder: (_, state) =>
            PropertyDetailScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/properties/:id/edit',
        builder: (_, state) =>
            PropertyFormScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/properties/:id/units/new',
        builder: (_, state) =>
            UnitFormScreen(propertyId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/properties/:id/units/edit',
        builder: (_, state) => UnitFormScreen(
          propertyId: state.pathParameters['id']!,
          initial: state.extra as Unit?,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId',
        builder: (_, state) => UnitDetailScreen(
          propertyId: state.pathParameters['id']!,
          unitId: state.pathParameters['unitId']!,
        ),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId/tenancy/new',
        builder: (_, state) =>
            TenancyFormScreen(unitId: state.pathParameters['unitId']!),
      ),
      GoRoute(
        path: '/properties/:id/units/:unitId/tenancy/edit',
        builder: (_, state) => TenancyFormScreen(
          unitId: state.pathParameters['unitId']!,
          initial: state.extra as Tenancy?,
        ),
      ),
      GoRoute(
        path: AppRoutes.tenantProfile,
        builder: (_, state) =>
            TenantProfileScreen(args: state.extra! as TenantProfileArgs),
      ),
      // Maintenance detail (manager) — full screen over the shell.
      GoRoute(
        path: '/maintenance/:id',
        builder: (_, state) =>
            MaintenanceDetailScreen(requestId: state.pathParameters['id']!),
      ),
      // Maintenance — tenant. `new` before `:id`.
      GoRoute(
        path: AppRoutes.tenantMaintenanceNew,
        builder: (_, _) => const MaintenanceFormScreen(),
      ),
      GoRoute(
        path: '/my-unit/maintenance/:id',
        builder: (_, state) =>
            MaintenanceDetailScreen(requestId: state.pathParameters['id']!),
      ),
    ],
  );

  // Re-run redirects on any auth/profile transition.
  ref
    ..listen(sessionProvider, (_, _) => router.refresh())
    ..listen(currentProfileProvider, (_, _) => router.refresh())
    ..onDispose(router.dispose);

  return router;
}
