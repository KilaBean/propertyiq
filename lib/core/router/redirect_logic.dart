import '../../shared/models/user_role.dart';
import 'app_routes.dart';

/// Pure, side-effect-free routing decision. Kept separate from the GoRouter
/// wiring so it can be unit-tested without a widget tree or Supabase.
///
/// Returns the path to redirect to, or `null` to allow [location].
String? resolveRedirect({
  required String location,
  required bool hasSession,
  required UserRole? role,
  required bool profileLoading,
  bool needsPassword = false,
}) {
  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.signup;
  final isSplash = location == AppRoutes.splash;

  // Logged out → only the auth routes are reachable.
  if (!hasSession) {
    return isAuthRoute ? null : AppRoutes.login;
  }

  // Arrived via an invite / recovery link: a session exists, but the user has
  // never chosen a password. Nothing else is reachable until they do.
  if (needsPassword) {
    return location == AppRoutes.setPassword ? null : AppRoutes.setPassword;
  }

  // Session exists but role not yet known → hold on the splash screen.
  if (role == null) {
    if (profileLoading) {
      return isSplash ? null : AppRoutes.splash;
    }
    // Resolved with no profile (unexpected): fall back to login.
    return isAuthRoute ? null : AppRoutes.login;
  }

  final home =
      role.isManager ? AppRoutes.dashboard : AppRoutes.myUnit;

  // Authenticated users never sit on auth/splash, nor linger on set-password
  // once the flag has cleared.
  if (isAuthRoute || isSplash || location == AppRoutes.setPassword) return home;

  // Role gating: each home belongs to exactly one role.
  if (location == AppRoutes.dashboard && !role.isManager) return home;

  // Tenant area (My Unit + tenant maintenance) — tenant-only.
  if (location.startsWith(AppRoutes.myUnit) && !role.isTenant) return home;

  // Property management + manager maintenance — manager-only.
  if (location.startsWith(AppRoutes.properties) && !role.isManager) return home;
  if (location.startsWith(AppRoutes.maintenance) && !role.isManager) return home;

  return null;
}
