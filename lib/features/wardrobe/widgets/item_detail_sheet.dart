import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/constants/money_format.dart';
import '../../../core/logic/stats.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/widgets/item_art.dart';
import '../../../data/providers.dart';

/// Opens a bottom sheet showing [item]'s full details, with an option to
/// delete it from the wardrobe.
Future<void> showItemDetailSheet(BuildContext context, ClothingItem item) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => ItemDetailSheet(item: item),
  );
}

class ItemDetailSheet extends ConsumerWidget {
  const ItemDetailSheet({super.key, required this.item});

  final ClothingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: scheme.outlineVariant, borderRadius: BorderRadius.circular(999)),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 64, borderRadius: 18, emojiScale: 0.5),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        '${item.category.label} · ${item.color}',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailRow(label: 'Brand', value: item.brand),
            _DetailRow(label: 'Size', value: item.size),
            _DetailRow(label: 'Price', value: formatPrice(item.price)),
            _DetailRow(label: 'Cost per wear', value: formatPrice(costPerWear(item))),
            _DetailRow(label: 'Times worn', value: '${item.wearCount}'),
            _DetailRow(
              label: 'Last worn',
              value: item.lastWornDate == null ? 'Never' : formatRelativeToToday(item.lastWornDate!, DateTime.now()),
            ),
            _DetailRow(label: 'Purchased', value: formatMediumDate(item.purchaseDate)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: Icon(Icons.delete_outline, color: scheme.error),
                label: Text('Remove from wardrobe', style: TextStyle(color: scheme.error)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: scheme.error.withValues(alpha: 0.5))),
              ),
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
        title: const Text('Remove item?'),
        content: Text('"${item.name}" will be removed from your wardrobe and any outfits that use it.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(itemsProvider.notifier).removeItem(item.id);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"${item.name}" removed')));
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
