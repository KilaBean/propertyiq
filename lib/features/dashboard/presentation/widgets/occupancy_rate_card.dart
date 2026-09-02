import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/async_value_view.dart';
import '../providers/dashboard_providers.dart';

/// Occupancy rate over time, with a Monthly/Yearly toggle — self-contained
/// (reads its own providers) so it can be dropped anywhere.
class OccupancyRateCard extends ConsumerWidget {
  const OccupancyRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(occupancyPeriodSelectionProvider);
    final trend = ref.watch(occupancyTrendProvider(period));
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Occupancy Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _PeriodMenu(
                  selected: period,
                  onSelected: (p) => ref
                      .read(occupancyPeriodSelectionProvider.notifier)
                      .select(p),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 190,
              child: AsyncValueView(
                value: trend,
                onRetry: () => ref.invalidate(occupancyTrendProvider(period)),
                data: (points) => points.every((p) => p.rate == 0)
                    ? Center(
                        child: Text(
                          'No occupancy history yet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : _Chart(points: points, scheme: scheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodMenu extends StatelessWidget {
  const _PeriodMenu({required this.selected, required this.onSelected});

  final OccupancyPeriod selected;
  final ValueChanged<OccupancyPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<OccupancyPeriod>(
      initialValue: selected,
      onSelected: onSelected,
      offset: const Offset(0, 32),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => const [
        PopupMenuItem(value: OccupancyPeriod.monthly, child: Text('Monthly')),
        PopupMenuItem(value: OccupancyPeriod.yearly, child: Text('Yearly')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected == OccupancyPeriod.monthly ? 'Monthly' : 'Yearly',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            Icon(Icons.expand_more, size: 18, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.points, required this.scheme});

  final List<OccupancyPoint> points;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        groupsSpace: 18,
        gridData: FlGridData(
          horizontalInterval: 25,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: scheme.outlineVariant, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 25,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= points.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    points[i].label,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => scheme.inverseSurface,
            getTooltipItem: (group, _, rod, _) => BarTooltipItem(
              '${rod.toY.round()}%',
              TextStyle(color: scheme.onInverseSurface),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < points.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: points[i].rate,
                  width: 20,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scheme.primary.withValues(alpha: 0.55),
                      scheme.primary,
                    ],
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: 100,
                    color: scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
