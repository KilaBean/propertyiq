import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/models/profile.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Emits on every auth transition (sign in / out / token refresh). Everything
/// reactive downstream (session, profile, router) keys off this.
@Riverpod(keepAlive: true)
Stream<AuthState> authChanges(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

/// Current session, recomputed whenever [authChanges] emits. Synchronous read
/// for the router redirect guard.
@Riverpod(keepAlive: true)
Session? session(Ref ref) {
  ref.watch(authChangesProvider);
  return ref.watch(authRepositoryProvider).currentSession;
}

/// True while the signed-in user is still on a password somebody else chose,
/// and so must replace it before going anywhere.
///
/// Two sources, because there are two ways in:
///
///  * `profiles.must_change_password` — the normal path. A manager generates a
///    tenant's password and hands it over, so the manager knows it. The flag is
///    raised at account creation (and on a manager-initiated reset) and cleared
///    once the tenant picks their own, which bounds the manager's access to
///    that account at the tenant's first sign-in.
///  * `AuthChangeEvent.passwordRecovery` — only fires if email recovery is
///    enabled later. Harmless to keep, and means the screen already works if
///    SMTP is switched on.
///
/// [resolve] is the local override, so the router releases immediately after a
/// successful change rather than waiting on a profile refetch.
@Riverpod(keepAlive: true)
class PasswordRecovery extends _$PasswordRecovery {
  @override
  bool build() {
    ref.listen(authChangesProvider, (_, next) {
      if (next.value?.event == AuthChangeEvent.passwordRecovery) {
        state = true;
      } else if (next.value?.event == AuthChangeEvent.signedOut) {
        // Don't strand the next user on the set-password screen.
        state = false;
        _resolvedLocally = false;
      }
    });

    // A profile carrying the flag pins the user here too.
    final profile = ref.watch(currentProfileProvider).value;
    if (!_resolvedLocally && (profile?.mustChangePassword ?? false)) {
      return true;
    }
    return false;
  }

  bool _resolvedLocally = false;

  /// Called once the user has set their own password.
  void resolve() {
    _resolvedLocally = true;
    state = false;
  }
}

/// The signed-in user's profile (role lives here). Null when logged out.
@Riverpod(keepAlive: true)
Future<Profile?> currentProfile(Ref ref) async {
  final session = ref.watch(sessionProvider);
  if (session == null) return null;
  return ref.watch(authRepositoryProvider).fetchProfile(session.user.id);
}

/// Any profile by id — used by a manager to view a tenant's profile (RLS
/// allows reading profiles of tenants in the manager's units).
@riverpod
Future<Profile?> profileById(Ref ref, String id) =>
    ref.watch(authRepositoryProvider).fetchProfile(id);

/// A short-lived signed URL for a stored avatar.
@riverpod
Future<String> avatarUrl(Ref ref, String path) =>
    ref.watch(authRepositoryProvider).signedAvatarUrl(path);
