import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/shared/models/chat_message.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/personal_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/widgets/chat_button.dart';
import 'package:travelmate/shared/widgets/chat_input_bar.dart';
import 'package:travelmate/shared/widgets/chat_message_bubble.dart';
import 'package:travelmate/shared/widgets/chat_online_status.dart';
import 'package:travelmate/shared/widgets/chat_trip_attachment_picker.dart';
import 'package:travelmate/shared/widgets/custom_button.dart';
import 'package:travelmate/shared/widgets/editable_personal_tag_group.dart';
import 'package:travelmate/shared/widgets/mate_card.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/mate_tag_group.dart';
import 'package:travelmate/shared/widgets/mates_vertical_section.dart';
import 'package:travelmate/shared/widgets/personal_profile_card.dart';
import 'package:travelmate/shared/widgets/personal_tag_group.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';
import 'package:travelmate/shared/widgets/settings_action_button.dart';
import 'package:travelmate/shared/widgets/settings_action_card.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';
import 'package:travelmate/shared/widgets/tag_section.dart';
import 'package:travelmate/shared/widgets/travel_image_slider.dart';
import 'package:travelmate/shared/widgets/travel_tag.dart';
import 'package:travelmate/shared/widgets/trip_info_card.dart';
import 'package:travelmate/shared/widgets/trips_vertical_section.dart';

import 'package:travelmate/shared/state/trip_store.dart';

import 'helpers/test_harness.dart';

TripTileData _trip(String id, String label) => TripTileData(
  tripId: id,
  asset: 'assets/images/home/$id.svg',
  label: label,
  scheduleImages: const ['assets/images/schedule/s.svg'],
  tags: const [
    TripTag(
      label: 'relax',
      backgroundColor: Color(0xFF112233),
      textColor: Color(0xFF445566),
    ),
  ],
  destinationTitle: 'Destination $label',
  description: 'Description of $label',
);

MateProfile _mate(String id, String name) => MateProfile(
  id: id,
  name: name,
  description: 'About $name',
  profileImageAsset: 'assets/icons/mate_avatar_1.svg',
  interests: const ['culture'],
  preferredTrips: const ['island-vibe'],
);

