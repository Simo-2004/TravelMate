import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_colors.dart';
import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/core/theme/app_text_styles.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

/// Horizontal strip of the user's bookmarked trips, shown above the chat
/// input bar so one can be attached to the conversation with a tap.
class ChatTripAttachmentPicker extends StatelessWidget {
  final List<TripTileData> trips;
  final ValueChanged<TripTileData> onTripSelected;

  const ChatTripAttachmentPicker({
    super.key,
    required this.trips,
    required this.onTripSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final tileSize = sizes.sliderTileSize * 0.85;

    return Material(
      color: AppColors.white,
      elevation: sizes.navElevation,
      child: Padding(
        padding: EdgeInsets.fromLTRB(sizes.padM, sizes.padM, sizes.padM, 0),
        child: trips.isEmpty
            ? Padding(
                padding: EdgeInsets.only(bottom: sizes.padS),
                child: Text(
                  AppStrings.chatNoSavedTripsMessage,
                  style: AppTextStyles.bodyMd(
                    sizes,
                  ).copyWith(fontSize: sizes.textSm),
                ),
              )
            : SizedBox(
                height: tileSize,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trips.length,
                  separatorBuilder: (_, _) =>
                      SizedBox(width: sizes.sliderTileSpacing),
                  itemBuilder: (context, index) {
                    final trip = trips[index];

                    return SquareImageButton(
                      imageAsset: trip.asset,
                      label: trip.label,
                      size: tileSize,
                      borderRadius: sizes.radiusM,
                      onTap: () => onTripSelected(trip),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
