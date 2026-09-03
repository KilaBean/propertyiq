// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's GoRouter. Auth + role gating live entirely in [resolveRedirect];
/// the router just re-evaluates it whenever the session or profile changes.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// The app's GoRouter. Auth + role gating live entirely in [resolveRedirect];
/// the router just re-evaluates it whenever the session or profile changes.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's GoRouter. Auth + role gating live entirely in [resolveRedirect];
  /// the router just re-evaluates it whenever the session or profile changes.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'6b689cd8e24ddcef7f2a10c6195711891311f1d4';
