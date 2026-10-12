import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted PBKDF2-HMAC-SHA256. Passwords are never stored: only the random
/// salt and the derived hash go into SQLite.
abstract final class PasswordHasher {
  static const _iterations = 10000;

  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    return base64Encode(List<int>.generate(length, (_) => random.nextInt(256)));
  }

  static String hash(String password, String salt) {
    final derived = _pbkdf2(
      utf8.encode(password),
      base64Decode(salt),
      _iterations,
    );
    return base64Encode(derived);
  }

  static bool verify(String password, String salt, String expectedHash) {
    return _constantTimeEquals(hash(password, salt), expectedHash);
  }

  // PBKDF2 with a 32-byte output (exactly one SHA-256 block).
  static List<int> _pbkdf2(List<int> password, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, password);
    var u = hmac.convert([...salt, 0, 0, 0, 1]).bytes;
    final result = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
