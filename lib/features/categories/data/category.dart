import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/utils/icon_registry.dart';

class Category {
  const Category({
    this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    this.isDefault = false,
  });

  final String? id;
  final String name;
  final String iconKey;

  /// ARGB int (e.g. 0xFF17B77D) — stored as a number in Firestore.
  final int colorValue;
  final bool isDefault;

  Color get color => Color(colorValue);
  IconData get icon => iconFromKey(iconKey);

  /// A custom category saved under users/{uid}/categories.
  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Category.fromEmbedded(doc.data()!, id: doc.id);

  /// Reads the copy of a category stored inside an expense or budget.
  factory Category.fromEmbedded(Map<String, dynamic> map, {String? id}) =>
      Category(
        id: id ?? map[CategoriesCollection.id] as String,
        name: map[CategoriesCollection.categoryName] as String,
        iconKey: map[CategoriesCollection.iconKey] as String,
        colorValue: (map[CategoriesCollection.color] as num).toInt(),
        isDefault: (map[CategoriesCollection.isDefault] as bool?) ?? false,
      );

  Map<String, Object?> toEmbedded() => {
    CategoriesCollection.id: id,
    CategoriesCollection.categoryName: name,
    CategoriesCollection.iconKey: iconKey,
    CategoriesCollection.color: colorValue,
    CategoriesCollection.isDefault: isDefault,
  };
}
