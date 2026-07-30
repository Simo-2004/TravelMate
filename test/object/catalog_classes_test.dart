/// Object class testing — the static catalogs and configuration classes.
///
/// These classes hold no mutable state, but they still have an interface worth
/// pinning: lookups that must normalise their input, collections that must stay
/// internally consistent, and sizing/styling tokens that must react correctly
/// to the device metrics they are derived from.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/data/trip_media_catalog.dart';
import 'package:travelmate/shared/data/trip_tag_catalog.dart';

/// Pumps a widget just to obtain an [AppSizes] for the given surface, since
/// its constructor is private and derives from [MediaQuery].
Future<AppSizes> sizesFor(WidgetTester tester, Size surface) async {
  late AppSizes sizes;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: surface),
      child: Builder(
        builder: (context) {
          sizes = AppSizes.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return sizes;
}

void main() {
  group('TripTagCatalog', () {
    test('resolves known labels case- and whitespace-insensitively', () {
      expect(TripTagCatalog.resolve('adventure'), isNotNull);
      expect(TripTagCatalog.resolve('  ADVENTURE '), isNotNull);
    });

    test('returns null for unknown and blank labels', () {
      expect(TripTagCatalog.resolve('does-not-exist'), isNull);
      expect(TripTagCatalog.resolve(''), isNull);
    });

    test('every catalog entry resolves back to itself by label', () {
      expect(TripTagCatalog.all, isNotEmpty);
      for (final tag in TripTagCatalog.all) {
        expect(
          TripTagCatalog.resolve(tag.label)?.label,
          tag.label,
          reason: 'tag "${tag.label}" is not resolvable',
        );
      }
    });
  });

  group('TripCatalog', () {
    test('builds one trip per media entry, plus recents', () {
      expect(TripCatalog.trips, hasLength(TripMediaCatalog.tripCount));
      expect(TripCatalog.recents, isNotEmpty);
    });

    test('findTripById normalises case and whitespace', () {
      expect(TripCatalog.findTripById('trip_1'), isNotNull);
      expect(TripCatalog.findTripById('  TRIP_1 '), isNotNull);
    });

    test('findTripById returns null for unknown and blank ids', () {
      expect(TripCatalog.findTripById('nope'), isNull);
      expect(TripCatalog.findTripById(''), isNull);
      expect(TripCatalog.findTripById('   '), isNull);
    });

    test('trip ids are unique', () {
      final ids = TripCatalog.trips.map((trip) => trip.tripId).toList();

      expect(ids.toSet(), hasLength(ids.length));
    });

    test('every trip is fully populated', () {
      for (final trip in TripCatalog.trips) {
        expect(trip.tripId, isNotEmpty, reason: 'trip with a blank id');
        expect(trip.label, isNotEmpty, reason: '${trip.tripId} has no label');
        expect(
          trip.destinationTitle,
          isNotEmpty,
          reason: '${trip.tripId} has no destination',
        );
        expect(
          trip.scheduleImages,
          isNotEmpty,
          reason: '${trip.tripId} has no schedule images',
        );
      }
    });

    test('every recent trip is also a lookup hit in the main catalog', () {
      for (final recent in TripCatalog.recents) {
        expect(
          TripCatalog.findTripById(recent.tripId),
          isNotNull,
          reason: 'recent ${recent.tripId} is not in the catalog',
        );
      }
    });
  });

  group('TripMediaCatalog', () {
    test('builds asset lists of the declared sizes', () {
      expect(TripMediaCatalog.homeTripAssets, hasLength(8));
      expect(
        TripMediaCatalog.scheduleAssets,
        hasLength(
          TripMediaCatalog.tripCount * TripMediaCatalog.schedulePerTrip,
        ),
      );
      expect(TripMediaCatalog.scheduleSets, hasLength(8));
      expect(TripMediaCatalog.scheduleSets.first, hasLength(4));
    });

    test('every schedule set has the declared number of images', () {
      for (final set in TripMediaCatalog.scheduleSets) {
        expect(set, hasLength(TripMediaCatalog.schedulePerTrip));
      }
    });
  });

  group('MateCatalog', () {
    test('exposes mates with unique ids and non-empty names', () {
      expect(MateCatalog.mates, isNotEmpty);

      final ids = MateCatalog.mates.map((mate) => mate.id).toList();
      expect(ids.toSet(), hasLength(ids.length));

      for (final mate in MateCatalog.mates) {
        expect(mate.name, isNotEmpty);
      }
    });
  });

  group('NavigationDefaults', () {
    test('declares exactly the four bottom tabs, in order', () {
      expect(NavigationDefaults.config.items.map((item) => item.label), [
        'Home',
        'Search',
        'Saved',
        'Settings',
      ]);
    });

    test('starts on the first tab', () {
      expect(NavigationDefaults.config.initialIndex, 0);
    });

    test('every tab has a title, an icon and a distinct page', () {
      final pages = <Type>{};

      for (final item in NavigationDefaults.config.items) {
        expect(item.title, isNotEmpty, reason: '${item.label} has no title');
        expect(item.svgAsset, isNotNull, reason: '${item.label} has no asset');
        expect(
          pages.add(item.page.runtimeType),
          isTrue,
          reason: '${item.label} reuses another tab\'s page widget',
        );
      }
    });

    test('uses the brand yellow bar with black labels', () {
      expect(NavigationDefaults.style.backgroundColor, AppColors.yellow);
      expect(NavigationDefaults.style.selectedColor, AppColors.black);
      expect(NavigationDefaults.style.unselectedColor, AppColors.black);
    });
  });

  group('NavigationStyle', () {
    testWidgets('resolves selected and unselected presentation', (
      tester,
    ) async {
      final sizes = await sizesFor(tester, const Size(400, 900));
      const style = NavigationDefaults.style;

      expect(style.iconColor(true), style.selectedColor);
      expect(style.iconColor(false), style.unselectedColor);
      expect(style.labelStyle(sizes, true).fontWeight, FontWeight.bold);
      expect(style.labelStyle(sizes, false).fontWeight, FontWeight.w600);
    });

    testWidgets('derives every metric from the given sizes', (tester) async {
      final sizes = await sizesFor(tester, const Size(400, 900));
      const style = NavigationDefaults.style;

      expect(style.elevation(sizes), sizes.navElevation);
      expect(style.iconSize(sizes), sizes.iconM);
      expect(style.labelSpacing(sizes), sizes.padXs);
      expect(style.indicatorPadding(sizes), sizes.padS);
      expect(style.padding(sizes).horizontal, sizes.padM * 2);
      expect(style.itemRadius(sizes).topLeft.x, sizes.radiusM);
    });
  });

  group('AppSizes', () {
    testWidgets('scales every spacing token with the shortest side', (
      tester,
    ) async {
      final small = await sizesFor(tester, const Size(360, 800));
      final large = await sizesFor(tester, const Size(720, 1600));

      expect(large.shortestSide, small.shortestSide * 2);
      expect(large.padL, closeTo(small.padL * 2, 0.001));
      expect(large.iconM, closeTo(small.iconM * 2, 0.001));
      expect(large.radiusM, closeTo(small.radiusM * 2, 0.001));
    });

    testWidgets('orders its spacing scale from smallest to largest', (
      tester,
    ) async {
      final sizes = await sizesFor(tester, const Size(400, 900));

      expect(sizes.padXs, lessThan(sizes.padS));
      expect(sizes.padS, lessThan(sizes.padM));
      expect(sizes.padM, lessThan(sizes.padL));
      expect(sizes.spaceS, lessThan(sizes.spaceM));
      expect(sizes.spaceM, lessThan(sizes.spaceL));
      expect(sizes.textSm, lessThan(sizes.textMd));
      expect(sizes.textMd, lessThan(sizes.textLg));
    });

    testWidgets('keeps the slider image scale inside its clamp', (
      tester,
    ) async {
      for (final surface in const [
        Size(200, 400),
        Size(400, 900),
        Size(1200, 2000),
      ]) {
        final sizes = await sizesFor(tester, surface);

        expect(sizes.sliderImageScale, inInclusiveRange(0.6, 0.9));
      }
    });
  });
}
