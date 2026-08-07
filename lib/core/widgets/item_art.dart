import 'package:flutter/material.dart';

import '../constants/gradients.dart';

/// A rounded gradient square with a big emoji centered on top - Closet's
/// stand-in for clothing photography. Used at different sizes on the
/// Wardrobe grid, outfit clusters, the outfit builder, and the Plan/Stats
/// screens, so a given [gradientIndex] always looks the same everywhere.
class ItemArt extends StatelessWidget {
  const ItemArt({
    super.key,
    required this.emoji,
    required this.gradientIndex,
    this.size = 56,
    this.borderRadius = 16,
    this.emojiScale = 0.5,
  });

  final String emoji;
  final int gradientIndex;
  final double size;
  final double borderRadius;

  /// Emoji font size as a fraction of [size].
  final double emojiScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(gradient: gradientFor(gradientIndex), borderRadius: BorderRadius.circular(borderRadius)),
      alignment: Alignment.center,
      child: Text(emoji, style: TextStyle(fontSize: size * emojiScale)),
    );
  }
}
