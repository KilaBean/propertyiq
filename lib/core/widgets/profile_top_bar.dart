import 'package:flutter/material.dart';

import 'avatar_circle.dart';

/// Header row used on the manager Dashboard and tenant My Unit screens:
/// avatar (real photo if set, else initials), name + role, and trailing
/// round action buttons (e.g. quick-add, notifications).
class ProfileTopBar extends StatelessWidget {
  const ProfileTopBar({
    super.key,
    required this.name,
    required this.roleLabel,
    this.avatarPath,
    this.actions = const [],
  });

  final String name;
  final String roleLabel;
  final String? avatarPath;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarCircle(name: name, avatarPath: avatarPath, radius: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(roleLabel, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          actions[i],
        ],
      ],
    );
  }
}
