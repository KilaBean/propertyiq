import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/supabase/supabase_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../properties/presentation/providers/property_providers.dart';
import '../../../tenancies/data/repositories/tenancy_repository.dart';

part 'dashboard_providers.g.dart';

/// Immutable snapshot of the manager's portfolio for the dashboard KPIs.
class DashboardStats {
  const DashboardStats({
    required this.propertyCount,
    required this.unitCount,
    required this.occupiedCount,
  });

  final int propertyCount;
  final int unitCount;
  final int occupiedCount;

  int get vacantCount => unitCount - occupiedCount;

  /// 0.0–1.0; defined as 0 when there are no units (avoids divide-by-zero).
  double get occupancyRate => unitCount == 0 ? 0 : occupiedCount / unitCount;

  static const empty =
      DashboardStats(propertyCount: 0, unitCount: 0, occupiedCount: 0);
}

/// Aggregates property + unit counts and occupancy. Recomputes when the
/// property list changes; unit mutations invalidate it explicitly.
@riverpod
Future<DashboardStats> dashboardStats(Ref ref) async {
  final uid = ref.watch(sessionProvider)?.user.id;
  if (uid == null) return DashboardStats.empty;

  // Reactivity to property add/remove via the realtime list.
  final properties = await ref.watch(propertiesListProvider.future);

  // RLS scopes this to the manager's own units; only `status` is needed.
  final rows = await ref
      .watch(supabaseClientProvider)
      .from('units')
      .select('status');

  final occupied = rows.where((r) => r['status'] == 'occupied').length;

  return DashboardStats(
    propertyCount: properties.length,
    unitCount: rows.length,
    occupiedCount: occupied,
  );
}

/// One point on the occupancy trend chart: a period label + occupancy % (0-100).
class OccupancyPoint {
  const OccupancyPoint({required this.label, required this.rate});

  final String label;
  final double rate;
}

/// Which grouping the occupancy chart is showing.
enum OccupancyPeriod { monthly, yearly }

/// The chart's currently selected period (toggled by the "Monthly ▾" menu).
@riverpod
class OccupancyPeriodSelection extends _$OccupancyPeriodSelection {
  @override
  OccupancyPeriod build() => OccupancyPeriod.monthly;

  void select(OccupancyPeriod period) => state = period;
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
@riverpod
Future<List<OccupancyPoint>> occupancyTrend(
  Ref ref,
  OccupancyPeriod period,
) async {
  final stats = await ref.watch(dashboardStatsProvider.future);
  final totalUnits = stats.unitCount;
  final ranges = await ref.watch(tenancyRepositoryProvider).fetchDateRanges();
  final now = DateTime.now();

  double monthlyRate(DateTime monthStart, DateTime monthEnd) {
    if (totalUnits == 0) return 0;
    final occupiedUnitIds = <String>{};
    for (final r in ranges) {
      final startRaw = r['start_date'] as String?;
      if (startRaw == null) continue;
      final start = DateTime.parse(startRaw);
      final endRaw = r['end_date'] as String?;
      final end = endRaw == null ? null : DateTime.parse(endRaw);

      final overlaps =
          !start.isAfter(monthEnd) && (end == null || !end.isBefore(monthStart));
      if (overlaps) occupiedUnitIds.add(r['unit_id'] as String);
    }
    return occupiedUnitIds.length / totalUnits * 100;
  }

  final points = <OccupancyPoint>[];

  if (period == OccupancyPeriod.monthly) {
    final monthFmt = DateFormat.MMM();
    for (var i = 5; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      points.add(OccupancyPoint(
        label: monthFmt.format(monthStart),
        rate: monthlyRate(monthStart, monthEnd),
      ));
    }
  } else {
    for (var i = 4; i >= 0; i--) {
      final year = now.year - i;
      final monthsElapsed = year == now.year ? now.month : 12;
      var sum = 0.0;
      for (var m = 1; m <= monthsElapsed; m++) {
        sum += monthlyRate(DateTime(year, m, 1), DateTime(year, m + 1, 0));
      }
      final avg = monthsElapsed == 0 ? 0.0 : sum / monthsElapsed;
      points.add(OccupancyPoint(label: '$year', rate: avg));
    }
  }

  return points;
}
