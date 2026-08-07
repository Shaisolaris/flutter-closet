# Closet

A wardrobe and outfit planner built with Flutter. Closet catalogs every piece you
own, lets you build named outfits out of them, plan what to wear on the calendar,
and see the numbers behind your closet - most and least worn, cost-per-wear, and
a category breakdown.

**Live preview:** https://shaisolaris.github.io/flutter-closet/

## Screens

| Screen | What it does |
| --- | --- |
| **Wardrobe** | Every item as a gradient+emoji tile with its name and wear count, filterable by category (Tops/Bottoms/Shoes/Outerwear/Accessories). Tap a tile for its full detail - brand, size, price, cost-per-wear, last worn - or add a new item. |
| **Outfits** | Saved outfits shown as clustered item art with their item count and total value. The builder lets you name an outfit and pick one or more items from each category section, with a live selection summary. |
| **Plan** | A month calendar for assigning an outfit to any day - dates with something planned get a dot, filled once it's been worn. The selected day's card lets you assign, change, or clear its outfit, and "Wear today" bumps the wear count of every item in that day's outfit at once. |
| **Stats** | Wardrobe value, average cost-per-wear, and total wears at a glance, a hand-drawn category breakdown donut, most/least-worn rankings, and a called-out list of anything you've never worn. |

Navigation is a bottom bar with four tabs: **Wardrobe**, **Outfits**, **Plan**, **Stats**.

## Architecture

```
lib/
  main.dart                  Entry point - loads SharedPreferences, wires ProviderScope
  app.dart                   MaterialApp, Material 3 theme (light + dark), bottom-nav shell
  core/
    models/                  Plain, JSON-serializable data classes (ClothingItem, Outfit, PlanEntry)
    logic/                   Pure, Flutter-free business logic (see Testing below)
    constants/                Gradient palette, category colors, date/money formatting, nav tab indices
    widgets/                  Small shared UI (item art, empty state, section header)
    utils/                    Dependency-free ID generation
  data/
    closet_repository.dart   Storage interface + a shared_preferences-backed implementation
    seed_data.dart             Deterministic first-run demo data (pure functions of "now")
    providers.dart             Riverpod providers/notifiers wiring the repository to the UI
  features/
    wardrobe/   screen + widgets   Filterable grid, add-item form, item detail sheet
    outfits/    screen + widgets   Outfit cards, the category-by-category builder
    plan/       screen + widgets   Month calendar, day detail, outfit-assignment sheet
    stats/      screen + widgets   Summary tiles, category donut (CustomPainter), ranked lists
```

State management is [flutter_riverpod], using `AsyncNotifier`s that load from - and
persist back to - a small `ClosetRepository` abstraction. The UI never talks to
`shared_preferences` directly, which keeps the storage layer swappable and easy to
fake in tests. Every record type (items, outfits, plan entries) is stored as JSON
under its own key.

The **outfit, stats, and day-plan math is pure Dart** with no Flutter dependency -
it lives entirely under `lib/core/logic/` and is exercised directly by unit tests,
independent of widgets or storage:

- `outfit.dart` - builds and validates an outfit from a candidate set of item ids,
  resolves ids against the live wardrobe, computes an outfit's total value, and
  applies "worn today" to its items.
- `stats.dart` - cost-per-wear (`price / max(1, wearCount)`), most/least-worn
  rankings, and per-category counts and value.
- `plan.dart` - assigns an outfit to a calendar date (one outfit per day, replacing
  whatever was there), resolves what's planned for a date (including "today"), and
  builds the blank-padded day grid the month calendar renders.

"Wear today" is a single guarded action: it marks the day's plan entry worn, bumps
every item in that day's outfit, and bumps the outfit's own counter - all three in
lockstep, and a no-op if that day has already been marked worn.

## Testing

```
test/
  core/logic/
    outfit_test.dart          Validation, resolution, total value, applying wear
    stats_test.dart           Cost-per-wear, rankings and their tie-breaks, category math
    plan_test.dart            Assign/clear/mark-worn, date resolution, the month grid
    date_math_test.dart       Calendar-day arithmetic across month and year boundaries
  data/
    seed_data_test.dart       The seed is deterministic, and its totals, rankings, and
                               outfit/item consistency match a fully hand-tallied breakdown
  widget_test.dart            App launches, tabs navigate, category filtering, and the
                               full "Wear today" flow end to end
```

Every pure-logic test asserts a **hand-traced expected value** - for example, the
seeded wardrobe's total value is checked against `$1,989.00`, added up by hand from
each of the 20 seeded prices, not just against whatever the function happens to
return.

```bash
flutter test
```

## Run it

```bash
flutter pub get
flutter run                          # any connected device/simulator
flutter run -d chrome                # web
flutter build web --base-href /flutter-closet/
```

## Tech stack

- Flutter 3.24+, null-safe Dart, Material 3 (seed color `#DB2777`, light + dark)
- [flutter_riverpod] for state management
- `shared_preferences` for local, on-device persistence
- Zero third-party UI or date-formatting dependencies

[flutter_riverpod]: https://pub.dev/packages/flutter_riverpod

## License

MIT - see [LICENSE](LICENSE).

---

Author: **Shai**
