import 'package:flutter/material.dart';

/// Brand + semantic color tokens. Brand palette adopted from the blue/lavender
/// reference; status colors keep their conventional meanings.
class AppColors {
  const AppColors._();

  // Brand
  static const Color primary = Color(0xFF3E63F0); // royal blue
  static const Color primaryLight = Color(0xFF7B93F6);
  static const Color accent = Color(0xFF5B7BF5);

  // Neutrals (light)
  static const Color background = Color(0xFFEFF1FB); // soft lavender
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF141833); // dark navy
  static const Color textSecondary = Color(0xFF6B7190);
  static const Color border = Color(0xFFE4E7F4);

  // Neutrals (dark)
  static const Color backgroundDark = Color(0xFF0E1020);
  static const Color surfaceDark = Color(0xFF181B2E);
  static const Color textPrimaryDark = Color(0xFFE6E8F5);
  static const Color textSecondaryDark = Color(0xFF99A0C0);
  static const Color borderDark = Color(0xFF2A2E45);

  // Semantic (shared across both themes)
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

/// Status colors exposed via [ThemeExtension] so widgets read them from the
/// theme rather than branching on brightness manually.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.success,
    required this.warning,
    required this.danger,
  });

  final Color success;
  final Color warning;
  final Color danger;

  static const light = AppStatusColors(
    success: AppColors.success,
    warning: AppColors.warning,
    danger: AppColors.error,
  );

  static const dark = light;

  @override
  AppStatusColors copyWith({Color? success, Color? warning, Color? danger}) {
    return AppStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) {
    if (other is! AppStatusColors) return this;
    return AppStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
