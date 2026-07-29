import 'package:flutter/material.dart';

import 'package:travelmate/shared/models/trip_tag.dart';

/// Single source of truth for (de)serializing [TripTag]s to/from JSON maps.
///
/// Colors are stored as ARGB32 integers. Shared by everything that persists
/// tags (saved bookmarks, the trip catalog database) so the encoding lives in
/// one place instead of being copy-pasted per store.
class TripTagCodec {
  const TripTagCodec._();

  // Fallbacks match the first entry of the default tag palette, so a corrupt
  // or missing color still renders as a valid chip rather than crashing.
  static const int _defaultBackground = 0xFFFFF700;
  static const int _defaultText = 0xFF3A3200;
  static const int _defaultBorder = 0xFFFFF199;

  static Map<String, Object?> toJson(TripTag tag) {
    return {
      'label': tag.label,
      'backgroundColor': tag.backgroundColor.toARGB32(),
      'textColor': tag.textColor.toARGB32(),
      'borderColor': tag.borderColor?.toARGB32(),
    };
  }

  static TripTag fromJson(Map<String, Object?> json) {
    final borderColor = json['borderColor'];

    return TripTag(
      label: _asString(json['label']),
      backgroundColor: Color(
        _asInt(json['backgroundColor'], _defaultBackground),
      ),
      textColor: Color(_asInt(json['textColor'], _defaultText)),
      borderColor: borderColor == null
          ? null
          : Color(_asInt(borderColor, _defaultBorder)),
    );
  }

  static List<Map<String, Object?>> encodeList(List<TripTag> tags) {
    return tags.map(toJson).toList(growable: false);
  }

  static List<TripTag> decodeList(Object? raw) {
    if (raw is! List) {
      return const <TripTag>[];
    }

    return raw
        .whereType<Map>()
        .map((item) => fromJson(Map<String, Object?>.from(item)))
        .toList(growable: false);
  }

  static String _asString(Object? value) {
    if (value is String) {
      return value;
    }

    return value?.toString() ?? '';
  }

  static int _asInt(Object? value, int fallback) {
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
