import '../models/plan_entry.dart';
import 'date_math.dart';

/// Pure day-plan math: assigning an outfit to a calendar date, resolving
/// what is planned for a given date (including "today"), and generating the
/// blank-padded day grid a month calendar renders. Nothing here depends on
/// Flutter or storage.

/// Returns a new list with [outfitId] assigned to [date] under [id],
/// replacing any existing entry already on that date - a day can only have
/// one planned outfit at a time. [entries] is left untouched.
List<PlanEntry> assignOutfitToDate({
  required List<PlanEntry> entries,
  required DateTime date,
  required String outfitId,
  required String id,
}) {
  final normalizedDate = dateOnly(date);
  final withoutThatDay = entries.where((entry) => !isSameDate(entry.date, normalizedDate)).toList();
  return <PlanEntry>[...withoutThatDay, PlanEntry(id: id, date: normalizedDate, outfitId: outfitId)];
}

/// Returns a new list with any plan entry for [date] removed.
List<PlanEntry> clearPlanForDate(List<PlanEntry> entries, DateTime date) {
  final normalizedDate = dateOnly(date);
  return entries.where((entry) => !isSameDate(entry.date, normalizedDate)).toList();
}

/// Returns a new list with the entry for [date] marked as worn (see
/// [PlanEntry.worn]). A no-op (returns [entries] unchanged) if [date] has no
/// plan entry.
List<PlanEntry> markPlanWorn(List<PlanEntry> entries, DateTime date) {
  final normalizedDate = dateOnly(date);
  return <PlanEntry>[
    for (final entry in entries) isSameDate(entry.date, normalizedDate) ? entry.copyWith(worn: true) : entry,
  ];
}

/// The single plan entry covering [date], or `null` if nothing is planned.
PlanEntry? resolvePlanForDate(List<PlanEntry> entries, DateTime date) {
  final normalizedDate = dateOnly(date);
  for (final entry in entries) {
    if (isSameDate(entry.date, normalizedDate)) return entry;
  }
  return null;
}

/// Convenience wrapper for "what's planned today" - the Plan screen's
/// primary question.
PlanEntry? resolveTodayPlan(List<PlanEntry> entries, DateTime now) => resolvePlanForDate(entries, now);

/// Plan entries whose date falls within [from]..[to] inclusive, sorted
/// chronologically (earliest first).
List<PlanEntry> entriesInRange(List<PlanEntry> entries, DateTime from, DateTime to) {
  final start = dateOnly(from);
  final end = dateOnly(to);
  final inRange = entries.where((entry) {
    final entryDate = dateOnly(entry.date);
    return !entryDate.isBefore(start) && !entryDate.isAfter(end);
  }).toList();
  inRange.sort((a, b) => a.date.compareTo(b.date));
  return inRange;
}

/// A single cell in a month calendar grid: either a real calendar [date], or
/// `null` for a leading/trailing blank that pads the grid out to full weeks.
typedef MonthGridCell = DateTime?;

/// Builds the calendar grid for [year]/[month] as a flat list of 7-per-row
/// cells (Monday-first), with `null` cells padding the first week's leading
/// blanks and the last week's trailing blanks so every row has exactly 7
/// entries and the grid always renders as complete weeks.
List<MonthGridCell> monthGridDays(int year, int month) {
  final firstOfMonth = DateTime(year, month);
  final totalDays = daysInMonth(year, month);

  // DateTime.weekday is Monday=1..Sunday=7; a Monday-first grid needs 0
  // leading blanks for Monday, up to 6 for Sunday.
  final leadingBlanks = firstOfMonth.weekday - 1;

  final cells = <MonthGridCell>[
    for (var i = 0; i < leadingBlanks; i++) null,
    for (var day = 1; day <= totalDays; day++) DateTime(year, month, day),
  ];

  final trailingBlanks = (7 - (cells.length % 7)) % 7;
  cells.addAll(List<MonthGridCell>.filled(trailingBlanks, null));
  return cells;
}
