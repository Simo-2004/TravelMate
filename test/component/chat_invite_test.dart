/// Component testing — sending a trip invite from the chat screen.
///
/// This is the one place where three parts meet: the saved-trips picker, the
/// [mateLikesTrip] decision, and the chat store. Whether the mate accepts is
/// decided from their interests, so the same gesture produces a different
/// reply depending on who is being invited.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/chat/chat_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';
import 'package:travelmate/shared/widgets/chat_trip_attachment_picker.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    usePhoneSurface(binding);

    TripStore.instance.debugSetData(
      trips: [
        buildTrip(
          id: 'trip_1',
          label: 'Island Week',
          tags: [buildTag('island-vibe')],
        ),
      ],
      recents: const [],
    );
    SavedTripPreviewStore.instance.value = const [];
    SavedTripPreviewStore.instance.stageBookmark(
      buildBookmark(name: 'Island Week', sourceId: 'trip_1'),
    );
  });

  /// Opens the attachment picker and taps the first saved trip in it.
  Future<void> attachFirstTrip(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    await tester.tap(find.byType(SquareImageButton).first);
    await tester.pump();
  }

  testWidgets('a mate who likes the trip accepts the invite', (tester) async {
    final mate = buildMate(
      id: 'mate_yes',
      name: 'Yara',
      preferredTrips: ['island-vibe'],
    );

    await tester.pumpWidget(wrapApp(ChatScreen(mate: mate)));
    await tester.pump();

    await attachFirstTrip(tester);

    expect(find.text(AppStrings.chatTripInviteMessage), findsOneWidget);

    // The reply arrives after the scripted delay.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text(AppStrings.chatReplyTripAccepted), findsOneWidget);

    await tester.pump(const Duration(seconds: 6)); // drain the online timer
  });

  testWidgets('a mate with different tastes declines', (tester) async {
    final mate = buildMate(
      id: 'mate_no',
      name: 'Nils',
      interests: ['mountains'],
    );

    await tester.pumpWidget(wrapApp(ChatScreen(mate: mate)));
    await tester.pump();

    await attachFirstTrip(tester);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text(AppStrings.chatReplyTripDeclined), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('the picker closes once a trip has been attached', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        ChatScreen(
          mate: buildMate(id: 'mate_x', name: 'Xu'),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump();
    expect(find.byType(ChatTripAttachmentPicker), findsOneWidget);

    await tester.tap(find.byType(SquareImageButton).first);
    await tester.pump();
    expect(find.byType(ChatTripAttachmentPicker), findsNothing);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('tapping the attached trip card opens its schedule', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapApp(
        ChatScreen(
          mate: buildMate(id: 'mate_x', name: 'Xu'),
        ),
      ),
    );
    await tester.pump();

    await attachFirstTrip(tester);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Island Week'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(TravelScheduleScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
  });
}
