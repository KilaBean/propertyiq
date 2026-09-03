import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light & dark [ThemeData] for PropertyIQ, built from the design system:
/// deep-green brand, Inter type scale, subtle shadows, generous whitespace.
///
/// Inter is bundled as a local asset (assets/fonts/Inter-Variable.ttf,
/// declared under pubspec.yaml's `fonts:`) rather than loaded through the
/// google_fonts package. google_fonts fetches font files over the network on
/// first use unless assets are pre-bundled to its exact naming convention,
/// which produced a visible flash of the fallback font on a slow connection
/// and an avoidable network dependency for something that should ship with
/// the binary. A single variable font covers every weight the theme uses.
class AppTheme {
  const AppTheme._();

  static const double _radius = 16;

  static ThemeData light() => _build(_lightScheme, AppColors.background, true);
  static ThemeData dark() => _build(_darkScheme, AppColors.backgroundDark, false);

  // ── Color schemes ─────────────────────────────────────────────────────────
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFE2E8FF),
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
    error: AppColors.error,
    onError: Colors.white,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.primaryLight,
    onPrimary: const Color(0xFF0A1230),
    primaryContainer: const Color(0xFF273169),
    onPrimaryContainer: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark,
    error: AppColors.error,
    onError: Colors.white,
  );

  // ── Builder ───────────────────────────────────────────────────────────────
  static ThemeData _build(ColorScheme scheme, Color background, bool isLight) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      extensions: const [AppStatusColors.light],
    );

    return base.copyWith(
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: _inter(
          fontSize: 20,
          height: 26 / 20,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isLight ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        color: scheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(
            color: scheme.outlineVariant,
            width: isLight ? 0 : 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.5),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: _inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  /// Builds a [TextStyle] on the bundled Inter font. Named to match the
  /// call sites this replaced (`GoogleFonts.inter(...)`) so the diff that
  /// introduced it stayed small; only the parameters this theme actually
  /// uses are exposed.
  static TextStyle _inter({
    double? fontSize,
    double? height,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      height: height,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
    );
  }

  /// Inter type scale from the design system.
  static TextTheme _textTheme(ColorScheme scheme) {
    final primary = scheme.onSurface;
    final secondary = scheme.onSurfaceVariant;
    TextStyle s(double size, double lineHeight, FontWeight weight,
            {Color? color, double? spacing}) =>
        _inter(
          fontSize: size,
          height: lineHeight / size,
          fontWeight: weight,
          color: color ?? primary,
          letterSpacing: spacing,
        );

    return TextTheme(
      displaySmall: s(32, 38, FontWeight.w700, spacing: -0.5), // Display
      headlineSmall: s(24, 30, FontWeight.w600), // Heading 1
      titleLarge: s(20, 26, FontWeight.w600), // Heading 2
      titleMedium: s(16, 22, FontWeight.w600), // Heading 3
      bodyLarge: s(16, 24, FontWeight.w400),
      bodyMedium: s(14, 20, FontWeight.w400), // Body
      bodySmall: s(12, 16, FontWeight.w400, color: secondary), // Caption
      labelLarge: s(14, 18, FontWeight.w600),
      labelSmall: s(11, 14, FontWeight.w600, color: secondary),
    );
  }
}
