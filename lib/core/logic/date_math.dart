/// Small calendar-date helpers shared by the pure logic layer. A "calendar
/// date" here means local midnight for that year/month/day - no time
/// component, no timezone math. Nothing in this file depends on Flutter.

/// Strips the time-of-day component, returning local midnight for the same
/// calendar date.
///
/// `DateTime.add`/`.subtract` with a fixed [Duration] are avoided elsewhere
/// in this layer in favor of comparing calendar fields directly, which stays
/// correct across daylight-saving transitions (a local "day" is not always
/// exactly 24 hours).
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

/// Local midnight, [days] calendar days after [date] (or before, if [days]
/// is negative). Rebuilds the date from its calendar fields instead of
/// adding a fixed-length [Duration], which keeps it DST-safe.
DateTime addCalendarDays(DateTime date, int days) {
  return DateTime(date.year, date.month, date.day + days);
}

/// Whole calendar days from [from] to [to] (positive when [to] is later).
int daysBetween(DateTime from, DateTime to) {
  return dateOnly(to).difference(dateOnly(from)).inDays;
}

/// Whether [a] and [b] fall on the same calendar date, ignoring time-of-day.
bool isSameDate(DateTime a, DateTime b) => daysBetween(a, b) == 0;

/// Whether [a] and [b] fall in the same calendar month and year.
bool isSameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

/// The number of days in [year]/[month] (1-12), leap-year aware. Works by
/// asking for "day 0" of the following month, which `DateTime` normalizes
/// back to the last day of [month].
int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