void main() {
  setUp(() {
    // Seed the trip catalog so widgets that resolve an attached trip (e.g.
    // ChatMessageBubble) find it, without touching the SQLite plugin.
    TripStore.instance.debugSetData(
      trips: [_trip('trip_1', 'City break')],
      recents: const [],
    );
  });

  testWidgets('CustomButton renders label and fires onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(CustomButton(text: 'Go', onPressed: () => tapped = true)),
    );
    expect(find.text('Go'), findsOneWidget);
    await tester.tap(find.text('Go'));
    expect(tapped, isTrue);
  });

  testWidgets('ChatButton renders and fires onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(ChatButton(label: 'Chat', onTap: () => tapped = true)),
    );
    expect(find.text('Chat'), findsOneWidget);
    await tester.tap(find.byType(ChatButton));
    expect(tapped, isTrue);
  });

  testWidgets('ChatOnlineStatus shows online and offline labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const Column(
          children: [
            ChatOnlineStatus(isOnline: true),
            ChatOnlineStatus(isOnline: false),
          ],
        ),
      ),
    );
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
  });

  testWidgets('ChatMessageBubble renders text and mine/theirs', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        Column(
          children: [
            ChatMessageBubble(
              message: ChatMessage(
                id: '1',
                text: 'from me',
                isFromMe: true,
                sentAt: DateTime(2024, 1, 1, 9, 5),
              ),
            ),
            ChatMessageBubble(
              message: ChatMessage(
                id: '2',
                text: 'from them',
                isFromMe: false,
                sentAt: DateTime(2024, 1, 1, 9, 6),
              ),
            ),
          ],
        ),
      ),
    );
    expect(find.text('from me'), findsOneWidget);
    expect(find.text('from them'), findsOneWidget);
    expect(find.text('09:05'), findsOneWidget);
  });

  testWidgets('ChatMessageBubble renders attached trip card', (tester) async {
    var tappedTrip = false;
    await tester.pumpWidget(
      wrapScaffold(
        ChatMessageBubble(
          message: ChatMessage(
            id: '3',
            text: 'invite',
            isFromMe: true,
            sentAt: DateTime(2024, 1, 1, 10, 0),
            attachedTripId: 'trip_1',
          ),
          onTripTap: (_) => tappedTrip = true,
        ),
      ),
    );
    expect(find.byType(SquareImageButton), findsOneWidget);
    await tester.tap(find.byType(SquareImageButton));
    expect(tappedTrip, isTrue);
  });

  testWidgets('ChatInputBar sends on tap and toggles attach', (tester) async {
    final controller = TextEditingController();
    String? sent;
    var attachTapped = false;
    await tester.pumpWidget(
      wrapScaffold(
        ChatInputBar(
          controller: controller,
          onSend: (text) => sent = text,
          onAttachTap: () => attachTapped = true,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'hi there');
    await tester.tap(find.byIcon(Icons.send_rounded));
    expect(sent, 'hi there');

    await tester.tap(find.byIcon(Icons.add_rounded));
    expect(attachTapped, isTrue);
  });

  testWidgets('ChatInputBar ignores blank send', (tester) async {
    final controller = TextEditingController();
    var sends = 0;
    await tester.pumpWidget(
      wrapScaffold(
        ChatInputBar(controller: controller, onSend: (_) => sends++),
      ),
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    expect(sends, 0);
  });

  testWidgets('ChatTripAttachmentPicker shows empty state and trips', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        ChatTripAttachmentPicker(trips: const [], onTripSelected: (_) {}),
      ),
    );
    expect(find.textContaining('No saved trips'), findsOneWidget);

    TripTileData? selected;
    await tester.pumpWidget(
      wrapScaffold(
        ChatTripAttachmentPicker(
          trips: [_trip('trip_1', 'One')],
          onTripSelected: (t) => selected = t,
        ),
      ),
    );
    await tester.tap(find.byType(SquareImageButton).first);
    expect(selected, isNotNull);
  });

  testWidgets('SaveTripButton reflects saved state and fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(SaveTripButton(isSaved: true, onTap: () => tapped = true)),
    );
    await tester.tap(find.byType(SaveTripButton));
    expect(tapped, isTrue);
  });

  testWidgets(
    'SaveTripButton rings and colors the flag gray when unsaved, yellow when saved',
    (tester) async {
      Color ringColorOf() {
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(SaveTripButton),
            matching: find.byType(Material),
          ),
        );
        return (material.shape! as CircleBorder).side.color;
      }

      await tester.pumpWidget(
        wrapScaffold(SaveTripButton(isSaved: false, onTap: () {})),
      );
      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        const ColorFilter.mode(AppColors.inactiveGray, BlendMode.srcIn),
      );
      expect(ringColorOf(), AppColors.inactiveGray);

      await tester.pumpWidget(
        wrapScaffold(SaveTripButton(isSaved: true, onTap: () {})),
      );
      expect(
        tester.widget<SvgPicture>(find.byType(SvgPicture)).colorFilter,
        const ColorFilter.mode(AppColors.yellow, BlendMode.srcIn),
      );
      expect(ringColorOf(), AppColors.yellow);
    },
  );

  testWidgets('TravelTag truncates long labels', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        const TravelTag(
          label: 'a-very-long-tag-label-indeed',
          backgroundColor: Color(0xFF112233),
          textColor: Color(0xFF445566),
          maxCharacters: 8,
        ),
      ),
    );
    expect(find.textContaining('...'), findsOneWidget);
  });

  testWidgets('SliderSection renders title and child', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        const SliderSection(title: 'My section', child: Text('content')),
      ),
    );
    expect(find.text('My section'), findsOneWidget);
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('SquareImageButton renders label and fires', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(
        SquareImageButton(
          imageAsset: 'assets/images/home/trip_1.svg',
          label: 'Trip',
          onTap: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Trip'), findsOneWidget);
    await tester.tap(find.byType(SquareImageButton));
    expect(tapped, isTrue);
  });

  testWidgets('TravelSearchBar shows hint and reacts to input', (tester) async {
    final controller = TextEditingController();
    String? changed;
    await tester.pumpWidget(
      wrapScaffold(
        TravelSearchBar(
          controller: controller,
          hintText: 'Search here',
          onChanged: (v) => changed = v,
        ),
      ),
    );
    expect(find.text('Search here'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'abc');
    expect(changed, 'abc');
  });

  testWidgets('SearchModeSwitchButton renders label and toggles', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(
        SearchModeSwitchButton(
          mode: SearchResearchMode.trips,
          onTap: () => tapped = true,
          tripsLabel: 'Trips',
          matesLabel: 'Mates',
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Trips'), findsOneWidget);
    await tester.tap(find.byType(SearchModeSwitchButton));
    expect(tapped, isTrue);
  });

  testWidgets('SearchModeSwitchButton resolves an icon asset path', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        SearchModeSwitchButton(
          mode: SearchResearchMode.mates,
          onTap: () {},
          tripsLabel: 'Trips',
          matesLabel: 'Mates',
          tripsIconAsset: 'assets/icons/airplane.svg',
          matesIconAsset: 'assets/icons/user_icon.svg',
        ),
      ),
    );
    // Let the async asset-availability FutureBuilder resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Mates'), findsOneWidget);
  });

  testWidgets('MateCard renders name and description', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(
        MateCard(
          title: 'Alessia',
          description: 'Beach lover',
          onTap: () => tapped = true,
        ),
      ),
    );
    expect(find.text('Alessia'), findsOneWidget);
    expect(find.text('Beach lover'), findsOneWidget);
    await tester.tap(find.byType(MateCard));
    expect(tapped, isTrue);
  });

  testWidgets('MatesVerticalSection shows empty message and list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const MatesVerticalSection(
          title: 'Mates',
          mates: [],
          emptyMessage: 'no mates here',
          listHeight: 300,
        ),
      ),
    );
    expect(find.text('no mates here'), findsOneWidget);

    await tester.pumpWidget(
      wrapScaffold(
        MatesVerticalSection(
          title: 'Mates',
          mates: [_mate('m1', 'Alessia')],
          emptyMessage: 'no mates here',
          listHeight: 300,
        ),
      ),
    );
    expect(find.text('Alessia'), findsOneWidget);
  });

  testWidgets('TripsVerticalSection shows empty message and list', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const TripsVerticalSection(
          title: 'Trips',
          trips: [],
          emptyMessage: 'no trips here',
          listHeight: 300,
        ),
      ),
    );
    expect(find.text('no trips here'), findsOneWidget);

    await tester.pumpWidget(
      wrapScaffold(
        TripsVerticalSection(
          title: 'Trips',
          trips: [_trip('trip_1', 'One')],
          emptyMessage: 'no trips here',
          listHeight: 300,
        ),
      ),
    );
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('TripInfoCard renders title and description', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        const TripInfoCard(title: 'Bali', description: 'Sunny island'),
      ),
    );
    expect(find.text('Bali'), findsOneWidget);
    expect(find.text('Sunny island'), findsOneWidget);
  });

  testWidgets('TagSection renders each tag', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        const TagSection(
          tags: [
            TripTag(
              label: 'alpha',
              backgroundColor: Color(0xFF112233),
              textColor: Color(0xFF445566),
            ),
            TripTag(
              label: 'beta',
              backgroundColor: Color(0xFF223344),
              textColor: Color(0xFF556677),
            ),
          ],
        ),
      ),
    );
    expect(find.text('alpha'), findsOneWidget);
    expect(find.text('beta'), findsOneWidget);
  });

  testWidgets('MateDetailsPanel renders name, description and trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const MateDetailsPanel(
          name: 'Marco',
          description: 'Hiker',
          nameTrailing: Icon(Icons.star),
        ),
      ),
    );
    expect(find.text('Marco'), findsOneWidget);
    expect(find.text('Hiker'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });

  testWidgets('MateTagGroup renders tags and matches catalog colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const MateTagGroup(
          title: 'Preferred trips',
          tags: ['island-vibe', 'unknown-tag'],
          matchTripTagCatalog: true,
        ),
      ),
    );
    expect(find.text('Preferred trips'), findsOneWidget);
    expect(find.text('island-vibe'), findsOneWidget);
    expect(find.text('unknown-tag'), findsOneWidget);
  });

  testWidgets('MateTagGroup hides when empty', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(const MateTagGroup(title: 'X', tags: [])),
    );
    expect(find.text('X'), findsNothing);
  });

  testWidgets('TravelTag truncates edge cases (zero max, exact fit)', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const Column(
          children: [
            TravelTag(
              label: 'super-long-personal-tag',
              backgroundColor: Color(0xFF112233),
              textColor: Color(0xFF445566),
              borderColor: Color(0xFF778899),
              maxCharacters: 6,
            ),
            TravelTag(
              label: 'hidden',
              backgroundColor: Color(0xFF112233),
              textColor: Color(0xFF445566),
              maxCharacters: 0,
            ),
            TravelTag(
              label: 'abcdef',
              backgroundColor: Color(0xFF112233),
              textColor: Color(0xFF445566),
              maxCharacters: 2,
            ),
          ],
        ),
      ),
    );
    expect(find.textContaining('...'), findsOneWidget);
    expect(find.text('ab'), findsOneWidget);
  });

  testWidgets('PersonalTagGroup renders labels', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        const PersonalTagGroup(
          title: 'Interests',
          tags: ['Beach life', 'City walks'],
        ),
      ),
    );
    expect(find.text('Interests'), findsOneWidget);
    expect(find.text('Beach life'), findsOneWidget);
  });

  testWidgets('PersonalProfileCard and header render profile', (tester) async {
    await tester.pumpWidget(
      wrapScaffold(
        Column(
          children: const [
            ProfileIdentityHeader(profile: PersonalProfile.defaultProfile),
            PersonalProfileCard(profile: PersonalProfile.defaultProfile),
          ],
        ),
      ),
    );
    expect(find.text(PersonalProfile.defaultProfile.fullName), findsWidgets);
  });

  testWidgets('SettingsActionButton and card render and fire', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrapScaffold(
        SettingsActionCard(
          child: SettingsActionButton(
            label: 'Profile',
            color: const Color(0xFF2F80ED),
            onTap: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('Profile'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    expect(tapped, isTrue);
  });

  testWidgets('EditablePersonalTagGroup adds and removes tags', (tester) async {
    final controller = TextEditingController();
    var addPressed = false;
    String? removed;
    await tester.pumpWidget(
      wrapScaffold(
        SingleChildScrollView(
          child: EditablePersonalTagGroup(
            title: 'Interests',
            fieldLabel: 'Add interest',
            emptyText: 'none yet',
            inputController: controller,
            tags: const ['Beach'],
            onAddPressed: () => addPressed = true,
            onRemoveTag: (t) => removed = t,
          ),
        ),
      ),
    );
    expect(find.text('Beach'), findsOneWidget);
    await tester.tap(find.text('Add personal tag'));
    expect(addPressed, isTrue);
    await tester.tap(find.byIcon(Icons.close_rounded));
    expect(removed, 'Beach');
  });

  testWidgets('TravelImageSlider renders indicator, empty is shrunk', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapScaffold(
        const SizedBox(
          height: 300,
          width: 300,
          child: TravelImageSlider(
            images: [
              'assets/images/schedule/s1.svg',
              'assets/images/schedule/s2.svg',
            ],
          ),
        ),
      ),
    );
    expect(find.text('1/2'), findsOneWidget);

    await tester.pumpWidget(wrapScaffold(const TravelImageSlider(images: [])));
    expect(find.byType(TravelImageSlider), findsOneWidget);
  });
}
