import 'dart:math' as math;

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// 1234567 -> "1,234,567" (digits stay 0-9 in every language).
String formatAmount(num amount) {
  final digits = amount.round().toString();
  final grouped = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) grouped.write(',');
    grouped.write(digits[index]);
  }
  return grouped.toString();
}

/// Parses what a person typed, including Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩),
/// the Arabic decimal mark (٫) and "1,234.5" / "1.234,5" style separators.
double? parseAmount(String input) {
  var text = input.trim();
  if (text.isEmpty) return null;

  const arabicIndic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    var digit = arabicIndic.indexOf(ch);
    if (digit < 0) digit = persian.indexOf(ch);
    buffer.write(digit >= 0 ? '$digit' : ch);
  }
  text = buffer
      .toString()
      .replaceAll('٫', '.')
      .replaceAll('٬', ',')
      .replaceAll(' ', '');

  if (text.contains('.') && text.contains(',')) {
    text = text.replaceAll(',', '');
  } else if (text.contains(',')) {
    // "1,234" is a thousands separator; "1,5" is a decimal comma.
    text = RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(text)
        ? text.replaceAll(',', '')
        : text.replaceAll(',', '.');
  }
  return double.tryParse(text);
}

/// The next payday on or after today (today counts, so on payday the
/// countdown shows 0). Computed in UTC so daylight-saving changes can't make
/// the day count off by one, and the day is clamped to the month length
/// (a payday of 31 becomes the 28th/29th/30th when the month is shorter).
DateTime nextPayday(DateTime now, int paydayDay) {
  final today = DateTime.utc(now.year, now.month, now.day);

  DateTime paydayIn(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0).day;
    return DateTime.utc(year, month, math.min(paydayDay, lastDay));
  }

  var payday = paydayIn(today.year, today.month);
  if (payday.isBefore(today)) {
    payday = paydayIn(today.year, today.month + 1);
  }
  return payday;
}

int daysUntilPayday(DateTime now, int paydayDay) {
  final today = DateTime.utc(now.year, now.month, now.day);
  return nextPayday(now, paydayDay).difference(today).inDays;
}
