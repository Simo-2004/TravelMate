// Smoke test: the app boots and shows the Home tab.
//
// Broader coverage lives in the focused suites: logic_test.dart,
// persistence_test.dart, chat_store_test.dart, widgets_test.dart, and
// screens_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/main.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/state/trip_store.dart';

import 'helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TravelMateApp boots to login then enters the Home tab', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    // The test pumps the app directly (bypassing main()), so seed the trip
    // catalog the Home tab reads after login and the login account.
    TripStore.instance.debugSetData(
      trips: TripCatalog.trips,
      recents: TripCatalog.recents,
    );
    await seedAuthService();
    final view = binding.platformDispatcher.implicitView!;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(900, 500);
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: FakeAssetBundle(),
        child: const TravelMateApp(),
      ),
    );
    await tester.pump();

    // Login gate is shown first; enter valid credentials to reach the app.
    expect(find.text('Enter'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'alessia');
    await tester.enterText(find.byType(TextField).last, 'travelmate');
    await tester.tap(find.text('Enter'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Recommended trips for you'), findsOneWidget);
  });
}
