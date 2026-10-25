import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/firestore_cache.dart';
import 'budget.dart';

class BudgetRepository {
  BudgetRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _budgets => _firestore
      .collection(UsersCollection.name)
      .doc(_uid)
      .collection(BudgetsCollection.name);

  Stream<List<Budget>> watchAll() => _budgets
      .orderBy(BudgetsCollection.order)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Budget.fromFirestore).toList());

  void updateAmount(String id, double amount) => sendInBackground(
    _budgets.doc(id).update({BudgetsCollection.amount: amount}),
  );
}
