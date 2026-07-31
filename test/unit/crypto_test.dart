/// Unit testing — the two cryptographic primitives, as algorithms.
///
/// [AesCipher] (AES-256-GCM) and [PasswordHasher] (PBKDF2-HMAC-SHA256) are
/// tested here for the properties any correct implementation must have:
/// round-tripping, fresh randomness per call, and determinism when the random
/// input is pinned. Adversarial behaviour — tampering, wrong keys, what ends
/// up on disk — is covered separately in test/security/.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

void main() {
  group('AesCipher', () {
    test('round-trips text through encryption', () {
      final cipher = testCipher();
      const plain = 'Alessia Rossi — beach lover';

      final payload = cipher.encryptString(plain);

      expect(payload, isNot(plain));
      expect(cipher.decryptString(payload), plain);
    });

    test('produces a different payload each call (random nonce)', () {
      final cipher = testCipher();

      final a = cipher.encryptString('same');
      final b = cipher.encryptString('same');

      expect(a, isNot(b));
      expect(cipher.decryptString(a), 'same');
      expect(cipher.decryptString(b), 'same');
    });

    test('round-trips an empty string', () {
      final cipher = testCipher();
      expect(cipher.decryptString(cipher.encryptString('')), '');
    });

    test('round-trips unicode and emoji without loss', () {
      final cipher = testCipher();
      const plain = 'Ciao 🌍 — città, naïve, 日本語';

      expect(cipher.decryptString(cipher.encryptString(plain)), plain);
    });

    test('round-trips a long value', () {
      final cipher = testCipher();
      final plain = 'a' * 10000;

      expect(cipher.decryptString(cipher.encryptString(plain)), plain);
    });

    test('emits base64, so it is safe in a text column', () {
      final payload = testCipher().encryptString('anything');

      expect(() => base64Decode(payload), returnsNormally);
    });

    test('rejects a payload shorter than the nonce', () {
      expect(
        () => testCipher().decryptString(base64Encode([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  group('PasswordHasher', () {
    test('verifies the correct password and rejects a wrong one', () {
      final hashed = testHasher.hash('s3cret');

      expect(
        testHasher.verify(
          's3cret',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations,
        ),
        isTrue,
      );
      expect(
        testHasher.verify(
          'wrong',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations,
        ),
        isFalse,
      );
    });

    test('uses a fresh random salt per hash', () {
      final a = testHasher.hash('same');
      final b = testHasher.hash('same');

      expect(a.saltBase64, isNot(b.saltBase64));
      expect(a.hashBase64, isNot(b.hashBase64));
    });

    test('is deterministic for a fixed salt', () {
      final salt = Uint8List.fromList(List<int>.filled(16, 7));

      final a = testHasher.hash('pw', salt: salt);
      final b = testHasher.hash('pw', salt: salt);

      expect(a.hashBase64, b.hashBase64);
    });

    test('records the iteration count it used, so verify can reproduce it', () {
      expect(testHasher.hash('pw').iterations, 1000);
    });

    test('verification fails if the recorded iteration count is wrong', () {
      final hashed = testHasher.hash('pw');

      expect(
        testHasher.verify(
          'pw',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations + 1,
        ),
        isFalse,
      );
    });

    test('handles unicode passwords', () {
      final hashed = testHasher.hash('pässwörd🔑');

      expect(
        testHasher.verify(
          'pässwörd🔑',
          saltBase64: hashed.saltBase64,
          hashBase64: hashed.hashBase64,
          iterations: hashed.iterations,
        ),
        isTrue,
      );
    });
  });
}
