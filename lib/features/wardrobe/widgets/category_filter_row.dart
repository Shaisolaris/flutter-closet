import 'package:flutter/material.dart';

import '../../../core/models/clothing_category.dart';

/// A horizontally-scrolling row of category chips, with a leading "All"
/// chip. Purely presentational - `null` in [onSelect] means "All".
class CategoryFilterRow extends StatelessWidget {
  const CategoryFilterRow({super.key, required this.selected, required this.onSelect});

  final ClothingCategory? selected;
  final ValueChanged<ClothingCategory?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: ClothingCategory.values.length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ChoiceChip(label: const Text('All'), selected: selected == null, onSelected: (_) => onSelect(null));
          }
          final category = ClothingCategory.values[index - 1];
          return ChoiceChip(
            avatar: Text(category.emoji, style: const TextStyle(fontSize: 14)),
            label: Text(category.label),
            selected: selected == category,
            onSelected: (_) => onSelect(category),
          );
        },
      ),
    );
  }
}
