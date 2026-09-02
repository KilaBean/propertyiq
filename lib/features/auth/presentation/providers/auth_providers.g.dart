// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Emits on every auth transition (sign in / out / token refresh). Everything
/// reactive downstream (session, profile, router) keys off this.

@ProviderFor(authChanges)
final authChangesProvider = AuthChangesProvider._();

/// Emits on every auth transition (sign in / out / token refresh). Everything
/// reactive downstream (session, profile, router) keys off this.

final class AuthChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// Emits on every auth transition (sign in / out / token refresh). Everything
  /// reactive downstream (session, profile, router) keys off this.
  AuthChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authChangesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authChanges(ref);
  }
}

String _$authChangesHash() => r'e2c13758abaae2b7e6a7ba7f5eb73acf06c9df8c';

/// Current session, recomputed whenever [authChanges] emits. Synchronous read
/// for the router redirect guard.

@ProviderFor(session)
final sessionProvider = SessionProvider._();

/// Current session, recomputed whenever [authChanges] emits. Synchronous read
/// for the router redirect guard.

final class SessionProvider
    extends $FunctionalProvider<Session?, Session?, Session?>
    with $Provider<Session?> {
  /// Current session, recomputed whenever [authChanges] emits. Synchronous read
  /// for the router redirect guard.
  SessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @$internal
  @override
  $ProviderElement<Session?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Session? create(Ref ref) {
    return session(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Session? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Session?>(value),
    );
  }
}

String _$sessionHash() => r'cdad50bd2fda6dd662e70912f7b6dad2105102b6';

/// The signed-in user's profile (role lives here). Null when logged out.

@ProviderFor(currentProfile)
final currentProfileProvider = CurrentProfileProvider._();

/// The signed-in user's profile (role lives here). Null when logged out.

final class CurrentProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// The signed-in user's profile (role lives here). Null when logged out.
  CurrentProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    return currentProfile(ref);
  }
}

String _$currentProfileHash() => r'b4decf98d661e47cc5fcf0649c04ecaf8e27849c';

/// Any profile by id — used by a manager to view a tenant's profile (RLS
/// allows reading profiles of tenants in the manager's units).

@ProviderFor(profileById)
final profileByIdProvider = ProfileByIdFamily._();

/// Any profile by id — used by a manager to view a tenant's profile (RLS
/// allows reading profiles of tenants in the manager's units).

final class ProfileByIdProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// Any profile by id — used by a manager to view a tenant's profile (RLS
  /// allows reading profiles of tenants in the manager's units).
  ProfileByIdProvider._({
    required ProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileByIdHash();

  @override
  String toString() {
    return r'profileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    final argument = this.argument as String;
    return profileById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileByIdHash() => r'a0d6b6f91084e84a04b884eb4891e958c8bb33ad';

/// Any profile by id — used by a manager to view a tenant's profile (RLS
/// allows reading profiles of tenants in the manager's units).

final class ProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile?>, String> {
  ProfileByIdFamily._()
    : super(
        retry: null,
        name: r'profileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Any profile by id — used by a manager to view a tenant's profile (RLS
  /// allows reading profiles of tenants in the manager's units).

  ProfileByIdProvider call(String id) =>
      ProfileByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'profileByIdProvider';
}

/// A short-lived signed URL for a stored avatar.

@ProviderFor(avatarUrl)
final avatarUrlProvider = AvatarUrlFamily._();

/// A short-lived signed URL for a stored avatar.

final class AvatarUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A short-lived signed URL for a stored avatar.
  AvatarUrlProvider._({
    required AvatarUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'avatarUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$avatarUrlHash();

  @override
  String toString() {
    return r'avatarUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as String;
    return avatarUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AvatarUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$avatarUrlHash() => r'7e123cfc46b253dc2a9f07c030dc13baf232834e';

/// A short-lived signed URL for a stored avatar.

final class AvatarUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  AvatarUrlFamily._()
    : super(
        retry: null,
        name: r'avatarUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A short-lived signed URL for a stored avatar.

  AvatarUrlProvider call(String path) =>
      AvatarUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'avatarUrlProvider';
}
