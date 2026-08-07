import '../core/logic/date_math.dart';
import '../core/models/clothing_category.dart';
import '../core/models/clothing_item.dart';
import '../core/models/outfit.dart';
import '../core/models/plan_entry.dart';

/// Deterministic first-run demo data for Closet: 20 wardrobe items spread
/// across all 5 categories, 4 saved outfits built from them, and a handful
/// of plan entries (yesterday and 4 days ago already worn, today assigned
/// but not yet worn, and one upcoming).
///
/// Every function here is pure: given the same [now], it always returns the
/// exact same records (no [DateTime.now()] calls, no randomness). Anchoring
/// every date to [now] (rather than fixed calendar dates) keeps the demo
/// data realistic - purchase dates in the past, wear dates before "today" -
/// no matter what day the app is actually first run on.
///
/// Every item that belongs to a saved outfit shares that outfit's exact
/// [ClothingItem.wearCount] and [ClothingItem.lastWornDate]: since the only
/// way to wear an item in Closet is via "Wear today" on its outfit, pieces
/// that are only ever worn together stay in lockstep. Items not part of any
/// seeded outfit (a top, two outerwear pieces, and one accessory) carry
/// their own independent, still-realistic wear history.
library;

const String _oxfordShirtId = 'item-oxford-shirt';
const String _silkBlouseId = 'item-silk-blouse';
const String _bretonTeeId = 'item-breton-tee';
const String _cashmereSweaterId = 'item-cashmere-sweater';
const String _linenTopId = 'item-linen-top';
const String _darkJeansId = 'item-dark-jeans';
const String _blackTrousersId = 'item-black-trousers';
const String _khakiChinosId = 'item-khaki-chinos';
const String _midiSkirtId = 'item-midi-skirt';
const String _whiteSneakersId = 'item-white-sneakers';
const String _ankleBootsId = 'item-ankle-boots';
const String _suedeLoafersId = 'item-suede-loafers';
const String _strappySandalsId = 'item-strappy-sandals';
const String _woolCoatId = 'item-wool-coat';
const String _denimJacketId = 'item-denim-jacket';
const String _pufferJacketId = 'item-puffer-jacket';
const String _trenchCoatId = 'item-trench-coat';
const String _crossbodyBagId = 'item-crossbody-bag';
const String _silkScarfId = 'item-silk-scarf';
const String _hoopEarringsId = 'item-hoop-earrings';

const String _mondayClientCallId = 'outfit-monday-client-call';
const String _weekendErrandsId = 'outfit-weekend-errands';
const String _dateNightId = 'outfit-date-night';
const String _chillyWeekendId = 'outfit-chilly-weekend';

