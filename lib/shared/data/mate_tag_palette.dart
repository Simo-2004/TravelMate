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
class MateTagPalette {
  static const List<MateTagPaletteEntry> entries = [
    MateTagPaletteEntry(
      backgroundColor: Color(0xFFFFF700),
      textColor: Color(0xFF3A3200),
      borderColor: Color(0xFFFFF199),
    ),
    MateTagPaletteEntry(
      backgroundColor: Color(0xFF00E5FF),
      textColor: Color(0xFF00343A),
      borderColor: Color(0xFF99F8FF),
    ),
    MateTagPaletteEntry(
      backgroundColor: Color(0xFF7CFF4D),
      textColor: Color(0xFF1F3A00),
      borderColor: Color(0xFFC8FFB5),
    ),
    MateTagPaletteEntry(
      backgroundColor: Color(0xFFFF9100),
      textColor: Color(0xFF4A2600),
      borderColor: Color(0xFFFFD299),
    ),
    MateTagPaletteEntry(
      backgroundColor: Color(0xFFFF4FD8),
      textColor: Color(0xFF3A0032),
      borderColor: Color(0xFFFFC2EF),
    ),
    MateTagPaletteEntry(
      backgroundColor: Color(0xFFB24CFF),
      textColor: Color(0xFF2F005C),
      borderColor: Color(0xFFE0B6FF),
    ),
  ];

  static MateTagPaletteEntry resolve(int index) {
    return entries[index % entries.length];
  }
}
