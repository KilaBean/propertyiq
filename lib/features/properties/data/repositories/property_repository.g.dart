// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(propertyRepository)
final propertyRepositoryProvider = PropertyRepositoryProvider._();

final class PropertyRepositoryProvider
    extends
        $FunctionalProvider<
          PropertyRepository,
          PropertyRepository,
          PropertyRepository
        >
    with $Provider<PropertyRepository> {
  PropertyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propertyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propertyRepositoryHash();

  @$internal
  @override
  $ProviderElement<PropertyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PropertyRepository create(Ref ref) {
    return propertyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PropertyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PropertyRepository>(value),
    );
  }
}

String _$propertyRepositoryHash() =>
    r'b4d8223a8e0df0b89b0e3eb851882cd5e43ae940';
