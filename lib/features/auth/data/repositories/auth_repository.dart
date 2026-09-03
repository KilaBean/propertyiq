import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../../shared/models/profile.dart';
import '../../../../shared/models/user_role.dart';

part 'auth_repository.g.dart';

/// The only class that talks to Supabase Auth + the `profiles` table.
/// Keeping it behind a provider makes the auth flow mockable in tests.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  Session? get currentSession => _client.auth.currentSession;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Role + name are passed as user metadata; the `handle_new_user` trigger
  /// creates the matching `profiles` row server-side. The client never inserts
  /// into `profiles` directly.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role.name},
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  /// Sends a password-reset / set-password email. Used by anyone who forgot
  /// theirs.
  Future<void> resetPassword(String email) =>
      _client.auth.resetPasswordForEmail(email);

  /// Changes the signed-in user's password (e.g. an invited tenant replacing
  /// the temporary password their manager shared).
  Future<void> changePassword(String newPassword) =>
      _client.auth.updateUser(UserAttributes(password: newPassword));

  /// Clears `profiles.must_change_password` after a successful change.
  ///
  /// Goes through a definer RPC because the client has no UPDATE grant on that
  /// column (migration 0017) — otherwise a tenant could clear the flag without
  /// ever replacing the password their manager knows.
  Future<void> clearMustChangePassword() =>
      _client.rpc('clear_must_change_password');

  Future<Profile?> fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
  }

  static const _avatarBucket = 'avatars';

  /// Uploads the signed-in user's avatar and records its path on their own
  /// profile (allowed directly — `profiles_update_own` covers this). Returns
  /// the stored path so the caller can invalidate its signed-URL cache (the
  /// path is stable across re-uploads, so a stale cached URL would otherwise
  /// keep showing the old photo).
  Future<String?> uploadAvatar(XFile file) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final bytes = await file.readAsBytes();
    final ext =
        file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'jpg';
    final path = '$uid/avatar.$ext';
    await _client.storage.from(_avatarBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            contentType: file.mimeType ?? 'image/jpeg',
            upsert: true,
          ),
        );
    await _client.from('profiles').update({'avatar_path': path}).eq('id', uid);
    return path;
  }

  /// A short-lived signed URL for a stored avatar (bucket is private).
  Future<String> signedAvatarUrl(String path) =>
      _client.storage.from(_avatarBucket).createSignedUrl(path, 3600);
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider));
