import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/models/user_role.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_providers.dart';

part 'auth_controller.g.dart';

/// Drives the sign-in / sign-up / sign-out actions and exposes their
/// loading / error state to the screens via [AsyncValue]. It holds no data —
/// the resulting session/profile flow back through the reactive providers.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(
      () => _repo.signInWithPassword(email: email, password: password),
    );
    if (ref.mounted) state = guarded;
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(
      () => _repo.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      ),
    );
    if (ref.mounted) state = guarded;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(_repo.signOut);
    if (ref.mounted) state = guarded;
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _repo.resetPassword(email));
    if (ref.mounted) state = guarded;
    return !guarded.hasError;
  }

  Future<bool> changePassword(String newPassword) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _repo.changePassword(newPassword));
    if (ref.mounted) state = guarded;
    return !guarded.hasError;
  }

  Future<bool> uploadAvatar(XFile file) async {
    state = const AsyncLoading();
    String? path;
    final guarded = await AsyncValue.guard(() async {
      path = await _repo.uploadAvatar(file);
    });
    if (ref.mounted) {
      state = guarded;
      if (!guarded.hasError) {
        ref.invalidate(currentProfileProvider);
        // The path is stable across re-uploads, so the cached signed URL
        // must be invalidated or the old photo sticks.
        if (path != null) ref.invalidate(avatarUrlProvider(path!));
      }
    }
    return !guarded.hasError;
  }
}
