import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/avatar_circle.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/single_field_dialog.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../shared/models/profile.dart';
import '../../../../shared/models/user_role.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Shared profile screen (manager or tenant) — identity, contact info, and
/// account actions.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reading `.value` here used to swallow both the loading and the error
    // state, so a failed profile fetch rendered a blank page with no way back.
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: profileAsync,
          onRetry: () => ref.invalidate(currentProfileProvider),
          data: (profile) => _body(context, ref, profile),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, Profile? profile) {
    final email = ref.watch(sessionProvider)?.user.email;
    final isBusy = ref.watch(authControllerProvider).isLoading;
    final name = (profile?.fullName.isNotEmpty ?? false)
        ? profile!.fullName
        : 'Unnamed user';

    return ReadableWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          Center(
            child: Column(
              children: [
                _AvatarPicker(
                  avatarPath: profile?.avatarPath,
                  name: name,
                  busy: isBusy,
                ),
                const SizedBox(height: 12),
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                StatusBadge(
                  label: profile?.role == UserRole.manager
                      ? 'Property manager'
                      : 'Tenant',
                  tone: StatusTone.info,
                  dot: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          InfoCard(
            title: 'Account',
            children: [
              InfoRow(label: 'Email', value: email ?? '—'),
              InfoRow(
                label: 'Phone',
                value: (profile?.phone?.isNotEmpty ?? false)
                    ? profile!.phone!
                    : '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isBusy ? null : () => _changePassword(context, ref),
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: _errorColor(context)),
                  title: Text(
                    'Sign out',
                    style: TextStyle(color: _errorColor(context)),
                  ),
                  onTap: isBusy
                      ? null
                      : () =>
                            ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _errorColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final newPassword = await showSingleFieldDialog(
      context,
      title: 'Change password',
      label: 'New password (min 6)',
      confirmLabel: 'Save',
      obscure: true,
    );
    if (newPassword == null || newPassword.length < 6 || !context.mounted) {
      return;
    }
    final ok = await ref
        .read(authControllerProvider.notifier)
        .changePassword(newPassword);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated')));
    }
  }
}

class _AvatarPicker extends ConsumerWidget {
  const _AvatarPicker({
    required this.avatarPath,
    required this.name,
    required this.busy,
  });

  final String? avatarPath;
  final String name;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: !busy,
      label: 'Change profile photo',
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: busy ? null : () => _pick(context, ref),
          child: Stack(
            children: [
              AvatarCircle(name: name, avatarPath: avatarPath, radius: 44),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return;
    await ref.read(authControllerProvider.notifier).uploadAvatar(picked);
  }
}
