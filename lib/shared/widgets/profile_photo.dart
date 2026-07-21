import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:travelmate/core/constants/app_colors.dart';

/// Renders a profile image from any supported source, in one place, so the
/// avatar/preview widgets don't each duplicate the resolution logic.
///
/// Resolution order:
/// * empty  → a person placeholder icon;
/// * bundled `assets/…svg`  → [SvgPicture.asset];
/// * bundled `assets/…`     → [Image.asset];
/// * anything else (an absolute file path from the image picker) →
///   [Image.file], with a graceful placeholder if the file is missing.
class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    super.key,
    required this.source,
    required this.size,
    this.placeholderColor,
    this.fit = BoxFit.cover,
  });

  final String source;
  final double size;
  final Color? placeholderColor;
  final BoxFit fit;

  static const String _assetPrefix = 'assets/';

  bool get _isAsset => source.startsWith(_assetPrefix);

  bool get _isSvg => source.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return _placeholder();
    }

    if (_isAsset) {
      return _isSvg
          ? SvgPicture.asset(trimmed, fit: fit)
          : Image.asset(trimmed, fit: fit, errorBuilder: _onError);
    }

    return Image.file(File(trimmed), fit: fit, errorBuilder: _onError);
  }

  Widget _onError(BuildContext context, Object error, StackTrace? stackTrace) {
    return _placeholder();
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.person_outline,
        size: size * 0.46,
        color: placeholderColor ?? AppColors.blackAlpha60,
      ),
    );
  }
}
