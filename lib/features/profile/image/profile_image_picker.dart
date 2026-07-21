import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:travelmate/features/profile/image/profile_image_storage.dart';

/// Lets the user pick a profile photo and persists it into app storage,
/// returning the saved file path (or null if the user cancelled).
///
/// Thin adapter over `image_picker` + `path_provider` (excluded from coverage);
/// the actual file copy is delegated to the unit-tested [ProfileImageStorage].
class ProfileImagePicker {
  const ProfileImagePicker({
    ImagePicker? picker,
    ProfileImageStorage storage = const ProfileImageStorage(),
  }) : _picker = picker,
       _storage = storage;

  final ImagePicker? _picker;
  final ProfileImageStorage _storage;

  Future<String?> pickAndStore() async {
    final picker = _picker ?? ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (picked == null) {
      return null;
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    return _storage.saveProfileImage(
      source: File(picked.path),
      documentsDir: documentsDir,
    );
  }
}
