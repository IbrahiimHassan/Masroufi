import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/firestore_cache.dart';
import 'expense.dart';

/// All Firestore access for expenses lives here — the UI never touches it.
/// Everything is under users/{uid}, so accounts never see each other's data.
class ExpenseRepository {
  ExpenseRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _expenses => _firestore
      .collection(UsersCollection.name)
      .doc(_uid)
      .collection(ExpensesCollection.name);

  /// Newest first. Emits the cached copy immediately, then server updates
  /// (including changes made on other devices).
  Stream<Synced<List<Expense>>> watchAll() => _expenses
      .orderBy(ExpensesCollection.expenseDate, descending: true)
      .snapshots(includeMetadataChanges: true)
      .map(
        (snapshot) => Synced(
          snapshot.docs.map(Expense.fromFirestore).toList(),
          snapshot.metadata,
        ),
      );

  /// Returns the new id right away; the upload happens in the background.
  String add(Expense expense) {
    final doc = _expenses.doc();
    sendInBackground(
      doc.set({
        ...expense.toFirestore(),
        ExpensesCollection.createdAt: FieldValue.serverTimestamp(),
        ExpensesCollection.updatedAt: FieldValue.serverTimestamp(),
      }),
    );
    return doc.id;
  }

  void update(Expense expense) {
    sendInBackground(
      _expenses.doc(expense.id).update({
        ...expense.toFirestore(),
        ExpensesCollection.updatedAt: FieldValue.serverTimestamp(),
      }),
    );
  }

  void delete(String id) => sendInBackground(_expenses.doc(id).delete());
}
