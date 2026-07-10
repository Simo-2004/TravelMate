import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/schedule/travel_schedule_screen.dart';
import 'package:travelmate/features/search/mate_details_screen.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
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

/// Search tab that routes user queries to trip or mate results.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const int _maxMatesShown = 5;
  static const int _maxTripsShown = 5;
  static final List<MateProfile> _mates = MateCatalog.mates;
  static final List<TripTileData> _tripTiles = TripCatalog.trips;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  NavigationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextController = NavigationScope.maybeControllerOf(context);

    if (_controller == nextController) {
      _handleController();
      return;
    }

    _controller?.removeListener(_handleController);
    _controller = nextController;
    _controller?.addListener(_handleController);
    _handleController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleController);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearchResults(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      return;
    }

    _focusNode.unfocus();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchResultsScreen(initialQuery: query),
      ),
    );
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

  void _handleController() {
    if (!mounted || _controller == null) {
      return;
    }

    final searchIndex = NavigationScope.indexOfLabel(
      context,
      AppStrings.navSearchLabel,
    );

    if (searchIndex == null || _controller!.index != searchIndex) {
      return;
    }

    if (_controller!.consumeFocusRequest()) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    final modeButtonSize = sizes.padL * 2.6;
    final bottomClearance = modeButtonSize + sizes.padS * 2;

    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        final hintText = mode == SearchResearchMode.trips
            ? AppStrings.searchTripHint
            : AppStrings.searchMateHint;
        final filteredMates = mode == SearchResearchMode.mates
            ? filterMates(
                _mates,
                _searchController.text,
                limit: _maxMatesShown,
              )
            : const <MateProfile>[];
        final filteredTrips = mode == SearchResearchMode.trips
            ? filterTrips(
                _tripTiles,
                _searchController.text,
                limit: _maxTripsShown,
              )
            : const <TripTileData>[];

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
                      controller: _searchController,
                      hintText: hintText,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: _openSearchResults,
                      textInputAction: TextInputAction.done,
                      autofocus: false,
                      focusNode: _focusNode,
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
        );
      },
    );
  }
}
