import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/search/search_mode_view.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/utils/mate_search.dart';
import 'package:travelmate/shared/utils/trip_search.dart';

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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.pageSearchTitle)),
          body: SearchModeView(
            mode: mode,
            controller: _searchController,
            filteredMates: mode == SearchResearchMode.mates
                ? filterMates(
                    _mates,
                    _searchController.text,
                    limit: _maxMatesShown,
                  )
                : const <MateProfile>[],
            filteredTrips: mode == SearchResearchMode.trips
                ? filterTrips(
                    _tripTiles,
                    _searchController.text,
                    limit: _maxTripsShown,
                  )
                : const <TripTileData>[],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => setState(() {}),
          ),
        );
      },
    );
  }
}
