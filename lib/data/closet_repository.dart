import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/clothing_item.dart';
import '../core/models/outfit.dart';
import '../core/models/plan_entry.dart';

/// Persistence contract for Closet's data. The UI and Riverpod notifiers
/// only ever talk to this interface, never to `shared_preferences` directly -
/// that keeps the storage mechanism swappable (and easy to fake in tests).
abstract class ClosetRepository {
  Future<List<ClothingItem>> loadItems();
  Future<void> saveItems(List<ClothingItem> items);

  Future<List<Outfit>> loadOutfits();
  Future<void> saveOutfits(List<Outfit> outfits);

  Future<List<PlanEntry>> loadPlanEntries();
  Future<void> savePlanEntries(List<PlanEntry> entries);

  /// Wipes every stored Closet key, restoring the app to a first-run state.
  Future<void> clearAll();
}

/// [ClosetRepository] backed by `shared_preferences`, with each record type
/// stored as a single JSON-encoded string under its own key.
class SharedPreferencesClosetRepository implements ClosetRepository {
  SharedPreferencesClosetRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String itemsKey = 'closet.items.v1';
  static const String outfitsKey = 'closet.outfits.v1';
  static const String planEntriesKey = 'closet.plan_entries.v1';

  @override
  Future<List<ClothingItem>> loadItems() async {
    final decoded = _readList(itemsKey);
    if (decoded == null) return const <ClothingItem>[];
    return decoded.map(ClothingItem.fromJson).toList();
  }

  @override
  Future<void> saveItems(List<ClothingItem> items) {
    return _writeList(itemsKey, items.map((item) => item.toJson()).toList());
  }

  @override
  Future<List<Outfit>> loadOutfits() async {
    final decoded = _readList(outfitsKey);
    if (decoded == null) return const <Outfit>[];
    return decoded.map(Outfit.fromJson).toList();
  }

  @override
  Future<void> saveOutfits(List<Outfit> outfits) {
    return _writeList(outfitsKey, outfits.map((outfit) => outfit.toJson()).toList());
  }

  @override
  Future<List<PlanEntry>> loadPlanEntries() async {
    final decoded = _readList(planEntriesKey);
    if (decoded == null) return const <PlanEntry>[];
    return decoded.map(PlanEntry.fromJson).toList();
  }

  @override
  Future<void> savePlanEntries(List<PlanEntry> entries) {
    return _writeList(planEntriesKey, entries.map((entry) => entry.toJson()).toList());
  }

  @override
  Future<void> clearAll() async {
    await _prefs.remove(itemsKey);
    await _prefs.remove(outfitsKey);
    await _prefs.remove(planEntriesKey);
  }

  List<Map<String, dynamic>>? _readList(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((entry) => entry as Map<String, dynamic>).toList();
  }

  Future<void> _writeList(String key, List<Map<String, dynamic>> value) {
    return _prefs.setString(key, jsonEncode(value));
  }
}
