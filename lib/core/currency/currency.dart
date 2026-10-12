import '../utils/formatters.dart';

/// A currency the user can pick in Settings.
/// Only the LABEL changes; amounts are not converted (that needs exchange rates).
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.symbolAr,
    required this.nameEn,
    required this.nameAr,
  });

  final String code;
  final String symbol;
  final String symbolAr;
  final String nameEn;
  final String nameAr;

  static const egp = Currency(
    code: 'EGP',
    symbol: 'EGP',
    symbolAr: 'ج.م',
    nameEn: 'Egyptian pound',
    nameAr: 'جنيه مصري',
  );
  static const usd = Currency(
    code: 'USD',
    symbol: '\$',
    symbolAr: '\$',
    nameEn: 'US dollar',
    nameAr: 'دولار أمريكي',
  );
  static const eur = Currency(
    code: 'EUR',
    symbol: '€',
    symbolAr: '€',
    nameEn: 'Euro',
    nameAr: 'يورو',
  );
  static const gbp = Currency(
    code: 'GBP',
    symbol: '£',
    symbolAr: '£',
    nameEn: 'British pound',
    nameAr: 'جنيه إسترليني',
  );
  static const sar = Currency(
    code: 'SAR',
    symbol: 'SAR',
    symbolAr: 'ر.س',
    nameEn: 'Saudi riyal',
    nameAr: 'ريال سعودي',
  );
  static const aed = Currency(
    code: 'AED',
    symbol: 'AED',
    symbolAr: 'د.إ',
    nameEn: 'UAE dirham',
    nameAr: 'درهم إماراتي',
  );
  static const kwd = Currency(
    code: 'KWD',
    symbol: 'KWD',
    symbolAr: 'د.ك',
    nameEn: 'Kuwaiti dinar',
    nameAr: 'دينار كويتي',
  );
  static const qar = Currency(
    code: 'QAR',
    symbol: 'QAR',
    symbolAr: 'ر.ق',
    nameEn: 'Qatari riyal',
    nameAr: 'ريال قطري',
  );

  static const all = [egp, usd, eur, gbp, sar, aed, kwd, qar];

  static Currency byCode(String? code) =>
      all.firstWhere((c) => c.code == code, orElse: () => egp);

  String label({required bool arabic}) => arabic ? symbolAr : symbol;

  String name({required bool arabic}) => arabic ? nameAr : nameEn;

  /// "EGP 1,234" / "$1,234" in English, "1,234 ج.م" in Arabic.
  String format(num amount, {required bool arabic}) {
    final digits = formatAmount(amount);
    if (arabic) return '$digits $symbolAr';
    return symbol.length == 1 ? '$symbol$digits' : '$symbol $digits';
  }
}
