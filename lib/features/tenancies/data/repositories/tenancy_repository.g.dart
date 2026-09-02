// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenancy_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tenancyRepository)
final tenancyRepositoryProvider = TenancyRepositoryProvider._();

final class TenancyRepositoryProvider
    extends
        $FunctionalProvider<
          TenancyRepository,
          TenancyRepository,
          TenancyRepository
        >
    with $Provider<TenancyRepository> {
  TenancyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenancyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenancyRepositoryHash();

  @$internal
  @override
  $ProviderElement<TenancyRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TenancyRepository create(Ref ref) {
    return tenancyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TenancyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TenancyRepository>(value),
    );
  }
}

String _$tenancyRepositoryHash() => r'62562c87d00c05e1fc65cb336aedde364a32cca4';
