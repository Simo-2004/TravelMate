import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/widgets/mates_vertical_section.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';
import 'package:travelmate/shared/widgets/trips_vertical_section.dart';

/// Shared body for both the Search tab and the Search results screen: the
/// search bar, the mates/trips vertical list for the active [mode], and the
/// floating mode-switch button. The parent owns the [controller] and the
/// filtering; this widget only lays them out and handles result taps.
class SearchModeView extends StatelessWidget {
  final SearchResearchMode mode;
  final TextEditingController controller;
  final List<MateProfile> filteredMates;
  final List<TripTileData> filteredTrips;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;

  const SearchModeView({
    super.key,
    required this.mode,
    required this.controller,
    required this.filteredMates,
    required this.filteredTrips,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
  });

  void _openMateDetails(BuildContext context, MateProfile mate) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MateDetailsScreen(mate: mate)));
  }

  void _openTripSchedule(BuildContext context, TripTileData trip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TravelScheduleScreen(
          tripId: trip.tripId,
          tripName: trip.destinationTitle,
          images: trip.scheduleImages,
          tags: trip.tags,
          destinationTitle: trip.destinationTitle,
          destinationDescription: trip.description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final modeButtonSize = sizes.padL * 2.6;
    final bottomClearance = modeButtonSize + sizes.padS * 2;
    final hintText = mode == SearchResearchMode.trips
        ? AppStrings.searchTripHint
        : AppStrings.searchMateHint;

    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.padL,
              sizes.padL,
              sizes.padL,
              bottomClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TravelSearchBar(
                  controller: controller,
                  hintText: hintText,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.done,
                  autofocus: autofocus,
                  focusNode: focusNode,
                ),
                if (mode == SearchResearchMode.mates)
                  Expanded(
                    child: MatesVerticalSection(
                      title: AppStrings.searchMatesTitle,
                      mates: filteredMates,
                      emptyMessage: AppStrings.searchNoMatesMessage,
                      listHeight: double.infinity,
                      onMateTap: (mate) => _openMateDetails(context, mate),
                    ),
                  )
                else
                  Expanded(
                    child: TripsVerticalSection(
                      title: AppStrings.searchTripsTitle,
                      trips: filteredTrips,
                      emptyMessage: AppStrings.searchNoTripsMessage,
                      listHeight: double.infinity,
                      onTripTap: (trip) => _openTripSchedule(context, trip),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            right: sizes.padL,
            bottom: sizes.padS,
            child: SearchModeSwitchButton(
              mode: mode,
              onTap: SearchResearchModeStore.instance.toggle,
              tripsLabel: AppStrings.searchModeTripsLabel,
              matesLabel: AppStrings.searchModeMatesLabel,
              size: modeButtonSize,
            ),
          ),
        ],
      ),
    );
  }
}
