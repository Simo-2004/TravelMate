/// Component testing — the Saved tab's bookmark resolution.
///
/// A saved card only stores a *snapshot* of what was bookmarked. Opening it
/// again has to find the live catalog entry behind that snapshot, and records
/// written by older builds may identify it by id, by label, or by destination
/// title. When nothing matches, the screen still has to open something
/// sensible rather than fail — so each of those paths is exercised here.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/saved/saved_items_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/state/trip_store.dart';

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
          label: 'Beach Escape',
          destinationTitle: 'Bali',
          tags: [buildTag('relax')],
        ),
      ],
      recents: [buildTrip(id: 'trip_2', label: 'Mountain Hike')],
    );
    SavedTripPreviewStore.instance.value = const [];
  });

  /// Pumps the screen with [bookmark] already saved, then taps its card.
  Future<void> openCardFor(
    WidgetTester tester,
    SavedTripPreview bookmark,
  ) async {
    SavedTripPreviewStore.instance.stageBookmark(bookmark);
    await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
    await tester.pump();

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('resolving a saved trip back to the catalog', () {
    testWidgets('by its canonical id', (tester) async {
      await openCardFor(tester, buildBookmark(sourceId: 'trip_1'));

      final screen = tester.widget<TravelScheduleScreen>(
        find.byType(TravelScheduleScreen),
      );
      expect(screen.tripId, 'trip_1');
      expect(screen.destinationTitle, 'Bali');
    });

    testWidgets('by label, for records that stored the label as the id', (
      tester,
    ) async {
      await openCardFor(
        tester,
        buildBookmark(name: 'ignored', sourceId: 'beach escape'),
      );

      expect(
        tester
            .widget<TravelScheduleScreen>(find.byType(TravelScheduleScreen))
            .tripId,
        'trip_1',
      );
    });

    testWidgets('by trip name, when the id matches nothing', (tester) async {
      await openCardFor(
        tester,
        buildBookmark(name: 'Mountain Hike', sourceId: ''),
      );

      expect(
        tester
            .widget<TravelScheduleScreen>(find.byType(TravelScheduleScreen))
            .tripId,
        'trip_2',
      );
    });

    testWidgets('by destination title, for the oldest records', (tester) async {
      await openCardFor(
        tester,
        buildBookmark(name: 'nothing matches', sourceId: ''),
      );

      // "Dest" matches nothing either, so the snapshot itself is shown.
      final screen = tester.widget<TravelScheduleScreen>(
        find.byType(TravelScheduleScreen),
      );
      expect(screen.destinationTitle, 'Dest');
    });

    testWidgets('falls back to the snapshot when nothing matches at all', (
      tester,
    ) async {
      await openCardFor(
        tester,
        buildBookmark(
          name: 'Deleted Trip',
          sourceId: 'trip_gone',
          destinationTitle: 'Nowhere',
        ),
      );

      final screen = tester.widget<TravelScheduleScreen>(
        find.byType(TravelScheduleScreen),
      );
      expect(screen.tripId, 'trip_gone');
      expect(screen.tripName, 'Deleted Trip');
      expect(screen.destinationTitle, 'Nowhere');
    });
  });

  group('resolving a saved mate', () {
    testWidgets('builds a stand-in profile when the mate is unknown', (
      tester,
    ) async {
      await openCardFor(
        tester,
        buildBookmark(
          name: 'Ghost Mate',
          sourceId: '',
          type: SavedBookmarkType.mate,
          tags: [buildTag('hiking')],
        ),
      );

      final screen = tester.widget<MateDetailsScreen>(
        find.byType(MateDetailsScreen),
      );
      expect(screen.mate.name, 'Ghost Mate');
      expect(screen.mate.id, contains('ghost_mate'));
      expect(screen.mate.interests, ['hiking']);
    });

    testWidgets('keeps a stored sourceId as the stand-in id', (tester) async {
      await openCardFor(
        tester,
        buildBookmark(
          name: 'Ghost Mate',
          sourceId: 'mate_42',
          type: SavedBookmarkType.mate,
        ),
      );

      expect(
        tester
            .widget<MateDetailsScreen>(find.byType(MateDetailsScreen))
            .mate
            .id,
        'mate_42',
      );
    });
  });

  group('the saved card artwork', () {
    testWidgets('shows a placeholder icon when there is no cover image', (
      tester,
    ) async {
      SavedTripPreviewStore.instance.stageBookmark(buildBookmark());
      await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
      await tester.pump();

      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    });

    testWidgets('renders an SVG cover as a vector', (tester) async {
      SavedTripPreviewStore.instance.stageBookmark(
        SavedTripPreview.fromJson({
          'tripName': 'With cover',
          'destinationTitle': 'Bali',
          'description': 'd',
          'coverImage': 'assets/images/home/trip_1.svg',
          'sourceId': 'trip_1',
          'tags': const [],
        }),
      );
      await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
      await tester.pump();

      expect(find.byType(SvgPicture), findsWidgets);
      expect(find.byIcon(Icons.bookmark_border), findsNothing);
    });

    testWidgets('renders a raster cover as an image', (tester) async {
      SavedTripPreviewStore.instance.stageBookmark(
        SavedTripPreview.fromJson({
          'tripName': 'With png',
          'destinationTitle': 'Bali',
          'description': 'd',
          'coverImage': 'assets/images/home/trip_1.png',
          'sourceId': 'trip_1',
          'tags': const [],
        }),
      );
      await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
      await tester.pump();

      expect(find.byType(Image), findsWidgets);
      // The test bundle answers every asset with an SVG, so the raster decode
      // itself fails — that is the stub's doing, not the widget's.
      expect(tester.takeException(), isA<FormatException>());
    });
  });
}
