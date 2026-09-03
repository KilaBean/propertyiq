import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/tenancy.dart';
import '../../../../shared/models/tenancy_status.dart';
import '../../../../shared/models/unit.dart';
import '../../../../shared/models/unit_status.dart';
import '../../../properties/presentation/providers/property_providers.dart';
import '../../../tenancies/presentation/providers/tenancy_controller.dart';
import '../../../tenancies/presentation/providers/tenancy_providers.dart';
import '../../../tenancies/presentation/widgets/tenant_credentials.dart';
import '../../../tenants/presentation/screens/tenant_profile_screen.dart';
import '../providers/unit_controller.dart';
import '../providers/unit_providers.dart';

/// Manager view of a single unit: details + its tenancy. The unit is read live
/// from the property's unit stream so it stays fresh after edits.
class UnitDetailScreen extends ConsumerWidget {
  const UnitDetailScreen({
    super.key,
    required this.propertyId,
    required this.unitId,
  });

  final String propertyId;
  final String unitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsListProvider(propertyId));
    final property = ref.watch(propertyDetailProvider(propertyId)).value;

    return units.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('$e')),
      ),
      data: (list) {
        final unit = list.firstWhereOrNull((u) => u.id == unitId);
        if (unit == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('This unit no longer exists.')),
          );
        }
        return _UnitDetail(
          propertyId: propertyId,
          unit: unit,
          propertyName: property?.name ?? '',
          currency: property?.currency ?? '',
        );
      },
    );
  }
}

class _UnitDetail extends ConsumerWidget {
  const _UnitDetail({
    required this.propertyId,
    required this.unit,
    required this.propertyName,
    required this.currency,
  });

  final String propertyId;
  final Unit unit;
  final String propertyName;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenancies = ref.watch(tenanciesByUnitProvider(unit.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit unit',
            onPressed: () => context.push(
              AppRoutes.unitEdit(propertyId),
              extra: unit,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete unit',
            onPressed: () => _confirmDeleteUnit(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(unit.label,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                          propertyName,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: unit.status.label,
                    tone: unit.status == UnitStatus.occupied
                        ? StatusTone.success
                        : StatusTone.neutral,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Details',
            children: [
              InfoRow(label: 'Bedrooms', value: '${unit.bedrooms}'),
              InfoRow(
                label: 'Base rent',
                value: formatMoney(unit.baseRent, currency),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Tenancy', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          tenancies.when(
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Could not load tenancy: $e'),
            data: (list) => _TenancySection(
              propertyId: propertyId,
              unit: unit,
              propertyName: propertyName,
              currency: currency,
              tenancies: list,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUnit(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete unit?'),
        content: const Text('This also removes its tenancies.'),
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
    if (ok != true) return;
    final deleted =
        await ref.read(unitControllerProvider.notifier).delete(unit.id);
    if (deleted && context.mounted) context.pop();
  }
}

class _TenancySection extends ConsumerWidget {
  const _TenancySection({
    required this.propertyId,
    required this.unit,
    required this.propertyName,
    required this.currency,
    required this.tenancies,
  });

  final String propertyId;
  final Unit unit;
  final String propertyName;
  final String currency;
  final List<Tenancy> tenancies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active =
        tenancies.firstWhereOrNull((t) => t.status == TenancyStatus.active);

    if (active == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'No active tenant on this unit.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.tenancyNew(propertyId, unit.id)),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Assign tenant'),
          ),
        ],
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(active.tenantEmail,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                StatusBadge(
                  label: active.tenantId == null ? 'Invited' : 'Linked',
                  tone: active.tenantId == null
                      ? StatusTone.warning
                      : StatusTone.success,
                ),
              ],
            ),
            const SizedBox(height: 4),
            InfoRow(
              label: 'Rent',
              value:
                  '${formatMoney(active.rentAmount, currency)} · ${active.rentCycle.label}',
            ),
            if (active.startDate != null)
              InfoRow(label: 'Start', value: formatDate(active.startDate!)),
            if (active.endDate != null)
              InfoRow(label: 'End', value: formatDate(active.endDate!)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.tonal(
                  onPressed: () => context.push(
                    AppRoutes.tenantProfile,
                    extra: TenantProfileArgs(
                      tenancy: active,
                      unitLabel: unit.label,
                      propertyName: propertyName,
                      currency: currency,
                    ),
                  ),
                  child: const Text('Profile'),
                ),
                OutlinedButton(
                  onPressed: () => context.push(
                    AppRoutes.tenancyEdit(propertyId, unit.id),
                    extra: active,
                  ),
                  child: const Text('Edit'),
                ),
                if (active.tenantId != null)
                  TextButton(
                    onPressed: () => _resetPassword(context, ref, active),
                    child: const Text('Reset password'),
                  ),
                TextButton(
                  onPressed: () => _confirmEnd(context, ref, active.id),
                  child: const Text('End tenancy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEnd(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End tenancy?'),
        content: const Text('The unit becomes available for a new tenant.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(tenancyControllerProvider.notifier).end(id);
  }

  Future<void> _resetPassword(
    BuildContext context,
    WidgetRef ref,
    Tenancy tenancy,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset password?'),
        content: Text(
          'Generate a new password for ${tenancy.tenantEmail}? Their current '
          'password stops working, and they will be asked to choose a new one '
          'when they next sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final password =
        await ref.read(tenancyControllerProvider.notifier).resetPassword(
              unitId: tenancy.unitId,
              tenantId: tenancy.tenantId!,
            );
    if (password == null || !context.mounted) return;
    await showTenantCredentialsDialog(
      context,
      email: tenancy.tenantEmail,
      password: password,
    );
  }
}
