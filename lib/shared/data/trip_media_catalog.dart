class TripMediaCatalog {
  static const int tripCount = 6;
  static const int schedulePerTrip = 4;
  static const String _homeFolder = 'assets/images/home';
  static const String _scheduleFolder = 'assets/images/schedule';

  static final List<String> homeTripAssets =
      _buildAssets(folder: _homeFolder, prefix: 'trip', count: tripCount);

  static final List<String> scheduleAssets = _buildAssets(
    folder: _scheduleFolder,
    prefix: 'schedule',
    count: tripCount * schedulePerTrip,
  );

  static final List<List<String>> scheduleSets = _buildScheduleSets();

  static List<String> _buildAssets({
    required String folder,
    required String prefix,
    required int count,
  }) {
    return List.generate(
      count,
      (index) => '$folder/${prefix}_${index + 1}.svg',
    );
  }

  static List<List<String>> _buildScheduleSets() {
    return List.generate(tripCount, (index) {
      final start = index * schedulePerTrip;
      return scheduleAssets.sublist(start, start + schedulePerTrip);
    });
  }
}
