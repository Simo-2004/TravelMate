// Component-level tests: each screen is pumped on its own, with the stores it
// reads from seeded in memory. Whole-app journeys live in test/system/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/chat/chat_screen.dart';
import 'package:travelmate/features/home/home_screen.dart';
import 'package:travelmate/features/saved/saved_items_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
import 'package:travelmate/features/search/search_screen.dart';
import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/features/settings/privacy_settings_screen.dart';
import 'package:travelmate/features/settings/settings_screen.dart';
import 'package:travelmate/features/settings/support_screen.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/personal_profile_store.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

import '../helpers/test_harness.dart';

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

  setUp(() async {
    // Every singleton store back to a clean, plugin-free state, then a
    // phone-sized render surface.
    await resetAllStores();
    usePhoneSurface(binding);
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
    await tester.pumpWidget(wrapApp(ChatScreen(mate: MateCatalog.mates.first)));
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
    await tester.pumpWidget(wrapApp(ChatScreen(mate: MateCatalog.mates.first)));
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

  testWidgets('SupportScreen expands FAQ and contacts support', (tester) async {
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
  });

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
    // Logout returns to the login screen.
    expect(find.text('Enter'), findsOneWidget);
    expect(find.text('Travel Mate'), findsOneWidget);
  });

  testWidgets(
    'PersonalProfileScreen edits fields, tags and photo, then saves',
    (tester) async {
      // Start from a profile with no tags yet, so the tag added below is
      // the only one on screen and its remove icon is unambiguous.
      PersonalProfileStore.instance.value = PersonalProfile.defaultProfile
          .copyWith(interestTags: const [], tripTags: const []);

      await tester.pumpWidget(wrapApp(const PersonalProfileScreen()));
      await tester.pump();
      expect(find.text('Edit profile'), findsOneWidget);
      expect(
        find.text(PersonalProfile.defaultProfile.fullName),
        findsOneWidget,
      );

      await tester.tap(find.text('Edit profile'));
      await tester.pump();
      expect(find.text('Edit your profile'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Zara');

      // Pick a different avatar from the photo picker.
      await tester.tap(
        find
            .descendant(of: find.byType(Wrap), matching: find.byType(InkWell))
            .last,
      );
      await tester.pump();

      // Add then remove an interest tag. The list grows past the viewport in
      // edit mode, so each further target needs to be scrolled into view.
      await tester.ensureVisible(
        find.widgetWithText(TextField, 'Type and add an interest tag'),
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Type and add an interest tag'),
        'Sunsets',
      );
      await tester.ensureVisible(find.text('Add personal tag').first);
      await tester.tap(find.text('Add personal tag').first);
      await tester.pump();
      // Shows both in the live read-only preview at the top of the screen
      // and in the editable list below it.
      expect(find.text('Sunsets'), findsWidgets);

      await tester.ensureVisible(find.byIcon(Icons.close_rounded).first);
      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pump();
      expect(find.text('Sunsets'), findsNothing);

      await tester.ensureVisible(find.text('Save profile changes'));
      await tester.tap(find.text('Save profile changes'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(PersonalProfileStore.instance.value.firstName, 'Zara');
      expect(find.text('Edit profile'), findsOneWidget);
    },
  );

  testWidgets('PersonalProfileScreen cancel discards draft changes', (
    tester,
  ) async {
    await tester.pumpWidget(wrapApp(const PersonalProfileScreen()));
    await tester.pump();

    await tester.tap(find.text('Edit profile'));
    await tester.pump();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Temp');

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pump();

    expect(find.text('Edit profile'), findsOneWidget);
    expect(
      PersonalProfileStore.instance.value.firstName,
      PersonalProfile.defaultProfile.firstName,
    );
  });
}
