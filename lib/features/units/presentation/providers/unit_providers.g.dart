// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live list of units within a property.

@ProviderFor(unitsList)
final unitsListProvider = UnitsListFamily._();

/// Live list of units within a property.

final class UnitsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Unit>>,
          List<Unit>,
          Stream<List<Unit>>
        >
    with $FutureModifier<List<Unit>>, $StreamProvider<List<Unit>> {
  /// Live list of units within a property.
  UnitsListProvider._({
    required UnitsListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'unitsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unitsListHash();

  @override
  String toString() {
    return r'unitsListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Unit>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Unit>> create(Ref ref) {
    final argument = this.argument as String;
    return unitsList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UnitsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unitsListHash() => r'bb0b3f61362829a46f15ecf0732f82cc81c89f0d';

/// Live list of units within a property.

final class UnitsListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Unit>>, String> {
  UnitsListFamily._()
    : super(
        retry: null,
        name: r'unitsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Live list of units within a property.

  UnitsListProvider call(String propertyId) =>
      UnitsListProvider._(argument: propertyId, from: this);

  @override
  String toString() => r'unitsListProvider';
}
