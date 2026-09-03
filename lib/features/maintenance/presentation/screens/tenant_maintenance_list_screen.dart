import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/maintenance_chips.dart';

/// Tenant view: their own maintenance requests. Loads a page at a time
/// (tenantRequestsProvider) and fetches the next as the user nears the
/// bottom of the list.
class TenantMaintenanceListScreen extends ConsumerStatefulWidget {
  const TenantMaintenanceListScreen({super.key});

  @override
  ConsumerState<TenantMaintenanceListScreen> createState() =>
      _TenantMaintenanceListScreenState();
}

class _TenantMaintenanceListScreenState
    extends ConsumerState<TenantMaintenanceListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(tenantRequestsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  data: (page) {
                    if (page.items.isEmpty) {
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
                    final showSpinner = page.isLoadingMore;
                    return ResponsiveCardList(
                      controller: _scrollController,
                      childAspectRatio: 2.6,
                      itemCount: page.items.length + (showSpinner ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == page.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        final v = page.items[i];
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
