import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Builds the light and dark themes. Arabic uses the Cairo font, English Inter.
abstract final class AppTheme {
  static ThemeData light({required bool arabic}) =>
      _build(Brightness.light, AppColors.light, arabic);

  static ThemeData dark({required bool arabic}) =>
      _build(Brightness.dark, AppColors.dark, arabic);

  static ThemeData _build(
    Brightness brightness,
    AppColors colors,
    bool arabic,
  ) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.seed,
        brightness: brightness,
      ),
    );
    final fontFamily = arabic
        ? GoogleFonts.cairo().fontFamily
        : GoogleFonts.inter().fontFamily;

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      textTheme: base.textTheme.apply(fontFamily: fontFamily),
      extensions: [colors],
    );
  }
}
