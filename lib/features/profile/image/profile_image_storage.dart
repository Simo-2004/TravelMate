import 'dart:io';

import 'package:path/path.dart' as p;

/// Copies a picked image into the app's private documents directory and returns
/// the stored file's absolute path — never a BLOB.
///
/// Storing only the path keeps the database small and avoids the RAM/perf cost
/// of loading image bytes through SQLite. Pure `dart:io`, so it is unit-testable
/// with real temporary directories; the plugin-driven picking of the source
/// file lives in the excluded [ProfileImagePicker] adapter.
class ProfileImageStorage {
  const ProfileImageStorage();

  /// Subfolder (inside the documents dir) that holds saved profile pictures.
  static const String folderName = 'profile_images';

  /// Copies [source] into [documentsDir]/[folderName] under a unique name and
  /// returns the new absolute path. The extension of [source] is preserved.
  Future<String> saveProfileImage({
    required File source,
    required Directory documentsDir,
    DateTime? now,
  }) async {
    final targetDir = Directory(p.join(documentsDir.path, folderName));
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    final stamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final extension = p.extension(source.path);
    final fileName = 'profile_$stamp$extension';
    final destination = p.join(targetDir.path, fileName);

    final saved = await source.copy(destination);
    return saved.path;
  }
}
