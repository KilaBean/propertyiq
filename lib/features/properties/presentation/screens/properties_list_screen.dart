import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/search_field.dart';
import '../../../../shared/models/property.dart';
import '../providers/property_providers.dart';

/// The manager's full property list already loads into memory (a realtime
/// stream, not paginated), so search filters it client-side rather than
/// round-tripping to the server.
class PropertiesListScreen extends ConsumerStatefulWidget {
  const PropertiesListScreen({super.key});

  @override
  ConsumerState<PropertiesListScreen> createState() =>
      _PropertiesListScreenState();
}

class _PropertiesListScreenState extends ConsumerState<PropertiesListScreen> {
  String _query = '';

  List<Property> _filter(List<Property> items) {
    if (_query.isEmpty) return items;
    final q = _query.toLowerCase();
    return items
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            (p.address?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final properties = ref.watch(propertiesListProvider);

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
                      'Properties',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: SearchField(
                hintText: 'Search properties',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: properties,
                onRetry: () => ref.invalidate(propertiesListProvider),
                loading: (_) => const ListSkeleton(),
                data: (allItems) {
                  if (allItems.isEmpty) {
                    return EmptyState(
                      icon: Icons.apartment_outlined,
                      title: 'No properties yet',
                      message:
                          'Add your first property to start tracking units.',
                      actionLabel: 'Add property',
                      onAction: () => context.push(AppRoutes.propertyNew),
                    );
                  }
                  final items = _filter(allItems);
                  if (items.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No matches',
                      message: 'No properties match your search.',
                    );
                  }
                  return ResponsiveCardList(
                    itemCount: items.length,
                    itemBuilder: (context, i) => PropertyCard(
                      property: items[i],
                      onTap: () =>
                          context.push(AppRoutes.propertyDetail(items[i].id)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
