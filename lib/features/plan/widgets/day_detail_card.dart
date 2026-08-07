import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/constants/nav_tabs.dart';
import '../../../core/logic/outfit.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/models/outfit.dart';
import '../../../core/models/plan_entry.dart';
import '../../../core/widgets/item_art.dart';
import '../../../data/providers.dart';
import 'assign_outfit_sheet.dart';

/// The selected calendar day's detail: what's planned (if anything), and
/// the actions available for it - assign/change/clear, plus "Wear today"
/// when [date] is today and something is planned.
class DayDetailCard extends ConsumerWidget {
  const DayDetailCard({
    super.key,
    required this.date,
    required this.isToday,
    required this.entry,
    required this.outfit,
    required this.hasOutfits,
  });

  final DateTime date;
  final bool isToday;
  final PlanEntry? entry;
  final Outfit? outfit;
  final bool hasOutfits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final allItems = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatWeekdayLong(date),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    formatRelativeToToday(date, DateTime.now()),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(formatMediumDate(date), style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (entry == null)
              _buildEmpty(context, ref)
            else if (outfit == null)
              _buildDangling(context, ref)
            else
              _buildAssigned(context, ref, entry!, outfit!, allItems),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasOutfits ? 'Nothing planned for this day.' : 'Create an outfit first, then plan it here.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        if (hasOutfits)
          FilledButton.icon(
            onPressed: () => showAssignOutfitSheet(context, date),
            icon: const Icon(Icons.add),
            label: const Text('Assign outfit'),
          )
        else
          OutlinedButton.icon(
            onPressed: () => ref.read(rootTabIndexProvider.notifier).state = NavTab.outfits,
            icon: const Icon(Icons.style_outlined),
            label: const Text('Go to Outfits'),
          ),
      ],
    );
  }

  Widget _buildDangling(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'That outfit was deleted.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => ref.read(planEntriesProvider.notifier).clearDate(date),
              child: const Text('Clear'),
            ),
            const SizedBox(width: 10),
            FilledButton(onPressed: () => showAssignOutfitSheet(context, date), child: const Text('Assign new')),
          ],
        ),
      ],
    );
  }

  Widget _buildAssigned(
    BuildContext context,
    WidgetRef ref,
    PlanEntry entry,
    Outfit outfit,
    List<ClothingItem> allItems,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = resolveItems(outfit.itemIds, allItems);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Wrap(
              spacing: 6,
              children: [
                for (final item in items.take(5))
                  ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 36, borderRadius: 10, emojiScale: 0.5),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(outfit.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(
          '${items.length} item${items.length == 1 ? '' : 's'}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            OutlinedButton(
              onPressed: () => showAssignOutfitSheet(context, date),
              child: const Text('Change'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => ref.read(planEntriesProvider.notifier).clearDate(date),
              child: const Text('Clear'),
            ),
          ],
        ),
        if (isToday) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: entry.worn ? null : () => _wearToday(context, ref),
              icon: Icon(entry.worn ? Icons.check_circle : Icons.checkroom),
              label: Text(entry.worn ? 'Worn today' : 'Wear today'),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _wearToday(BuildContext context, WidgetRef ref) async {
    await ref.read(planEntriesProvider.notifier).markWornForDate(date);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wear counts updated for today\'s outfit')));
    }
  }
}
