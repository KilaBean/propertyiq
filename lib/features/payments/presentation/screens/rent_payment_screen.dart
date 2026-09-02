import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../tenancies/presentation/providers/tenancy_providers.dart';

/// Tenant's rent payment tab. Online payment processing (Flutterwave) is
/// architecture-only for now — this screen shows the real lease/rent terms
/// and a "Pay Rent" action that's honestly labelled as coming soon rather
/// than faking a transaction.
class RentPaymentScreen extends ConsumerWidget {
  const RentPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lease = ref.watch(tenantLeaseProvider);

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
                      'Pay Rent',
                      style: Theme.of(context).textTheme.headlineSmall,
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
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'No active lease yet',
                            message:
                                "When your manager assigns you to a unit, "
                                "you'll be able to pay rent here.",
                          ),
                        ],
                      );
                    }
                    return _PaymentView(lease: lease);
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

class _PaymentView extends StatelessWidget {
  const _PaymentView({required this.lease});

  final TenantLease lease;

  @override
  Widget build(BuildContext context) {
    final currency = lease.property.currency;
    final t = lease.tenancy;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          color: scheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Rent due',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(t.rentAmount, currency),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  t.rentCycle.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Online rent payments are coming soon.'),
                ),
              );
          },
          icon: const Icon(Icons.lock_clock_outlined),
          label: const Text('Pay Rent — coming soon'),
        ),
        const SizedBox(height: 20),
        InfoCard(
          title: 'Lease',
          children: [
            InfoRow(label: 'Property', value: lease.property.name),
            InfoRow(label: 'Unit', value: lease.unit.label),
            if (t.startDate != null)
              InfoRow(label: 'Start', value: formatDate(t.startDate!)),
            if (t.endDate != null)
              InfoRow(label: 'End', value: formatDate(t.endDate!)),
            InfoRow(label: 'Status', value: t.status.label),
          ],
        ),
      ],
    );
  }
}
