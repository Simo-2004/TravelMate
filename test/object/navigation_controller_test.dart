import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';

import '../helpers/test_harness.dart';

void main() {
  group('NavigationController', () {
    test('index setter notifies only on change', () {
      final controller = NavigationController(initialIndex: 0);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.index = 0; // same, no notify
      expect(notifications, 0);

      controller.index = 2;
      expect(controller.index, 2);
      expect(notifications, 1);
    });

    test('requestFocus increments and consumeFocusRequest fires once', () {
      final controller = NavigationController();
      expect(controller.consumeFocusRequest(), isFalse);

      controller.requestFocus();
      expect(controller.focusRequest, 1);
      expect(controller.consumeFocusRequest(), isTrue);
      // Already consumed: no second fire until a new request.
      expect(controller.consumeFocusRequest(), isFalse);

      controller.requestFocus();
      expect(controller.consumeFocusRequest(), isTrue);
    });
  });

  testWidgets('NavigationScope exposes controller and label lookup', (
    tester,
  ) async {
    final controller = NavigationController();
    int? searchIndex;
    NavigationController? found;

    await tester.pumpWidget(
      wrapApp(
        NavigationScope(
          controller: controller,
          items: NavigationDefaults.config.items,
          child: Builder(
            builder: (context) {
              found = NavigationScope.maybeControllerOf(context);
              searchIndex = NavigationScope.indexOfLabel(context, 'Search');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(identical(found, controller), isTrue);
    expect(searchIndex, 1);
  });

  testWidgets('indexOfLabel returns null for an unknown label', (tester) async {
    int? result = -1;
    await tester.pumpWidget(
      wrapApp(
        NavigationScope(
          controller: NavigationController(),
          items: NavigationDefaults.config.items,
          child: Builder(
            builder: (context) {
              result = NavigationScope.indexOfLabel(context, 'Nope');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(result, isNull);
  });
}
