// Dev-only entrypoint: renders the real DashboardScreen (inside the real
// AppShell bottom-nav) with mock provider data, so we can screenshot actual
// app UI for marketing use instead of a hand-drawn mockup.
//
// Run with: flutter build web -t lib/dev_preview/dashboard_preview_main.dart
//           --dart-define=PREVIEW_DARK=true   (omit/false for light)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/app_shell.dart';
import '../core/router/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/dashboard/presentation/providers/dashboard_providers.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/maintenance/data/repositories/maintenance_repository.dart';
import '../features/maintenance/presentation/providers/maintenance_providers.dart';
import '../shared/models/maintenance_category.dart';
import '../shared/models/maintenance_priority.dart';
import '../shared/models/maintenance_request.dart';
import '../shared/models/maintenance_status.dart';
import '../shared/models/profile.dart';
import '../shared/models/user_role.dart';

const _isDark = bool.fromEnvironment('PREVIEW_DARK', defaultValue: false);

/// Reserves space for the fake status bar the landing page draws over the
/// captured screenshot, so SafeArea pushes real content below it instead of
/// the overlay covering the app's own header.
const _statusBarInset = 40.0;

final _mockProfile = Profile(
  id: 'preview-manager',
  fullName: 'Ama Boateng',
  role: UserRole.manager,
);

const _mockStats = DashboardStats(
  propertyCount: 8,
  unitCount: 24,
  occupiedCount: 21,
);

final _mockRequests = [
  MaintenanceView(
    request: MaintenanceRequest(
      id: 'r1',
      unitId: 'u1',
      tenantId: 't1',
      title: 'Kitchen faucet leaking',
      category: MaintenanceCategory.plumbing,
      priority: MaintenancePriority.high,
      status: MaintenanceStatus.open,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    unitLabel: '4B',
    propertyName: 'Cedar Heights',
    propertyAddress: '',
    tenantName: 'Kwame Mensah',
  ),
  MaintenanceView(
    request: MaintenanceRequest(
      id: 'r2',
      unitId: 'u2',
      tenantId: 't2',
      title: 'AC unit not cooling',
      category: MaintenanceCategory.other,
      priority: MaintenancePriority.medium,
      status: MaintenanceStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    unitLabel: '12',
    propertyName: 'Maple Court',
    propertyAddress: '',
    tenantName: 'Efua Asante',
  ),
  MaintenanceView(
    request: MaintenanceRequest(
      id: 'r3',
      unitId: 'u3',
      tenantId: 't3',
      title: 'Hallway light bulb replaced',
      category: MaintenanceCategory.electrical,
      priority: MaintenancePriority.low,
      status: MaintenanceStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    unitLabel: '2A',
    propertyName: 'Birchwood',
    propertyAddress: '',
    tenantName: 'Yaw Owusu',
  ),
];

const _mockTrend = [
  OccupancyPoint(label: 'Feb', rate: 78),
  OccupancyPoint(label: 'Mar', rate: 81),
  OccupancyPoint(label: 'Apr', rate: 85),
  OccupancyPoint(label: 'May', rate: 83),
  OccupancyPoint(label: 'Jun', rate: 88),
  OccupancyPoint(label: 'Jul', rate: 92),
];

void main() {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const AppShell(child: DashboardScreen()),
      ),
    ],
  );

  runApp(
    ProviderScope(
      overrides: [
        currentProfileProvider.overrideWith((ref) => _mockProfile),
        dashboardStatsProvider.overrideWith((ref) => _mockStats),
        managerRequestsProvider.overrideWith((ref) => _mockRequests),
        occupancyTrendProvider.overrideWith((ref, period) => _mockTrend),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: _statusBarInset),
          ),
          child: child!,
        ),
        routerConfig: router,
      ),
    ),
  );
}
