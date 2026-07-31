/// System testing — startup and the authentication gate.
///
/// These tests drive the whole assembled application: the real [TravelMateApp]
/// widget, the real screens, the real singleton stores. Nothing is stubbed
/// except the platform plugins themselves (SQLite, secure storage, the asset
/// bundle), which would need a device.
///
/// The concern at this level is emergent behaviour that no single component
/// owns: that the app comes up at all, that it comes up *locked*, and that
/// only a valid credential unlocks it.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/login_screen.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    useWideSurface(binding);
  });

  testWidgets('boots to the login gate, not to the app shell', (tester) async {
    await pumpApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Enter'), findsOneWidget);
    // The authenticated shell must not exist before a successful login.
    expect(find.byType(NavigationShell), findsNothing);
  });

  testWidgets('valid credentials unlock the app on the Home tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await logIn(tester);

    expect(find.byType(NavigationShell), findsOneWidget);
    // The login route is replaced, not stacked: it must be gone entirely.
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.text('Recommended trips for you'), findsOneWidget);
  });

  testWidgets('a wrong password leaves the app locked', (tester) async {
    await pumpApp(tester);
    await logIn(tester, password: 'definitely-not-the-password');

    expect(find.text('Invalid username or password'), findsOneWidget);
    expect(find.byType(NavigationShell), findsNothing);
    expect(find.text('Recommended trips for you'), findsNothing);
  });

  testWidgets('an unknown username leaves the app locked', (tester) async {
    await pumpApp(tester);
    await logIn(tester, username: 'someone_else');

    expect(find.text('Invalid username or password'), findsOneWidget);
    expect(find.byType(NavigationShell), findsNothing);
  });
}
