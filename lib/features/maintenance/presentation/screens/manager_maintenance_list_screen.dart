import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/maintenance_chips.dart';

/// Manager view: all maintenance requests across their units.
class ManagerMaintenanceListScreen extends ConsumerWidget {
  const ManagerMaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(managerRequestsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Maintenance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(managerRequestsProvider),
                child: AsyncValueView(
                  value: requests,
                  onRetry: () => ref.invalidate(managerRequestsProvider),
                  data: (items) {
                    if (items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.build_outlined,
                            title: 'No maintenance requests',
                            message:
                                'Requests filed by your tenants will appear here.',
                          ),
                        ],
                      );
                    }
                    return ResponsiveCardList(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      childAspectRatio: 2.6,
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final v = items[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(v.request.title),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child:
                                  Text('${v.propertyName} · ${v.unitLabel}'),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                PriorityChip(priority: v.request.priority),
                                const SizedBox(height: 6),
                                StatusChip(status: v.request.status),
                              ],
                            ),
                            onTap: () => context
                                .push(AppRoutes.maintenanceDetail(v.request.id)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
