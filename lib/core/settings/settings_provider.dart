import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../currency/currency.dart';

enum LanguageChoice { system, english, arabic }

/// App-wide preferences, saved with SharedPreferences so they survive
/// restarts and apply to every account on this phone.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    _themeMode = switch (_prefs.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _language = switch (_prefs.getString(_languageKey)) {
      'en' => LanguageChoice.english,
      'ar' => LanguageChoice.arabic,
      _ => LanguageChoice.system,
    };
    _currency = Currency.byCode(_prefs.getString(_currencyKey));
  }

  static const _themeKey = 'settings_theme_mode';
  static const _languageKey = 'settings_language';
  static const _currencyKey = 'settings_currency';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  LanguageChoice _language = LanguageChoice.system;
  Currency _currency = Currency.egp;

  ThemeMode get themeMode => _themeMode;
  LanguageChoice get language => _language;
  Currency get currency => _currency;

  /// null = follow the phone's language.
  Locale? get locale => switch (_language) {
    LanguageChoice.english => const Locale('en'),
    LanguageChoice.arabic => const Locale('ar'),
    LanguageChoice.system => null,
  };

  /// Whether the UI is (or will be) Arabic. Used to pick the font.
  bool get usesArabic {
    final chosen = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
    return chosen.languageCode == 'ar';
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _prefs.setString(_themeKey, mode.name);
  }

  Future<void> setLanguage(LanguageChoice choice) async {
    _language = choice;
    notifyListeners();
    await _prefs.setString(_languageKey, switch (choice) {
      LanguageChoice.english => 'en',
      LanguageChoice.arabic => 'ar',
      LanguageChoice.system => 'system',
    });
  }

  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    notifyListeners();
    await _prefs.setString(_currencyKey, currency.code);
  }
}
