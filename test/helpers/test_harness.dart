import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:travelmate/core/database/account_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/theme/app_theme.dart';
import 'package:travelmate/core/security/password_hasher.dart';
import 'package:travelmate/shared/data/account_repository.dart';
import 'package:travelmate/shared/data/profile_data_source.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/auth_service.dart';

/// In-memory [ProfileDataSource] for tests, so exercising the profile store
/// never reaches the SQLite / secure-storage platform plugins.
class InMemoryProfileData implements ProfileDataSource {
  InMemoryProfileData([this._profile = PersonalProfile.defaultProfile]);

  PersonalProfile _profile;

  @override
  Future<PersonalProfile> read() async => _profile;

  @override
  Future<void> write(PersonalProfile profile) async => _profile = profile;
}

/// In-memory [AccountDao] so auth flows run without a native SQLite engine.
class FakeAccountDao implements AccountDao {
  Map<String, Object?>? _row;

  @override
  Future<int> countAccounts() async => _row == null ? 0 : 1;

  @override
  Future<Map<String, Object?>?> readAccountRow() async => _row;

  @override
  Future<void> upsertAccountRow(Map<String, Object?> row) async {
    _row = Map<String, Object?>.from(row);
  }
}

/// Installs an in-memory account into [AuthService] and seeds the given
/// credentials, so login flows can be tested without SQLite / secure storage.
/// Uses a low PBKDF2 iteration count to keep tests fast.
Future<void> seedAuthService({
  String username = AuthService.defaultUsername,
  String password = AuthService.defaultPassword,
}) async {
  // Reuse a single cipher (fixed key) so encrypt and decrypt match, mirroring
  // the production key provider which memoizes the key.
  final cipher = AesCipher(enc.Key.fromLength(32));
  final repository = AccountRepository(
    dao: FakeAccountDao(),
    cipher: () async => cipher,
    hasher: const PasswordHasher(iterations: 1000),
  );
  await repository.ensureSeeded(username: username, password: password);
  AuthService.instance.debugSetRepository(repository);
}

/// Asset bundle that returns a tiny valid SVG for any key, so widgets calling
/// `SvgPicture.asset` render in tests without the real asset bundle.
class FakeAssetBundle extends CachingAssetBundle {
  static const String _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="8" height="8"></svg>';

  @override
  Future<ByteData> load(String key) async {
    final bytes = Uint8List.fromList(utf8.encode(_svg));
    return ByteData.sublistView(bytes);
  }
}

/// Wraps [child] in a MaterialApp (with the app theme and a fake asset bundle)
/// so it can be pumped in isolation.
Widget wrapApp(Widget child) {
  return DefaultAssetBundle(
    bundle: FakeAssetBundle(),
    child: MaterialApp(theme: AppTheme.light(), home: child),
  );
}

/// Wraps [child] inside a Scaffold body — for widgets that expect Material
/// ancestors but do not provide their own Scaffold.
Widget wrapScaffold(Widget child) {
  return wrapApp(Scaffold(body: child));
}
