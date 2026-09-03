// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All requests across the manager's units, paginated and searchable.

@ProviderFor(ManagerRequests)
final managerRequestsProvider = ManagerRequestsProvider._();

/// All requests across the manager's units, paginated and searchable.
final class ManagerRequestsProvider
    extends $AsyncNotifierProvider<ManagerRequests, MaintenancePage> {
  /// All requests across the manager's units, paginated and searchable.
  ManagerRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'managerRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$managerRequestsHash();

  @$internal
  @override
  ManagerRequests create() => ManagerRequests();
}

String _$managerRequestsHash() => r'480c175489d6ee89f331dae526969d47bbb0bebf';

/// All requests across the manager's units, paginated and searchable.

abstract class _$ManagerRequests extends $AsyncNotifier<MaintenancePage> {
  FutureOr<MaintenancePage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MaintenancePage>, MaintenancePage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MaintenancePage>, MaintenancePage>,
              AsyncValue<MaintenancePage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in tenant's own requests, paginated and searchable.

@ProviderFor(TenantRequests)
final tenantRequestsProvider = TenantRequestsProvider._();

/// The signed-in tenant's own requests, paginated and searchable.
final class TenantRequestsProvider
    extends $AsyncNotifierProvider<TenantRequests, MaintenancePage> {
  /// The signed-in tenant's own requests, paginated and searchable.
  TenantRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantRequestsHash();

  @$internal
  @override
  TenantRequests create() => TenantRequests();
}

String _$tenantRequestsHash() => r'cbd85ba67b0a0fd33d40758d6b51ed5fd674ff59';

/// The signed-in tenant's own requests, paginated and searchable.

abstract class _$TenantRequests extends $AsyncNotifier<MaintenancePage> {
  FutureOr<MaintenancePage> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MaintenancePage>, MaintenancePage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MaintenancePage>, MaintenancePage>,
              AsyncValue<MaintenancePage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A single request (RLS scopes visibility to its tenant or managing manager).

@ProviderFor(maintenanceDetail)
final maintenanceDetailProvider = MaintenanceDetailFamily._();

/// A single request (RLS scopes visibility to its tenant or managing manager).

final class MaintenanceDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<MaintenanceView>,
          MaintenanceView,
          FutureOr<MaintenanceView>
        >
    with $FutureModifier<MaintenanceView>, $FutureProvider<MaintenanceView> {
  /// A single request (RLS scopes visibility to its tenant or managing manager).
  MaintenanceDetailProvider._({
    required MaintenanceDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'maintenanceDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$maintenanceDetailHash();

  @override
  String toString() {
    return r'maintenanceDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MaintenanceView> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MaintenanceView> create(Ref ref) {
    final argument = this.argument as String;
    return maintenanceDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MaintenanceDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$maintenanceDetailHash() => r'37bf7839619e2056670b8420b1aa30119d66d576';

/// A single request (RLS scopes visibility to its tenant or managing manager).

final class MaintenanceDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MaintenanceView>, String> {
  MaintenanceDetailFamily._()
    : super(
        retry: null,
        name: r'maintenanceDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single request (RLS scopes visibility to its tenant or managing manager).

  MaintenanceDetailProvider call(String id) =>
      MaintenanceDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'maintenanceDetailProvider';
}

/// A short-lived signed URL for a stored maintenance photo (cached per path).

@ProviderFor(maintenancePhotoUrl)
final maintenancePhotoUrlProvider = MaintenancePhotoUrlFamily._();

/// A short-lived signed URL for a stored maintenance photo (cached per path).

final class MaintenancePhotoUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A short-lived signed URL for a stored maintenance photo (cached per path).
  MaintenancePhotoUrlProvider._({
    required MaintenancePhotoUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'maintenancePhotoUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$maintenancePhotoUrlHash();

  @override
  String toString() {
    return r'maintenancePhotoUrlProvider'
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
    return maintenancePhotoUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MaintenancePhotoUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$maintenancePhotoUrlHash() =>
    r'4214cad86e6cae9af81d38760940214e5576318a';

/// A short-lived signed URL for a stored maintenance photo (cached per path).

final class MaintenancePhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  MaintenancePhotoUrlFamily._()
    : super(
        retry: null,
        name: r'maintenancePhotoUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A short-lived signed URL for a stored maintenance photo (cached per path).

  MaintenancePhotoUrlProvider call(String path) =>
      MaintenancePhotoUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'maintenancePhotoUrlProvider';
}
