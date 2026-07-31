/// Component testing — the Search tab and the full-results screen.
///
/// Both screens are driven by the same [SearchResearchModeStore], and each has
/// to filter a different catalog depending on it. The Search tab additionally
/// owns two behaviours the shell depends on: it pushes the results screen on
/// submit, and it takes keyboard focus when the bottom bar asks it to.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
import 'package:travelmate/features/search/search_screen.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    usePhoneSurface(binding);

    TripStore.instance.debugSetData(
      trips: [
        buildTrip(id: 'trip_1', label: 'Beach Escape'),
        buildTrip(id: 'trip_2', label: 'Mountain Hike'),
      ],
      recents: const [],
    );
  });

  group('SearchScreen', () {
    testWidgets('submitting a query pushes the full results screen', (
      tester,
    ) async {
      await tester.pumpWidget(wrapScaffold(const SearchScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'beach');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final results = tester.widget<SearchResultsScreen>(
        find.byType(SearchResultsScreen),
      );
      expect(results.initialQuery, 'beach');
    });

    testWidgets('submitting a blank query does nothing', (tester) async {
      await tester.pumpWidget(wrapScaffold(const SearchScreen()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(SearchResultsScreen), findsNothing);
    });

    testWidgets('typing narrows the visible results live', (tester) async {
      await tester.pumpWidget(wrapScaffold(const SearchScreen()));
      await tester.pump();
      expect(find.byType(MateCard), findsNWidgets(2));

      await tester.enterText(find.byType(TextField), 'beach');
      await tester.pump();

      expect(find.byType(MateCard), findsOneWidget);
      expect(find.text('Beach Escape'), findsWidgets);
    });

    testWidgets('a focus request from the bottom bar reaches the field', (
      tester,
    ) async {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapScaffold(
          NavigationScope(
            controller: controller,
            items: NavigationDefaults.config.items,
            child: const SearchScreen(),
          ),
        ),
      );
      await tester.pump();

      // Ask the field itself, not the global primary focus — the enclosing
      // scopes report focus of their own.
      bool fieldHasFocus() => tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode
          .hasFocus;

      expect(fieldHasFocus(), isFalse);

      // Tapping the Search tab while already on it asks the field to focus.
      controller
        ..index = 1
        ..requestFocus();
      await tester.pump();

      expect(
        fieldHasFocus(),
        isTrue,
        reason: 'the search field should have taken focus',
      );
      // The request is one-shot: Search consumed it.
      expect(controller.consumeFocusRequest(), isFalse);
    });

    testWidgets('a focus request for a different tab is ignored', (
      tester,
    ) async {
      final controller = NavigationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrapScaffold(
          NavigationScope(
            controller: controller,
            items: NavigationDefaults.config.items,
            child: const SearchScreen(),
          ),
        ),
      );
      await tester.pump();

      controller
        ..index =
            0 // Home, not Search
        ..requestFocus();
      await tester.pump();

      expect(
        controller.consumeFocusRequest(),
        isTrue,
        reason: 'the request must still be pending, not consumed by Search',
      );
    });
  });

  group('SearchResultsScreen', () {
    testWidgets('filters trips by the initial query', (tester) async {
      await tester.pumpWidget(
        wrapApp(const SearchResultsScreen(initialQuery: 'beach')),
      );
      await tester.pump();

      expect(find.byType(MateCard), findsOneWidget);
      expect(find.text('Beach Escape'), findsWidgets);
    });

    testWidgets('filters mates when the store is in mates mode', (
      tester,
    ) async {
      SearchResearchModeStore.instance.value = SearchResearchMode.mates;

      await tester.pumpWidget(
        wrapApp(const SearchResultsScreen(initialQuery: '')),
      );
      await tester.pump();

      // Mates come from the real catalog, not from the trip store.
      expect(find.byType(MateCard), findsWidgets);
      expect(find.text('Beach Escape'), findsNothing);
    });

    testWidgets('editing the query re-filters in place', (tester) async {
      await tester.pumpWidget(
        wrapApp(const SearchResultsScreen(initialQuery: '')),
      );
      await tester.pump();
      expect(find.byType(MateCard), findsNWidgets(2));

      await tester.enterText(find.byType(TextField), 'mountain');
      await tester.pump();

      expect(find.byType(MateCard), findsOneWidget);
      expect(find.text('Mountain Hike'), findsWidgets);
    });

    testWidgets('submitting inside the results screen just re-filters', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(const SearchResultsScreen(initialQuery: 'beach')),
      );
      await tester.pump();

      // Focus the field so the action reaches it, then submit.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // No second results screen was pushed on top of this one.
      expect(find.byType(SearchResultsScreen), findsOneWidget);
      expect(find.text('Beach Escape'), findsWidgets);
    });
  });
}
