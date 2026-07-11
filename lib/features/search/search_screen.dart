import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/search/search_mode_view.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
import 'package:travelmate/shared/data/mate_catalog.dart';
import 'package:travelmate/shared/data/trip_catalog.dart';
import 'package:travelmate/shared/models/mate_profile.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/models/trip_tile_data.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/utils/mate_search.dart';
import 'package:travelmate/shared/utils/trip_search.dart';

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
    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        return SearchModeView(
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
          onSubmitted: _openSearchResults,
          focusNode: _focusNode,
        );
      },
    );
  }
}
