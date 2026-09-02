import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Semantic tone for a [StatusBadge].
enum StatusTone { success, warning, danger, info, neutral }

/// A small tinted pill used for statuses and priorities across the app
/// (Paid / Overdue / In progress / Open …). Consistent shape + tone so the
/// same meaning always looks the same.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.dot = true,
  });

  final String label;
  final StatusTone tone;
  final bool dot;

  Color _color(BuildContext context) {
    // Fall back rather than assert: a badge rendered under a Theme that doesn't
    // carry the extension (a dialog with a local theme, a test, a future
    // embedded surface) should still paint, not throw a null-check error.
    final status = Theme.of(context).extension<AppStatusColors>() ??
        AppStatusColors.light;
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      StatusTone.success => status.success,
      StatusTone.warning => status.warning,
      StatusTone.danger => status.danger,
      StatusTone.info => scheme.primary,
      StatusTone.neutral => scheme.onSurfaceVariant,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: EdgeInsets.fromLTRB(dot ? 8 : 10, 4, 10, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            // Purely decorative: it restates the colour, which the label
            // already carries in words.
            ExcludeSemantics(
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