/// The 20 starter wardrobe items: 5 tops, 4 bottoms, 4 shoes, 4 outerwear,
/// 3 accessories.
List<ClothingItem> seedClothingItems(DateTime now) {
  return <ClothingItem>[
    // --- Tops --------------------------------------------------------------
    ClothingItem(
      id: _oxfordShirtId,
      name: 'White Oxford Shirt',
      category: ClothingCategory.tops,
      color: 'White',
      brand: 'Northfield & Co.',
      size: 'M',
      price: 68,
      purchaseDate: _daysAgo(now, 400),
      emoji: '👕',
      gradientIndex: 0,
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),
    ClothingItem(
      id: _silkBlouseId,
      name: 'Black Silk Blouse',
      category: ClothingCategory.tops,
      color: 'Black',
      brand: 'Marlowe & Finch',
      size: 'S',
      price: 92,
      purchaseDate: _daysAgo(now, 200),
      emoji: '👚',
      gradientIndex: 1,
      wearCount: 3,
      lastWornDate: _daysAgo(now, 15),
    ),
    ClothingItem(
      id: _bretonTeeId,
      name: 'Striped Breton Tee',
      category: ClothingCategory.tops,
      color: 'Navy/White',
      brand: 'Cove Supply Co.',
      size: 'M',
      price: 34,
      purchaseDate: _daysAgo(now, 150),
      emoji: '🎽',
      gradientIndex: 2,
      wearCount: 22,
      lastWornDate: _daysAgo(now, 1),
    ),
    ClothingItem(
      id: _cashmereSweaterId,
      name: 'Charcoal Cashmere Sweater',
      category: ClothingCategory.tops,
      color: 'Charcoal',
      brand: 'Ashgrove',
      size: 'M',
      price: 145,
      purchaseDate: _daysAgo(now, 500),
      emoji: '👕',
      gradientIndex: 3,
      wearCount: 9,
      lastWornDate: _daysAgo(now, 9),
    ),
    ClothingItem(
      id: _linenTopId,
      name: 'Yellow Linen Top',
      category: ClothingCategory.tops,
      color: 'Butter Yellow',
      brand: 'Petal & Pine',
      size: 'S',
      price: 54,
      purchaseDate: _daysAgo(now, 60),
      emoji: '👚',
      gradientIndex: 4,
      wearCount: 3,
      lastWornDate: _daysAgo(now, 20),
    ),

    // --- Bottoms -------------------------------------------------------------
    ClothingItem(
      id: _darkJeansId,
      name: 'Dark Wash Jeans',
      category: ClothingCategory.bottoms,
      color: 'Indigo',
      brand: 'Rivermark Denim',
      size: '30',
      price: 88,
      purchaseDate: _daysAgo(now, 450),
      emoji: '👖',
      gradientIndex: 5,
      wearCount: 22,
      lastWornDate: _daysAgo(now, 1),
    ),
    ClothingItem(
      id: _blackTrousersId,
      name: 'Tailored Black Trousers',
      category: ClothingCategory.bottoms,
      color: 'Black',
      brand: 'Marlowe & Finch',
      size: '8',
      price: 76,
      purchaseDate: _daysAgo(now, 300),
      emoji: '👖',
      gradientIndex: 6,
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),
    ClothingItem(
      id: _khakiChinosId,
      name: 'Khaki Chinos',
      category: ClothingCategory.bottoms,
      color: 'Khaki',
      brand: 'Northfield & Co.',
      size: '32x30',
      price: 58,
      purchaseDate: _daysAgo(now, 220),
      emoji: '👖',
      gradientIndex: 7,
      wearCount: 9,
      lastWornDate: _daysAgo(now, 9),
    ),
    ClothingItem(
      id: _midiSkirtId,
      name: 'Pleated Midi Skirt',
      category: ClothingCategory.bottoms,
      color: 'Sage Green',
      brand: 'Fernwood',
      size: 'S',
      price: 64,
      purchaseDate: _daysAgo(now, 90),
      emoji: '👗',
      gradientIndex: 8,
      wearCount: 3,
      lastWornDate: _daysAgo(now, 15),
    ),

    // --- Shoes -----------------------------------------------------------
    ClothingItem(
      id: _whiteSneakersId,
      name: 'White Leather Sneakers',
      category: ClothingCategory.shoes,
      color: 'White',
      brand: 'Amble Works',
      size: '9',
      price: 110,
      purchaseDate: _daysAgo(now, 260),
      emoji: '👟',
      gradientIndex: 9,
      wearCount: 22,
      lastWornDate: _daysAgo(now, 1),
    ),
    ClothingItem(
      id: _ankleBootsId,
      name: 'Black Ankle Boots',
      category: ClothingCategory.shoes,
      color: 'Black',
      brand: 'Harbor & Hide',
      size: '8',
      price: 135,
      purchaseDate: _daysAgo(now, 320),
      emoji: '👢',
      gradientIndex: 0,
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),
    ClothingItem(
      id: _suedeLoafersId,
      name: 'Tan Suede Loafers',
      category: ClothingCategory.shoes,
      color: 'Tan',
      brand: 'Harbor & Hide',
      size: '9.5',
      price: 128,
      purchaseDate: _daysAgo(now, 100),
      emoji: '👞',
      gradientIndex: 1,
      wearCount: 9,
      lastWornDate: _daysAgo(now, 9),
    ),
    ClothingItem(
      id: _strappySandalsId,
      name: 'Strappy Sandals',
      category: ClothingCategory.shoes,
      color: 'Nude',
      brand: 'Sable Row',
      size: '8',
      price: 72,
      purchaseDate: _daysAgo(now, 80),
      emoji: '👡',
      gradientIndex: 2,
      wearCount: 3,
      lastWornDate: _daysAgo(now, 15),
    ),

    // --- Outerwear -----------------------------------------------------------
    ClothingItem(
      id: _woolCoatId,
      name: 'Camel Wool Coat',
      category: ClothingCategory.outerwear,
      color: 'Camel',
      brand: 'Ashgrove',
      size: 'M',
      price: 220,
      purchaseDate: _daysAgo(now, 500),
      emoji: '🧥',
      gradientIndex: 3,
      wearCount: 12,
      lastWornDate: _daysAgo(now, 210),
    ),
    ClothingItem(
      id: _denimJacketId,
      name: 'Denim Jacket',
      category: ClothingCategory.outerwear,
      color: 'Light Wash',
      brand: 'Rivermark Denim',
      size: 'M',
      price: 95,
      purchaseDate: _daysAgo(now, 400),
      emoji: '🧥',
      gradientIndex: 4,
      wearCount: 9,
      lastWornDate: _daysAgo(now, 9),
    ),
    ClothingItem(
      id: _pufferJacketId,
      name: 'Black Puffer Jacket',
      category: ClothingCategory.outerwear,
      color: 'Black',
      brand: 'Windrow Studio',
      size: 'M',
      price: 150,
      purchaseDate: _daysAgo(now, 250),
      emoji: '🧥',
      gradientIndex: 5,
      wearCount: 16,
      lastWornDate: _daysAgo(now, 195),
    ),
    ClothingItem(
      id: _trenchCoatId,
      name: 'Trench Coat',
      category: ClothingCategory.outerwear,
      color: 'Beige',
      brand: 'Marlowe & Finch',
      size: 'S',
      price: 175,
      purchaseDate: _daysAgo(now, 130),
      emoji: '🧥',
      gradientIndex: 6,
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),

    // --- Accessories ---------------------------------------------------------
    ClothingItem(
      id: _crossbodyBagId,
      name: 'Leather Crossbody Bag',
      category: ClothingCategory.accessories,
      color: 'Cognac',
      brand: 'Sable Row',
      size: 'One Size',
      price: 145,
      purchaseDate: _daysAgo(now, 300),
      emoji: '👜',
      gradientIndex: 7,
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),
    ClothingItem(
      id: _silkScarfId,
      name: 'Silk Scarf',
      category: ClothingCategory.accessories,
      color: 'Blush Floral',
      brand: 'Petal & Pine',
      size: 'One Size',
      price: 38,
      purchaseDate: _daysAgo(now, 70),
      emoji: '🧣',
      gradientIndex: 8,
      wearCount: 0,
    ),
    ClothingItem(
      id: _hoopEarringsId,
      name: 'Gold Hoop Earrings',
      category: ClothingCategory.accessories,
      color: 'Gold',
      brand: 'Copperline',
      size: 'One Size',
      price: 42,
      purchaseDate: _daysAgo(now, 500),
      emoji: '💍',
      gradientIndex: 9,
      wearCount: 3,
      lastWornDate: _daysAgo(now, 15),
    ),
  ];
}

