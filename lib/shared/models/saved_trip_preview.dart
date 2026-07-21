import 'package:travelmate/shared/models/trip_tag.dart';
import 'package:travelmate/shared/models/trip_tag_codec.dart';

class SavedBookmarkType {
  static const String trip = 'trip';
  static const String mate = 'mate';
}

class SavedTripPreview {
  final String tripName;
  final String destinationTitle;
  final String description;
  final String coverImage;
  final List<TripTag> tags;
  final String bookmarkType;
  final String sourceId;

  const SavedTripPreview({
    required this.tripName,
    required this.destinationTitle,
    required this.description,
    required this.coverImage,
    required this.tags,
    this.bookmarkType = SavedBookmarkType.trip,
    this.sourceId = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'tripName': tripName,
      'destinationTitle': destinationTitle,
      'description': description,
      'coverImage': coverImage,
      'bookmarkType': bookmarkType,
      'sourceId': sourceId,
      'tags': TripTagCodec.encodeList(tags),
    };
  }

  factory SavedTripPreview.fromJson(Map<String, dynamic> json) {
    final destinationTitle = _asString(json['destinationTitle']);
    final rawBookmarkType = _asString(json['bookmarkType']).toLowerCase();
    final resolvedBookmarkType = _resolveBookmarkType(
      rawBookmarkType,
      destinationTitle,
    );

    return SavedTripPreview(
      tripName: _asString(json['tripName']),
      destinationTitle: destinationTitle,
      description: _asString(json['description']),
      coverImage: _asString(json['coverImage']),
      tags: TripTagCodec.decodeList(json['tags']),
      bookmarkType: resolvedBookmarkType,
      sourceId: _asString(json['sourceId']),
    );
  }

  static String _resolveBookmarkType(
    String rawBookmarkType,
    String destinationTitle,
  ) {
    if (rawBookmarkType == SavedBookmarkType.mate ||
        rawBookmarkType == SavedBookmarkType.trip) {
      return rawBookmarkType;
    }

    if (destinationTitle.toLowerCase().startsWith('profile:')) {
      return SavedBookmarkType.mate;
    }

    return SavedBookmarkType.trip;
  }

  static String _asString(Object? value) {
    if (value is String) {
      return value;
    }

    return value?.toString() ?? '';
  }
}
