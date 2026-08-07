import '../models/clothing_category.dart';
import '../models/clothing_item.dart';

/// Pure wardrobe statistics: cost-per-wear, most/least-worn rankings, and
/// category breakdowns. Nothing here depends on Flutter - the Stats screen
/// (including its `CustomPainter` chart) reads straight from these
/// functions.

/// Cost per wear for [item]: price divided by wear count, with the wear
/// count floored at 1 so a never-worn item shows its full price rather than
/// dividing by zero (and a single wear isn't rewarded with an artificially
/// tiny number).
double costPerWear(ClothingItem item) {
  final effectiveWears = item.wearCount < 1 ? 1 : item.wearCount;
  return item.price / effectiveWears;
}

/// [items] sorted most-worn-first; ties break alphabetically by name for a
/// stable, deterministic order.
List<ClothingItem> mostWorn(List<ClothingItem> items, {int limit = 5}) {
  final sorted = List<ClothingItem>.of(items)
    ..sort((a, b) {
      final byWear = b.wearCount.compareTo(a.wearCount);
      return byWear != 0 ? byWear : a.name.compareTo(b.name);
    });
  return sorted.take(limit).toList();
}

/// [items] sorted least-worn-first; never-worn items (wearCount == 0) sort
/// first, exactly matching "what am I not wearing". Ties break alphabetically.
List<ClothingItem> leastWorn(List<ClothingItem> items, {int limit = 5}) {
  final sorted = List<ClothingItem>.of(items)
    ..sort((a, b) {
      final byWear = a.wearCount.compareTo(b.wearCount);
      return byWear != 0 ? byWear : a.name.compareTo(b.name);
    });
  return sorted.take(limit).toList();
}

/// Items that have never been worn - cost-per-wear is undefined/misleading
/// for these, so Stats calls them out as their own list instead.
List<ClothingItem> neverWorn(List<ClothingItem> items) {
  return items.where((item) => item.wearCount == 0).toList();
}

/// Number of items per category, including categories with zero items so a
/// chart can always render a consistent set of slices/bars.
Map<ClothingCategory, int> categoryCounts(List<ClothingItem> items) {
  final counts = <ClothingCategory, int>{for (final category in ClothingCategory.values) category: 0};
  for (final item in items) {
    counts[item.category] = (counts[item.category] ?? 0) + 1;
  }
  return counts;
}

/// Total price of every item per category.
Map<ClothingCategory, double> categoryValue(List<ClothingItem> items) {
  final totals = <ClothingCategory, double>{for (final category in ClothingCategory.values) category: 0};
  for (final item in items) {
    totals[item.category] = (totals[item.category] ?? 0) + item.price;
  }
  return totals;
}

/// Sum of [ClothingItem.price] across the whole wardrobe.
double totalWardrobeValue(List<ClothingItem> items) {
  return items.fold<double>(0, (sum, item) => sum + item.price);
}

/// Sum of [ClothingItem.wearCount] across the whole wardrobe.
int totalWearCount(List<ClothingItem> items) {
  return items.fold<int>(0, (sum, item) => sum + item.wearCount);
}

/// The mean of every item's own [costPerWear] - not total value divided by
/// total wears, so one expensive-but-heavily-worn item can't single-handedly
/// drag the average down. Returns 0 for an empty wardrobe.
double averageCostPerWear(List<ClothingItem> items) {
  if (items.isEmpty) return 0;
  final total = items.fold<double>(0, (sum, item) => sum + costPerWear(item));
  return total / items.length;
}
