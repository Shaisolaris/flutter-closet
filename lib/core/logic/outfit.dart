import '../models/clothing_category.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import 'date_math.dart';

/// Pure outfit math: building and validating an outfit from a candidate set
/// of item ids, resolving those ids against the live wardrobe, computing an
/// outfit's total value, and applying "worn today" to its items. Nothing
/// here depends on Flutter or storage.

/// The result of validating a candidate set of item ids for a new or edited
/// outfit.
class OutfitValidation {
  const OutfitValidation({required this.errors, required this.categoriesCovered});

  /// Human-readable problems with the candidate selection. Empty means the
  /// selection is valid and safe to save.
  final List<String> errors;

  /// Categories represented among the *resolved* (still-existing) items in
  /// the candidate selection - used by the builder UI to show which
  /// category sections already have a pick.
  final Set<ClothingCategory> categoriesCovered;

  bool get isValid => errors.isEmpty;

  @override
  String toString() => 'OutfitValidation(valid: $isValid, errors: $errors)';
}

/// Validates a candidate set of [itemIds] against [allItems]: at least one
/// item must be picked, every id must resolve to a real item, and no id may
/// repeat.
OutfitValidation validateOutfitItems(List<String> itemIds, List<ClothingItem> allItems) {
  final errors = <String>[];

  if (itemIds.isEmpty) {
    errors.add('Pick at least one item.');
  }

  final knownIds = allItems.map((item) => item.id).toSet();
  final unknownCount = itemIds.where((id) => !knownIds.contains(id)).length;
  if (unknownCount > 0) {
    errors.add('$unknownCount selected item(s) no longer exist.');
  }

  if (itemIds.toSet().length != itemIds.length) {
    errors.add('The same item is selected more than once.');
  }

  final categoriesCovered = resolveItems(itemIds, allItems).map((item) => item.category).toSet();

  return OutfitValidation(errors: errors, categoriesCovered: categoriesCovered);
}

/// Resolves [itemIds] to their [ClothingItem]s, in the same order, silently
/// dropping any id that no longer exists in [allItems] (e.g. the item was
/// deleted after the outfit was saved).
List<ClothingItem> resolveItems(List<String> itemIds, List<ClothingItem> allItems) {
  final byId = <String, ClothingItem>{for (final item in allItems) item.id: item};
  return <ClothingItem>[for (final id in itemIds) if (byId.containsKey(id)) byId[id]!];
}

/// Builds a new [Outfit] from [name] and [itemIds]. Does not validate -
/// callers should run [validateOutfitItems] first and only build when
/// `isValid` is true.
Outfit buildOutfit({
  required String id,
  required String name,
  required List<String> itemIds,
  required DateTime createdDate,
}) {
  return Outfit(
    id: id,
    name: name.trim(),
    itemIds: List<String>.unmodifiable(itemIds),
    createdDate: dateOnly(createdDate),
  );
}

/// Sum of [ClothingItem.price] for every item in [outfit] that still exists
/// in [allItems]. Deleted items contribute nothing rather than throwing.
double outfitTotalValue(Outfit outfit, List<ClothingItem> allItems) {
  final items = resolveItems(outfit.itemIds, allItems);
  return items.fold<double>(0, (sum, item) => sum + item.price);
}

/// Number of items in [outfit] that still resolve to a real wardrobe item.
int outfitLiveItemCount(Outfit outfit, List<ClothingItem> allItems) {
  return resolveItems(outfit.itemIds, allItems).length;
}

/// Returns [items] with [ClothingItem.wearCount] incremented by one and
/// [ClothingItem.lastWornDate] set to [wornOn] for every item referenced by
/// [outfit]; every other item passes through unchanged. Used by "Wear
/// today" to bump every piece in the day's planned outfit at once.
List<ClothingItem> applyOutfitWear(Outfit outfit, List<ClothingItem> items, DateTime wornOn) {
  final wornIds = outfit.itemIds.toSet();
  return <ClothingItem>[
    for (final item in items)
      if (wornIds.contains(item.id))
        item.copyWith(wearCount: item.wearCount + 1, lastWornDate: wornOn)
      else
        item,
  ];
}

/// [outfit] with its own [Outfit.wearCount] incremented and
/// [Outfit.lastWornDate] set to [wornOn] - the outfit-level counterpart to
/// [applyOutfitWear].
Outfit markOutfitWorn(Outfit outfit, DateTime wornOn) {
  return outfit.copyWith(wearCount: outfit.wearCount + 1, lastWornDate: wornOn);
}
