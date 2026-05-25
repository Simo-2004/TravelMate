import 'package:flutter/foundation.dart';

import 'package:travelmate/shared/models/search_research_mode.dart';

class SearchResearchModeStore extends ValueNotifier<SearchResearchMode> {
  SearchResearchModeStore._() : super(SearchResearchMode.trips);

  static final SearchResearchModeStore instance =
      SearchResearchModeStore._();

  void toggle() {
    value = value == SearchResearchMode.trips
        ? SearchResearchMode.mates
        : SearchResearchMode.trips;
  }
}
