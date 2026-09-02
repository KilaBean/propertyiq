// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / update / delete for units. Returns `true` on success.
///
/// There is no `status` parameter: occupancy is derived from the unit's
/// tenancies in the database (migration 0012), so it changes by assigning or
/// ending a tenancy, never by editing the unit.

@ProviderFor(UnitController)
final unitControllerProvider = UnitControllerProvider._();

/// Create / update / delete for units. Returns `true` on success.
///
/// There is no `status` parameter: occupancy is derived from the unit's
/// tenancies in the database (migration 0012), so it changes by assigning or
/// ending a tenancy, never by editing the unit.
final class UnitControllerProvider
    extends $AsyncNotifierProvider<UnitController, void> {
  /// Create / update / delete for units. Returns `true` on success.
  ///
  /// There is no `status` parameter: occupancy is derived from the unit's
  /// tenancies in the database (migration 0012), so it changes by assigning or
  /// ending a tenancy, never by editing the unit.
  UnitControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitControllerHash();

  @$internal
  @override
  UnitController create() => UnitController();
}

String _$unitControllerHash() => r'fbdb786be05862420ff9c3fe754c891367e13b19';

/// Create / update / delete for units. Returns `true` on success.
///
/// There is no `status` parameter: occupancy is derived from the unit's
/// tenancies in the database (migration 0012), so it changes by assigning or
/// ending a tenancy, never by editing the unit.

abstract class _$UnitController extends $AsyncNotifier<void> {
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
