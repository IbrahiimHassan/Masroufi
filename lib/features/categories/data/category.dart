import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../core/utils/icon_registry.dart';

class Category {
  const Category({
    this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.isDefault = false,
  });

  final int? id;
  final String name;
  final String iconKey;

  /// ARGB int (e.g. 0xFF17B77D) — SQLite stores it as INTEGER.
  final int colorValue;
  final bool isDefault;

  Color get color => Color(colorValue);
  IconData get icon => iconFromKey(iconKey);

  // ── Aliases used when another table JOINs categories (alias "c") ──
  static const aliasName = 'category_name';
  static const aliasIcon = 'category_icon';
  static const aliasColor = 'category_color';
  static const joinColumns =
      'c.${CategoriesTable.name} AS $aliasName, '
      'c.${CategoriesTable.iconKey} AS $aliasIcon, '
      'c.${CategoriesTable.color} AS $aliasColor';

  factory Category.fromMap(Map<String, Object?> map) => Category(
    id: map[CategoriesTable.id] as int,
    name: map[CategoriesTable.name] as String,
    iconKey: map[CategoriesTable.iconKey] as String,
    colorValue: map[CategoriesTable.color] as int,
    isDefault: (map[CategoriesTable.isDefault] as int) == 1,
  );

  /// Builds a category from a row that used [joinColumns].
  factory Category.fromJoinedMap(Map<String, Object?> map, {required int id}) =>
      Category(
        id: id,
        name: map[aliasName] as String,
        iconKey: map[aliasIcon] as String,
        colorValue: map[aliasColor] as int,
      );

  Map<String, Object?> toMap() => {
    if (id != null) CategoriesTable.id: id,
    CategoriesTable.name: name,
    CategoriesTable.iconKey: iconKey,
    CategoriesTable.color: colorValue,
    CategoriesTable.isDefault: isDefault ? 1 : 0,
  };
}
