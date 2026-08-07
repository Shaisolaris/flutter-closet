import 'package:flutter_closet/core/logic/date_math.dart';
import 'package:flutter_closet/core/logic/outfit.dart';
import 'package:flutter_closet/core/logic/plan.dart';
import 'package:flutter_closet/core/logic/stats.dart';
import 'package:flutter_closet/core/models/clothing_category.dart';
import 'package:flutter_closet/data/seed_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A fixed anchor so every assertion below is a hand-traceable,
  // deterministic fact rather than "whatever today happens to be".
  final now = DateTime(2026, 8, 7);

  group('seedClothingItems', () {
    test('returns 20 items, deterministically', () {
      final first = seedClothingItems(now);
      final second = seedClothingItems(now);

      expect(first.length, 20);
      expect(first.map((item) => item.id).toList(), second.map((item) => item.id).toList());
      expect(first.map((item) => item.wearCount).toList(), second.map((item) => item.wearCount).toList());
    });

    test('spreads across all 5 categories: 5/4/4/4/3', () {
      final counts = categoryCounts(seedClothingItems(now));
      expect(counts[ClothingCategory.tops], 5);
      expect(counts[ClothingCategory.bottoms], 4);
      expect(counts[ClothingCategory.shoes], 4);
      expect(counts[ClothingCategory.outerwear], 4);
      expect(counts[ClothingCategory.accessories], 3);
    });

    test('aggregate value and wear count match the hand-tallied totals', () {
      final items = seedClothingItems(now);
      // Every seeded price is a whole dollar amount, so these sums are exact.
      expect(totalWardrobeValue(items), 1989.0);
      expect(totalWearCount(items), 215);
    });

    test('most-worn ranking', () {
      final ranked = mostWorn(seedClothingItems(now), limit: 5);
      expect(ranked.map((item) => item.name).toList(), <String>[
        'Dark Wash Jeans',
        'Striped Breton Tee',
        'White Leather Sneakers',
        'Black Puffer Jacket',
        'Black Ankle Boots',
      ]);
    });

    test('least-worn ranking', () {
      final ranked = leastWorn(seedClothingItems(now), limit: 5);
      expect(ranked.map((item) => item.name).toList(), <String>[
        'Silk Scarf',
        'Black Silk Blouse',
        'Gold Hoop Earrings',
        'Pleated Midi Skirt',
        'Strappy Sandals',
      ]);
    });

    test('exactly one item has never been worn', () {
      final never = neverWorn(seedClothingItems(now));
      expect(never.map((item) => item.name).toList(), <String>['Silk Scarf']);
    });

    test('spot check: White Oxford Shirt', () {
      final shirt = seedClothingItems(now).firstWhere((item) => item.name == 'White Oxford Shirt');
      expect(shirt.category, ClothingCategory.tops);
      expect(shirt.color, 'White');
      expect(shirt.brand, 'Northfield & Co.');
      expect(shirt.price, 68.0);
      expect(shirt.wearCount, 14);
      expect(daysBetween(shirt.purchaseDate, now), 400);
      expect(daysBetween(shirt.lastWornDate!, now), 4);
    });
  });

  group('seedOutfits', () {
    test('returns the 4 named outfits with the expected value totals', () {
      final items = seedClothingItems(now);
      final outfits = seedOutfits(now);
      expect(outfits.length, 4);
      expect(outfits.map((outfit) => outfit.name).toList(), <String>[
        'Monday Client Call',
        'Weekend Errands',
        'Date Night',
        'Chilly Weekend',
      ]);

      final byName = {for (final outfit in outfits) outfit.name: outfit};
      expect(outfitTotalValue(byName['Monday Client Call']!, items), 599.0);
      expect(outfitTotalValue(byName['Weekend Errands']!, items), 232.0);
      expect(outfitTotalValue(byName['Date Night']!, items), 270.0);
      expect(outfitTotalValue(byName['Chilly Weekend']!, items), 426.0);
    });

    test('every outfit item is a real, still-existing item', () {
      final items = seedClothingItems(now);
      final knownIds = items.map((item) => item.id).toSet();
      for (final outfit in seedOutfits(now)) {
        expect(outfit.itemIds.every(knownIds.contains), isTrue, reason: '${outfit.name} references a missing item');
      }
    });

    test('items that belong to an outfit share its exact wearCount and lastWornDate', () {
      final items = seedClothingItems(now);
      for (final outfit in seedOutfits(now)) {
        final members = resolveItems(outfit.itemIds, items);
        for (final item in members) {
          expect(item.wearCount, outfit.wearCount, reason: '${item.name} vs ${outfit.name}');
          expect(item.lastWornDate, outfit.lastWornDate, reason: '${item.name} vs ${outfit.name}');
        }
      }
    });

    test('items not in any outfit are exactly the 4 independents', () {
      final outfits = seedOutfits(now);
      final usedIds = <String>{for (final outfit in outfits) ...outfit.itemIds};
      final unused = seedClothingItems(now).where((item) => !usedIds.contains(item.id)).map((item) => item.name);
      expect(unused.toSet(), <String>{'Yellow Linen Top', 'Camel Wool Coat', 'Black Puffer Jacket', 'Silk Scarf'});
    });
  });

  group('seedPlanEntries', () {
    test('4 entries: 2 already worn, today assigned but not worn, one upcoming', () {
      final entries = seedPlanEntries(now);
      expect(entries.length, 4);
      expect(entries.where((entry) => entry.worn).length, 2);
    });

    test('today is "Weekend Errands", assigned but not yet marked worn', () {
      final today = resolveTodayPlan(seedPlanEntries(now), now);
      expect(today, isNotNull);
      expect(today!.worn, isFalse);

      final outfitName = seedOutfits(now).firstWhere((outfit) => outfit.id == today.outfitId).name;
      expect(outfitName, 'Weekend Errands');
    });

    test('yesterday and 4 days ago are already marked worn', () {
      final entries = seedPlanEntries(now);
      final yesterday = resolvePlanForDate(entries, addCalendarDays(now, -1))!;
      final fourDaysAgo = resolvePlanForDate(entries, addCalendarDays(now, -4))!;

      expect(yesterday.worn, isTrue);
      expect(fourDaysAgo.worn, isTrue);
    });

    test('there is an upcoming entry 2 days from now that is not yet worn', () {
      final upcoming = resolvePlanForDate(seedPlanEntries(now), addCalendarDays(now, 2));
      expect(upcoming, isNotNull);
      expect(upcoming!.worn, isFalse);
    });
  });
}
