import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/metric_card.dart';
import '../../../../core/widgets/profile_top_bar.dart';
import '../../../../core/widgets/round_icon_button.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../maintenance/data/repositories/maintenance_repository.dart';
import '../../../maintenance/presentation/providers/maintenance_providers.dart';
import '../../../maintenance/presentation/widgets/maintenance_chips.dart';
import '../../../../shared/models/maintenance_status.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/occupancy_rate_card.dart';

/// Manager home: portfolio KPIs + recent activity. Navigation lives in the
/// bottom bar.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final name = profile?.fullName ?? '';
    final stats = ref.watch(dashboardStatsProvider);
    final requests = ref.watch(managerRequestsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(managerRequestsProvider);
            ref.invalidate(occupancyTrendProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _TopNav(name: name, avatarPath: profile?.avatarPath),
              const SizedBox(height: 24),
              Text(
                'Property Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AsyncValueView(
                value: stats,
                onRetry: () => ref.invalidate(dashboardStatsProvider),
                data: (s) => _Metrics(stats: s),
                loading: (_) => const _MetricsSkeleton(),
              ),
              const SizedBox(height: 16),
              const OccupancyRateCard(),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent activity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.maintenance),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              requests.when(
                skipLoadingOnReload: true,
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text(
                  'Could not load activity.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                data: (page) {
                  // managerRequestsProvider is paginated (loads a page at a
                  // time, newest first); the card only ever shows the 5 most
                  // recent, which the first page always covers.
                  final items = page.items;
                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No maintenance activity yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }
                  final recent = items.take(5).toList();
                  return Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < recent.length; i++) ...[
                          _ActivityRow(view: recent[i]),
                          if (i != recent.length - 1)
                            Divider(
                              height: 1,
                              indent: 68,
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.name, this.avatarPath});

  final String name;
  final String? avatarPath;

  @override
  Widget build(BuildContext context) {
    return ProfileTopBar(
      name: name.isEmpty ? 'Welcome back' : name,
      roleLabel: 'Property manager',
      avatarPath: avatarPath,
      actions: [
        RoundIconButton(
          icon: Icons.add,
          label: 'New property',
          onTap: () => context.push(AppRoutes.propertyNew),
        ),
        RoundIconButton(
          icon: Icons.notifications_none,
          label: 'Notifications',
          onTap: () => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.view});

  final MaintenanceView view;

  @override
  Widget build(BuildContext context) {
    final r = view.request;
    final s = Theme.of(context).extension<AppStatusColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final tone = switch (r.status) {
      MaintenanceStatus.open => s.warning,
      MaintenanceStatus.inProgress => scheme.primary,
      MaintenanceStatus.resolved => s.success,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: tone.withValues(alpha: 0.12),
        child: Icon(Icons.build_outlined, color: tone, size: 18),
      ),
      title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        'Unit ${view.unitLabel}'
        '${r.createdAt != null ? ' · ${timeAgo(r.createdAt!)}' : ''}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusChip(status: r.status),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
      onTap: () => context.push(AppRoutes.maintenanceDetail(r.id)),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<AppStatusColors>()!;
    final cards = [
      MetricCard(
        label: 'Properties',
        value: '${stats.propertyCount}',
        icon: Icons.apartment,
      ),
      MetricCard(
        label: 'Units',
        value: '${stats.unitCount}',
        icon: Icons.meeting_room_outlined,
      ),
      MetricCard(
        label: 'Occupied',
        value: '${stats.occupiedCount}',
        icon: Icons.check_circle_outline,
        color: statusColors.success,
      ),
      MetricCard(
        label: 'Occupancy',
        value: '${(stats.occupancyRate * 100).round()}%',
        icon: Icons.pie_chart_outline,
        color: statusColors.warning,
      ),
    ];

    return _metricsGrid(cards);
  }
}

// Shared by _Metrics and _MetricsSkeleton so the loading state occupies
// exactly the layout the real cards will land in -- swapping one for the
// other shouldn't visibly reflow the page.
Widget _metricsGrid(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 600 ? 4 : 2;
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          mainAxisExtent: 132,
        ),
        children: children,
      );
    },
  );
}

class _MetricsSkeleton extends StatelessWidget {
  const _MetricsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _metricsGrid(List.generate(4, (_) => const MetricCardSkeleton()));
  }
}
