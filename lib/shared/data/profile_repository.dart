import 'dart:convert';

import 'package:travelmate/core/database/profile_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

/// Supplies the [AesCipher] used to protect profile fields. Async because the
/// key may need to be read from (or created in) secure storage on first use.
typedef CipherProvider = Future<AesCipher> Function();

/// Encrypts sensitive profile fields, persists them through a [ProfileDao], and
/// reconstructs the [PersonalProfile] on read.
///
/// All string columns except the primary key are stored as AES-GCM base64
/// payloads; tag lists are JSON-encoded before encryption. Depends only on the
/// [ProfileDao] abstraction and a [CipherProvider], so the full round trip is
/// unit-testable against an in-memory fake DAO.
class ProfileRepository {
  ProfileRepository({required ProfileDao dao, required CipherProvider cipher})
    : _dao = dao,
      _cipher = cipher;

  final ProfileDao _dao;
  final CipherProvider _cipher;

  Future<PersonalProfile?> readProfile() async {
    final row = await _dao.readProfileRow();
    if (row == null) {
      return null;
    }

    final cipher = await _cipher();

    return PersonalProfile(
      firstName: _decrypt(cipher, row['first_name']),
      lastName: _decrypt(cipher, row['last_name']),
      description: _decrypt(cipher, row['description']),
      photoAsset: _decrypt(cipher, row['photo_path']),
      interestTags: _decryptList(cipher, row['interest_tags']),
      tripTags: _decryptList(cipher, row['trip_tags']),
    );
  }

  Future<void> writeProfile(PersonalProfile profile) async {
    final cipher = await _cipher();

    await _dao.upsertProfileRow({
      'first_name': cipher.encryptString(profile.firstName),
      'last_name': cipher.encryptString(profile.lastName),
      'description': cipher.encryptString(profile.description),
      'photo_path': cipher.encryptString(profile.photoAsset),
      'interest_tags': cipher.encryptString(jsonEncode(profile.interestTags)),
      'trip_tags': cipher.encryptString(jsonEncode(profile.tripTags)),
    });
  }

  String _decrypt(AesCipher cipher, Object? value) {
    return cipher.decryptString(value! as String);
  }

  List<String> _decryptList(AesCipher cipher, Object? value) {
    final decoded = jsonDecode(_decrypt(cipher, value));
    if (decoded is! List) {
      return const <String>[];
    }

    return decoded.whereType<String>().toList(growable: false);
  }
}
