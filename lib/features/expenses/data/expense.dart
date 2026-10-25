import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/firebase/collections.dart';
import '../../categories/data/category.dart';

class Expense {
  const Expense({
    this.id,
    required this.title,
    required this.category,
    required this.merchant,
    required this.amount,
    required this.date,
  });

  /// Firestore document id; null until the expense has been saved.
  final String? id;
  final String title;
  final Category category;
  final String merchant;
  final double amount;
  final DateTime date;

  Color get color => category.color;
  IconData get icon => category.icon;

  factory Expense.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!;
    return Expense(
      id: doc.id,
      title: map[ExpensesCollection.title] as String,
      merchant: (map[ExpensesCollection.merchant] as String?) ?? '',
      amount: (map[ExpensesCollection.amount] as num).toDouble(),
      date: (map[ExpensesCollection.expenseDate] as Timestamp).toDate(),
      category: Category.fromEmbedded(
        Map<String, dynamic>.from(map[ExpensesCollection.category] as Map),
        id: map[ExpensesCollection.categoryId] as String,
      ),
    );
  }

  /// The fields the user controls.
  /// (createdAt / updatedAt are added by the repository.)
  Map<String, Object?> toFirestore() => {
    ExpensesCollection.categoryId: category.id,
    ExpensesCollection.category: category.toEmbedded(),
    ExpensesCollection.title: title,
    ExpensesCollection.merchant: merchant,
    ExpensesCollection.amount: amount,
    ExpensesCollection.expenseDate: Timestamp.fromDate(date),
    ExpensesCollection.paymentMethod: 'cash',
  };
}
