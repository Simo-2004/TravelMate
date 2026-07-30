/// Integration testing — profile photo storage on the real file system.
///
/// [ProfileImageStorage] is the piece that makes "upload a photo" safe: the
/// picked file is *copied* into the app's own documents directory and only its
/// path is ever persisted, so no image bytes end up as a BLOB in the database.
/// These tests run against real temporary directories rather than a fake, so
/// they exercise the actual copy.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/profile/image/profile_image_storage.dart';

void main() {
  late Directory documentsDir;
  late Directory sourceDir;

  setUp(() async {
    documentsDir = await Directory.systemTemp.createTemp('docs');
    sourceDir = await Directory.systemTemp.createTemp('src');
  });

  tearDown(() async {
    await documentsDir.delete(recursive: true);
    await sourceDir.delete(recursive: true);
  });

  Future<File> writeSource(String name, List<int> bytes) async {
    final source = File('${sourceDir.path}/$name');
    await source.writeAsBytes(bytes);
    return source;
  }

  test('copies the source into a profile_images subfolder', () async {
    const storage = ProfileImageStorage();
    final source = await writeSource('pick.png', [1, 2, 3, 4]);

    final savedPath = await storage.saveProfileImage(
      source: source,
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(42),
    );

    final saved = File(savedPath);
    expect(savedPath, contains(ProfileImageStorage.folderName));
    expect(savedPath, endsWith('.png'));
    expect(await saved.exists(), isTrue);
    expect(await saved.readAsBytes(), [1, 2, 3, 4]);
  });

  test('leaves the original file untouched', () async {
    const storage = ProfileImageStorage();
    final source = await writeSource('pick.png', [9, 9, 9]);

    await storage.saveProfileImage(
      source: source,
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(1),
    );

    expect(await source.exists(), isTrue);
    expect(await source.readAsBytes(), [9, 9, 9]);
  });

  test('keeps the original extension', () async {
    const storage = ProfileImageStorage();
    final source = await writeSource('pick.jpg', [1]);

    final savedPath = await storage.saveProfileImage(
      source: source,
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(1),
    );

    expect(savedPath, endsWith('.jpg'));
  });

  test('two saves at different times do not collide', () async {
    const storage = ProfileImageStorage();
    final first = await writeSource('one.png', [1]);
    final second = await writeSource('two.png', [2]);

    final firstPath = await storage.saveProfileImage(
      source: first,
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(100),
    );
    final secondPath = await storage.saveProfileImage(
      source: second,
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(200),
    );

    expect(firstPath, isNot(secondPath));
    expect(await File(firstPath).readAsBytes(), [1]);
    expect(await File(secondPath).readAsBytes(), [2]);
  });

  test('creates the folder when it does not exist yet', () async {
    const storage = ProfileImageStorage();
    final folder = Directory(
      '${documentsDir.path}/${ProfileImageStorage.folderName}',
    );
    expect(await folder.exists(), isFalse);

    await storage.saveProfileImage(
      source: await writeSource('pick.png', [1]),
      documentsDir: documentsDir,
      now: DateTime.fromMillisecondsSinceEpoch(1),
    );

    expect(await folder.exists(), isTrue);
  });
}
