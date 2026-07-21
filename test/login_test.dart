import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/create_account_screen.dart';
import 'package:travelmate/features/auth/login_screen.dart';
import 'package:travelmate/shared/widgets/app_text_field.dart';
import 'package:travelmate/shared/widgets/brand_header.dart';
import 'package:travelmate/shared/widgets/link_text.dart';

import 'helpers/test_harness.dart';

void main() {
  testWidgets('LoginScreen renders brand, fields and enter button', (
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
    expect(fields[0].obscureText, isFalse); // username
    expect(fields[1].obscureText, isTrue); // password
  });

  testWidgets('valid credentials trigger onAuthenticated', (tester) async {
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

    await tester.enterText(find.byType(TextField).first, 'alessia');
    await tester.enterText(find.byType(TextField).last, 'travelmate');
    await tester.tap(find.text('Enter'));
    await tester.pump();

    expect(entered, isTrue);
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

  testWidgets('create-account link opens the create screen', (tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));
    await tester.pump();

    await tester.ensureVisible(find.byType(LinkText));
    await tester.tap(find.byType(LinkText));
    await tester.pumpAndSettle();

    expect(find.byType(CreateAccountScreen), findsOneWidget);
  });
}
