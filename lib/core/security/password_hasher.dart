import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Result of hashing a password: the random salt, the derived hash, and the
/// iteration count used — all needed to verify a later login attempt.
class HashedPassword {
  const HashedPassword({
    required this.saltBase64,
    required this.hashBase64,
    required this.iterations,
  });

  final String saltBase64;
  final String hashBase64;
  final int iterations;
}

/// One-way password hashing with PBKDF2-HMAC-SHA256.
///
/// Passwords are never stored or encrypted reversibly: only a salted hash is
/// kept, and login re-derives the hash from the entered password to compare.
/// A fresh random salt per password defeats rainbow tables, and the comparison
/// is constant-time to avoid leaking information through timing.
class PasswordHasher {
  const PasswordHasher({
    this.iterations = 100000,
    this.keyLength = 32,
    this.saltLength = 16,
  });

  final int iterations;
  final int keyLength;
  final int saltLength;

  /// Hashes [password], generating a random [salt] when none is supplied.
  HashedPassword hash(String password, {Uint8List? salt}) {
    final resolvedSalt = salt ?? _randomBytes(saltLength);
    final derived = _derive(password, resolvedSalt, iterations);

    return HashedPassword(
      saltBase64: base64Encode(resolvedSalt),
      hashBase64: base64Encode(derived),
      iterations: iterations,
    );
  }

  /// Returns true if [password] reproduces [hashBase64] under the stored salt
  /// and iteration count.
  bool verify(
    String password, {
    required String saltBase64,
    required String hashBase64,
    required int iterations,
  }) {
    final salt = base64Decode(saltBase64);
    final expected = base64Decode(hashBase64);
    final derived = _derive(password, salt, iterations);

    return _constantTimeEquals(derived, expected);
  }

  Uint8List _derive(String password, Uint8List salt, int iterations) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, keyLength));

    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }

    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }

    return diff == 0;
  }
}
