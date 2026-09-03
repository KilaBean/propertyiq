// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'maintenance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates filing a request (AI triage → insert) and status updates.

@ProviderFor(MaintenanceController)
final maintenanceControllerProvider = MaintenanceControllerProvider._();

/// Orchestrates filing a request (AI triage → insert) and status updates.
final class MaintenanceControllerProvider
    extends $AsyncNotifierProvider<MaintenanceController, void> {
  /// Orchestrates filing a request (AI triage → insert) and status updates.
  MaintenanceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maintenanceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maintenanceControllerHash();

  @$internal
  @override
  MaintenanceController create() => MaintenanceController();
}

String _$maintenanceControllerHash() =>
    r'c8d266196d5ac44a4bacf865fcb7fb071cac5cd8';

/// Orchestrates filing a request (AI triage → insert) and status updates.

abstract class _$MaintenanceController extends $AsyncNotifier<void> {
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
