import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/nav_tabs.dart';
import '../../core/models/clothing_item.dart';
import '../../core/models/outfit.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/providers.dart';
import 'widgets/outfit_builder_page.dart';
import 'widgets/outfit_card.dart';

/// The Outfits tab: every saved outfit as a card of clustered item art, with
/// a builder to combine wardrobe items into a new named outfit.
class OutfitsScreen extends ConsumerWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outfitsAsync = ref.watch(outfitsProvider);
    final outfits = outfitsAsync.valueOrNull ?? const <Outfit>[];
    final hasItems = (ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[]).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Outfits'), centerTitle: false),
      body: outfitsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : outfits.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.style_outlined,
                title: 'No outfits yet',
                message: hasItems
                    ? 'Combine items from your wardrobe into a named outfit.'
                    : 'Add a few wardrobe items first, then build an outfit from them.',
                action: hasItems
                    ? FilledButton.icon(
                        onPressed: () => openOutfitBuilder(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Create outfit'),
                      )
                    : OutlinedButton.icon(
                        onPressed: () => ref.read(rootTabIndexProvider.notifier).state = NavTab.wardrobe,
                        icon: const Icon(Icons.checkroom_outlined),
                        label: const Text('Go to Wardrobe'),
                      ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: outfits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => OutfitCard(outfit: outfits[index]),
            ),
      floatingActionButton: hasItems
          ? FloatingActionButton.extended(
              onPressed: () => openOutfitBuilder(context),
              icon: const Icon(Icons.add),
              label: const Text('Create outfit'),
            )
          : null,
    );
  }
}
