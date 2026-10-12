import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../currency/currency.dart';
import '../l10n/app_strings.dart';
import '../settings/settings_provider.dart';
import '../theme/app_colors.dart';

/// Shortcuts used by every screen:
///   context.s            translated text      context.s.addExpense
///   context.c            theme colors         context.c.textPrimary
///   context.money(1234)  "EGP 1,234" in the chosen currency
///   context.font(...)    TextStyle in Inter (English) or Cairo (Arabic)
extension AppContext on BuildContext {
  AppStrings get s => AppStrings.of(this);

  AppColors get c => Theme.of(this).extension<AppColors>()!;

  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// The chosen currency. Only call this while building a widget: it makes
  /// the widget rebuild when the currency is changed in Settings.
  Currency get currency =>
      select<SettingsProvider, Currency>((settings) => settings.currency);

  String money(num amount) => currency.format(amount, arabic: s.isArabic);

  /// For TextField prefixes, e.g. "EGP  ".
  String get currencyPrefix => '${currency.label(arabic: s.isArabic)}  ';

  /// A "go forward" arrow that points the right way in both directions.
  IconData get chevronForward =>
      isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded;

  IconData get chevronBack =>
      isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded;

  TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    final arabic = Localizations.localeOf(this).languageCode == 'ar';
    final make = arabic ? GoogleFonts.cairo : GoogleFonts.inter;
    return make(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
