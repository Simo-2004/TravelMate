import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

/// Authenticated field-level encryption (AES-256-GCM) used to protect
/// sensitive profile columns before they are written to the local database.
///
/// Pure Dart — no platform channels — so the full round trip is unit-testable.
/// Each [encryptString] call uses a fresh random 12-byte nonce, and the GCM
/// authentication tag makes tampering detectable: [decryptString] throws if
/// the payload was altered or the wrong key is used.
class AesCipher {
  AesCipher(Key key) : _encrypter = Encrypter(AES(key, mode: AESMode.gcm));

  /// Recommended nonce length for AES-GCM.
  static const int _nonceLength = 12;

  final Encrypter _encrypter;

  /// Encrypts [plainText] and returns a base64 payload of `nonce || cipher+tag`.
  String encryptString(String plainText) {
    final iv = IV.fromSecureRandom(_nonceLength);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);

    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length)
      ..setRange(0, iv.bytes.length, iv.bytes)
      ..setRange(
        iv.bytes.length,
        iv.bytes.length + encrypted.bytes.length,
        encrypted.bytes,
      );

    return base64Encode(combined);
  }

  /// Reverses [encryptString]. Throws if [payload] is malformed, was tampered
  /// with, or was produced with a different key.
  String decryptString(String payload) {
    final combined = base64Decode(payload);
    if (combined.length <= _nonceLength) {
      throw const FormatException('Encrypted payload is too short.');
    }

    final iv = IV(Uint8List.sublistView(combined, 0, _nonceLength));
    final cipherBytes = Uint8List.sublistView(combined, _nonceLength);

    return _encrypter.decrypt(Encrypted(cipherBytes), iv: iv);
  }
}