/// The 4 starter outfits, each built entirely from [seedClothingItems].
List<Outfit> seedOutfits(DateTime now) {
  return <Outfit>[
    Outfit(
      id: _mondayClientCallId,
      name: 'Monday Client Call',
      itemIds: const <String>[_oxfordShirtId, _blackTrousersId, _ankleBootsId, _trenchCoatId, _crossbodyBagId],
      createdDate: _daysAgo(now, 110),
      wearCount: 14,
      lastWornDate: _daysAgo(now, 4),
    ),
    Outfit(
      id: _weekendErrandsId,
      name: 'Weekend Errands',
      itemIds: const <String>[_bretonTeeId, _darkJeansId, _whiteSneakersId],
      createdDate: _daysAgo(now, 140),
      wearCount: 22,
      lastWornDate: _daysAgo(now, 1),
    ),
    Outfit(
      id: _dateNightId,
      name: 'Date Night',
      itemIds: const <String>[_silkBlouseId, _midiSkirtId, _strappySandalsId, _hoopEarringsId],
      createdDate: _daysAgo(now, 75),
      wearCount: 3,
      lastWornDate: _daysAgo(now, 15),
    ),
    Outfit(
      id: _chillyWeekendId,
      name: 'Chilly Weekend',
      itemIds: const <String>[_cashmereSweaterId, _khakiChinosId, _suedeLoafersId, _denimJacketId],
      createdDate: _daysAgo(now, 95),
      wearCount: 9,
      lastWornDate: _daysAgo(now, 9),
    ),
  ];
}

/// A handful of plan entries: "Weekend Errands" worn yesterday and assigned
/// again for today (not yet marked worn - try "Wear today"), "Monday Client
/// Call" worn 4 days ago, and "Date Night" already lined up two days out.
List<PlanEntry> seedPlanEntries(DateTime now) {
  return <PlanEntry>[
    PlanEntry(id: 'plan-four-days-ago', date: _daysAgo(now, 4), outfitId: _mondayClientCallId, worn: true),
    PlanEntry(id: 'plan-yesterday', date: _daysAgo(now, 1), outfitId: _weekendErrandsId, worn: true),
    PlanEntry(id: 'plan-today', date: dateOnly(now), outfitId: _weekendErrandsId, worn: false),
    PlanEntry(id: 'plan-upcoming', date: _daysFromNow(now, 2), outfitId: _dateNightId, worn: false),
  ];
}

DateTime _daysAgo(DateTime now, int days) => addCalendarDays(dateOnly(now), -days);

DateTime _daysFromNow(DateTime now, int days) => addCalendarDays(dateOnly(now), days);
