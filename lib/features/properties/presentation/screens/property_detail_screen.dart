import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/signed_network_image.dart';
import '../../../../core/widgets/unit_card.dart';
import '../../../../shared/models/property.dart';
import '../../../units/presentation/providers/unit_providers.dart';
import '../providers/property_controller.dart';
import '../providers/property_providers.dart';

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(propertyDetailProvider(propertyId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit property',
            onPressed: () => context.push(AppRoutes.propertyEdit(propertyId)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete property',
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.unitNew(propertyId)),
        icon: const Icon(Icons.add),
        label: const Text('Add unit'),
      ),
      body: AsyncValueView(
        value: detail,
        onRetry: () => ref.invalidate(propertyDetailProvider(propertyId)),
        data: (property) => _Body(property: property),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete property?'),
        content: const Text(
          'This removes the property and all of its units. This cannot be '
          'undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok =
        await ref.read(propertyControllerProvider.notifier).delete(propertyId);
    if (ok && context.mounted) context.pop();
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsListProvider(property.id));

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (property.photoPath != null && property.photoPath!.isNotEmpty)
                _PhotoBanner(path: property.photoPath!),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.name,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            property.address?.isNotEmpty == true
                                ? property.address!
                                : 'No address',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(property.currency,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Units', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        units.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Could not load units: $e'),
          ),
          data: (items) {
            if (items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: EmptyState(
                  icon: Icons.meeting_room_outlined,
                  title: 'No units yet',
                  message: 'Add a unit to this property using the button below.',
                ),
              );
            }
            return Column(
              children: [
                for (final unit in items)
                  UnitCard(
                    unit: unit,
                    currency: property.currency,
                    onTap: () => context.push(
                      AppRoutes.unitDetail(property.id, unit.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PhotoBanner extends ConsumerWidget {
  const _PhotoBanner({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final url = ref.watch(propertyPhotoUrlProvider(path));
    return SizedBox(
      height: 160,
      width: double.infinity,
      child: url.when(
        data: (u) => SignedNetworkImage(
          url: u,
          cacheKey: path,
          // Width is unbounded (double.infinity) here, so only the fixed
          // height constrains the decode -- still far short of the original,
          // which is what actually matters.
          displayHeight: 160,
          errorWidget: Container(color: scheme.surfaceContainerHighest),
        ),
        loading: () => Container(color: scheme.surfaceContainerHighest),
        error: (_, _) => Container(color: scheme.surfaceContainerHighest),
      ),
    );
  }
}
