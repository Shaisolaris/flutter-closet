import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/constants/money_format.dart';
import '../../../core/logic/outfit.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/models/outfit.dart';
import '../../../core/widgets/item_art.dart';
import '../../../data/providers.dart';

/// One saved outfit: name, item count + total value, a cluster of its
/// items' gradient+emoji art, and its wear history. A trailing menu offers
/// deletion.
class OutfitCard extends ConsumerWidget {
  const OutfitCard({super.key, required this.outfit});

  final Outfit outfit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
    final resolvedItems = resolveItems(outfit.itemIds, allItems);
    final totalValue = outfitTotalValue(outfit, allItems);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(outfit.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        '${resolvedItems.length} item${resolvedItems.length == 1 ? '' : 's'} · ${formatPrice(totalValue)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                  onSelected: (value) {
                    if (value == 'delete') _confirmDelete(context, ref);
                  },
                  itemBuilder: (context) => const <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'delete', child: Text('Delete outfit')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in resolvedItems)
                  ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 42, borderRadius: 12, emojiScale: 0.5),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.repeat, size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Worn ${outfit.wearCount}x', style: theme.textTheme.bodySmall),
                if (outfit.lastWornDate != null) ...[
                  Text(' · ', style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  Text(
                    'last ${formatRelativeToToday(outfit.lastWornDate!, DateTime.now()).toLowerCase()}',
                    style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete outfit?'),
        content: Text('"${outfit.name}" will be removed. The items themselves stay in your wardrobe.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(outfitsProvider.notifier).removeOutfit(outfit.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${outfit.name}" deleted')));
    }
  }
}
