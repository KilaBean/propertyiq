import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/properties/presentation/providers/property_providers.dart';
import '../../shared/models/property.dart';

class PropertyCard extends ConsumerWidget {
  const PropertyCard({super.key, required this.property, this.onTap});

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final photoPath = property.photoPath;
    final subtitle = property.address?.isNotEmpty == true
        ? property.address!
        : property.currency;

    return Semantics(
      button: onTap != null,
      label: '${property.name}, $subtitle',
      child: ExcludeSemantics(
        child: _card(context, scheme, photoPath, subtitle),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    ColorScheme scheme,
    String? photoPath,
    String subtitle,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: photoPath != null && photoPath.isNotEmpty
            ? _Thumb(path: photoPath)
            : CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.apartment, color: scheme.onPrimaryContainer),
              ),
        title: Text(
          property.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _Thumb extends ConsumerWidget {
  const _Thumb({required this.path});

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final url = ref.watch(propertyPhotoUrlProvider(path));
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: url.when(
          data: (u) => Image.network(
            u,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: scheme.surfaceContainerHighest,
              child: const Icon(Icons.apartment, size: 18),
            ),
          ),
          loading: () => Container(color: scheme.surfaceContainerHighest),
          error: (_, _) => Container(
            color: scheme.surfaceContainerHighest,
            child: const Icon(Icons.apartment, size: 18),
          ),
        ),
      ),
    );
  }
}
