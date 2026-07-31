/// Unit testing — the trip-tag JSON codec.
///
/// [TripTagCodec] is what lets a list of styled [TripTag]s survive a round trip
/// through a single SQLite text column. It is pure and total: it must never
/// throw on malformed stored data, only fall back, because that data comes off
/// disk and may predate the current schema.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelmate/shared/models/trip_tag_codec.dart';

import '../helpers/fixtures.dart';

void main() {
  group('encode/decode round trip', () {
    test('round-trips a tag with and without a border color', () {
      final withBorder = buildTag(
        'scenic',
        borderColor: const Color(0xFF708090),
      );
      final noBorder = buildTag('budget');

      final decoded = TripTagCodec.decodeList(
        TripTagCodec.encodeList([withBorder, noBorder]),
      );

      expect(decoded, hasLength(2));
      expect(decoded[0].label, 'scenic');
      expect(decoded[0].backgroundColor.toARGB32(), 0xFF112233);
      expect(decoded[0].borderColor?.toARGB32(), 0xFF708090);
      expect(decoded[1].label, 'budget');
      expect(decoded[1].borderColor, isNull);
    });

    test('round-trips an empty list', () {
      expect(
        TripTagCodec.decodeList(TripTagCodec.encodeList(const [])),
        isEmpty,
      );
    });

    test('preserves order', () {
      final decoded = TripTagCodec.decodeList(
        TripTagCodec.encodeList([buildTag('a'), buildTag('b'), buildTag('c')]),
      );
      expect(decoded.map((tag) => tag.label), ['a', 'b', 'c']);
    });
  });

  group('tolerating malformed stored data', () {
    test('decodeList returns empty for a non-list', () {
      expect(TripTagCodec.decodeList('nope'), isEmpty);
      expect(TripTagCodec.decodeList(null), isEmpty);
      expect(TripTagCodec.decodeList(42), isEmpty);
    });

    test('fromJson falls back for missing/invalid colors', () {
      final tag = TripTagCodec.fromJson({'label': 'x'});

      expect(tag.label, 'x');
      expect(tag.backgroundColor.toARGB32(), 0xFFFFF700);
      expect(tag.textColor.toARGB32(), 0xFF3A3200);
      expect(tag.borderColor, isNull);
    });

    test('fromJson falls back to an empty label', () {
      expect(TripTagCodec.fromJson(const {}).label, '');
    });

    test('fromJson coerces a non-string label rather than dropping it', () {
      expect(TripTagCodec.fromJson(const {'label': 42}).label, '42');
      expect(TripTagCodec.fromJson(const {'label': true}).label, 'true');
    });

    test('fromJson accepts colors stored as numbers of any kind', () {
      // A value that came back from JSON as a double must still resolve.
      final fromDouble = TripTagCodec.fromJson(const {
        'label': 'x',
        'backgroundColor': 4278190080.0,
      });
      final fromInt = TripTagCodec.fromJson(const {
        'label': 'x',
        'backgroundColor': 4278190080,
      });
      final fromString = TripTagCodec.fromJson(const {
        'label': 'x',
        'backgroundColor': '4278190080',
      });

      expect(fromDouble.backgroundColor.toARGB32(), 0xFF000000);
      expect(fromInt.backgroundColor.toARGB32(), 0xFF000000);
      expect(fromString.backgroundColor.toARGB32(), 0xFF000000);
    });

    test('fromJson falls back when a color string is not a number', () {
      final tag = TripTagCodec.fromJson(const {
        'label': 'x',
        'backgroundColor': 'not-a-number',
      });

      expect(tag.backgroundColor.toARGB32(), 0xFFFFF700);
    });
  });
}
