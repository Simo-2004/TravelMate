import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/utils/mate_search.dart';
import 'package:travelmate/shared/utils/trip_search.dart';
import 'package:travelmate/shared/widgets/mates_vertical_section.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';
import 'package:travelmate/shared/widgets/trips_vertical_section.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  static const int _maxMatesShown = 5;
  static const int _maxTripsShown = 5;
  static final List<TripTileData> _tripTiles = TripCatalog.trips;
  static final List<MateProfile> _mates = MateCatalog.mates;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TripTileData> _filterTrips(String query) {
    return filterTrips(_tripTiles, query, limit: _maxTripsShown);
  }

  List<MateProfile> _filterMates(String query) {
    return filterMates(_mates, query, limit: _maxMatesShown);
  }

  void _openMateDetails(MateProfile mate) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MateDetailsScreen(mate: mate)));
  }

  void _openTripSchedule(TripTileData trip) {
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

    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        final filteredTrips = _filterTrips(_searchController.text);
        final filteredMates = _filterMates(_searchController.text);
        final hintText = mode == SearchResearchMode.trips
            ? AppStrings.searchTripHint
            : AppStrings.searchMateHint;

        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.pageSearchTitle)),
          body: SafeArea(
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
                        controller: _searchController,
                        hintText: hintText,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => setState(() {}),
                        textInputAction: TextInputAction.done,
                        autofocus: false,
                      ),
                      if (mode == SearchResearchMode.mates)
                        Expanded(
                          child: MatesVerticalSection(
                            title: AppStrings.searchMatesTitle,
                            mates: filteredMates,
                            emptyMessage: AppStrings.searchNoMatesMessage,
                            listHeight: double.infinity,
                            onMateTap: _openMateDetails,
                          ),
                        )
                      else
                        Expanded(
                          child: TripsVerticalSection(
                            title: AppStrings.searchTripsTitle,
                            trips: filteredTrips,
                            emptyMessage: AppStrings.searchNoTripsMessage,
                            listHeight: double.infinity,
                            onTripTap: _openTripSchedule,
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
          ),
        );
      },
    );
  }
}
