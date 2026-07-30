/// Component testing — the profile photo widget and the upload flow.
///
/// [ProfilePhoto] has to render three different kinds of source: an empty
/// value, a bundled SVG asset, and an absolute path to a file the user picked.
/// The upload flow on [PersonalProfileScreen] is tested through an injected
/// picker, so no gallery plugin is involved.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/profile_photo.dart';

import '../helpers/test_harness.dart';

Future<String?> fixedPicker() async => '/tmp/uploaded_profile.png';

Future<String?> throwingPicker() async => throw Exception('picker failed');

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfilePhoto', () {
    testWidgets('shows a placeholder icon for an empty source', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(const ProfilePhoto(source: '', size: 60)),
      );

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renders a bundled SVG asset', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const ProfilePhoto(source: 'assets/icons/user_icon.svg', size: 60),
        ),
      );
      await tester.pump();

      expect(find.byType(ProfilePhoto), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsNothing);
    });

    testWidgets('uses Image.file for an absolute file path', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const ProfilePhoto(source: '/tmp/does_not_exist.png', size: 60),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('a missing file does not crash the widget', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const ProfilePhoto(source: '/tmp/definitely_absent.png', size: 60),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(ProfilePhoto), findsOneWidget);
    });
  });

  group('PersonalProfileScreen photo upload', () {
    setUp(() {
      PersonalProfileStore.instance
        ..value = PersonalProfile.defaultProfile
        ..debugSetDataSource(InMemoryProfileData());

      usePhoneSurface(binding);
    });

    testWidgets('stores the picked photo path on save', (tester) async {
      await tester.pumpWidget(
        wrapApp(const PersonalProfileScreen(photoPicker: fixedPicker)),
      );
      await tester.pump();

      await tester.tap(find.text('Edit profile'));
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      await tester.ensureVisible(find.text('Save profile changes'));
      await tester.tap(find.text('Save profile changes'));
      await tester.pump();

      expect(
        PersonalProfileStore.instance.value.photoAsset,
        '/tmp/uploaded_profile.png',
      );
    });

    testWidgets('cancelling after a pick leaves the stored photo alone', (
      tester,
    ) async {
      final original = PersonalProfileStore.instance.value.photoAsset;

      await tester.pumpWidget(
        wrapApp(const PersonalProfileScreen(photoPicker: fixedPicker)),
      );
      await tester.pump();

      await tester.tap(find.text('Edit profile'));
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(PersonalProfileStore.instance.value.photoAsset, original);
    });

    testWidgets('shows an error when picking fails', (tester) async {
      await tester.pumpWidget(
        wrapApp(const PersonalProfileScreen(photoPicker: throwingPicker)),
      );
      await tester.pump();

      await tester.tap(find.text('Edit profile'));
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      expect(find.text('Could not load the selected photo.'), findsOneWidget);
    });
  });
}
