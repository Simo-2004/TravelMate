import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/create_account_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/utils/account_validation.dart';
import 'package:travelmate/shared/utils/tag_input.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';

import 'helpers/test_harness.dart';

void main() {
  group('AccountValidation', () {
    test('username: required, length bounds and allowed characters', () {
      expect(AccountValidation.validateUsername('  '), isNotNull);
      expect(AccountValidation.validateUsername('ab'), isNotNull); // too short
      expect(AccountValidation.validateUsername('a' * 21), isNotNull); // too long
      expect(AccountValidation.validateUsername('bad name'), isNotNull); // space
      expect(AccountValidation.validateUsername('good_user.1'), isNull);
    });

    test('password: required and minimum/maximum length', () {
      expect(AccountValidation.validatePassword(''), isNotNull);
      expect(AccountValidation.validatePassword('short7!'), isNotNull); // 7 chars
      expect(AccountValidation.validatePassword('a' * 65), isNotNull);
      expect(AccountValidation.validatePassword('travelmate'), isNull);
    });

    test('required name and description bounds', () {
      expect(AccountValidation.validateRequiredName('', 'Name'), isNotNull);
      expect(
        AccountValidation.validateRequiredName('a' * 41, 'Name'),
        isNotNull,
      );
      expect(AccountValidation.validateRequiredName('Alessia', 'Name'), isNull);
      expect(AccountValidation.validateDescription('a' * 301), isNotNull);
      expect(AccountValidation.validateDescription('short'), isNull);
    });
  });

  group('TagInput', () {
    test('normalize collapses whitespace', () {
      expect(TagInput.normalizeLabel('  beach   life '), 'beach life');
    });

    test('clean drops blanks and case-insensitive duplicates', () {
      expect(
        TagInput.clean(['Beach', 'beach', '  ', 'Food']),
        ['Beach', 'Food'],
      );
    });

    test('tryAdd appends, rejects duplicates and blanks', () {
      expect(TagInput.tryAdd(['Beach'], 'Food'), ['Beach', 'Food']);
      expect(TagInput.tryAdd(['Beach'], 'beach'), isNull);
      expect(TagInput.tryAdd(['Beach'], '   '), isNull);
    });

    test('remove deletes case-insensitively', () {
      expect(TagInput.remove(['Beach', 'Food'], 'beach'), ['Food']);
    });
  });

  group('CreateAccountScreen', () {
    late TestWidgetsFlutterBinding binding;

    setUp(() {
      binding = TestWidgetsFlutterBinding.ensureInitialized();
      PersonalProfileStore.instance.value = PersonalProfile.defaultProfile;
      PersonalProfileStore.instance.debugSetDataSource(InMemoryProfileData());

      final view = binding.platformDispatcher.implicitView!;
      view.devicePixelRatio = 1.0;
      view.physicalSize = const Size(400, 1200);
      addTearDown(() {
        view.resetPhysicalSize();
        view.resetDevicePixelRatio();
      });
    });

    testWidgets('valid form creates the account, profile and enters', (
      tester,
    ) async {
      String? createdUser;
      String? createdPass;
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (u, p) async {
              createdUser = u;
              createdPass = p;
            },
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');
      await tester.enterText(
        find.widgetWithText(TextField, 'Surname'),
        'Khan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'travelmate',
      );

      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(createdUser, 'zara_k');
      expect(createdPass, 'travelmate');
      expect(created, isTrue);
      expect(PersonalProfileStore.instance.value.firstName, 'Zara');
      expect(PersonalProfileStore.instance.value.lastName, 'Khan');
    });

    testWidgets('short password blocks creation and shows an error', (
      tester,
    ) async {
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (u, p) async => created = true,
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');
      await tester.enterText(
        find.widgetWithText(TextField, 'Surname'),
        'Khan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'short',
      );

      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(created, isFalse);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('uploaded photo is saved onto the new profile', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (u, p) async {},
            onCreated: (_) {},
            photoPicker: () async => '/tmp/new_avatar.png',
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');
      await tester.enterText(
        find.widgetWithText(TextField, 'Surname'),
        'Khan',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'travelmate',
      );

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();

      expect(
        PersonalProfileStore.instance.value.photoAsset,
        '/tmp/new_avatar.png',
      );
    });
  });
}
