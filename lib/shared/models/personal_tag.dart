import 'package:flutter/material.dart';

class PersonalTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const PersonalTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
}
