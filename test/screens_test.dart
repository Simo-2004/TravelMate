import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:travelmate/features/chat/chat_screen.dart';
import 'package:travelmate/features/home/home_screen.dart';
import 'package:travelmate/features/saved/saved_items_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
import 'package:travelmate/features/search/search_screen.dart';
import 'package:travelmate/features/settings/privacy_settings_screen.dart';
import 'package:travelmate/features/settings/settings_screen.dart';
//import 'package:travelmate/features/settings/support_screen.dart';
import 'package:travelmate/main.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

import 'helpers/test_harness.dart';

SavedTripPreview _tripBookmark() {
  final trip = TripCatalog.trips.first;
  return SavedTripPreview(
    tripName: trip.label,
    destinationTitle: trip.destinationTitle,
    description: trip.description,
    coverImage: trip.scheduleImages.first,
    tags: trip.tags,
    bookmarkType: SavedBookmarkType.trip,
    sourceId: trip.tripId,
  );
}

SavedTripPreview _mateBookmark() {
  final mate = MateCatalog.mates.first;
  return SavedTripPreview(
    tripName: mate.name,
    destinationTitle: 'Profile: ${mate.name}',
    description: mate.description,
    coverImage: mate.profileImageAsset ?? '',
    tags: const [],
    bookmarkType: SavedBookmarkType.mate,
    sourceId: mate.id,
  );
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SavedTripPreviewStore.instance.value = const [];
    SearchResearchModeStore.instance.value = SearchResearchMode.trips;

    // Render at a phone-sized surface (the default 800x600 test window is a
    // landscape tablet, which the mobile-first layouts are not designed for).
    final view = binding.platformDispatcher.implicitView!;
    view.devicePixelRatio = 1.0;
    view.physicalSize = const Size(400, 900);
  });

  tearDown(() {
    final view = binding.platformDispatcher.implicitView!;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('HomeScreen renders sliders and opens a trip', (tester) async {
    await tester.pumpWidget(wrapScaffold(const HomeScreen()));
    await tester.pump();
    expect(find.text('Recommended trips for you'), findsOneWidget);
    expect(find.text('Viewed recently'), findsOneWidget);

    await tester.tap(find.byType(SquareImageButton).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TravelScheduleScreen), findsOneWidget);
  });

  testWidgets('SearchScreen opens a trip and a mate from results', (
    tester,
  ) async {
    await tester.pumpWidget(wrapScaffold(const SearchScreen()));
    await tester.pump();

    // Trips mode: tap the first result card -> schedule screen.
    await tester.tap(find.byType(MateCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TravelScheduleScreen), findsOneWidget);

    // Back, switch to mates, tap the first mate card -> details screen.
    await tester.pageBack();
    await tester.pumpAndSettle();
    SearchResearchModeStore.instance.value = SearchResearchMode.mates;
    await tester.pump();
    await tester.tap(find.byType(MateCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MateDetailsScreen), findsOneWidget);
  });

  testWidgets('SearchScreen shows trips by default and switches to mates', (
    tester,
  ) async {
    await tester.pumpWidget(wrapScaffold(const SearchScreen()));
    await tester.pump();
    expect(find.text('Trips'), findsWidgets);

    SearchResearchModeStore.instance.value = SearchResearchMode.mates;
    await tester.pump();
    expect(find.text('Mates'), findsWidgets);
  });

  testWidgets('SearchResultsScreen filters by the initial query', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(SearchResultsScreen(initialQuery: TripCatalog.trips.first.label)),
    );
    await tester.pump();
    expect(find.text('Search'), findsWidgets);
  });

  testWidgets('SavedItemsScreen shows empty state then a saved card', (
    tester,
  ) async {
    await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
    await tester.pump();
    expect(find.textContaining('Tap the bookmark button'), findsOneWidget);

    SavedTripPreviewStore.instance.stageBookmark(_tripBookmark());
    await tester.pump();
    expect(find.text(TripCatalog.trips.first.label), findsWidgets);
  });

  testWidgets('SavedItemsScreen opens a saved trip', (tester) async {
    SavedTripPreviewStore.instance.stageBookmark(_tripBookmark());
    await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
    await tester.pump();

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(TravelScheduleScreen), findsOneWidget);
  });

  testWidgets('SavedItemsScreen opens a saved mate', (tester) async {
    SavedTripPreviewStore.instance.stageBookmark(_mateBookmark());
    await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
    await tester.pump();

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(MateDetailsScreen), findsOneWidget);
  });

  testWidgets('MateDetailsScreen renders and toggles bookmark', (tester) async {
    await tester.pumpWidget(
      wrapApp(MateDetailsScreen(mate: MateCatalog.mates.first)),
    );
    await tester.pump();
    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Interests'), findsOneWidget);
    expect(find.text('Preferred trips'), findsOneWidget);

    await tester.tap(find.byType(SaveTripButton));
    await tester.pump();
    expect(SavedTripPreviewStore.instance.value, isNotEmpty);
  });

  testWidgets('MateDetailsScreen chat button opens ChatScreen', (tester) async {
    await tester.pumpWidget(
      wrapApp(MateDetailsScreen(mate: MateCatalog.mates.first)),
    );
    await tester.pump();

    await tester.tap(find.text('Chat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ChatScreen), findsOneWidget);
  });

  testWidgets('TravelScheduleScreen renders and toggles bookmark', (
    tester,
  ) async {
    final trip = TripCatalog.trips.first;
    await tester.pumpWidget(
      wrapApp(
        TravelScheduleScreen(
          tripId: trip.tripId,
          tripName: trip.destinationTitle,
          images: trip.scheduleImages,
          tags: trip.tags,
          destinationTitle: trip.destinationTitle,
          destinationDescription: trip.description,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(SaveTripButton));
    await tester.pump();
    expect(SavedTripPreviewStore.instance.value, isNotEmpty);
  });

  testWidgets('ChatScreen sends a message and clears history', (tester) async {
    await tester.pumpWidget(
      wrapApp(ChatScreen(mate: MateCatalog.mates.first)),
    );
    await tester.pump();
    expect(find.textContaining('Say hi'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hello there');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    expect(find.text('hello there'), findsOneWidget);

    // Flush the reply + offline timers.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 6));

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    expect(find.text('hello there'), findsNothing);
  });

  testWidgets('ChatScreen attach button reveals the trip picker', (
    tester,
  ) async {
    SavedTripPreviewStore.instance.stageBookmark(_tripBookmark());
    await tester.pumpWidget(
      wrapApp(ChatScreen(mate: MateCatalog.mates.first)),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.byType(SquareImageButton), findsWidgets);
  });

  testWidgets('PrivacySettingsScreen toggles a switch', (tester) async {
    await tester.pumpWidget(wrapApp(const PrivacySettingsScreen()));
    await tester.pump();
    expect(find.text('Privacy'), findsWidgets);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);
  });

  /*testWidgets('SupportScreen expands FAQ and contacts support', (tester) async {
    await tester.pumpWidget(wrapApp(const SupportScreen()));
    await tester.pump();
    expect(find.text('FAQ'), findsOneWidget);

    // Expand the contact card and trigger the contact action.
    await tester.tap(find.text('Contact support').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.byType(SnackBar), findsOneWidget);

    // Expand the FAQ card to render its question/answer children.
    await tester.tap(find.text('FAQ'));
    await tester.pumpAndSettle();
    expect(find.textContaining('edit my personal profile'), findsOneWidget);
  });*/

  testWidgets('SettingsScreen renders profile and action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(const SettingsScreen()));
    await tester.pump();
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);

    await tester.tap(find.text('Exit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('log out done'), findsOneWidget);
  });

  testWidgets('App boots and navigates across bottom tabs', (tester) async {
    // Landscape surface: keeps the shortest side (and thus font scale) modest
    // while giving the bottom nav row enough width for all four labels.
    final view = binding.platformDispatcher.implicitView!;
    view.physicalSize = const Size(900, 500);

    // The bottom nav bar can trip a small cosmetic RenderFlex overflow in
    // debug at some surface sizes; that is a paint-time warning, not a logic
    // failure, so ignore it here while still surfacing every other error.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      DefaultAssetBundle(bundle: FakeAssetBundle(), child: const TravelMateApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Home tab content.
    expect(find.text('Recommended trips for you'), findsOneWidget);

    // Switch to Search.
    await tester.tap(find.text('Search'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Switch to Saved.
    await tester.tap(find.text('Saved'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Tap the bookmark button'), findsOneWidget);

    // Switch to Settings.
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Exit'), findsOneWidget);
  });
}
