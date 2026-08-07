import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/money_format.dart';
import '../../../core/logic/outfit.dart';
import '../../../core/models/clothing_category.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/widgets/item_art.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/providers.dart';

/// Pushes the full-screen outfit builder: name the outfit, then pick one or
/// more items from each category section.
Future<void> openOutfitBuilder(BuildContext context) {
  return Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const OutfitBuilderPage()));
}

class OutfitBuilderPage extends ConsumerStatefulWidget {
  const OutfitBuilderPage({super.key});

  @override
  ConsumerState<OutfitBuilderPage> createState() => _OutfitBuilderPageState();
}

class _OutfitBuilderPageState extends ConsumerState<OutfitBuilderPage> {
  late final TextEditingController _nameController;
  final Set<String> _selectedItemIds = <String>{};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggle(String itemId) {
    setState(() {
      if (!_selectedItemIds.add(itemId)) _selectedItemIds.remove(itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
    final selectedItems = allItems.where((item) => _selectedItemIds.contains(item.id)).toList();
    final totalValue = selectedItems.fold<double>(0, (sum, item) => sum + item.price);
    final validation = validateOutfitItems(_selectedItemIds.toList(), allItems);
    final canSave = _nameController.text.trim().isNotEmpty && validation.isValid;

    return Scaffold(
      appBar: AppBar(title: const Text('New outfit')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Outfit name', hintText: 'e.g. Friday Presentation'),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: allItems.isEmpty
                ? const Center(child: Text('Add wardrobe items first.'))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      for (final category in ClothingCategory.values)
                        _CategorySection(
                          category: category,
                          items: allItems.where((item) => item.category == category).toList(),
                          selectedIds: _selectedItemIds,
                          onToggle: _toggle,
                        ),
                    ],
                  ),
          ),
          _BuilderSummaryBar(
            selectedCount: selectedItems.length,
            totalValue: totalValue,
            canSave: canSave,
            onSave: () => _submit(allItems),
          ),
        ],
      ),
    );
  }

  void _submit(List<ClothingItem> allItems) {
    final validation = validateOutfitItems(_selectedItemIds.toList(), allItems);
    if (!validation.isValid || _nameController.text.trim().isEmpty) return;

    final outfit = buildOutfit(
      id: generateId('outfit'),
      name: _nameController.text.trim(),
      itemIds: _selectedItemIds.toList(),
      createdDate: DateTime.now(),
    );
    ref.read(outfitsProvider.notifier).addOutfit(outfit);
    Navigator.of(context).pop();
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({required this.category, required this.items, required this.selectedIds, required this.onToggle});

  final ClothingCategory category;
  final List<ClothingItem> items;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final selectedInCategory = items.where((item) => selectedIds.contains(item.id)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: '${category.emoji} ${category.label}',
            subtitle: selectedInCategory == 0 ? 'Pick one or more' : '$selectedInCategory selected',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                _SelectableItemChip(item: item, selected: selectedIds.contains(item.id), onTap: () => onToggle(item.id)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectableItemChip extends StatelessWidget {
  const _SelectableItemChip({required this.item, required this.selected, required this.onTap});

  final ClothingItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ItemArt(emoji: item.emoji, gradientIndex: item.gradientIndex, size: 48, borderRadius: 12, emojiScale: 0.5),
                  if (selected)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(Icons.check, size: 12, color: scheme.onPrimary),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuilderSummaryBar extends StatelessWidget {
  const _BuilderSummaryBar({
    required this.selectedCount,
    required this.totalValue,
    required this.canSave,
    required this.onSave,
  });

  final int selectedCount;
  final double totalValue;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surfaceContainer, border: Border(top: BorderSide(color: scheme.outlineVariant))),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$selectedCount item${selectedCount == 1 ? '' : 's'} selected',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      formatPrice(totalValue),
                      style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              FilledButton(onPressed: canSave ? onSave : null, child: const Text('Save outfit')),
            ],
          ),
        ),
      ),
    );
  }
}
