/// System testing — end-to-end user journeys.
///
/// Each test here follows a complete task the way a person would perform it,
/// entirely through the UI of the fully assembled app: no store is poked
/// directly, no screen is constructed by hand. What is being tested is the
/// behaviour that only emerges once everything is connected — that a bookmark
/// made on one tab shows up on another, that chat history outlives leaving the
/// screen, that logging out really locks the app again.
///
/// The two groups render at different surface sizes on purpose. The bottom
/// navigation row needs a landscape surface for all four labels to fit, while
/// the schedule screen does not scroll and needs a portrait one for its
/// bookmark control to stay on-screen. No single size satisfies both, so each
/// journey runs at the shape a real device would give it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/auth/login_screen.dart';
import 'package:travelmate/features/chat/chat_screen.dart';
import 'package:travelmate/features/profile/personal_profile_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetAllStores);

  /// Opens the app and logs in with the seeded account.
  Future<void> enterApp(WidgetTester tester) async {
    await pumpApp(tester);
    await logIn(tester);
  }

  /// Scrolls [finder] into view and lets the scroll settle before tapping it —
  /// tapping mid-scroll resolves the offset against a position the widget has
  /// already left.
  Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pump();
  }

  group('shell navigation (landscape: all four tabs fit)', () {
    setUp(() => useWideSurface(binding));

    testWidgets('a user can reach every bottom tab', (tester) async {
      await enterApp(tester);

      expect(find.text('Recommended trips for you'), findsOneWidget);

      await openTab(tester, 'Search');
      expect(find.byType(SearchModeSwitchButton), findsOneWidget);

      await openTab(tester, 'Saved');
      expect(find.textContaining('Tap the bookmark button'), findsOneWidget);

      await openTab(tester, 'Settings');
      expect(find.text('Exit'), findsOneWidget);

      await openTab(tester, 'Home');
      expect(find.text('Recommended trips for you'), findsOneWidget);
    });

    testWidgets('the Settings tab shows the signed-in profile and opens it', (
      tester,
    ) async {
      await enterApp(tester);
      await openTab(tester, 'Settings');

      // The identity header reflects whoever is signed in.
      expect(find.text(PersonalProfile.defaultProfile.fullName), findsWidgets);

      await scrollAndTap(tester, find.text('Profile'));
      await pumpTransition(tester);

      expect(find.byType(PersonalProfileScreen), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Exit'), findsOneWidget);
    });

    testWidgets('logging out locks the app and a fresh login works again', (
      tester,
    ) async {
      await enterApp(tester);
      await openTab(tester, 'Settings');

      await scrollAndTap(tester, find.text('Exit'));
      await pumpTransition(tester);

      // Back at the gate, with the app shell gone from the stack entirely.
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Recommended trips for you'), findsNothing);

      await logIn(tester);
      expect(find.text('Recommended trips for you'), findsOneWidget);
    });

    testWidgets('after logging out, a wrong password is still rejected', (
      tester,
    ) async {
      await enterApp(tester);
      await openTab(tester, 'Settings');
      await scrollAndTap(tester, find.text('Exit'));
      await pumpTransition(tester);

      await logIn(tester, password: 'wrong-password');
      expect(find.text('Recommended trips for you'), findsNothing);

      await logIn(tester);
      expect(find.text('Recommended trips for you'), findsOneWidget);
    });
  });

  group('content journeys (portrait: full-height screens)', () {
    setUp(() => usePhoneSurface(binding, size: const Size(560, 1000)));

    testWidgets('a trip bookmarked on Home appears on the Saved tab', (
      tester,
    ) async {
      await enterApp(tester);

      // Open the first recommended trip and bookmark it.
      await tester.tap(find.byType(SquareImageButton).first);
      await pumpTransition(tester);
      expect(find.byType(TravelScheduleScreen), findsOneWidget);

      await scrollAndTap(tester, find.byType(SaveTripButton));

      // Back to the shell, then over to Saved: the empty state is gone.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await openTab(tester, 'Saved');

      expect(find.textContaining('Tap the bookmark button'), findsNothing);
    });

    testWidgets('un-bookmarking a trip empties the Saved tab again', (
      tester,
    ) async {
      await enterApp(tester);

      await tester.tap(find.byType(SquareImageButton).first);
      await pumpTransition(tester);
      await scrollAndTap(tester, find.byType(SaveTripButton));

      // Toggle it straight back off before leaving the screen.
      await scrollAndTap(tester, find.byType(SaveTripButton));

      await tester.pageBack();
      await tester.pumpAndSettle();
      await openTab(tester, 'Saved');

      expect(find.textContaining('Tap the bookmark button'), findsOneWidget);
    });

    testWidgets('chat history survives leaving and re-opening the chat', (
      tester,
    ) async {
      await enterApp(tester);
      await openTab(tester, 'Search');

      // Switch the search tab from trips to mates, then open the first mate.
      await tester.tap(find.byType(SearchModeSwitchButton));
      await tester.pump();
      await tester.tap(find.byType(MateCard).first);
      await pumpTransition(tester);
      expect(find.byType(MateDetailsScreen), findsOneWidget);

      // Open the chat and send a message.
      await scrollAndTap(tester, find.text('Chat'));
      await pumpTransition(tester);
      expect(find.byType(ChatScreen), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'See you in Bali');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(find.text('See you in Bali'), findsOneWidget);

      // Let the mate's auto-reply and the online timer finish.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 6));

      // Leave the chat and come back: the message is still there.
      await tester.pageBack();
      await tester.pumpAndSettle();
      await scrollAndTap(tester, find.text('Chat'));
      await pumpTransition(tester);

      expect(find.text('See you in Bali'), findsOneWidget);
    });

    testWidgets('a mate bookmarked from their profile reaches the Saved tab', (
      tester,
    ) async {
      await enterApp(tester);
      await openTab(tester, 'Search');

      await tester.tap(find.byType(SearchModeSwitchButton));
      await tester.pump();
      await tester.tap(find.byType(MateCard).first);
      await pumpTransition(tester);

      await scrollAndTap(tester, find.byType(SaveTripButton));

      await tester.pageBack();
      await tester.pumpAndSettle();
      await openTab(tester, 'Saved');

      expect(find.textContaining('Tap the bookmark button'), findsNothing);
    });
  });
}
