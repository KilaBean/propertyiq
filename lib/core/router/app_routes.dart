/// Centralised route paths. Screens and the redirect guard reference these
/// constants instead of string literals to avoid typo'd navigation.
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';

  /// Where invite / password-recovery deep links land.
  static const String setPassword = '/set-password';

  /// Manager home.
  static const String dashboard = '/dashboard';

  /// Tenant home.
  static const String myUnit = '/my-unit';

  static const String profile = '/profile';

  // Properties & units (manager). Static segments are declared before the
  // `:id` route in the router so `/properties/new` is not captured by `:id`.
  static const String properties = '/properties';
  static const String propertyNew = '/properties/new';
  static String propertyDetail(String id) => '/properties/$id';
  static String propertyEdit(String id) => '/properties/$id/edit';
  static String unitNew(String propertyId) => '/properties/$propertyId/units/new';
  static String unitEdit(String propertyId) =>
      '/properties/$propertyId/units/edit';
  static String unitDetail(String propertyId, String unitId) =>
      '/properties/$propertyId/units/$unitId';
  static String tenancyNew(String propertyId, String unitId) =>
      '/properties/$propertyId/units/$unitId/tenancy/new';
  static String tenancyEdit(String propertyId, String unitId) =>
      '/properties/$propertyId/units/$unitId/tenancy/edit';

  /// Manager-facing tenant profile (args passed via GoRouter `extra`).
  static const String tenantProfile = '/tenant-profile';

  // Maintenance — manager (across their units).
  static const String maintenance = '/maintenance';
  static String maintenanceDetail(String id) => '/maintenance/$id';

  // Maintenance — tenant (their own requests, under My Unit).
  static const String tenantMaintenance = '/my-unit/maintenance';
  static const String tenantMaintenanceNew = '/my-unit/maintenance/new';
  static String tenantMaintenanceDetail(String id) =>
      '/my-unit/maintenance/$id';

  /// Rent payment (tenant tab root).
  static const String tenantPayments = '/my-unit/payments';
}
