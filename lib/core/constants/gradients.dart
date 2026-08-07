import 'package:flutter/material.dart';

import '../models/clothing_category.dart';

/// Shared gradient palette used to render clothing item art - Closet has no
/// product photography, so every item tile is a colored gradient with an
/// emoji on top. Items pick a [gradientIndex] at creation time (see
/// `data/seed_data.dart`), so the palette only needs to look good, not mean
/// anything semantically.
///
/// This file imports Flutter and must never be imported from `core/logic/`
/// or `core/models/` - only from widgets.
const List<List<Color>> _gradientPalette = <List<Color>>[
  [Color(0xFFF9A8D4), Color(0xFFBE185D)], // pink - matches the app's seed color
  [Color(0xFFC4B5FD), Color(0xFF6D28D9)], // violet
  [Color(0xFF7DD3FC), Color(0xFF0369A1)], // sky blue
  [Color(0xFFFCD34D), Color(0xFFB45309)], // amber
  [Color(0xFF5EEAD4), Color(0xFF0F766E)], // teal
  [Color(0xFFFDBA74), Color(0xFFC2410C)], // orange
  [Color(0xFFA7F3D0), Color(0xFF047857)], // mint
  [Color(0xFFFDA4AF), Color(0xFF9F1239)], // rose
  [Color(0xFF93C5FD), Color(0xFF1D4ED8)], // blue
  [Color(0xFFE9D5FF), Color(0xFF7E22CE)], // purple
];

/// The two colors used for gradient block [index], cycling through the
/// palette if there are more items than palette entries.
List<Color> gradientColorsFor(int index) {
  final safeIndex = index % _gradientPalette.length;
  return _gradientPalette[safeIndex < 0 ? safeIndex + _gradientPalette.length : safeIndex];
}

/// A ready-to-use [LinearGradient] for gradient block [index].
LinearGradient gradientFor(int index) {
  return LinearGradient(colors: gradientColorsFor(index), begin: Alignment.topLeft, end: Alignment.bottomRight);
}

/// A fixed solid color per wardrobe category, used by the Stats screen's
/// category breakdown chart and legend - unlike item art, a category needs
/// one *consistent* color rather than a cycling palette.
Color categoryChartColor(ClothingCategory category) {
  switch (category) {
    case ClothingCategory.tops:
      return const Color(0xFFEC4899); // pink
    case ClothingCategory.bottoms:
      return const Color(0xFF8B5CF6); // violet
    case ClothingCategory.shoes:
      return const Color(0xFF0EA5E9); // sky blue
    case ClothingCategory.outerwear:
      return const Color(0xFFF59E0B); // amber
    case ClothingCategory.accessories:
      return const Color(0xFF10B981); // emerald
  }
}
