import 'package:flutter/material.dart';

/// Branded header for the auth screens — app mark, name, and a contextual
/// title/subtitle. Keeps the login & signup screens visually consistent.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final logoAsset = theme.brightness == Brightness.dark
        ? 'assets/branding/propertyiq_logo_with_text_dark.png'
        : 'assets/branding/propertyiq_logo_with_text.png';
    return Column(
      children: [
        Image.asset(logoAsset, height: 56),
        const SizedBox(height: 28),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
