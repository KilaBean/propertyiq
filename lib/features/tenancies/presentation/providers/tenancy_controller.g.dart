// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenancy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Assign / update / end / delete tenancies. Returns `true` on success.
/// The realtime [tenanciesByUnit] stream reflects changes automatically;
/// derived one-shot providers (dashboard stats, occupancy trend, the tenant's
/// lease view) are invalidated explicitly since they don't watch the table.

@ProviderFor(TenancyController)
final tenancyControllerProvider = TenancyControllerProvider._();

/// Assign / update / end / delete tenancies. Returns `true` on success.
/// The realtime [tenanciesByUnit] stream reflects changes automatically;
/// derived one-shot providers (dashboard stats, occupancy trend, the tenant's
/// lease view) are invalidated explicitly since they don't watch the table.
final class TenancyControllerProvider
    extends $AsyncNotifierProvider<TenancyController, void> {
  /// Assign / update / end / delete tenancies. Returns `true` on success.
  /// The realtime [tenanciesByUnit] stream reflects changes automatically;
  /// derived one-shot providers (dashboard stats, occupancy trend, the tenant's
  /// lease view) are invalidated explicitly since they don't watch the table.
  TenancyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenancyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenancyControllerHash();

  @$internal
  @override
  TenancyController create() => TenancyController();
}

String _$tenancyControllerHash() => r'9ae6d2af323de0aa8a474472a6653a0b2d3f8e0e';

/// Assign / update / end / delete tenancies. Returns `true` on success.
/// The realtime [tenanciesByUnit] stream reflects changes automatically;
/// derived one-shot providers (dashboard stats, occupancy trend, the tenant's
/// lease view) are invalidated explicitly since they don't watch the table.

abstract class _$TenancyController extends $AsyncNotifier<void> {
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
