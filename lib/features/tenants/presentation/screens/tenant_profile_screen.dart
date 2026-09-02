import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/tenancy.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Arguments for the manager-facing tenant profile (passed via GoRouter extra).
class TenantProfileArgs {
  const TenantProfileArgs({
    required this.tenancy,
    required this.unitLabel,
    required this.propertyName,
    required this.currency,
  });

  final Tenancy tenancy;
  final String unitLabel;
  final String propertyName;
  final String currency;
}

/// Manager's view of a tenant: identity, contact, and lease terms.
class TenantProfileScreen extends ConsumerWidget {
  const TenantProfileScreen({super.key, required this.args});

  final TenantProfileArgs args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = args.tenancy;
    final profile =
        t.tenantId == null ? null : ref.watch(profileByIdProvider(t.tenantId!)).value;
    final name = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName
        : t.tenantEmail;
    final phone = profile?.phone;

    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AvatarCircle(
                    name: name,
                    avatarPath: profile?.avatarPath,
                    radius: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${args.propertyName} · ${args.unitLabel}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    label: t.tenantId == null ? 'Invited' : 'Active',
                    tone: t.tenantId == null
                        ? StatusTone.warning
                        : StatusTone.success,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: (phone != null && phone.isNotEmpty)
                      ? () => _launch(Uri(scheme: 'tel', path: phone))
                      : null,
                  icon: const Icon(Icons.call),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _launch(Uri(scheme: 'mailto', path: t.tenantEmail)),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Email'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Lease',
            children: [
              InfoRow(
                label: 'Rent',
                value:
                    '${formatMoney(t.rentAmount, args.currency)} · ${t.rentCycle.label}',
              ),
              InfoRow(
                label: 'Monthly utility',
                value: formatMoney(t.utilityAmount, args.currency),
              ),
              InfoRow(
                label: 'Security deposit',
                value: formatMoney(t.depositAmount, args.currency),
              ),
              if (t.startDate != null)
                InfoRow(label: 'Start', value: formatDate(t.startDate!)),
              if (t.endDate != null)
                InfoRow(label: 'End', value: formatDate(t.endDate!)),
              InfoRow(label: 'Status', value: t.status.label),
            ],
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Contact',
            children: [
              InfoRow(label: 'Email', value: t.tenantEmail),
              InfoRow(
                label: 'Phone',
                value: (phone != null && phone.isNotEmpty) ? phone : '—',
              ),
              if (t.emergencyContact != null &&
                  t.emergencyContact!.isNotEmpty)
                InfoRow(label: 'Emergency', value: t.emergencyContact!),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}
