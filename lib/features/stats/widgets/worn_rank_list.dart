import 'package:flutter/material.dart';

import '../../../core/constants/money_format.dart';
import '../../../core/logic/stats.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/widgets/item_art.dart';

/// A ranked list of items - used for both "Most worn" and "Least worn" on
/// the Stats screen. Each row shows the item's art, name, cost-per-wear,
/// and a wear-count badge.
class WornRankList extends StatelessWidget {
  const WornRankList({super.key, required this.items, required this.emptyMessage});

  final List<ClothingItem> items;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(emptyMessage, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 40, borderRadius: 12, emojiScale: 0.5),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${formatPrice(costPerWear(item))} / wear',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
                  child: Text(
                    item.wearCount == 0 ? 'New' : '${item.wearCount}x',
                    style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
