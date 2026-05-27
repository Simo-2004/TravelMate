import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/mate_tag_group.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';

class MateDetailsScreen extends StatelessWidget {
  static const List<Color> _tagBackgroundPalette = [
    Color(0xFFFFF700),
    Color(0xFF00E5FF),
    Color(0xFF7CFF4D),
    Color(0xFFFF9100),
    Color(0xFFFF4FD8),
    Color(0xFFB24CFF),
  ];

  static const List<Color> _tagTextPalette = [
    Color(0xFF3A3200),
    Color(0xFF00343A),
    Color(0xFF1F3A00),
    Color(0xFF4A2600),
    Color(0xFF3A0032),
    Color(0xFF2F005C),
  ];

  static const List<Color> _tagBorderPalette = [
    Color(0xFFFFF199),
    Color(0xFF99F8FF),
    Color(0xFFC8FFB5),
    Color(0xFFFFD299),
    Color(0xFFFFC2EF),
    Color(0xFFE0B6FF),
  ];

  final MateProfile mate;

  const MateDetailsScreen({super.key, required this.mate});

  List<TripTag> _buildPreviewTags() {
    final labels = <String>[...mate.interests, ...mate.preferredTrips]
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return labels
        .asMap()
        .entries
        .map((entry) {
          final paletteIndex = entry.key % _tagBackgroundPalette.length;

          return TripTag(
            label: entry.value,
            backgroundColor: _tagBackgroundPalette[paletteIndex],
            textColor: _tagTextPalette[paletteIndex],
            borderColor: _tagBorderPalette[paletteIndex],
          );
        })
        .toList(growable: false);
  }

  void _stageMatePreview(BuildContext context) {
    final preview = SavedTripPreview(
      tripName: mate.name,
      destinationTitle: '${AppStrings.mateDetailsPageTitle}: ${mate.name}',
      description: mate.description,
      coverImage: mate.profileImageAsset ?? '',
      tags: _buildPreviewTags(),
    );

    SavedTripPreviewStore.instance.stageTrip(preview);

    final targetIndex = NavigationScope.indexOfLabel(
      context,
      AppStrings.navSavedLabel,
    );
    final controller = NavigationScope.maybeControllerOf(context);

    if (controller != null && targetIndex != null) {
      controller.index = targetIndex;
      Navigator.of(context).pop();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mate profile card is ready in Saved Items.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.mateDetailsPageTitle,
          style: AppTextStyles.titleLg(sizes).copyWith(color: AppColors.yellow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.padL,
              sizes.padL,
              sizes.padL,
              sizes.padL * 1.4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sizes.padS),
                MateDetailsPanel(
                  name: mate.name,
                  description: mate.description,
                  profileImageAsset: mate.profileImageAsset,
                  nameTrailing: SaveTripButton(
                    onTap: () => _stageMatePreview(context),
                  ),
                ),
                MateTagGroup(
                  title: AppStrings.mateInterestsTitle,
                  tags: mate.interests,
                  paletteOffset: 0,
                ),
                MateTagGroup(
                  title: AppStrings.matePreferredTripsTitle,
                  tags: mate.preferredTrips,
                  paletteOffset: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
