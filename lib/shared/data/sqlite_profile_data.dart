import 'package:travelmate/core/database/profile_sqflite_dao.dart';
import 'package:travelmate/core/security/aes_cipher.dart';
import 'package:travelmate/core/security/flutter_secure_key_store.dart';
import 'package:travelmate/core/security/profile_key_provider.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/profile_data_source.dart';
import 'package:travelmate/shared/data/profile_repository.dart';
import 'package:travelmate/shared/models/personal_profile.dart';

/// SQLite-backed [ProfileDataSource]: the current persistence layer for the
/// personal profile.
///
/// On first read it transparently migrates any profile saved by a previous
/// (SharedPreferences) app version into the encrypted database, so upgrading
/// users keep their data. Falls back to [PersonalProfile.defaultProfile] when
/// neither store holds anything.
///
/// The database and secret-store wiring is injected, so this class (including
/// the migration path) is unit-testable with fakes.
class SqliteProfileData implements ProfileDataSource {
  SqliteProfileData({
    required ProfileRepository repository,
    PersonalProfileData legacy = const PersonalProfileData(),
  }) : _repository = repository,
       _legacy = legacy;

  /// Production wiring: encrypted sqflite repository + OS-keystore-held key.
  factory SqliteProfileData.production() {
    final keyProvider = ProfileKeyProvider(const FlutterSecureKeyStore());

    return SqliteProfileData(
      repository: ProfileRepository(
        dao: ProfileSqfliteDao(),
        cipher: () async => AesCipher(await keyProvider.getOrCreateKey()),
      ),
    );
  }

  final ProfileRepository _repository;
  final PersonalProfileData _legacy;

  @override
  Future<PersonalProfile> read() async {
    final stored = await _repository.readProfile();
    if (stored != null) {
      return stored;
    }

    final migrated = await _legacy.readStored();
    if (migrated != null) {
      await _repository.writeProfile(migrated);
      return migrated;
    }

    return PersonalProfile.defaultProfile;
  }

  @override
  Future<void> write(PersonalProfile profile) {
    return _repository.writeProfile(profile);
  }
}
