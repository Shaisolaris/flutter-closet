import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/logic/outfit.dart';
import '../core/logic/plan.dart';
import '../core/logic/stats.dart';
import '../core/models/clothing_category.dart';
import '../core/models/clothing_item.dart';
import '../core/models/outfit.dart';
import '../core/models/plan_entry.dart';
import 'closet_repository.dart';
import 'seed_data.dart';

/// Overridden with a real instance in `main.dart` once
/// `SharedPreferences.getInstance()` resolves. Left unimplemented here so
/// any accidental read before that override is applied fails loudly instead
/// of silently returning bad data.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden with a real SharedPreferences '
    'instance before the app runs - see main().',
  );
});

/// Which bottom-nav tab is showing on [RootShell]. A provider rather than
/// local widget state so any screen can jump to another tab - e.g. an empty
/// Plan screen's "Build an outfit first" action jumping to Outfits.
final rootTabIndexProvider = StateProvider<int>((ref) => 0);

final closetRepositoryProvider = Provider<ClosetRepository>((ref) {
  return SharedPreferencesClosetRepository(ref.watch(sharedPreferencesProvider));
});

// Wardrobe items --------------------------------------------------------------

class ItemsNotifier extends AsyncNotifier<List<ClothingItem>> {
  @override
  Future<List<ClothingItem>> build() async {
    final repository = ref.watch(closetRepositoryProvider);
    final existing = await repository.loadItems();
    if (existing.isNotEmpty) return existing;

    final seeded = seedClothingItems(DateTime.now());
    await repository.saveItems(seeded);
    return seeded;
  }

  Future<void> _persist(List<ClothingItem> items) async {
    state = AsyncData<List<ClothingItem>>(items);
    await ref.read(closetRepositoryProvider).saveItems(items);
  }

  Future<void> addItem(ClothingItem item) async {
    final current = state.valueOrNull ?? const <ClothingItem>[];
    await _persist(<ClothingItem>[...current, item]);
  }

  Future<void> updateItem(ClothingItem item) async {
    final current = state.valueOrNull ?? const <ClothingItem>[];
    final updated = <ClothingItem>[for (final existing in current) existing.id == item.id ? item : existing];
    await _persist(updated);
  }

  Future<void> removeItem(String itemId) async {
    final current = state.valueOrNull ?? const <ClothingItem>[];
    await _persist(current.where((item) => item.id != itemId).toList());
  }

  /// Applies [outfit]'s "worn today" bump (see
  /// `core/logic/outfit.dart#applyOutfitWear`) to every item it references.
  Future<void> applyWearFromOutfit(Outfit outfit, DateTime wornOn) async {
    final current = state.valueOrNull ?? const <ClothingItem>[];
    await _persist(applyOutfitWear(outfit, current, wornOn));
  }
}

final itemsProvider = AsyncNotifierProvider<ItemsNotifier, List<ClothingItem>>(ItemsNotifier.new);

/// Looks up a single item by id, or `null` if it doesn't exist (e.g. it was
/// since deleted).
final itemByIdProvider = Provider.family<ClothingItem?, String>((ref, id) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
});

// Wardrobe screen: category filter -----------------------------------------

/// `null` means "All categories".
final selectedCategoryProvider = StateProvider<ClothingCategory?>((ref) => null);

final filteredItemsProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  final category = ref.watch(selectedCategoryProvider);
  final filtered = category == null ? List<ClothingItem>.of(items) : items.where((item) => item.category == category).toList();
  return filtered..sort((a, b) => a.name.compareTo(b.name));
});

// Outfits -----------------------------------------------------------------

class OutfitsNotifier extends AsyncNotifier<List<Outfit>> {
  @override
  Future<List<Outfit>> build() async {
    final repository = ref.watch(closetRepositoryProvider);
    final existing = await repository.loadOutfits();
    if (existing.isNotEmpty) return existing;

    final seeded = seedOutfits(DateTime.now());
    await repository.saveOutfits(seeded);
    return seeded;
  }

  Future<void> _persist(List<Outfit> outfits) async {
    state = AsyncData<List<Outfit>>(outfits);
    await ref.read(closetRepositoryProvider).saveOutfits(outfits);
  }

  Future<void> addOutfit(Outfit outfit) async {
    final current = state.valueOrNull ?? const <Outfit>[];
    await _persist(<Outfit>[...current, outfit]);
  }

  Future<void> removeOutfit(String outfitId) async {
    final current = state.valueOrNull ?? const <Outfit>[];
    await _persist(current.where((outfit) => outfit.id != outfitId).toList());
  }

