import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/models/clothing_category.dart';

/// One category's slice of the donut: its share of the wardrobe and the
/// color it renders in.
class CategorySlice {
  const CategorySlice({required this.category, required this.count, required this.color});

  final ClothingCategory category;
  final int count;
  final Color color;
}

/// A hand-drawn donut chart: one arc per category, swept proportionally to
/// its item count, with the wardrobe's total item count centered inside.
class CategoryBreakdownChart extends StatelessWidget {
  const CategoryBreakdownChart({super.key, required this.slices, this.size = 176});

  final List<CategorySlice> slices;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.count);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(slices: slices, trackColor: scheme.surfaceContainerHighest),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$total', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
              Text('items', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.trackColor});

  final List<CategorySlice> slices;
  final Color trackColor;

  static const double _gapRadians = 0.035;

  @override
  void paint(Canvas canvas, Size size) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.count);
    final strokeWidth = size.width * 0.16;
    final rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.count <= 0) continue;
      final sweep = (slice.count / total) * 2 * math.pi;
      final drawSweep = math.max(sweep - _gapRadians, 0.0);
      final slicePaint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, drawSweep, false, slicePaint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.trackColor != trackColor;
  }
}

/// The chart's legend: one row per category with a color dot, label, and
/// item count.
class CategoryLegend extends StatelessWidget {
  const CategoryLegend({super.key, required this.slices});

  final List<CategorySlice> slices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final slice in slices)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(slice.category.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(
                  '${slice.count}  ·  ${total == 0 ? 0 : (slice.count / total * 100).round()}%',
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
