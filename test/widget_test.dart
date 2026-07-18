// Smoke test: the app boots and shows the Home tab.
//
// Broader coverage lives in the focused suites: logic_test.dart,
// persistence_test.dart, chat_store_test.dart, widgets_test.dart, and
// screens_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/main.dart';

import 'helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TravelMateApp boots to the Home tab', (tester) async {
    SharedPreferences.setMockInitialValues({});
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
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Recommended trips for you'), findsOneWidget);
  });
}
