import 'clothing_category.dart';

/// A single piece of clothing in the wardrobe.
///
/// Closet has no product photography - every item renders [emoji] over the
/// gradient looked up by [gradientIndex] (see `core/constants/gradients.dart`)
/// instead of a photo.
class ClothingItem {
  const ClothingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.color,
    required this.brand,
    required this.size,
    required this.price,
    required this.purchaseDate,
    required this.emoji,
    required this.gradientIndex,
    this.wearCount = 0,
    this.lastWornDate,
  });

  final String id;
  final String name;
  final ClothingCategory category;

  /// A short color label, e.g. "Navy", shown under the item name.
  final String color;

  final String brand;

  /// Free-form size label, e.g. "M", "32x30", "9.5".
  final String size;

  /// Purchase price in US dollars - the numerator of cost-per-wear.
  final double price;

  final DateTime purchaseDate;

  final String emoji;

  /// Index into the shared gradient palette (see `gradientFor`).
  final int gradientIndex;

  /// Number of times this item has been worn, incremented by "Wear today"
  /// on the Plan screen. Never negative.
  final int wearCount;

  /// The most recent date this item was worn, or `null` if it never has been.
  final DateTime? lastWornDate;

  ClothingItem copyWith({
    String? name,
    ClothingCategory? category,
    String? color,
    String? brand,
    String? size,
    double? price,
    DateTime? purchaseDate,
    String? emoji,
    int? gradientIndex,
    int? wearCount,
    DateTime? lastWornDate,
    bool clearLastWornDate = false,
  }) {
    return ClothingItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      emoji: emoji ?? this.emoji,
      gradientIndex: gradientIndex ?? this.gradientIndex,
      wearCount: wearCount ?? this.wearCount,
      lastWornDate: clearLastWornDate ? null : (lastWornDate ?? this.lastWornDate),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'category': category.storageKey,
      'color': color,
      'brand': brand,
      'size': size,
      'price': price,
      'purchaseDate': purchaseDate.toIso8601String(),
      'emoji': emoji,
      'gradientIndex': gradientIndex,
      'wearCount': wearCount,
      'lastWornDate': lastWornDate?.toIso8601String(),
    };
  }

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: clothingCategoryFromKey(json['category'] as String),
      color: json['color'] as String,
      brand: json['brand'] as String,
      size: json['size'] as String,
      price: (json['price'] as num).toDouble(),
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      emoji: json['emoji'] as String,
      gradientIndex: json['gradientIndex'] as int,
      wearCount: json['wearCount'] as int? ?? 0,
      lastWornDate: json['lastWornDate'] == null ? null : DateTime.parse(json['lastWornDate'] as String),
    );
  }

  @override
  String toString() => 'ClothingItem($id, $name, ${category.label}, worn $wearCount x)';
}
