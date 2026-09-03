import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/search_field.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/maintenance_chips.dart';

/// Manager view: all maintenance requests across their units. Loads a page at
/// a time (managerRequestsProvider) and fetches the next as the user nears
/// the bottom of the list.
class ManagerMaintenanceListScreen extends ConsumerStatefulWidget {
  const ManagerMaintenanceListScreen({super.key});

  @override
  ConsumerState<ManagerMaintenanceListScreen> createState() =>
      _ManagerMaintenanceListScreenState();
}

class _ManagerMaintenanceListScreenState
    extends ConsumerState<ManagerMaintenanceListScreen> {
  final _scrollController = ScrollController();
  String _query = '';

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

  // Triggers the next page a little before the physical end of the list, so
  // the next batch is already arriving by the time the user reaches it.
  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(managerRequestsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SearchField(
                hintText: 'Search by title',
                onChanged: (v) {
                  setState(() => _query = v);
                  ref.read(managerRequestsProvider.notifier).search(v);
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(managerRequestsProvider),
                child: AsyncValueView(
                  value: requests,
                  onRetry: () => ref.invalidate(managerRequestsProvider),
                  loading: (_) => const ListSkeleton(hasLeading: false),
                  data: (page) {
                    if (page.items.isEmpty) {
                      final searching = _query.isNotEmpty;
                      return ListView(
                        children: [
                          const SizedBox(height: 120),
                          EmptyState(
                            icon: searching
                                ? Icons.search_off
                                : Icons.build_outlined,
                            title: searching
                                ? 'No matches'
                                : 'No maintenance requests',
                            message: searching
                                ? 'No requests match your search.'
                                : 'Requests filed by your tenants will appear here.',
                          ),
                        ],
                      );
                    }
                    final showSpinner = page.isLoadingMore;
                    return ResponsiveCardList(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
