// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// All requests across the manager's units.

@ProviderFor(managerRequests)
final managerRequestsProvider = ManagerRequestsProvider._();

/// All requests across the manager's units.

final class ManagerRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MaintenanceView>>,
          List<MaintenanceView>,
          FutureOr<List<MaintenanceView>>
        >
    with
        $FutureModifier<List<MaintenanceView>>,
        $FutureProvider<List<MaintenanceView>> {
  /// All requests across the manager's units.
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
  $FutureProviderElement<List<MaintenanceView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MaintenanceView>> create(Ref ref) {
    return managerRequests(ref);
  }
}

String _$managerRequestsHash() => r'314e0e88380521a481598ee6b6978dd7fd6ac553';

/// The signed-in tenant's own requests.

@ProviderFor(tenantRequests)
final tenantRequestsProvider = TenantRequestsProvider._();

/// The signed-in tenant's own requests.

final class TenantRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MaintenanceView>>,
          List<MaintenanceView>,
          FutureOr<List<MaintenanceView>>
        >
    with
        $FutureModifier<List<MaintenanceView>>,
        $FutureProvider<List<MaintenanceView>> {
  /// The signed-in tenant's own requests.
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
  $FutureProviderElement<List<MaintenanceView>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MaintenanceView>> create(Ref ref) {
    return tenantRequests(ref);
  }
}

String _$tenantRequestsHash() => r'63c0eea214463ec721318f656f003bab4e2568a6';

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
