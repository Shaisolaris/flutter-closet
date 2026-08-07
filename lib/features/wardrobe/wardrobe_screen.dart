import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/clothing_category.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import 'widgets/add_item_sheet.dart';
import 'widgets/category_filter_row.dart';
import 'widgets/item_card.dart';
import 'widgets/item_detail_sheet.dart';

/// The Wardrobe tab: every item in the closet, filterable by category, as a
/// grid of gradient+emoji tiles with a wear count badge.
class WardrobeScreen extends ConsumerWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final filtered = ref.watch(filteredItemsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final totalCount = itemsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wardrobe'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$totalCount items',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
      body: itemsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 8),
                CategoryFilterRow(
                  selected: selectedCategory,
                  onSelect: (category) => ref.read(selectedCategoryProvider.notifier).state = category,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: EmptyState(
                            icon: Icons.checkroom_outlined,
                            title: selectedCategory == null ? 'Your wardrobe is empty' : 'Nothing here yet',
                            message: selectedCategory == null
                                ? 'Add the pieces you own to start building outfits.'
                                : 'Add a ${selectedCategory.label.toLowerCase()} item to fill this category.',
                            action: FilledButton.icon(
                              onPressed: () => showAddItemSheet(context, initialCategory: selectedCategory),
                              icon: const Icon(Icons.add),
                              label: const Text('Add item'),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return ItemCard(item: item, onTap: () => showItemDetailSheet(context, item));
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddItemSheet(context, initialCategory: selectedCategory),
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );
  }
}
