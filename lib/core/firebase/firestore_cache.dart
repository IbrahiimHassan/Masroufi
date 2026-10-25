import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Caching strategy
///
/// 1. Persistent disk cache. Every document the app reads or writes is kept
///    in Firestore's local cache, so the app opens instantly and keeps working
///    with no connection. Writes made offline are queued and sent later.
/// 2. Cache-first streams. Repositories listen with `snapshots()`: the first
///    event is served from the disk cache, then the server's version follows,
///    so screens never wait for the network to show something.
/// 3. In-memory cache. Providers hold the latest list (and memoize derived
///    totals), so switching tabs never re-reads anything.
abstract final class FirestoreCache {
  /// Firestore accepts 1 MB – 100 MB. 100 MB is years of expenses.
  static const sizeBytes = 100 * 1024 * 1024;

  static void configure(FirebaseFirestore firestore) {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: sizeBytes,
    );
  }
}

/// A value read from Firestore plus where it came from, so the UI can say
/// "offline — showing saved data" or "syncing".
class Synced<T> {
  const Synced(this.data, this.metadata);

  final T data;
  final SnapshotMetadata metadata;

  /// Served from the device cache (the server hasn't confirmed it yet).
  bool get isFromCache => metadata.isFromCache;

  /// Contains local changes that haven't reached the server yet.
  bool get hasPendingWrites => metadata.hasPendingWrites;
}

/// Firestore applies a write to the local cache (and to every open stream)
/// straight away, but its Future only completes once the SERVER confirms it,
/// which never happens while offline. Screens must not wait for that, so
/// repositories send writes through here instead of awaiting them.
void sendInBackground(Future<void> write) {
  unawaited(
    write.catchError(
      (Object error) => debugPrint('Firestore write failed: $error'),
    ),
  );
}
