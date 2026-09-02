// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / update / delete for properties. Surfaces loading/error via
/// [AsyncValue].

@ProviderFor(PropertyController)
final propertyControllerProvider = PropertyControllerProvider._();

/// Create / update / delete for properties. Surfaces loading/error via
/// [AsyncValue].
final class PropertyControllerProvider
    extends $AsyncNotifierProvider<PropertyController, void> {
  /// Create / update / delete for properties. Surfaces loading/error via
  /// [AsyncValue].
  PropertyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propertyControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propertyControllerHash();

  @$internal
  @override
  PropertyController create() => PropertyController();
}

String _$propertyControllerHash() =>
    r'195d256f096f7f60390332ac8fe2393380f86d62';

/// Create / update / delete for properties. Surfaces loading/error via
/// [AsyncValue].

abstract class _$PropertyController extends $AsyncNotifier<void> {
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
