import 'package:flutter_closet/core/logic/outfit.dart';
import 'package:flutter_closet/core/models/clothing_category.dart';
import 'package:flutter_closet/core/models/clothing_item.dart';
import 'package:flutter_closet/core/models/outfit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final shirt = ClothingItem(
    id: 'i1',
    name: 'Shirt',
    category: ClothingCategory.tops,
    color: 'White',
    brand: 'Brand',
    size: 'M',
    price: 50,
    purchaseDate: DateTime(2026, 1, 1),
    emoji: '👕',
    gradientIndex: 0,
    wearCount: 2,
    lastWornDate: DateTime(2026, 7, 1),
  );
  final pants = ClothingItem(
    id: 'i2',
    name: 'Pants',
    category: ClothingCategory.bottoms,
    color: 'Black',
    brand: 'Brand',
    size: '32',
    price: 70,
    purchaseDate: DateTime(2026, 1, 1),
    emoji: '👖',
    gradientIndex: 1,
    wearCount: 5,
  );
  final shoes = ClothingItem(
    id: 'i3',
    name: 'Shoes',
    category: ClothingCategory.shoes,
    color: 'Brown',
    brand: 'Brand',
    size: '9',
    price: 100,
    purchaseDate: DateTime(2026, 1, 1),
    emoji: '👞',
    gradientIndex: 2,
  );
  final items = <ClothingItem>[shirt, pants, shoes];

  group('validateOutfitItems', () {
    test('empty selection is invalid', () {
      final result = validateOutfitItems(const <String>[], items);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('Pick at least one item.'));
      expect(result.categoriesCovered, isEmpty);
    });

    test('a valid selection has no errors and reports its categories', () {
      final result = validateOutfitItems(<String>['i1', 'i2'], items);
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
      expect(result.categoriesCovered, <ClothingCategory>{ClothingCategory.tops, ClothingCategory.bottoms});
    });

    test('duplicate ids are rejected', () {
      final result = validateOutfitItems(<String>['i1', 'i1'], items);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('The same item is selected more than once.'));
    });

    test('unknown ids are rejected and excluded from categoriesCovered', () {
      final result = validateOutfitItems(<String>['i1', 'ghost'], items);
      expect(result.isValid, isFalse);
      expect(result.errors, contains('1 selected item(s) no longer exist.'));
      expect(result.categoriesCovered, <ClothingCategory>{ClothingCategory.tops});
    });
  });

  group('resolveItems', () {
    test('resolves in the given id order and drops unknown ids', () {
      final resolved = resolveItems(<String>['i2', 'i1', 'missing'], items);
      expect(resolved, <ClothingItem>[pants, shirt]);
    });
  });

  group('buildOutfit', () {
    test('trims the name and normalizes createdDate to a calendar date', () {
      final outfit = buildOutfit(
        id: 'o1',
        name: '  Test Look  ',
        itemIds: <String>['i1', 'i2'],
        createdDate: DateTime(2026, 8, 7, 15, 30),
      );
      expect(outfit.name, 'Test Look');
      expect(outfit.itemIds, <String>['i1', 'i2']);
      expect(outfit.createdDate, DateTime(2026, 8, 7));
      expect(() => outfit.itemIds.add('i3'), throwsUnsupportedError);
    });
  });

  group('outfitTotalValue', () {
    test('sums the price of every resolved item', () {
      final outfit = buildOutfit(
        id: 'o1',
        name: 'Full Look',
        itemIds: <String>['i1', 'i2', 'i3'],
        createdDate: DateTime(2026, 8, 1),
      );
      expect(outfitTotalValue(outfit, items), 220.0);
    });

    test('deleted items contribute nothing', () {
      final outfit = buildOutfit(
        id: 'o2',
        name: 'Partial Look',
        itemIds: <String>['i1', 'deleted-id'],
        createdDate: DateTime(2026, 8, 1),
      );
      expect(outfitTotalValue(outfit, items), 50.0);
    });
  });

  group('outfitLiveItemCount', () {
    test('counts only ids that still resolve', () {
      final outfit = buildOutfit(
        id: 'o3',
        name: 'Look',
        itemIds: <String>['i1', 'i2', 'missing'],
        createdDate: DateTime(2026, 8, 1),
      );
      expect(outfitLiveItemCount(outfit, items), 2);
    });
  });

  group('applyOutfitWear', () {
    test('bumps wearCount and lastWornDate only for items in the outfit', () {
      final outfit = buildOutfit(
        id: 'o4',
        name: 'Weekend',
        itemIds: <String>['i1', 'i3'],
        createdDate: DateTime(2026, 8, 1),
      );
      final wornOn = DateTime(2026, 8, 7);

      final result = applyOutfitWear(outfit, items, wornOn);

      expect(result.length, 3);
      expect(result[0].id, 'i1');
      expect(result[0].wearCount, 3); // 2 + 1
      expect(result[0].lastWornDate, wornOn);

      // Pants were not part of the outfit - untouched, same instance.
      expect(identical(result[1], pants), isTrue);
      expect(result[1].wearCount, 5);

      expect(result[2].id, 'i3');
      expect(result[2].wearCount, 1); // 0 + 1
      expect(result[2].lastWornDate, wornOn);
    });
  });

  group('markOutfitWorn', () {
    test('increments wearCount and sets lastWornDate, preserving everything else', () {
      final outfit = Outfit(
        id: 'o5',
        name: 'Gala Night',
        itemIds: const <String>['i1'],
        createdDate: DateTime(2026, 1, 1),
        wearCount: 3,
      );
      final result = markOutfitWorn(outfit, DateTime(2026, 8, 7));

      expect(result.id, 'o5');
      expect(result.name, 'Gala Night');
      expect(result.itemIds, const <String>['i1']);
      expect(result.createdDate, DateTime(2026, 1, 1));
      expect(result.wearCount, 4);
      expect(result.lastWornDate, DateTime(2026, 8, 7));
    });
  });
}
