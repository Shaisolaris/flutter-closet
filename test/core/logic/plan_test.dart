import 'package:flutter_closet/core/logic/plan.dart';
import 'package:flutter_closet/core/models/plan_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final e1 = PlanEntry(id: 'p1', date: DateTime(2026, 8, 5), outfitId: 'o1', worn: true);
  final e2 = PlanEntry(id: 'p2', date: DateTime(2026, 8, 7), outfitId: 'o2');
  final entries = <PlanEntry>[e1, e2];

  group('assignOutfitToDate', () {
    test('replaces an existing entry on the same date', () {
      final result = assignOutfitToDate(
        entries: entries,
        date: DateTime(2026, 8, 7, 9), // same date as e2, different time
        outfitId: 'o3',
        id: 'p3',
      );

      expect(result.length, 2);
      expect(result, contains(e1));
      expect(result.any((entry) => entry.id == 'p2'), isFalse);

      final replaced = result.firstWhere((entry) => entry.id == 'p3');
      expect(replaced.outfitId, 'o3');
      expect(replaced.date, DateTime(2026, 8, 7));
      expect(replaced.worn, isFalse);
    });

    test('adds a new entry for a date with nothing planned yet', () {
      final result = assignOutfitToDate(entries: entries, date: DateTime(2026, 8, 10), outfitId: 'o4', id: 'p4');
      expect(result.length, 3);
      expect(result, containsAll(<PlanEntry>[e1, e2]));
    });
  });

  group('clearPlanForDate', () {
    test('removes the entry on that date', () {
      final result = clearPlanForDate(entries, DateTime(2026, 8, 5));
      expect(result, <PlanEntry>[e2]);
    });

    test('a no-op when nothing is planned for that date', () {
      final result = clearPlanForDate(entries, DateTime(2026, 1, 1));
      expect(result, <PlanEntry>[e1, e2]);
    });
  });

  group('markPlanWorn', () {
    test('marks only the matching date worn, leaving others untouched', () {
      final result = markPlanWorn(entries, DateTime(2026, 8, 7));

      expect(identical(result[0], e1), isTrue); // untouched instance
      expect(result[1].id, 'p2');
      expect(result[1].worn, isTrue);
      expect(result[1].outfitId, 'o2');
    });

    test('a no-op when no entry matches the date', () {
      final result = markPlanWorn(entries, DateTime(2026, 1, 1));
      expect(identical(result[0], e1), isTrue);
      expect(identical(result[1], e2), isTrue);
    });
  });

  group('resolvePlanForDate', () {
    test('finds the entry regardless of time-of-day', () {
      expect(resolvePlanForDate(entries, DateTime(2026, 8, 5, 23, 0)), e1);
    });

    test('null when nothing is planned', () {
      expect(resolvePlanForDate(entries, DateTime(2026, 1, 1)), isNull);
    });
  });

  group('resolveTodayPlan', () {
    test('delegates to resolvePlanForDate using "now"', () {
      expect(resolveTodayPlan(entries, DateTime(2026, 8, 7, 10)), e2);
    });
  });

  group('entriesInRange', () {
    test('excludes entries outside the range', () {
      expect(entriesInRange(entries, DateTime(2026, 8, 1), DateTime(2026, 8, 6)), <PlanEntry>[e1]);
    });

    test('is inclusive of both endpoints and sorts chronologically', () {
      // Deliberately reversed input order to prove it actually sorts.
      final reversed = <PlanEntry>[e2, e1];
      expect(entriesInRange(reversed, DateTime(2026, 8, 5), DateTime(2026, 8, 7)), <PlanEntry>[e1, e2]);
    });
  });

  group('monthGridDays', () {
    test('August 2026: starts on a Saturday, 31 days, 6-week grid', () {
      final grid = monthGridDays(2026, 8);

      expect(grid.length, 42); // 6 full weeks
      expect(grid.sublist(0, 5), List<DateTime?>.filled(5, null)); // Mon-Fri blank
      expect(grid[5], DateTime(2026, 8, 1)); // Saturday
      expect(grid[35], DateTime(2026, 8, 31)); // Monday
      expect(grid.sublist(36), List<DateTime?>.filled(6, null)); // trailing blanks
    });

    test('February 2026: starts on a Sunday, 28 days, 5-week grid', () {
      final grid = monthGridDays(2026, 2);

      expect(grid.length, 35); // 5 full weeks
      expect(grid.sublist(0, 6), List<DateTime?>.filled(6, null)); // Mon-Sat blank
      expect(grid[6], DateTime(2026, 2, 1)); // Sunday
      expect(grid[33], DateTime(2026, 2, 28)); // Saturday
      expect(grid[34], isNull); // one trailing blank (Sunday)
    });
  });
}
