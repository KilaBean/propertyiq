// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenancy_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live list of tenancies on a unit (manager view).

@ProviderFor(tenanciesByUnit)
final tenanciesByUnitProvider = TenanciesByUnitFamily._();

/// Live list of tenancies on a unit (manager view).

final class TenanciesByUnitProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tenancy>>,
          List<Tenancy>,
          Stream<List<Tenancy>>
        >
    with $FutureModifier<List<Tenancy>>, $StreamProvider<List<Tenancy>> {
  /// Live list of tenancies on a unit (manager view).
  TenanciesByUnitProvider._({
    required TenanciesByUnitFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tenanciesByUnitProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenanciesByUnitHash();

  @override
  String toString() {
    return r'tenanciesByUnitProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Tenancy>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Tenancy>> create(Ref ref) {
    final argument = this.argument as String;
    return tenanciesByUnit(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TenanciesByUnitProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenanciesByUnitHash() => r'5f8ccf97c4f6baa9c4e60c81095f4623e2cbbbba';

/// Live list of tenancies on a unit (manager view).

final class TenanciesByUnitFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Tenancy>>, String> {
  TenanciesByUnitFamily._()
    : super(
        retry: null,
        name: r'tenanciesByUnitProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live list of tenancies on a unit (manager view).

  TenanciesByUnitProvider call(String unitId) =>
      TenanciesByUnitProvider._(argument: unitId, from: this);

  @override
  String toString() => r'tenanciesByUnitProvider';
}

/// The signed-in tenant's active lease, or null if none.

@ProviderFor(tenantLease)
final tenantLeaseProvider = TenantLeaseProvider._();

/// The signed-in tenant's active lease, or null if none.

final class TenantLeaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<TenantLease?>,
          TenantLease?,
          FutureOr<TenantLease?>
        >
    with $FutureModifier<TenantLease?>, $FutureProvider<TenantLease?> {
  /// The signed-in tenant's active lease, or null if none.
  TenantLeaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantLeaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantLeaseHash();

  @$internal
  @override
  $FutureProviderElement<TenantLease?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TenantLease?> create(Ref ref) {
    return tenantLease(ref);
  }
}

String _$tenantLeaseHash() => r'6b74c7d364d5408e9651e7765e8ebf907b2416c1';
