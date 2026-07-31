/// Component testing — the Home tab's two navigation affordances.
///
/// Home does not own a search field of its own: its search bar is read-only
/// and its job is to hand control to the Search tab, which it can only do when
/// it is mounted inside a [NavigationScope]. Both that hand-off and the
/// "viewed recently" shortcut are covered here.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/home/home_screen.dart';
import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/state/trip_store.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    usePhoneSurface(binding);

    TripStore.instance.debugSetData(
      trips: [buildTrip(id: 'trip_1', label: 'Island Week')],
      recents: [buildTrip(id: 'trip_2', label: 'Recent Ridge')],
    );
  });

  /// Mounts Home inside a navigation scope, as the app shell does.
  Widget homeInScope(NavigationController controller) {
    return wrapScaffold(
      NavigationScope(
        controller: controller,
        items: NavigationDefaults.config.items,
        child: const HomeScreen(),
      ),
    );
  }

  testWidgets(
    'the read-only search bar jumps to the Search tab and focuses it',
    (tester) async {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(homeInScope(controller));
      await tester.pump();

      await tester.tap(find.byType(TravelSearchBar));
      await tester.pump();

      expect(controller.index, 1, reason: 'Search is the second tab');
      expect(controller.consumeFocusRequest(), isTrue);
    },
  );

  testWidgets('without a navigation scope the search bar is simply inert', (
    tester,
  ) async {
    await tester.pumpWidget(wrapScaffold(const HomeScreen()));
    await tester.pump();

    await tester.tap(find.byType(TravelSearchBar));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('a recommended trip opens its schedule', (tester) async {
    await tester.pumpWidget(wrapScaffold(const HomeScreen()));
    await tester.pump();

    await tester.tap(find.widgetWithText(SquareImageButton, 'Island Week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester
          .widget<TravelScheduleScreen>(find.byType(TravelScheduleScreen))
          .tripId,
      'trip_1',
    );
  });

  testWidgets('a "viewed recently" trip opens its schedule too', (
    tester,
  ) async {
    await tester.pumpWidget(wrapScaffold(const HomeScreen()));
    await tester.pump();

    await tester.ensureVisible(
      find.widgetWithText(SquareImageButton, 'Recent Ridge'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SquareImageButton, 'Recent Ridge'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      tester
          .widget<TravelScheduleScreen>(find.byType(TravelScheduleScreen))
          .tripId,
      'trip_2',
    );
  });
}
