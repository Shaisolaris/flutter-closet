/// One calendar day's planned outfit.
///
/// At most one [PlanEntry] exists per date - assigning a new outfit to a
/// date that already has one replaces it (see
/// `core/logic/plan.dart#assignOutfitToDate`).
class PlanEntry {
  const PlanEntry({required this.id, required this.date, required this.outfitId, this.worn = false});

  final String id;

  /// Date-only (time-of-day is always normalized to midnight).
  final DateTime date;

  final String outfitId;

  /// Whether "Wear today" has already been applied for this entry. Guards
  /// against double-counting wear if the button is somehow tapped twice.
  final bool worn;

  PlanEntry copyWith({DateTime? date, String? outfitId, bool? worn}) {
    return PlanEntry(
      id: id,
      date: date ?? this.date,
      outfitId: outfitId ?? this.outfitId,
      worn: worn ?? this.worn,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'id': id, 'date': date.toIso8601String(), 'outfitId': outfitId, 'worn': worn};
  }

  factory PlanEntry.fromJson(Map<String, dynamic> json) {
    return PlanEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      outfitId: json['outfitId'] as String,
      worn: json['worn'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'PlanEntry($id, $date, outfit=$outfitId, worn=$worn)';
}
