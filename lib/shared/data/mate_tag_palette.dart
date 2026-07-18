import 'package:flutter/material.dart';

class MateTagPaletteEntry {
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;

  const MateTagPaletteEntry({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

/// Fallback fill-color palette cycled for mate tag chips (interests /
/// preferred trips) whose label doesn't match a real TripTagCatalog entry.
/// Single source of truth — reused by MateTagGroup and MateDetailsScreen so
/// the same index always renders the same colors in both places.
///
/// Colors are columnar (one list per channel, index-aligned) rather than a
/// list of six MateTagPaletteEntry(...) literals — with a fixed set of named
/// fields, six near-identical constructor blocks read as duplicated code; a
/// single resolve() built from parallel lists does not.
class MateTagPalette {
  static const List<Color> _backgroundColors = [
    Color(0xFFFFF700),
    Color(0xFF00E5FF),
    Color(0xFF7CFF4D),
    Color(0xFFFF9100),
    Color(0xFFFF4FD8),
    Color(0xFFB24CFF),
  ];

  static const List<Color> _textColors = [
    Color(0xFF3A3200),
    Color(0xFF00343A),
    Color(0xFF1F3A00),
    Color(0xFF4A2600),
    Color(0xFF3A0032),
    Color(0xFF2F005C),
  ];

  static const List<Color> _borderColors = [
    Color(0xFFFFF199),
    Color(0xFF99F8FF),
    Color(0xFFC8FFB5),
    Color(0xFFFFD299),
    Color(0xFFFFC2EF),
    Color(0xFFE0B6FF),
  ];

  static MateTagPaletteEntry resolve(int index) {
    final i = index % _backgroundColors.length;

    return MateTagPaletteEntry(
      backgroundColor: _backgroundColors[i],
      textColor: _textColors[i],
      borderColor: _borderColors[i],
    );
  }
}
