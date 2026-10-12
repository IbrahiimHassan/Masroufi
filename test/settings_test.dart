import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:first_app/core/currency/currency.dart';
import 'package:first_app/core/l10n/app_strings.dart';
import 'package:first_app/core/settings/settings_provider.dart';
import 'package:first_app/core/utils/formatters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseAmount', () {
    test('accepts Arabic-Indic digits and Arabic decimal separators', () {
      expect(parseAmount('١٬٢٣٤٫٥٠'), 1234.5);
      expect(parseAmount('۱۲۳٫۷۵'), 123.75);
    });

    test('accepts grouped English values and rejects invalid input', () {
      expect(parseAmount('1,234.50'), 1234.5);
      expect(parseAmount('1,5'), 1.5);
      expect(parseAmount(''), isNull);
      expect(parseAmount('abc'), isNull);
    });
  });

  test('settings load and persist theme, language, and currency', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final settings = SettingsProvider(preferences);

    await settings.setThemeMode(ThemeMode.dark);
    await settings.setLanguage(LanguageChoice.arabic);
    await settings.setCurrency(Currency.usd);

    final restored = SettingsProvider(preferences);
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.language, LanguageChoice.arabic);
    expect(restored.currency.code, 'USD');
  });

  test('Arabic strings include translated labels and day plurals', () {
    const strings = AppStrings(Locale('ar'));

    expect(strings.settings, 'الإعدادات');
    expect(strings.days(1), 'يوم واحد');
    expect(strings.days(2, genitive: true), 'يومين');
    expect(strings.days(6), '6 أيام');
    expect(strings.compactAmount(2500), '2٫5 ألف');
  });

  test('currency format changes label but never converts the amount', () {
    expect(Currency.usd.format(1234, arabic: false), r'$1,234');
    expect(Currency.usd.format(1234, arabic: true), r'1,234 $');
    expect(Currency.sar.format(1234, arabic: true), '1,234 ر.س');
  });
}
