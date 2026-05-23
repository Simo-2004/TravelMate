import 'package:flutter/material.dart';

class TripTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const TripTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}
