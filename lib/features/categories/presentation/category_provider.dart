import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;

import '../data/category.dart';
import '../data/category_repository.dart';
import '../data/default_categories.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repository);

  final CategoryRepository _repository;
  StreamSubscription<List<Category>>? _subscription;

  // The defaults are usable before the first snapshot arrives.
  List<Category> _categories = DefaultCategories.all;
  List<Category> get categories => _categories;

  void listen() {
    _subscription ??= _repository.watchAll().listen((categories) {
      _categories = categories;
      notifyListeners();
    }, onError: (Object e) => debugPrint('Categories stream failed: $e'));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
