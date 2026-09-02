import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Shows a tenant's login details for the manager to share. Used after inviting
/// a tenant and after resetting their password. [password] is null when no new
/// password was issued (e.g. the tenant already had an account).
Future<void> showTenantCredentialsDialog(
  BuildContext context, {
  required String email,
  required String? password,
}) {
  final hasPassword = password != null;
  final shareText = 'Your PropertyIQ login\n\n'
      'Email: $email\n'
      'Password: $password\n\n'
      'Install PropertyIQ and sign in. You can change your password under '
      'Profile.';

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(hasPassword ? 'Tenant login' : 'No new password'),
      content: hasPassword
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send these login details to your tenant:'),
                const SizedBox(height: 12),
                SelectableText('Email: $email'),
                SelectableText('Password: $password'),
              ],
            )
          : Text(
              '$email already has a PropertyIQ account. Share their existing '
              'login, or they can use “Forgot password”.',
            ),
      actions: [
        if (hasPassword)
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: shareText));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Copied')),
              );
            },
            child: const Text('Copy'),
          ),
        if (hasPassword)
          FilledButton.icon(
            onPressed: () =>
                SharePlus.instance.share(ShareParams(text: shareText)),
            icon: const Icon(Icons.share),
            label: const Text('Send'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}
