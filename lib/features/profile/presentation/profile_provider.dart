import 'package:flutter/foundation.dart';

import '../data/profile_repository.dart';
import '../data/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._repository);

  final ProfileRepository _repository;

  UserProfile _profile = const UserProfile.placeholder();
  UserProfile get profile => _profile;

  Future<void> load() async {
    _profile = await _repository.get() ?? _profile;
    notifyListeners();
  }

  /// Ready for a future Settings screen.
  Future<void> update({
    String? name,
    double? monthlyIncome,
    int? paydayDay,
  }) async {
    await _repository.update(
      name: name,
      monthlyIncome: monthlyIncome,
      paydayDay: paydayDay,
    );
    await load();
  }
}
