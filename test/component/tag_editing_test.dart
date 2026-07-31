/// Component testing — editing personal tags.
///
/// The profile and sign-up screens both host two [EditablePersonalTagGroup]s
/// (interests and trips) wired to *separate* controllers and lists. That
/// symmetry is exactly where a copy-paste slip hides — an "add trip tag"
/// handler that quietly edits the interest list — so both groups are driven
/// here, and each assertion checks that the other list was left alone.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/create_account_screen.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';

import '../helpers/test_harness.dart';

const String interestField = 'Type and add an interest tag';
const String tripField = 'Type and add a trip tag';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    usePhoneSurface(binding, size: const Size(400, 1400));
  });

  /// Types [label] into the tag field named [fieldLabel] and presses its
  /// "Add personal tag" button.
  Future<void> addTag(
    WidgetTester tester,
    String fieldLabel,
    String label,
  ) async {
    final field = find.widgetWithText(TextField, fieldLabel);
    await tester.ensureVisible(field);
    await tester.enterText(field, label);

    // Each group has its own Add button; pick the one after this field.
    final button = find
        .ancestor(of: field, matching: find.byType(Column))
        .first;
    final addButton = find
        .descendant(of: button, matching: find.text('Add personal tag'))
        .first;
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();
  }

  group('PersonalProfileScreen', () {
    Future<void> openEditor(WidgetTester tester) async {
      PersonalProfileStore.instance.value = PersonalProfile.defaultProfile
          .copyWith(interestTags: const ['Beaches'], tripTags: const ['Ferry']);

      await tester.pumpWidget(wrapApp(const PersonalProfileScreen()));
      await tester.pump();
      await tester.tap(find.text('Edit profile'));
      await tester.pump();
    }

    Future<void> save(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Save profile changes'));
      await tester.tap(find.text('Save profile changes'));
      await tester.pump();
    }

    testWidgets('adds a trip tag without touching the interest tags', (
      tester,
    ) async {
      await openEditor(tester);

      await addTag(tester, tripField, 'Night trains');
      await save(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.tripTags, ['Ferry', 'Night trains']);
      expect(profile.interestTags, ['Beaches']);
    });

    testWidgets('adds an interest tag without touching the trip tags', (
      tester,
    ) async {
      await openEditor(tester);

      await addTag(tester, interestField, 'Sunsets');
      await save(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.interestTags, ['Beaches', 'Sunsets']);
      expect(profile.tripTags, ['Ferry']);
    });

    testWidgets('submitting the tag field from the keyboard also adds it', (
      tester,
    ) async {
      await openEditor(tester);

      final field = find.widgetWithText(TextField, tripField);
      await tester.ensureVisible(field);
      await tester.enterText(field, 'Sleeper cars');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      await save(tester);

      expect(PersonalProfileStore.instance.value.tripTags, [
        'Ferry',
        'Sleeper cars',
      ]);
    });

    testWidgets('removes a trip tag, leaving the interest tags alone', (
      tester,
    ) async {
      await openEditor(tester);

      // Two remove icons are on screen: the first belongs to the interest
      // group, the second to the trip group.
      final removeIcons = find.byIcon(Icons.close_rounded);
      await tester.ensureVisible(removeIcons.last);
      await tester.tap(removeIcons.last);
      await tester.pump();

      await save(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.tripTags, isEmpty);
      expect(profile.interestTags, ['Beaches']);
    });

    testWidgets('removes an interest tag, leaving the trip tags alone', (
      tester,
    ) async {
      await openEditor(tester);

      final removeIcons = find.byIcon(Icons.close_rounded);
      await tester.ensureVisible(removeIcons.first);
      await tester.tap(removeIcons.first);
      await tester.pump();

      await save(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.interestTags, isEmpty);
      expect(profile.tripTags, ['Ferry']);
    });

    testWidgets('clearing a text field keeps the stored value, not a blank', (
      tester,
    ) async {
      await openEditor(tester);
      final stored = PersonalProfileStore.instance.value;

      await tester.enterText(find.widgetWithText(TextField, 'Name'), '   ');
      await tester.enterText(find.widgetWithText(TextField, 'Surname'), '');
      await tester.enterText(
        find.widgetWithText(TextField, 'Description'),
        '  ',
      );
      await save(tester);

      final saved = PersonalProfileStore.instance.value;
      expect(saved.firstName, stored.firstName);
      expect(saved.lastName, stored.lastName);
      expect(saved.description, stored.description);
    });
  });

  group('CreateAccountScreen', () {
    Future<void> fillCredentials(WidgetTester tester) async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');
      await tester.enterText(find.widgetWithText(TextField, 'Surname'), 'Khan');
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'travelmate',
      );
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();
    }

    testWidgets('trip and interest tags are collected separately', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
          ),
        ),
      );
      await tester.pump();

      await fillCredentials(tester);
      await addTag(tester, interestField, 'Sunsets');
      await addTag(tester, tripField, 'Night trains');
      await submit(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.interestTags, ['Sunsets']);
      expect(profile.tripTags, ['Night trains']);
    });

    testWidgets('a tag can be added then removed again before submitting', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
          ),
        ),
      );
      await tester.pump();

      await fillCredentials(tester);
      await addTag(tester, interestField, 'Sunsets');
      await addTag(tester, tripField, 'Night trains');

      // Drop the trip tag; the interest tag must survive.
      final removeIcons = find.byIcon(Icons.close_rounded);
      await tester.ensureVisible(removeIcons.last);
      await tester.tap(removeIcons.last);
      await tester.pump();

      await submit(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.tripTags, isEmpty);
      expect(profile.interestTags, ['Sunsets']);
    });

    testWidgets('removing an interest tag leaves the trip tag in place', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
          ),
        ),
      );
      await tester.pump();

      await fillCredentials(tester);
      await addTag(tester, interestField, 'Sunsets');
      await addTag(tester, tripField, 'Night trains');

      // The first close icon belongs to the interest group.
      final removeIcons = find.byIcon(Icons.close_rounded);
      await tester.ensureVisible(removeIcons.first);
      await tester.tap(removeIcons.first);
      await tester.pump();

      await submit(tester);

      final profile = PersonalProfileStore.instance.value;
      expect(profile.interestTags, isEmpty);
      expect(profile.tripTags, ['Night trains']);
    });

    testWidgets('with no onCreated callback it opens the app shell itself', (
      tester,
    ) async {
      // The shell brings the bottom nav bar, which overflows cosmetically on
      // this tall narrow surface.
      ignoreRenderFlexOverflow();

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(createAccount: (username, password) async {}),
        ),
      );
      await tester.pump();

      await fillCredentials(tester);
      await submit(tester);
      await pumpTransition(tester);

      expect(find.byType(NavigationShell), findsOneWidget);
      // Sign-up clears the stack, so the form cannot be returned to.
      expect(find.byType(CreateAccountScreen), findsNothing);
    });
  });
}
