import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/signed_network_image.dart';
import '../../../../shared/models/maintenance_status.dart';
import '../../../../shared/models/user_role.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/repositories/maintenance_repository.dart';
import '../providers/maintenance_controller.dart';
import '../providers/maintenance_providers.dart';
import '../widgets/maintenance_chips.dart';

/// Request detail. Managers can change status; tenants see it read-only.
class MaintenanceDetailScreen extends ConsumerWidget {
  const MaintenanceDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(maintenanceDetailProvider(requestId));
    final isManager =
        ref.watch(currentProfileProvider).value?.role == UserRole.manager;

    return Scaffold(
      appBar: AppBar(title: const Text('Request')),
      body: AsyncValueView(
        value: detail,
        onRetry: () => ref.invalidate(maintenanceDetailProvider(requestId)),
        data: (view) => _Body(view: view, isManager: isManager),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.view, required this.isManager});

  final MaintenanceView view;
  final bool isManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = view.request;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                r.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: r.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${view.propertyName} · ${view.unitLabel}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (r.description != null && r.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(r.description!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        if (r.photoPaths.isNotEmpty) ...[
          const SizedBox(height: 16),
          _PhotoStrip(paths: r.photoPaths),
        ],
        const SizedBox(height: 20),
        InfoCard(
          title: 'Details',
          children: [
            if (view.tenantName.isNotEmpty)
              InfoRow(label: 'Reported by', value: view.tenantName),
            if (view.propertyAddress.isNotEmpty)
              InfoRow(label: 'Address', value: view.propertyAddress),
            InfoRow(label: 'Category', value: r.category.label),
            InfoRow(
              label: 'Priority',
              valueWidget: PriorityChip(priority: r.priority),
            ),
            if (r.createdAt != null)
              InfoRow(label: 'Reported on', value: formatDate(r.createdAt!)),
          ],
        ),
        // AI triage is manager-facing — hidden from tenants.
        if (isManager &&
            r.aiRecommendation != null &&
            r.aiRecommendation!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _RecommendationCard(
            text: r.aiRecommendation!,
            aiGenerated: r.aiGenerated,
          ),
        ],
        if (isManager) ...[
          const SizedBox(height: 24),
          Text('Update status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<MaintenanceStatus>(
            segments: const [
              ButtonSegment(value: MaintenanceStatus.open, label: Text('Open')),
              ButtonSegment(
                value: MaintenanceStatus.inProgress,
                label: Text('In progress'),
              ),
              ButtonSegment(
                value: MaintenanceStatus.resolved,
                label: Text('Resolved'),
              ),
            ],
            selected: {r.status},
            onSelectionChanged: (sel) => ref
                .read(maintenanceControllerProvider.notifier)
                .setStatus(r.id, sel.first),
          ),
        ],
      ],
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _Thumb(path: paths[i]),
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
    final url = ref.watch(maintenancePhotoUrlProvider(path));
    return Semantics(
      button: true,
      label: 'Attached photo. Activate to view full screen.',
      child: GestureDetector(
        onTap: () => url.whenData((u) => _openViewer(context, u, path)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 88,
            height: 88,
            child: url.when(
              data: (u) => SignedNetworkImage(
                url: u,
                cacheKey: path,
                displayWidth: 88,
                displayHeight: 88,
                errorWidget: Container(
                  color: scheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
              loading: () => Container(color: scheme.surfaceContainerHighest),
              error: (_, _) => Container(
                color: scheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context, String url, String path) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            // No displayWidth/Height -- this is the full-resolution viewer,
            // so the point is to decode at full size, not a thumbnail size.
            child: SignedNetworkImage(url: url, cacheKey: path),
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.text, required this.aiGenerated});

  final String text;
  final bool aiGenerated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  aiGenerated ? 'AI suggestion' : 'Note',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
