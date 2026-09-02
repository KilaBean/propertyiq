// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / update / delete for units. Returns `true` on success.

@ProviderFor(UnitController)
final unitControllerProvider = UnitControllerProvider._();

/// Create / update / delete for units. Returns `true` on success.
final class UnitControllerProvider
    extends $AsyncNotifierProvider<UnitController, void> {
  /// Create / update / delete for units. Returns `true` on success.
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

String _$unitControllerHash() => r'3d62029db57b1ee9125121c8b08bbe92701b1e02';

/// Create / update / delete for units. Returns `true` on success.

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
