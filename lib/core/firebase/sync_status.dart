import 'package:flutter/foundation.dart';

import 'firestore_cache.dart';

/// Mixed into providers that are fed by a Firestore stream.
mixin SyncStatus on ChangeNotifier {
  bool _isFromCache = false;
  bool _hasPendingWrites = false;

  /// The data on screen comes from the device cache (usually: offline).
  bool get isFromCache => _isFromCache;

  /// Local changes are waiting to be uploaded.
  bool get hasPendingWrites => _hasPendingWrites;

  /// Call before notifyListeners() whenever a new snapshot arrives.
  void updateSyncStatus(Synced<Object?> snapshot) {
    _isFromCache = snapshot.isFromCache;
    _hasPendingWrites = snapshot.hasPendingWrites;
  }
}
