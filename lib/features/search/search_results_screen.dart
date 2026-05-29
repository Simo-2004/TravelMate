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
import 'package:travelmate/shared/widgets/mates_vertical_section.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';
import 'package:travelmate/shared/widgets/slider_section.dart';
import 'package:travelmate/shared/widgets/square_image_button.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({super.key, required this.initialQuery});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
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
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final terms = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    final scoredTrips = <({TripTileData trip, int score})>[];

    for (final trip in _tripTiles) {
      final label = trip.label.toLowerCase();
      final destination = trip.destinationTitle.toLowerCase();
      final description = trip.description.toLowerCase();
      final tagLabels = trip.tags
          .map((tag) => tag.label.toLowerCase())
          .toList(growable: false);

      var score = 0;
      var matchesAllTerms = true;

      for (final term in terms) {
        var termMatched = false;

        if (label.startsWith(term)) {
          score += 8;
          termMatched = true;
        } else if (label.contains(term)) {
          score += 5;
          termMatched = true;
        }

        if (destination.startsWith(term)) {
          score += 7;
          termMatched = true;
        } else if (destination.contains(term)) {
          score += 4;
          termMatched = true;
        }

        if (description.contains(term)) {
          score += 2;
          termMatched = true;
        }

        final matchingTag = tagLabels.firstWhere(
          (tagLabel) => tagLabel.startsWith(term) || tagLabel.contains(term),
          orElse: () => '',
        );
        if (matchingTag.isNotEmpty) {
          score += matchingTag.startsWith(term) ? 6 : 3;
          termMatched = true;
        }

        if (!termMatched) {
          matchesAllTerms = false;
          break;
        }
      }

      if (matchesAllTerms) {
        scoredTrips.add((trip: trip, score: score));
      }
    }

    scoredTrips.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }

      return a.trip.label.compareTo(b.trip.label);
    });

    return scoredTrips.map((entry) => entry.trip).toList(growable: false);
  }

  List<MateProfile> _filterMates(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final terms = normalizedQuery
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList(growable: false);

    final scoredMates = <({MateProfile mate, int score})>[];

    for (final mate in _mates) {
      final name = mate.name.toLowerCase();
      final description = mate.description.toLowerCase();
      final keywords = mate.keywords
          .map((keyword) => keyword.toLowerCase())
          .toList(growable: false);

      var score = 0;
      var matchesAllTerms = true;

      for (final term in terms) {
        var termMatched = false;

        if (name.startsWith(term)) {
          score += 8;
          termMatched = true;
        } else if (name.contains(term)) {
          score += 5;
          termMatched = true;
        }

        if (description.contains(term)) {
          score += 3;
          termMatched = true;
        }

        final matchingKeyword = keywords.firstWhere(
          (keyword) => keyword.startsWith(term) || keyword.contains(term),
          orElse: () => '',
        );

        if (matchingKeyword.isNotEmpty) {
          score += matchingKeyword.startsWith(term) ? 6 : 4;
          termMatched = true;
        }

        if (!termMatched) {
          matchesAllTerms = false;
          break;
        }
      }

      if (matchesAllTerms) {
        scoredMates.add((mate: mate, score: score));
      }
    }

    scoredMates.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }

      return a.mate.name.compareTo(b.mate.name);
    });

    return scoredMates.map((entry) => entry.mate).toList(growable: false);
  }

  void _openMateDetails(MateProfile mate) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => MateDetailsScreen(mate: mate)));
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);
    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        final filteredTrips = _filterTrips(_searchController.text);
        final filteredMates = _filterMates(_searchController.text);
        final hasQuery = _searchController.text.trim().isNotEmpty;
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
                    sizes.padL * 2.4,
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
                            emptyMessage: hasQuery
                                ? AppStrings.searchNoMatesMessage
                                : AppStrings.searchMateHint,
                            listHeight: double.infinity,
                            onMateTap: _openMateDetails,
                          ),
                        )
                      else if (filteredTrips.isEmpty && hasQuery)
                        Padding(
                          padding: EdgeInsets.only(top: sizes.spaceM),
                          child: Text(
                            AppStrings.searchNoTripsMessage,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontSize: sizes.textSm),
                          ),
                        )
                      else
                        SliderSection(
                          title: AppStrings.searchTripsTitle,
                          child: SizedBox(
                            height: sizes.sliderTileSize,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredTrips.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(width: sizes.sliderTileSpacing),
                              itemBuilder: (context, index) {
                                final item = filteredTrips[index];

                                return SquareImageButton(
                                  imageAsset: item.asset,
                                  label: item.label,
                                  borderRadius: sizes.radiusL,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TravelScheduleScreen(
                                          tripId: item.tripId,
                                          tripName: item.destinationTitle,
                                          images: item.scheduleImages,
                                          tags: item.tags,
                                          destinationTitle:
                                              item.destinationTitle,
                                          destinationDescription:
                                              item.description,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: sizes.padS,
                  child: Center(
                    child: SearchModeSwitchButton(
                      mode: mode,
                      onTap: SearchResearchModeStore.instance.toggle,
                      tripsLabel: AppStrings.searchModeTripsLabel,
                      matesLabel: AppStrings.searchModeMatesLabel,
                    ),
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
