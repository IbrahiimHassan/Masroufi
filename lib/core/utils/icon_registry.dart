import 'package:flutter/material.dart';

/// SQLite can't store an IconData, so categories store a short string key and
/// this registry maps it back to the icon. Add keys here for custom categories.
const _icons = <String, IconData>{
  'car': Icons.directions_car_rounded,
  'receipt': Icons.receipt_long_rounded,
  'bag': Icons.shopping_bag_rounded,
  'movie': Icons.movie_rounded,
  'payments': Icons.payments_rounded,
};

List<String> get availableIconKeys => _icons.keys.toList();

IconData iconFromKey(String key) => _icons[key] ?? Icons.payments_rounded;
