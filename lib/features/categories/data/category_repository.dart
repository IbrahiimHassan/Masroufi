import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/collections.dart';
import 'category.dart';
import 'default_categories.dart';

class CategoryRepository {
  CategoryRepository(this._firestore, this._uid);

  final FirebaseFirestore _firestore;
  final String _uid;

  CollectionReference<Map<String, dynamic>> get _custom => _firestore
      .collection(UsersCollection.name)
      .doc(_uid)
      .collection(CategoriesCollection.name);

  /// Default categories + this user's custom ones.
  Stream<List<Category>> watchAll() => _custom.snapshots().map(
    (snapshot) => [
      ...DefaultCategories.all,
      ...snapshot.docs.map(Category.fromFirestore),
    ],
  );
}
