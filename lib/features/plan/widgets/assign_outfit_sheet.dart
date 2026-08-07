import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/logic/outfit.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/models/outfit.dart';
import '../../../core/widgets/item_art.dart';
import '../../../data/providers.dart';

/// Opens a bottom sheet listing every saved outfit; tapping one assigns it
/// to [date] and closes the sheet.
Future<void> showAssignOutfitSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => AssignOutfitSheet(date: date),
  );
}

class AssignOutfitSheet extends ConsumerWidget {
  const AssignOutfitSheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final outfits = ref.watch(outfitsProvider).valueOrNull ?? const <Outfit>[];
    final allItems = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
              Text('Assign an outfit', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(formatMediumDate(date), style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              if (outfits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('No saved outfits yet.', style: theme.textTheme.bodyMedium),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: outfits.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final outfit = outfits[index];
                      final items = resolveItems(outfit.itemIds, allItems).take(3).toList();
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        tileColor: scheme.surfaceContainerHigh,
                        leading: SizedBox(
                          width: 44,
                          height: 32,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              for (var i = 0; i < items.length; i++)
                                Positioned(
                                  left: i * 14.0,
                                  child: ItemArt(
                                    emoji: items[i].emoji,
                                    gradientIndex: items[i].gradientIndex,
                                    size: 32,
                                    borderRadius: 10,
                                    emojiScale: 0.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        title: Text(outfit.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text('${outfit.itemIds.length} items'),
                        onTap: () async {
                          await ref.read(planEntriesProvider.notifier).assignOutfit(date, outfit.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
