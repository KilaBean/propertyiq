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
