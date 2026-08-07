import 'package:flutter_closet/core/logic/stats.dart';
import 'package:flutter_closet/core/models/clothing_category.dart';
import 'package:flutter_closet/core/models/clothing_item.dart';
import 'package:flutter_test/flutter_test.dart';

ClothingItem _item(String id, String name, ClothingCategory category, double price, int wearCount) {
  return ClothingItem(
    id: id,
    name: name,
    category: category,
    color: 'Color',
    brand: 'Brand',
    size: 'M',
    price: price,
    purchaseDate: DateTime(2026, 1, 1),
    emoji: '👕',
    gradientIndex: 0,
    wearCount: wearCount,
  );
}

void main() {
  // costPerWear: 100/2=50, 60/3=20, 90/max(1,0)=90, 40/max(1,0)=40.
  final alpha = _item('a', 'Alpha Jacket', ClothingCategory.outerwear, 100, 2);
  final beta = _item('b', 'Beta Shirt', ClothingCategory.tops, 60, 3);
  final gamma = _item('c', 'Gamma Shoes', ClothingCategory.shoes, 90, 0);
  final delta = _item('d', 'Delta Shirt', ClothingCategory.tops, 40, 0);
  final items = <ClothingItem>[alpha, beta, gamma, delta];

  group('costPerWear', () {
    test('divides price by wear count', () {
      expect(costPerWear(alpha), 50.0);
      expect(costPerWear(beta), 20.0);
    });

    test('floors wear count at 1 so a never-worn item is not a division by zero', () {
      expect(costPerWear(gamma), 90.0);
      expect(costPerWear(delta), 40.0);
    });
  });

  group('mostWorn', () {
    test('sorts most-worn first and respects the limit', () {
      expect(mostWorn(items, limit: 2).map((i) => i.name).toList(), <String>['Beta Shirt', 'Alpha Jacket']);
    });

    test('ties break alphabetically by name', () {
      expect(mostWorn(items, limit: 10).map((i) => i.name).toList(), <String>[
        'Beta Shirt',
        'Alpha Jacket',
        'Delta Shirt',
        'Gamma Shoes',
      ]);
    });
  });

  group('leastWorn', () {
    test('sorts least-worn first, ties broken alphabetically', () {
      expect(leastWorn(items, limit: 2).map((i) => i.name).toList(), <String>['Delta Shirt', 'Gamma Shoes']);
    });

    test('full ranking', () {
      expect(leastWorn(items, limit: 10).map((i) => i.name).toList(), <String>[
        'Delta Shirt',
        'Gamma Shoes',
        'Alpha Jacket',
        'Beta Shirt',
      ]);
    });
  });

  group('tie-breaking is alphabetical, independent of input order', () {
    final zebra = _item('x', 'Zebra Top', ClothingCategory.tops, 10, 5);
    final apple = _item('y', 'Apple Top', ClothingCategory.tops, 10, 5);

    test('mostWorn', () {
      expect(mostWorn(<ClothingItem>[zebra, apple]).map((i) => i.name).toList(), <String>['Apple Top', 'Zebra Top']);
    });

    test('leastWorn', () {
      expect(leastWorn(<ClothingItem>[zebra, apple]).map((i) => i.name).toList(), <String>['Apple Top', 'Zebra Top']);
    });
  });

  group('neverWorn', () {
    test('keeps original list order, unlike mostWorn/leastWorn', () {
      // gamma (index 2) precedes delta (index 3) in `items`, even though
      // delta sorts before gamma alphabetically.
      expect(neverWorn(items), <ClothingItem>[gamma, delta]);
    });
  });

  group('categoryCounts', () {
    test('counts every category, including zero-count ones', () {
      final counts = categoryCounts(items);
      expect(counts[ClothingCategory.tops], 2);
      expect(counts[ClothingCategory.shoes], 1);
      expect(counts[ClothingCategory.outerwear], 1);
      expect(counts[ClothingCategory.bottoms], 0);
      expect(counts[ClothingCategory.accessories], 0);
    });
  });

  group('categoryValue', () {
    test('sums price per category', () {
      final totals = categoryValue(items);
      expect(totals[ClothingCategory.tops], 100.0); // 60 + 40
      expect(totals[ClothingCategory.shoes], 90.0);
      expect(totals[ClothingCategory.outerwear], 100.0);
      expect(totals[ClothingCategory.bottoms], 0.0);
    });
  });

  group('totalWardrobeValue', () {
    test('sums every item price', () => expect(totalWardrobeValue(items), 290.0));
  });

  group('totalWearCount', () {
    test('sums every item wearCount', () => expect(totalWearCount(items), 5));
  });

  group('averageCostPerWear', () {
    test('mean of each item\'s own cost-per-wear', () {
      // (50 + 20 + 90 + 40) / 4 = 50.
      expect(averageCostPerWear(items), 50.0);
    });

    test('zero for an empty wardrobe', () {
      expect(averageCostPerWear(const <ClothingItem>[]), 0.0);
    });
  });
}
