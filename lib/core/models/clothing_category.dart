/// The five wardrobe categories Closet organizes every item into. A fixed
/// enum (rather than free-form reference data) because the set is small,
/// stable, and drives both the Wardrobe filter row and the outfit builder's
/// section layout.
enum ClothingCategory { tops, bottoms, shoes, outerwear, accessories }

extension ClothingCategoryX on ClothingCategory {
  /// Plural display label, e.g. "Tops".
  String get label => switch (this) {
    ClothingCategory.tops => 'Tops',
    ClothingCategory.bottoms => 'Bottoms',
    ClothingCategory.shoes => 'Shoes',
    ClothingCategory.outerwear => 'Outerwear',
    ClothingCategory.accessories => 'Accessories',
  };

  /// Stand-in art for a category tile when no more specific item emoji
  /// applies (e.g. an empty-state icon).
  String get emoji => switch (this) {
    ClothingCategory.tops => '👕',
    ClothingCategory.bottoms => '👖',
    ClothingCategory.shoes => '👟',
    ClothingCategory.outerwear => '🧥',
    ClothingCategory.accessories => '👜',
  };

  /// The stable string stored in JSON - `name` already satisfies this
  /// (`tops`, `bottoms`, ...) but a named getter keeps call sites reading
  /// intentionally rather than relying on the enum's implicit `name`.
  String get storageKey => name;
}

/// Parses a [ClothingCategory] from its [ClothingCategoryX.storageKey],
/// falling back to [ClothingCategory.tops] for unrecognized or corrupted
/// data rather than throwing.
ClothingCategory clothingCategoryFromKey(String key) {
  return ClothingCategory.values.firstWhere(
    (category) => category.storageKey == key,
    orElse: () => ClothingCategory.tops,
  );
}
