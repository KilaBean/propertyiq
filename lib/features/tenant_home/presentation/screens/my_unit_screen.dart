import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/profile_top_bar.dart';
import '../../../../core/widgets/round_icon_button.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/tenancy_status.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../tenancies/presentation/providers/tenancy_providers.dart';

/// Tenant home: profile header + the tenant's active lease (unit, property,
/// rent terms).
class MyUnitScreen extends ConsumerWidget {
  const MyUnitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final lease = ref.watch(tenantLeaseProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ProfileTopBar(
                name: (profile?.fullName.isNotEmpty ?? false)
                    ? profile!.fullName
                    : 'Welcome back',
                roleLabel: 'Tenant',
                avatarPath: profile?.avatarPath,
                actions: [
                  RoundIconButton(
                    icon: Icons.notifications_none,
                    onTap: () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(content: Text('No new notifications')),
                      ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(tenantLeaseProvider),
                child: AsyncValueView(
                  value: lease,
                  onRetry: () => ref.invalidate(tenantLeaseProvider),
                  data: (lease) {
                    if (lease == null) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          EmptyState(
                            icon: Icons.home_work_outlined,
                            title: 'No active lease yet',
                            message:
                                "When your manager assigns you to a unit, it'll "
                                "appear here.",
                          ),
                        ],
                      );
                    }
                    return _LeaseView(lease: lease);
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

class _LeaseView extends StatelessWidget {
  const _LeaseView({required this.lease});

  final TenantLease lease;

  @override
  Widget build(BuildContext context) {
    final currency = lease.property.currency;
    final t = lease.tenancy;

    return ListView(
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
                      Text(lease.property.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(lease.unit.label,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                StatusBadge(
                  label: t.status.label,
                  tone: t.status == TenancyStatus.active
                      ? StatusTone.success
                      : StatusTone.neutral,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        InfoCard(
          title: 'Lease',
          children: [
            InfoRow(
              label: 'Rent',
              value:
                  '${formatMoney(t.rentAmount, currency)} · ${t.rentCycle.label}',
            ),
            if (t.startDate != null)
              InfoRow(label: 'Start', value: formatDate(t.startDate!)),
            if (t.endDate != null)
              InfoRow(label: 'End', value: formatDate(t.endDate!)),
          ],
        ),
      ],
    );
  }
}
