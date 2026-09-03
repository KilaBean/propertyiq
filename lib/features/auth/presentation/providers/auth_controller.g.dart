// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the sign-in / sign-up / sign-out actions and exposes their
/// loading / error state to the screens via [AsyncValue]. It holds no data —
/// the resulting session/profile flow back through the reactive providers.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Drives the sign-in / sign-up / sign-out actions and exposes their
/// loading / error state to the screens via [AsyncValue]. It holds no data —
/// the resulting session/profile flow back through the reactive providers.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Drives the sign-in / sign-up / sign-out actions and exposes their
  /// loading / error state to the screens via [AsyncValue]. It holds no data —
  /// the resulting session/profile flow back through the reactive providers.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'e81309fac32c1e18f3546d2fb4e9dbb890b5ac2e';

/// Drives the sign-in / sign-up / sign-out actions and exposes their
/// loading / error state to the screens via [AsyncValue]. It holds no data —
/// the resulting session/profile flow back through the reactive providers.

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
