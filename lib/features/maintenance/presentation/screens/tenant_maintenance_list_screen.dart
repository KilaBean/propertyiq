import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/maintenance_chips.dart';

/// Tenant view: their own maintenance requests.
class TenantMaintenanceListScreen extends ConsumerWidget {
  const TenantMaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(tenantRequestsProvider);

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
                onRefresh: () async => ref.invalidate(tenantRequestsProvider),
                child: AsyncValueView(
                  value: requests,
                  onRetry: () => ref.invalidate(tenantRequestsProvider),
                  data: (items) {
                    if (items.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.build_outlined,
                            title: 'No requests yet',
                            message:
                                'Report an issue and we’ll route it to your manager.',
                            actionLabel: 'New request',
                            onAction: () =>
                                context.push(AppRoutes.tenantMaintenanceNew),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
                              child: Text(v.request.category.label),
                            ),
                            trailing: StatusChip(status: v.request.status),
                            onTap: () => context.push(
                              AppRoutes.tenantMaintenanceDetail(v.request.id),
                            ),
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