  /// Bumps [outfitId]'s own wear counter (see
  /// `core/logic/outfit.dart#markOutfitWorn`). A no-op if the id no longer
  /// exists.
  Future<void> markWorn(String outfitId, DateTime wornOn) async {
    final current = state.valueOrNull ?? const <Outfit>[];
    final updated = <Outfit>[
      for (final outfit in current) outfit.id == outfitId ? markOutfitWorn(outfit, wornOn) : outfit,
    ];
    await _persist(updated);
  }
}

final outfitsProvider = AsyncNotifierProvider<OutfitsNotifier, List<Outfit>>(OutfitsNotifier.new);

final outfitByIdProvider = Provider.family<Outfit?, String>((ref, id) {
  final outfits = ref.watch(outfitsProvider).valueOrNull ?? const <Outfit>[];
  for (final outfit in outfits) {
    if (outfit.id == id) return outfit;
  }
  return null;
});

// Day plan ------------------------------------------------------------------

class PlanEntriesNotifier extends AsyncNotifier<List<PlanEntry>> {
  @override
  Future<List<PlanEntry>> build() async {
    final repository = ref.watch(closetRepositoryProvider);
    final existing = await repository.loadPlanEntries();
    if (existing.isNotEmpty) return existing;

    final seeded = seedPlanEntries(DateTime.now());
    await repository.savePlanEntries(seeded);
    return seeded;
  }

  Future<void> _persist(List<PlanEntry> entries) async {
    state = AsyncData<List<PlanEntry>>(entries);
    await ref.read(closetRepositoryProvider).savePlanEntries(entries);
  }

  /// Assigns [outfitId] to [date], replacing any outfit already planned for
  /// that day.
  Future<void> assignOutfit(DateTime date, String outfitId) async {
    final current = state.valueOrNull ?? const <PlanEntry>[];
    final updated = assignOutfitToDate(
      entries: current,
      date: date,
      outfitId: outfitId,
      id: 'plan-${date.toIso8601String()}-${current.length}',
    );
    await _persist(updated);
  }

  /// Removes whatever is planned for [date], if anything.
  Future<void> clearDate(DateTime date) async {
    final current = state.valueOrNull ?? const <PlanEntry>[];
    await _persist(clearPlanForDate(current, date));
  }

  /// "Wear today": marks [date]'s plan entry worn and bumps both the
  /// outfit's and its items' wear counters. Safe to call more than once -
  /// a day that is already marked worn, or has no plan entry at all, is a
  /// no-op.
  Future<void> markWornForDate(DateTime date) async {
    final current = state.valueOrNull ?? const <PlanEntry>[];
    final entry = resolvePlanForDate(current, date);
    if (entry == null || entry.worn) return;

    final outfits = ref.read(outfitsProvider).valueOrNull ?? const <Outfit>[];
    Outfit? outfit;
    for (final candidate in outfits) {
      if (candidate.id == entry.outfitId) {
        outfit = candidate;
        break;
      }
    }
    if (outfit == null) return;

    await _persist(markPlanWorn(current, date));
    await ref.read(itemsProvider.notifier).applyWearFromOutfit(outfit, date);
    await ref.read(outfitsProvider.notifier).markWorn(outfit.id, date);
  }
}

final planEntriesProvider = AsyncNotifierProvider<PlanEntriesNotifier, List<PlanEntry>>(PlanEntriesNotifier.new);

/// The plan entry for [date], or `null` if nothing is assigned yet.
final planForDateProvider = Provider.family<PlanEntry?, DateTime>((ref, date) {
  final entries = ref.watch(planEntriesProvider).valueOrNull ?? const <PlanEntry>[];
  return resolvePlanForDate(entries, date);
});

/// What's planned for "today", refreshed against the device clock.
final todayPlanProvider = Provider<PlanEntry?>((ref) {
  final entries = ref.watch(planEntriesProvider).valueOrNull ?? const <PlanEntry>[];
  return resolveTodayPlan(entries, DateTime.now());
});

/// The date selected on the Plan screen's calendar - defaults to today.
final selectedPlanDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// The month currently shown on the Plan screen's calendar grid - defaults
/// to the current month.
final visibleMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

// Stats ---------------------------------------------------------------------

final mostWornProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return mostWorn(items);
});

final leastWornProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return leastWorn(items);
});

final neverWornProvider = Provider<List<ClothingItem>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return neverWorn(items);
});

final categoryCountsProvider = Provider<Map<ClothingCategory, int>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return categoryCounts(items);
});

final categoryValueProvider = Provider<Map<ClothingCategory, double>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return categoryValue(items);
});

final totalWardrobeValueProvider = Provider<double>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return totalWardrobeValue(items);
});

final averageCostPerWearProvider = Provider<double>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return averageCostPerWear(items);
});

final totalWearCountProvider = Provider<int>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <ClothingItem>[];
  return totalWearCount(items);
});
