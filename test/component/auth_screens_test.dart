/// Component testing — the login and sign-up screens.
///
/// A component here is a whole screen: several widgets, a piece of form state,
/// and a set of collaborators reached through its constructor. Both screens
/// take their authentication callback as an injectable parameter, so the
/// component can be tested through its own interface without the real
/// [AuthService] behind it. Whether the *real* credentials work is a system
/// concern, covered in test/system/.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/create_account_screen.dart';
import 'package:travelmate/features/auth/login_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/brand_header.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';
import 'package:travelmate/shared/widgets/link_text.dart';

import '../helpers/test_harness.dart';

/// A validator that always answers [result], recording what it was asked.
CredentialValidator recordingValidator(bool result, List<String> attempts) {
  return (username, password) async {
    attempts.add('$username/$password');
    return result;
  };
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen', () {
    testWidgets('renders the brand, both fields and the enter button', (
      tester,
    ) async {
      await tester.pumpWidget(wrapApp(const LoginScreen()));
      await tester.pump();

      expect(find.byType(BrandHeader), findsOneWidget);
      expect(find.text('Travel Mate'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Enter'), findsOneWidget);
    });

    testWidgets('password field is obscured, username is not', (tester) async {
      await tester.pumpWidget(wrapApp(const LoginScreen()));
      await tester.pump();

      final fields = tester
          .widgetList<AppTextField>(find.byType(AppTextField))
          .toList();

      expect(fields, hasLength(2));
      expect(fields[0].obscureText, isFalse, reason: 'username');
      expect(fields[1].obscureText, isTrue, reason: 'password');
    });

    testWidgets('valid credentials trigger onAuthenticated', (tester) async {
      var entered = false;
      final attempts = <String>[];

      await tester.pumpWidget(
        wrapApp(
          LoginScreen(
            authenticate: recordingValidator(true, attempts),
            onAuthenticated: (_) => entered = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, 'alessia');
      await tester.enterText(find.byType(TextField).last, 'travelmate');
      await tester.tap(find.text('Enter'));
      await tester.pump();

      expect(entered, isTrue);
      expect(attempts, ['alessia/travelmate']);
    });

    testWidgets('the username is trimmed but the password is passed as typed', (
      tester,
    ) async {
      final attempts = <String>[];

      await tester.pumpWidget(
        wrapApp(
          LoginScreen(
            authenticate: recordingValidator(true, attempts),
            onAuthenticated: (_) {},
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).first, '  alessia  ');
      await tester.enterText(find.byType(TextField).last, ' spaced ');
      await tester.tap(find.text('Enter'));
      await tester.pump();

      expect(attempts, ['alessia/ spaced ']);
    });

    testWidgets('invalid credentials show an error and do not enter', (
      tester,
    ) async {
      var entered = false;

      await tester.pumpWidget(
        wrapApp(
          LoginScreen(
            authenticate: (username, password) async => false,
            onAuthenticated: (_) => entered = true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Enter'));
      await tester.pump();

      expect(entered, isFalse);
      expect(find.text('Invalid username or password'), findsOneWidget);
    });

    testWidgets('submitting the password field triggers authentication', (
      tester,
    ) async {
      var entered = false;

      await tester.pumpWidget(
        wrapApp(
          LoginScreen(
            authenticate: (username, password) async => true,
            onAuthenticated: (_) => entered = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField).last, 'travelmate');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(entered, isTrue);
    });

    testWidgets('the create-account link opens the sign-up screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapApp(const LoginScreen()));
      await tester.pump();

      await tester.ensureVisible(find.byType(LinkText));
      await tester.tap(find.byType(LinkText));
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });
  });

  group('CreateAccountScreen', () {
    setUp(() {
      PersonalProfileStore.instance
        ..value = PersonalProfile.defaultProfile
        ..debugSetDataSource(InMemoryProfileData());

      usePhoneSurface(binding, size: const Size(400, 1200));
    });

    /// Fills the four mandatory fields with valid values.
    Future<void> fillRequiredFields(
      WidgetTester tester, {
      String password = 'travelmate',
    }) async {
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');
      await tester.enterText(find.widgetWithText(TextField, 'Surname'), 'Khan');
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        password,
      );
    }

    Future<void> submit(WidgetTester tester) async {
      await tester.ensureVisible(find.byType(CustomButton));
      await tester.tap(find.byType(CustomButton));
      await tester.pump();
    }

    testWidgets('a valid form creates the account, the profile and enters', (
      tester,
    ) async {
      String? createdUser;
      String? createdPass;
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {
              createdUser = username;
              createdPass = password;
            },
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await fillRequiredFields(tester);
      await submit(tester);

      expect(createdUser, 'zara_k');
      expect(createdPass, 'travelmate');
      expect(created, isTrue);
      expect(PersonalProfileStore.instance.value.firstName, 'Zara');
      expect(PersonalProfileStore.instance.value.lastName, 'Khan');
    });

    testWidgets('a short password blocks creation and shows an error', (
      tester,
    ) async {
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async => created = true,
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await fillRequiredFields(tester, password: 'short');
      await submit(tester);

      expect(created, isFalse);
      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('an invalid username blocks creation and shows an error', (
      tester,
    ) async {
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async => created = true,
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await fillRequiredFields(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'has a space',
      );
      await submit(tester);

      expect(created, isFalse);
      expect(find.textContaining('Use only letters'), findsOneWidget);
    });

    testWidgets('missing name and surname block creation', (tester) async {
      var created = false;

      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async => created = true,
            onCreated: (_) => created = true,
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextField, 'Username'),
        'zara_k',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'travelmate',
      );
      await submit(tester);

      expect(created, isFalse);
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('Surname is required'), findsOneWidget);
    });

    testWidgets('added tags are saved onto the new profile', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
          ),
        ),
      );
      await tester.pump();

      await fillRequiredFields(tester);

      const tagField = 'Type and add an interest tag';
      await tester.ensureVisible(find.widgetWithText(TextField, tagField));
      await tester.enterText(
        find.widgetWithText(TextField, tagField),
        'Sunsets',
      );
      await tester.ensureVisible(find.text('Add personal tag').first);
      await tester.tap(find.text('Add personal tag').first);
      await tester.pump();

      await submit(tester);

      expect(PersonalProfileStore.instance.value.interestTags, ['Sunsets']);
    });

    testWidgets('an uploaded photo is saved onto the new profile', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
            photoPicker: () async => '/tmp/new_avatar.png',
          ),
        ),
      );
      await tester.pump();

      await fillRequiredFields(tester);

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      await submit(tester);

      expect(
        PersonalProfileStore.instance.value.photoAsset,
        '/tmp/new_avatar.png',
      );
    });

    testWidgets('a failing photo picker shows an error and keeps the form', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          CreateAccountScreen(
            createAccount: (username, password) async {},
            onCreated: (_) {},
            photoPicker: () async => throw Exception('picker failed'),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Upload photo'));
      await tester.tap(find.text('Upload photo'));
      await tester.pump();

      expect(find.text('Could not load the selected photo.'), findsOneWidget);
      expect(find.byType(CreateAccountScreen), findsOneWidget);
    });
  });
}
