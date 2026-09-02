import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/property_card.dart';
import '../providers/property_providers.dart';

class PropertiesListScreen extends ConsumerWidget {
  const PropertiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Expanded(
              child: AsyncValueView(
                value: properties,
                onRetry: () => ref.invalidate(propertiesListProvider),
                data: (items) {
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.apartment_outlined,
                      title: 'No properties yet',
                      message: 'Add your first property to start tracking units.',
                      actionLabel: 'Add property',
                      onAction: () => context.push(AppRoutes.propertyNew),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
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
