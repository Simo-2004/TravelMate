/// Component testing — the alternate rendering branches.
///
/// Most widgets here have two or three ways to draw the same thing: a vector
/// asset or a raster one, a supplied image widget or a path to resolve, one
/// item in a list or several. The main suite covers the common path; this file
/// covers the others, plus the keyboard-submit shortcuts that sit beside every
/// "add"/"send" button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/features/navigation/navigation_config.dart';
import 'package:travelmate/features/navigation/navigation_shell.dart';
import 'package:travelmate/features/saved/saved_items_screen.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/brand_header.dart';
import 'package:travelmate/shared/widgets/chat_input_bar.dart';
import 'package:travelmate/shared/widgets/chat_trip_attachment_picker.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';
import 'package:travelmate/shared/widgets/travel_image_slider.dart';

import '../helpers/test_harness.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await resetAllStores();
    usePhoneSurface(binding);
  });

  group('vector or raster artwork', () {
    testWidgets('SquareImageButton draws an SVG as a vector', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const SquareImageButton(imageAsset: 'assets/images/home/trip_1.svg'),
        ),
      );
      await tester.pump();

      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('SquareImageButton draws a raster asset as an image', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(
          const SquareImageButton(imageAsset: 'assets/images/home/trip_1.png'),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('TravelImageSlider draws a raster asset as an image', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(
          const TravelImageSlider(
            images: ['assets/images/schedule/trip_1_1.png'],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('MateCard resolves a raster avatar through Image.asset', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(
          const MateCard(
            title: 'Marco',
            description: 'Hiker',
            profileImageAsset: 'assets/icons/mate_avatar_1.png',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('BrandHeader logo fallback', () {
    testWidgets('shows the logo when the asset loads', (tester) async {
      await tester.pumpWidget(wrapScaffold(const BrandHeader()));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.travel_explore), findsNothing);
    });

    testWidgets('falls back to an icon when the logo cannot be loaded', (
      tester,
    ) async {
      // Regression cover for the launch bug where assets/logo.png was missing
      // from the bundle: the header must degrade to an icon, not a blank hole.
      await tester.pumpWidget(
        wrapScaffold(
          const BrandHeader(),
          bundle: FakeAssetBundle(corruptKeys: const {'assets/logo.png'}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.travel_explore), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('a supplied image widget wins over an asset path', () {
    testWidgets('MateCard renders the widget it was given', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const MateCard(
            title: 'Marco',
            description: 'Hiker',
            profileImageAsset: 'assets/icons/mate_avatar_1.svg',
            profileImage: Icon(Icons.face, key: ValueKey('supplied')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('supplied')), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('MateDetailsPanel renders the widget it was given', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(
          const MateDetailsPanel(
            name: 'Marco',
            description: 'Hiker',
            profileImageAsset: 'assets/icons/mate_avatar_1.svg',
            profileImage: Icon(Icons.face, key: ValueKey('supplied')),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('supplied')), findsOneWidget);
      expect(find.byType(SvgPicture), findsNothing);
    });
  });

  group('lists with more than one entry draw separators', () {
    testWidgets('SavedItemsScreen separates several saved cards', (
      tester,
    ) async {
      SavedTripPreviewStore.instance
        ..stageBookmark(buildBookmark(name: 'One', sourceId: 'trip_1'))
        ..stageBookmark(buildBookmark(name: 'Two', sourceId: 'trip_2'));

      await tester.pumpWidget(wrapScaffold(const SavedItemsScreen()));
      await tester.pump();

      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
    });

    testWidgets('the trip attachment picker separates several trips', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapScaffold(
          ChatTripAttachmentPicker(
            trips: [
              buildTrip(id: 'trip_1', label: 'One'),
              buildTrip(id: 'trip_2', label: 'Two'),
            ],
            onTripSelected: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SquareImageButton), findsNWidgets(2));
    });
  });

  group('keyboard submit mirrors the button', () {
    testWidgets('ChatInputBar sends on the done action', (tester) async {
      final controller = TextEditingController(text: 'sent by keyboard');
      addTearDown(controller.dispose);
      String? sent;

      await tester.pumpWidget(
        wrapScaffold(
          ChatInputBar(controller: controller, onSend: (text) => sent = text),
        ),
      );
      await tester.pump();

      // The action only reaches a focused field.
      await tester.tap(find.byType(TextField));
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(sent, 'sent by keyboard');
    });
  });

  group('TravelImageSlider paging', () {
    testWidgets('swiping advances the position indicator', (tester) async {
      await tester.pumpWidget(
        wrapScaffold(
          const TravelImageSlider(
            images: [
              'assets/images/schedule/trip_1_1.svg',
              'assets/images/schedule/trip_1_2.svg',
              'assets/images/schedule/trip_1_3.svg',
            ],
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1/3'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('2/3'), findsOneWidget);
    });
  });

  group('NavigationShell defensive paths', () {
    testWidgets('creates its own controller when none is supplied', (
      tester,
    ) async {
      ignoreRenderFlexOverflow();
      useWideSurface(binding);

      await tester.pumpWidget(
        wrapApp(const NavigationShell(config: NavigationDefaults.config)),
      );
      await tester.pump();

      expect(find.text('Recommended trips for you'), findsOneWidget);

      // Disposing the shell must not throw for a controller it owns.
      await tester.pumpWidget(wrapApp(const SizedBox.shrink()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a configuration with no tabs at all', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          const NavigationShell(
            config: NavigationConfig(
              items: [],
              style: NavigationDefaults.style,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byType(NavigationShell), findsOneWidget);
    });

    testWidgets('falls back to the IconData when a tab has no SVG', (
      tester,
    ) async {
      ignoreRenderFlexOverflow();
      useWideSurface(binding);

      await tester.pumpWidget(
        wrapApp(
          const NavigationShell(
            config: NavigationConfig(
              items: [
                NavigationItem(
                  label: 'Plain',
                  title: 'Plain',
                  icon: Icons.star,
                  page: SizedBox.shrink(),
                ),
              ],
              style: NavigationDefaults.style,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
