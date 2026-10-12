import 'package:flutter/material.dart';

/// Every color the screens use, named by purpose. Read it with `context.c`.
/// Light and dark values live side by side here, so a new screen never needs
/// a hard-coded hex value.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.primaryFaint,
    required this.track,
    required this.danger,
    required this.dangerSoft,
  });

  /// Seed for the Material color scheme (the brand teal).
  static const seed = Color(0xFF1D8B7D);

  /// Page background.
  final Color background;

  /// Cards, sheets, dialogs.
  final Color surface;

  /// Tinted panels: stat tiles, nav bars, segmented-control track.
  final Color surfaceAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  /// Brand teal.
  final Color primary;
  final Color onPrimary;

  /// Soft teal panel background.
  final Color primarySoft;

  /// Inactive chart bars.
  final Color primaryFaint;

  /// Progress-bar track, chart grid lines.
  final Color track;
  final Color danger;
  final Color dangerSoft;

  static const light = AppColors(
    background: Color(0xFFE7E3DE),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF4F1ED),
    border: Color(0xFFD9D9D0),
    textPrimary: Color(0xFF152422),
    textSecondary: Color(0xFF5A6966),
    textMuted: Color(0xFF8A9490),
    primary: Color(0xFF1D8B7D),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE7F1EE),
    primaryFaint: Color(0xFFA8D5C8),
    track: Color(0xFFDAE3E0),
    danger: Color(0xFFC7452F),
    dangerSoft: Color(0xFFFBE4E0),
  );

  static const dark = AppColors(
    background: Color(0xFF111715),
    surface: Color(0xFF1C2421),
    surfaceAlt: Color(0xFF252F2B),
    border: Color(0xFF35413D),
    textPrimary: Color(0xFFE8F0ED),
    textSecondary: Color(0xFFA7B6B1),
    textMuted: Color(0xFF7C8985),
    primary: Color(0xFF3DBBA9),
    onPrimary: Color(0xFF06201C),
    primarySoft: Color(0xFF1E3A35),
    primaryFaint: Color(0xFF2F5A52),
    track: Color(0xFF2F3B37),
    danger: Color(0xFFFF8F7C),
    dangerSoft: Color(0xFF3D2420),
  );

  @override
  AppColors copyWith() => this;

  // Theme switches are instant, so there is nothing to interpolate.
  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) =>
      other is AppColors ? (t < 0.5 ? this : other) : this;
}
