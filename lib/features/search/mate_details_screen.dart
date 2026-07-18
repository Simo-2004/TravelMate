import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/features/chat/chat_screen.dart';
import 'package:travelmate/shared/data/mate_tag_palette.dart';
import 'package:travelmate/shared/data/trip_tag_catalog.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/saved_trip_preview.dart';
import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/state/saved_trip_preview_store.dart';
import 'package:travelmate/shared/widgets/chat_button.dart';
import 'package:travelmate/shared/widgets/mate_details_panel.dart';
import 'package:travelmate/shared/widgets/mate_tag_group.dart';
import 'package:travelmate/shared/widgets/save_trip_button.dart';

class MateDetailsScreen extends StatelessWidget {
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
          // Reuse the real trip tag's colors when this label matches one
          // (typically a preferredTrips entry), so the bookmark preview
          // stays consistent with the on-screen chip and with actual trips.
          final catalogTag = TripTagCatalog.resolve(entry.value);
          if (catalogTag != null) {
            return catalogTag;
          }

          final palette = MateTagPalette.resolve(entry.key);

          return TripTag(
            label: entry.value,
            backgroundColor: palette.backgroundColor,
            textColor: palette.textColor,
            borderColor: palette.borderColor,
          );
        })
        .toList(growable: false);
  }

  SavedTripPreview _buildMatePreview() {
    return SavedTripPreview(
      tripName: mate.name,
      destinationTitle: '${AppStrings.mateDetailsPageTitle}: ${mate.name}',
      description: mate.description,
      coverImage: mate.profileImageAsset ?? '',
      tags: _buildPreviewTags(),
      bookmarkType: SavedBookmarkType.mate,
      sourceId: mate.id,
    );
  }

  void _openChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(mate: mate)));
  }

  void _toggleMateBookmark(BuildContext context) {
    final nowSaved = SavedTripPreviewStore.instance.toggleBookmark(
      _buildMatePreview(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nowSaved
              ? 'Mate profile saved to Saved Items.'
              : 'Mate profile removed from Saved Items.',
        ),
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
        child: Stack(
          children: [
            // Positioned.fill (rather than a plain child) makes this the
            // only content Stack sizes around, so Stack claims the full
            // available height instead of shrink-wrapping to the profile
            // content — otherwise the floating button below would anchor
            // itself to the bottom of the content instead of the screen.
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    sizes.padL,
                    sizes.padL,
                    sizes.padL,
                    sizes.padL * 3.4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: sizes.padS),
                      MateDetailsPanel(
                        name: mate.name,
                        description: mate.description,
                        profileImageAsset: mate.profileImageAsset,
                        nameTrailing:
                            ValueListenableBuilder<List<SavedTripPreview>>(
                              valueListenable: SavedTripPreviewStore.instance,
                              builder: (context, _, __) {
                                final isSaved = SavedTripPreviewStore.instance
                                    .isSaved(_buildMatePreview());

                                return SaveTripButton(
                                  isSaved: isSaved,
                                  onTap: () => _toggleMateBookmark(context),
                                );
                              },
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
                        matchTripTagCatalog: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: sizes.padL,
              child: Center(
                child: ChatButton(
                  label: AppStrings.mateChatButtonLabel,
                  onTap: () => _openChat(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
