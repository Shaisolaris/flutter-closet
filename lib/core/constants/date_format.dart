/// Lightweight date formatting for the UI layer. Deliberately dependency-free
/// (no `intl` package) - Closet only ever needs a handful of short, English
/// date labels.
const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const List<String> _fullMonths = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> _weekdayAbbreviations = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const List<String> _weekdayNames = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

/// e.g. "Aug 20, 2026".
String formatMediumDate(DateTime date) {
  return '${_monthAbbreviations[date.month - 1]} ${date.day}, ${date.year}';
}

/// e.g. "Aug 20" - used when the year is shown separately, or is the current
/// year and would be redundant.
String formatShortDate(DateTime date) {
  return '${_monthAbbreviations[date.month - 1]} ${date.day}';
}

/// e.g. "August 2026" - the month calendar's header label.
String formatMonthYear(DateTime date) {
  return '${_fullMonths[date.month - 1]} ${date.year}';
}

/// Full weekday name, e.g. "Friday", using [DateTime.weekday]'s
/// Monday=1..Sunday=7 convention.
String formatWeekdayLong(DateTime date) => _weekdayNames[date.weekday - 1];

/// Three-letter weekday column header, e.g. "Mon", Monday-first.
String weekdayAbbreviation(int mondayFirstIndex) => _weekdayAbbreviations[mondayFirstIndex % 7];

/// A relative-to-today label for a planned/worn date: "Today", "Tomorrow",
/// "Yesterday", "N days ago"/"in N days" close to today, and a plain medium
/// date once it's far enough away that a relative label stops being useful.
String formatRelativeToToday(DateTime date, DateTime today) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedToday = DateTime(today.year, today.month, today.day);
  final diff = normalizedDate.difference(normalizedToday).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  if (diff > 1 && diff <= 7) return 'In $diff days';
  if (diff < -1 && diff >= -7) return '${-diff} days ago';
  return formatMediumDate(date);
}
