// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live list of the signed-in manager's properties.

@ProviderFor(propertiesList)
final propertiesListProvider = PropertiesListProvider._();

/// Live list of the signed-in manager's properties.

final class PropertiesListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Property>>,
          List<Property>,
          Stream<List<Property>>
        >
    with $FutureModifier<List<Property>>, $StreamProvider<List<Property>> {
  /// Live list of the signed-in manager's properties.
  PropertiesListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'propertiesListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$propertiesListHash();

  @$internal
  @override
  $StreamProviderElement<List<Property>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Property>> create(Ref ref) {
    return propertiesList(ref);
  }
}

String _$propertiesListHash() => r'71546c5ffe7aca25851c4e3408749d8aa2981073';

/// A single property by id (for the detail/edit screens).

@ProviderFor(propertyDetail)
final propertyDetailProvider = PropertyDetailFamily._();

/// A single property by id (for the detail/edit screens).

final class PropertyDetailProvider
    extends
        $FunctionalProvider<AsyncValue<Property>, Property, FutureOr<Property>>
    with $FutureModifier<Property>, $FutureProvider<Property> {
  /// A single property by id (for the detail/edit screens).
  PropertyDetailProvider._({
    required PropertyDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'propertyDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$propertyDetailHash();

  @override
  String toString() {
    return r'propertyDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Property> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Property> create(Ref ref) {
    final argument = this.argument as String;
    return propertyDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PropertyDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$propertyDetailHash() => r'922eab87393d85c5beeba8329cd2d96cd53dfeb3';

/// A single property by id (for the detail/edit screens).

final class PropertyDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Property>, String> {
  PropertyDetailFamily._()
    : super(
        retry: null,
        name: r'propertyDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single property by id (for the detail/edit screens).

  PropertyDetailProvider call(String id) =>
      PropertyDetailProvider._(argument: id, from: this);

  @override
  String toString() => r'propertyDetailProvider';
}

/// A short-lived signed URL for a stored property cover photo.

@ProviderFor(propertyPhotoUrl)
final propertyPhotoUrlProvider = PropertyPhotoUrlFamily._();

/// A short-lived signed URL for a stored property cover photo.

final class PropertyPhotoUrlProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// A short-lived signed URL for a stored property cover photo.
  PropertyPhotoUrlProvider._({
    required PropertyPhotoUrlFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'propertyPhotoUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$propertyPhotoUrlHash();

  @override
  String toString() {
    return r'propertyPhotoUrlProvider'
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
    return propertyPhotoUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PropertyPhotoUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$propertyPhotoUrlHash() => r'dbb1d145ee02240b5cbcfa89c83282591315a48c';

/// A short-lived signed URL for a stored property cover photo.

final class PropertyPhotoUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, String> {
  PropertyPhotoUrlFamily._()
    : super(
        retry: null,
        name: r'propertyPhotoUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A short-lived signed URL for a stored property cover photo.

  PropertyPhotoUrlProvider call(String path) =>
      PropertyPhotoUrlProvider._(argument: path, from: this);

  @override
  String toString() => r'propertyPhotoUrlProvider';
}
