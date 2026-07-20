import 'package:flutter/material.dart';
import 'package:travelmate/shared/models/trip_tag.dart';

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
      'tags': tags
          .map(
            (tag) => {
              'label': tag.label,
              'backgroundColor': tag.backgroundColor.toARGB32(),
              'textColor': tag.textColor.toARGB32(),
              'borderColor': tag.borderColor?.toARGB32(),
            },
          )
          .toList(growable: false),
    };
  }

  factory SavedTripPreview.fromJson(Map<String, dynamic> json) {
    final destinationTitle = _asString(json['destinationTitle']);
    final rawBookmarkType = _asString(json['bookmarkType']).toLowerCase();
    final resolvedBookmarkType = _resolveBookmarkType(
      rawBookmarkType,
      destinationTitle,
    );

    final rawTags = json['tags'];
    final parsedTags = rawTags is List
        ? rawTags
              .whereType<Map>()
              .map((rawTag) {
                final tag = Map<String, dynamic>.from(rawTag);

                return TripTag(
                  label: _asString(tag['label']),
                  backgroundColor: Color(
                    _asInt(tag['backgroundColor'], fallback: 0xFFFFF700),
                  ),
                  textColor: Color(
                    _asInt(tag['textColor'], fallback: 0xFF3A3200),
                  ),
                  borderColor: tag['borderColor'] == null
                      ? null
                      : Color(_asInt(tag['borderColor'], fallback: 0xFFFFF199)),
                );
              })
              .toList(growable: false)
        : const <TripTag>[];

    return SavedTripPreview(
      tripName: _asString(json['tripName']),
      destinationTitle: destinationTitle,
      description: _asString(json['description']),
      coverImage: _asString(json['coverImage']),
      tags: parsedTags,
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

  static int _asInt(Object? value, {required int fallback}) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }

    return fallback;
  }
}
