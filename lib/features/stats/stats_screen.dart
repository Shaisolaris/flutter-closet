import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/gradients.dart';
import '../../core/constants/money_format.dart';
import '../../core/models/clothing_category.dart';
import '../../core/models/clothing_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/item_art.dart';
import '../../core/widgets/section_header.dart';
import '../../data/providers.dart';
import 'widgets/category_breakdown_chart.dart';
import 'widgets/stat_tile.dart';
import 'widgets/worn_rank_list.dart';

/// The Stats tab: wardrobe-wide numbers (value, cost per wear, total
/// wears), a category breakdown donut, and most/least/never-worn rankings.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final items = itemsAsync.valueOrNull ?? const <ClothingItem>[];

    if (!itemsAsync.isLoading && items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stats'), centerTitle: false),
        body: const Center(
          child: EmptyState(
            icon: Icons.insights_outlined,
            title: 'Nothing to analyze yet',
            message: 'Add a few wardrobe items to see cost-per-wear and category stats.',
          ),
        ),
      );
    }

    final totalValue = ref.watch(totalWardrobeValueProvider);
    final avgCostPerWear = ref.watch(averageCostPerWearProvider);
    final totalWears = ref.watch(totalWearCountProvider);
    final categoryCounts = ref.watch(categoryCountsProvider);
    final mostWorn = ref.watch(mostWornProvider);
    final leastWorn = ref.watch(leastWornProvider);
    final neverWorn = ref.watch(neverWornProvider);

    final slices = [
      for (final category in ClothingCategory.values)
        CategorySlice(category: category, count: categoryCounts[category] ?? 0, color: categoryChartColor(category)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Stats'), centerTitle: false),
      body: itemsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                Row(
                  children: [
                    StatTile(label: 'Wardrobe value', value: formatPrice(totalValue), icon: Icons.savings_outlined),
                    const SizedBox(width: 12),
                    StatTile(label: 'Items', value: '${items.length}', icon: Icons.checkroom_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    StatTile(
                      label: 'Avg cost / wear',
                      value: formatPrice(avgCostPerWear),
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(width: 12),
                    StatTile(label: 'Total wears', value: '$totalWears', icon: Icons.repeat),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Category breakdown'),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CategoryBreakdownChart(slices: slices),
                        const SizedBox(width: 16),
                        Expanded(child: CategoryLegend(slices: slices)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Most worn'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: WornRankList(items: mostWorn, emptyMessage: 'Wear something to see it here.'),
                  ),
                ),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Least worn'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: WornRankList(items: leastWorn, emptyMessage: 'Nothing to show yet.'),
                  ),
                ),
                if (neverWorn.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Never worn (${neverWorn.length})', subtitle: 'Might be worth a rewear'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final item in neverWorn)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 52, borderRadius: 14, emojiScale: 0.5),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
