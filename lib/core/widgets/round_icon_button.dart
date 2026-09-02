import 'package:flutter/material.dart';

/// A circular, outlined icon button used in screen headers (quick-add,
/// notifications, etc.) — the same shape used across the dashboard and
/// tab-root screens for a consistent top bar.
///
/// [label] is required rather than optional: an icon-only control is invisible
/// to a screen reader without one, and it doubles as the long-press tooltip.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// The design system's minimum touch target. The visible circle is smaller;
  /// the tappable area is padded out to meet it.
  static const double _minTarget = 44;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: scheme.surface,
          shape: CircleBorder(side: BorderSide(color: scheme.outlineVariant)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: _minTarget,
                minHeight: _minTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 20, color: scheme.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
