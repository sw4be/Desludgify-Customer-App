import 'package:flutter/material.dart';

extension DeslugifyThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get appText =>
      isDarkMode ? const Color(0xFFF5F6F7) : const Color(0xFF003D1A);
  Color get appMutedText =>
      isDarkMode ? const Color(0xFFB0B4BC) : const Color(0xFF707970);
  Color get appAccent =>
      isDarkMode ? const Color(0xFFE8EAED) : const Color(0xFF006D38);
  Color get appSurface => isDarkMode ? const Color(0xFF17181C) : Colors.white;
  Color get appSurfaceContainer =>
      isDarkMode ? const Color(0xFF202126) : const Color(0xFFF2F5EE);
  Color get appBorder =>
      isDarkMode ? const Color(0xFF3A3D44) : const Color(0xFFE1E3DD);
  Color get appOnAccent => isDarkMode ? const Color(0xFF08090A) : Colors.white;

  /// Error / destructive color that stays legible on both light and dark
  /// surfaces (lighter red in dark mode).
  Color get appError =>
      isDarkMode ? const Color(0xFFFFB4AB) : const Color(0xFFBA1A1A);

  /// Background fill for error / warning banners.
  Color get appErrorContainer =>
      isDarkMode ? const Color(0xFF3B2020) : const Color(0xFFFFDAD6);

  /// Border color paired with [appErrorContainer].
  Color get appErrorBorder =>
      isDarkMode ? const Color(0xFF8C1D18) : const Color(0xFFFFDAD6);

  /// Dark text/icon that is always legible on top of a light accent chip
  /// (e.g. the light-green [0xFF94F4AD] chips) regardless of theme.
  Color get appOnLightAccent => const Color(0xFF003D1A);

  /// Soft translucent accent fill used for subtle tinted surfaces.
  Color get appAccentTint => appAccent.withValues(alpha: 0.15);
}
