import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'signed_network_image.dart';

/// A circular avatar that shows the user's uploaded photo (via a signed URL)
/// when [avatarPath] is set, falling back to their initials otherwise — used
/// on the manager/tenant profile screens and the Tenant Profile detail.
class AvatarCircle extends ConsumerWidget {
  const AvatarCircle({
    super.key,
    required this.name,
    this.avatarPath,
    this.radius = 36,
  });

  final String name;
  final String? avatarPath;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final path = avatarPath;

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: (path != null && path.isNotEmpty)
              ? _NetworkOrInitials(path: path, name: name)
              : _Initials(name: name),
        ),
      ),
    );
  }
}

class _NetworkOrInitials extends ConsumerWidget {
  const _NetworkOrInitials({required this.path, required this.name});

  final String path;
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(avatarUrlProvider(path));
    // The size actually painted here is the CircleAvatar's diameter, set by
    // the parent -- but that isn't known inside this widget, so fall back to
    // a size generous enough for any radius this app actually uses.
    return url.when(
      data: (u) => SignedNetworkImage(
        url: u,
        cacheKey: path,
        displayWidth: 96,
        displayHeight: 96,
        errorWidget: _Initials(name: name),
      ),
      loading: () => _Initials(name: name),
      error: (_, _) => _Initials(name: name),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? '?'
        : parts.length == 1
            ? parts.first.substring(0, 1).toUpperCase()
            : (parts.first.substring(0, 1) + parts[1].substring(0, 1))
                .toUpperCase();
    return ColoredBox(
      color: scheme.primaryContainer,
      child: Center(
        child: Text(
          initials,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
