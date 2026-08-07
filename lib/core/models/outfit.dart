/// A named combination of wardrobe items, e.g. "Monday Client Call" built
/// from a blazer, trousers, and loafers.
///
/// Outfits are read-only reference data plus a couple of mutable counters
/// once saved - see `data/seed_data.dart` for the starting set and
/// `core/logic/outfit.dart` for the pure build/validate/value math.
class Outfit {
  const Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.createdDate,
    this.wearCount = 0,
    this.lastWornDate,
  });

  final String id;
  final String name;

  /// Ids of the [ClothingItem]s that make up this outfit. May reference an
  /// item that has since been deleted - resolve through
  /// `core/logic/outfit.dart#resolveItems`, which silently drops those,
  /// rather than assuming every id is still live.
  final List<String> itemIds;

  final DateTime createdDate;

  /// Number of times this outfit has been marked worn via "Wear today".
  final int wearCount;

  final DateTime? lastWornDate;

  Outfit copyWith({
    String? name,
    List<String>? itemIds,
    DateTime? createdDate,
    int? wearCount,
    DateTime? lastWornDate,
  }) {
    return Outfit(
      id: id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      createdDate: createdDate ?? this.createdDate,
      wearCount: wearCount ?? this.wearCount,
      lastWornDate: lastWornDate ?? this.lastWornDate,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'itemIds': itemIds,
      'createdDate': createdDate.toIso8601String(),
      'wearCount': wearCount,
      'lastWornDate': lastWornDate?.toIso8601String(),
    };
  }

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      id: json['id'] as String,
      name: json['name'] as String,
      itemIds: (json['itemIds'] as List<dynamic>).map((id) => id as String).toList(),
      createdDate: DateTime.parse(json['createdDate'] as String),
      wearCount: json['wearCount'] as int? ?? 0,
      lastWornDate: json['lastWornDate'] == null ? null : DateTime.parse(json['lastWornDate'] as String),
    );
  }

  @override
  String toString() => 'Outfit($id, $name, ${itemIds.length} items)';
}
