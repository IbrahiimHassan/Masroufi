import 'package:flutter/foundation.dart' hide Category;

import '../data/category.dart';
import '../data/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider(this._repository);

  final CategoryRepository _repository;

  List<Category> _categories = const [];
  List<Category> get categories => _categories;

  Future<void> load() async {
    _categories = await _repository.getAll();
    notifyListeners();
  }
}
