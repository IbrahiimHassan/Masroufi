import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import '../../../core/firebase/firestore_cache.dart';
import 'savings_goal.dart';

class SavingsRepository {
  SavingsRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _goals => _firestore
      .collection(UsersCollection.name)
      .doc(_uid)
      .collection(SavingsGoalsCollection.name);

  /// The main jar (first goal). The structure allows several goals later.
  Stream<SavingsGoal?> watchMainGoal() => _goals
      .orderBy(SavingsGoalsCollection.createdAt)
      .limit(1)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs.isEmpty
            ? null
            : SavingsGoal.fromFirestore(snapshot.docs.first),
      );

  /// FieldValue.increment is applied by the server, so two devices adding at
  /// the same time can't overwrite each other with a stale value.
  void addContribution(String goalId, double amount) => sendInBackground(
    _goals.doc(goalId).update({
      SavingsGoalsCollection.currentAmount: FieldValue.increment(amount),
    }),
  );

  void updateTarget(String goalId, double target) => sendInBackground(
    _goals.doc(goalId).update({SavingsGoalsCollection.targetAmount: target}),
  );
}
