import 'package:flutter/material.dart';

/// Confirms the outcome of inviting a tenant.
///
/// This deliberately shows no credential. Tenants set their own password from
/// the link emailed to them, so the manager never holds one — see
/// `supabase/functions/invite-tenant` and docs/tenant-invites.md.
Future<void> showTenantInviteDialog(
  BuildContext context, {
  required String email,
  required bool invited,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        invited ? Icons.mark_email_read_outlined : Icons.link_outlined,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: Text(invited ? 'Invite sent' : 'Tenant linked'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invited
                ? "We've emailed an invite to:"
                : 'This address already has a PropertyIQ account:',
          ),
          const SizedBox(height: 8),
          SelectableText(
            email,
            style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            invited
                ? 'They set their own password from the link, then sign in. '
                    'If it does not arrive, check their spam folder or resend '
                    'from the unit.'
                : 'They have been assigned to this unit and will see it the '
                    'next time they sign in.',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

/// Confirms that a password-reset email is on its way to the tenant.
Future<void> showPasswordResetSentDialog(
  BuildContext context, {
  required String email,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        Icons.mark_email_read_outlined,
        color: Theme.of(ctx).colorScheme.primary,
      ),
      title: const Text('Reset link sent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('We emailed a password reset link to:'),
          const SizedBox(height: 8),
          SelectableText(
            email,
            style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Their current password keeps working until they set a new one.',
            style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
