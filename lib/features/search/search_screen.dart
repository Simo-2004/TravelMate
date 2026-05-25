import 'package:flutter/material.dart';

import 'package:travelmate/core/constants/app_sizes.dart';
import 'package:travelmate/core/constants/app_strings.dart';
import 'package:travelmate/features/navigation/navigation_controller.dart';
import 'package:travelmate/features/search/search_results_screen.dart';
import 'package:travelmate/shared/models/search_research_mode.dart';
import 'package:travelmate/shared/state/search_research_mode_store.dart';
import 'package:travelmate/shared/widgets/search_bar.dart';
import 'package:travelmate/shared/widgets/search_mode_switch_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  NavigationController? _controller;
  int _lastFocusRequest = 0;

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

    if (_controller!.focusRequest == _lastFocusRequest) {
      return;
    }

    _lastFocusRequest = _controller!.focusRequest;
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes.of(context);

    return ValueListenableBuilder<SearchResearchMode>(
      valueListenable: SearchResearchModeStore.instance,
      builder: (context, mode, _) {
        final hintText = mode == SearchResearchMode.trips
            ? AppStrings.searchTripHint
            : AppStrings.searchMateHint;

        return SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(sizes.padL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TravelSearchBar(
                      controller: _searchController,
                      hintText: hintText,
                      onSubmitted: _openSearchResults,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      focusNode: _focusNode,
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
        );
      },
    );
  }
}
