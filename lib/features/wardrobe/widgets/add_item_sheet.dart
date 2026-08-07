import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/models/clothing_category.dart';
import '../../../core/models/clothing_item.dart';
import '../../../core/utils/id_generator.dart';
import '../../../data/providers.dart';

const Map<ClothingCategory, String> _defaultEmoji = <ClothingCategory, String>{
  ClothingCategory.tops: '👕',
  ClothingCategory.bottoms: '👖',
  ClothingCategory.shoes: '👟',
  ClothingCategory.outerwear: '🧥',
  ClothingCategory.accessories: '👜',
};

/// Opens a bottom sheet form for adding a new wardrobe item.
Future<void> showAddItemSheet(BuildContext context, {ClothingCategory? initialCategory}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => AddItemSheet(initialCategory: initialCategory),
  );
}

class AddItemSheet extends ConsumerStatefulWidget {
  const AddItemSheet({super.key, this.initialCategory});

  final ClothingCategory? initialCategory;

  @override
  ConsumerState<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _colorController;
  late final TextEditingController _brandController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;

  late ClothingCategory _category;
  late DateTime _purchaseDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _colorController = TextEditingController();
    _brandController = TextEditingController();
    _sizeController = TextEditingController();
    _priceController = TextEditingController();
    _category = widget.initialCategory ?? ClothingCategory.tops;
    _purchaseDate = DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text('Add an item', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g. Navy Wool Blazer'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                Text('Category', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in ClothingCategory.values)
                      ChoiceChip(
                        avatar: Text(category.emoji, style: const TextStyle(fontSize: 14)),
                        label: Text(category.label),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Color', hintText: 'Navy'),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a color' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _sizeController,
                        decoration: const InputDecoration(labelText: 'Size', hintText: 'M'),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a size' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandController,
                  decoration: const InputDecoration(labelText: 'Brand', hintText: 'e.g. Northfield & Co.'),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter a brand' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final parsed = double.tryParse(value?.trim() ?? '');
                          if (parsed == null || parsed < 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _pickPurchaseDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Purchased'),
                          child: Text(formatMediumDate(_purchaseDate)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _submit, child: const Text('Add item')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPurchaseDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final existingCount = ref.read(itemsProvider).valueOrNull?.length ?? 0;
    ref.read(itemsProvider.notifier).addItem(
      ClothingItem(
        id: generateId('item'),
        name: _nameController.text.trim(),
        category: _category,
        color: _colorController.text.trim(),
        brand: _brandController.text.trim(),
        size: _sizeController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        purchaseDate: _purchaseDate,
        emoji: _defaultEmoji[_category] ?? '👕',
        gradientIndex: existingCount,
      ),
    );
    Navigator.of(context).pop();
  }
}
