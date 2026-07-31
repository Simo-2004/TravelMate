/// Regression testing — bugs that were reported, fixed, and must stay fixed.
///
/// Unlike the other suites, this one is not organised by architectural level.
/// Each test names a specific defect and asserts the behaviour that replaced
/// it, so a future change that quietly reintroduces the bug fails here with an
/// obvious label rather than somewhere unrelated.
library;

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/features/settings/privacy_settings_screen.dart';
import 'package:travelmate/shared/data/chat_history_data.dart';
import 'package:travelmate/shared/data/personal_profile_data.dart';
import 'package:travelmate/shared/data/sqlite_chat_data.dart';
import 'package:travelmate/shared/data/sqlite_profile_data.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/chat_store.dart';
import 'package:travelmate/shared/widgets/app_snackbar.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('snackbars used to queue up and linger', () {
    // Reported as: toggling "Private Profile" on/off/on left a backlog of
    // stale confirmations appearing long after the taps, each lasting 3-4s.

    testWidgets('rapid toggles leave exactly one snackbar, the newest', (
      tester,
    ) async {
      usePhoneSurface(binding);
      await tester.pumpWidget(wrapApp(const PrivacySettingsScreen()));
      await tester.pump();

      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byType(Switch).first);
        await tester.pump();
      }

      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('the confirmation is short-lived', (tester) async {
      usePhoneSurface(binding);
      await tester.pumpWidget(wrapApp(const PrivacySettingsScreen()));
      await tester.pump();

      await tester.tap(find.byType(Switch).first);
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.duration, AppSnackBar.duration);
      expect(AppSnackBar.duration, const Duration(milliseconds: 1500));

      // And it is gone well before the old 3-4 second dwell time.
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('chat message ids used to restart at 1 after a restart', () {
    // Reported as: history restored from disk did not advance the id counter,
    // so the next message reused an id that already existed.

    test('a restored conversation continues the id sequence', () {
      fakeAsync((async) {
        ChatStore.instance.debugSetDataSource(
          InMemoryChatData({
            'mate_z': [buildMessage('5', text: 'From last time')],
          }),
        );

        ChatStore.instance.initialize();
        async.flushMicrotasks();

        ChatStore.instance.sendMessage('mate_z', 'Back again');
        async.flushMicrotasks();

        final ids = ChatStore.instance
            .conversationFor('mate_z')
            .value
            .map((message) => message.id)
            .toList();
        expect(ids, ['5', '6']);

        // Drain the scheduled auto-reply timer.
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('ids stay unique across several conversations', () {
      fakeAsync((async) {
        resetChatStore();

        ChatStore.instance.sendMessage('mate_a', 'one');
        ChatStore.instance.sendMessage('mate_b', 'two');
        async.flushMicrotasks();

        final ids = [
          ...ChatStore.instance.conversationFor('mate_a').value,
          ...ChatStore.instance.conversationFor('mate_b').value,
        ].map((message) => message.id).toList();

        expect(ids.toSet(), hasLength(ids.length));

        async.elapse(const Duration(seconds: 2));
      });
    });
  });

  group('the bookmark button used to swap icons instead of colours', () {
    // Reported as: the saved/unsaved states swapped a plain flag for a
    // "barred" one, which was hard to read. The fix keeps a single icon and
    // a visible ring, and communicates state through colour alone.

    testWidgets('both states render the same icon asset', (tester) async {
      String assetOf() =>
          (tester.widget<SvgPicture>(find.byType(SvgPicture)).bytesLoader
                  as SvgAssetLoader)
              .assetName;

      await tester.pumpWidget(
        wrapScaffold(SaveTripButton(isSaved: false, onTap: () {})),
      );
      final unsavedAsset = assetOf();

      await tester.pumpWidget(
        wrapScaffold(SaveTripButton(isSaved: true, onTap: () {})),
      );

      expect(assetOf(), unsavedAsset);
    });

    testWidgets('the unsaved state is still visible, not invisible', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(SaveTripButton(isSaved: false, onTap: () {})),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(SaveTripButton),
          matching: find.byType(Material),
        ),
      );
      final ring = (material.shape! as CircleBorder).side;

      // A drawn ring with a real width, in the neutral grey — not transparent,
      // not the white background it sits on.
      expect(ring.color, AppColors.inactiveGray);
      expect(ring.width, greaterThan(0));
      expect(ring.color, isNot(AppColors.white));
    });
  });

  group('legacy data used to be migrated more than once', () {
    // Reported as: re-reading after a migration could pull the old
    // SharedPreferences copy back over newer database content.

    test('chat history is not re-migrated once the db has messages', () async {
      final data = SqliteChatData(
        repository: testChatRepository(FakeChatDao()),
      );
      await data.appendMessage('mate_1', buildMessage('1', text: 'Fresh'));

      // Something older is still sitting in the legacy store.
      await const ChatHistoryData().writeAll({
        'mate_1': [buildMessage('2', text: 'Stale')],
      });

      expect((await data.readAll())['mate_1']!.single.text, 'Fresh');
    });

    test(
      'a profile write after migration is not undone by a re-read',
      () async {
        await const PersonalProfileData().write(
          PersonalProfile.defaultProfile.copyWith(firstName: 'Legacy'),
        );
        final data = SqliteProfileData(
          repository: testProfileRepository(FakeProfileDao()),
        );

        await data.read(); // triggers the migration
        await data.write(
          PersonalProfile.defaultProfile.copyWith(firstName: 'Newer'),
        );

        expect((await data.read()).firstName, 'Newer');
      },
    );
  });

  group('profile photos must stay paths, never bytes', () {
    // Reported as a design constraint: images are copied into app storage and
    // only the path is persisted, so the database never grows a BLOB column.

    test('the stored profile row holds a path, not image data', () async {
      final dao = FakeProfileDao();
      final repository = testProfileRepository(dao);
      const path = '/data/user/0/app/profile_images/photo_1.png';

      await repository.writeProfile(
        PersonalProfile.defaultProfile.copyWith(photoAsset: path),
      );

      final stored = dao.row!['photo_path']! as String;
      // Encrypted, so not the path itself — but nowhere near image size.
      expect(stored, isNot(path));
      expect(stored.length, lessThan(500));

      // There is no bytes/blob column at all, only the encrypted path.
      expect(dao.row!.keys, isNot(contains('photo_bytes')));
      expect((await repository.readProfile())!.photoAsset, path);
    });
  });
}
