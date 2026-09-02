// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aggregates property + unit counts and occupancy. Recomputes when the
/// property list changes; unit mutations invalidate it explicitly.

@ProviderFor(dashboardStats)
final dashboardStatsProvider = DashboardStatsProvider._();

/// Aggregates property + unit counts and occupancy. Recomputes when the
/// property list changes; unit mutations invalidate it explicitly.

final class DashboardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          FutureOr<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $FutureProvider<DashboardStats> {
  /// Aggregates property + unit counts and occupancy. Recomputes when the
  /// property list changes; unit mutations invalidate it explicitly.
  DashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardStats> create(Ref ref) {
    return dashboardStats(ref);
  }
}

String _$dashboardStatsHash() => r'54de6755677dec8140e77258ee76b8d7a89c3e34';

/// The chart's currently selected period (toggled by the "Monthly ▾" menu).

@ProviderFor(OccupancyPeriodSelection)
final occupancyPeriodSelectionProvider = OccupancyPeriodSelectionProvider._();

/// The chart's currently selected period (toggled by the "Monthly ▾" menu).
final class OccupancyPeriodSelectionProvider
    extends $NotifierProvider<OccupancyPeriodSelection, OccupancyPeriod> {
  /// The chart's currently selected period (toggled by the "Monthly ▾" menu).
  OccupancyPeriodSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'occupancyPeriodSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$occupancyPeriodSelectionHash();

  @$internal
  @override
  OccupancyPeriodSelection create() => OccupancyPeriodSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OccupancyPeriod value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OccupancyPeriod>(value),
    );
  }
}

String _$occupancyPeriodSelectionHash() =>
    r'3436b32e1b2de9853b618eda25d2593e438512af';

/// The chart's currently selected period (toggled by the "Monthly ▾" menu).

abstract class _$OccupancyPeriodSelection extends $Notifier<OccupancyPeriod> {
  OccupancyPeriod build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OccupancyPeriod, OccupancyPeriod>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OccupancyPeriod, OccupancyPeriod>,
              OccupancyPeriod,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Occupancy rate over time. A unit counts as occupied in a given month if any
/// tenancy's [start_date, end_date] range overlaps that month — this reflects
/// history even for tenancies that have since ended, unlike the
/// current-snapshot `unitCount`/`occupiedCount` above.
///
/// - [OccupancyPeriod.monthly] — the last 6 calendar months (oldest first).
/// - [OccupancyPeriod.yearly] — the last 5 years (oldest first), each point is
///   the average of that year's monthly rates (only months up to now for the
///   current year, so it isn't dragged down by unelapsed months).

@ProviderFor(occupancyTrend)
final occupancyTrendProvider = OccupancyTrendFamily._();

/// Occupancy rate over time. A unit counts as occupied in a given month if any
/// tenancy's [start_date, end_date] range overlaps that month — this reflects
/// history even for tenancies that have since ended, unlike the
/// current-snapshot `unitCount`/`occupiedCount` above.
///
/// - [OccupancyPeriod.monthly] — the last 6 calendar months (oldest first).
/// - [OccupancyPeriod.yearly] — the last 5 years (oldest first), each point is
///   the average of that year's monthly rates (only months up to now for the
///   current year, so it isn't dragged down by unelapsed months).

final class OccupancyTrendProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OccupancyPoint>>,
          List<OccupancyPoint>,
          FutureOr<List<OccupancyPoint>>
        >
    with
        $FutureModifier<List<OccupancyPoint>>,
        $FutureProvider<List<OccupancyPoint>> {
  /// Occupancy rate over time. A unit counts as occupied in a given month if any
  /// tenancy's [start_date, end_date] range overlaps that month — this reflects
  /// history even for tenancies that have since ended, unlike the
  /// current-snapshot `unitCount`/`occupiedCount` above.
  ///
  /// - [OccupancyPeriod.monthly] — the last 6 calendar months (oldest first).
  /// - [OccupancyPeriod.yearly] — the last 5 years (oldest first), each point is
  ///   the average of that year's monthly rates (only months up to now for the
  ///   current year, so it isn't dragged down by unelapsed months).
  OccupancyTrendProvider._({
    required OccupancyTrendFamily super.from,
    required OccupancyPeriod super.argument,
  }) : super(
         retry: null,
         name: r'occupancyTrendProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$occupancyTrendHash();

  @override
  String toString() {
    return r'occupancyTrendProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OccupancyPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OccupancyPoint>> create(Ref ref) {
    final argument = this.argument as OccupancyPeriod;
    return occupancyTrend(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OccupancyTrendProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$occupancyTrendHash() => r'9da2fd8d5e6c1c4a1bcfd5c3e4feb4326f16deb3';

/// Occupancy rate over time. A unit counts as occupied in a given month if any
/// tenancy's [start_date, end_date] range overlaps that month — this reflects
/// history even for tenancies that have since ended, unlike the
/// current-snapshot `unitCount`/`occupiedCount` above.
///
/// - [OccupancyPeriod.monthly] — the last 6 calendar months (oldest first).
/// - [OccupancyPeriod.yearly] — the last 5 years (oldest first), each point is
///   the average of that year's monthly rates (only months up to now for the
///   current year, so it isn't dragged down by unelapsed months).

final class OccupancyTrendFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<OccupancyPoint>>,
          OccupancyPeriod
        > {
  OccupancyTrendFamily._()
    : super(
        retry: null,
        name: r'occupancyTrendProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Occupancy rate over time. A unit counts as occupied in a given month if any
  /// tenancy's [start_date, end_date] range overlaps that month — this reflects
  /// history even for tenancies that have since ended, unlike the
  /// current-snapshot `unitCount`/`occupiedCount` above.
  ///
  /// - [OccupancyPeriod.monthly] — the last 6 calendar months (oldest first).
  /// - [OccupancyPeriod.yearly] — the last 5 years (oldest first), each point is
  ///   the average of that year's monthly rates (only months up to now for the
  ///   current year, so it isn't dragged down by unelapsed months).

  OccupancyTrendProvider call(OccupancyPeriod period) =>
      OccupancyTrendProvider._(argument: period, from: this);

  @override
  String toString() => r'occupancyTrendProvider';
}
