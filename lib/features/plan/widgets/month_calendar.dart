import 'package:flutter/material.dart';

import '../../../core/constants/date_format.dart';
import '../../../core/logic/date_math.dart';
import '../../../core/logic/plan.dart';

/// A Monday-first month grid: a header with month navigation, a weekday
/// row, and a day grid with a small dot under any date that has a planned
/// outfit (filled once "Wear today" has been applied for that date, hollow
/// otherwise).
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.plannedDates,
    required this.wornDates,
    required this.onSelectDate,
    required this.onChangeMonth,
  });

  /// The first day of the month currently shown.
  final DateTime visibleMonth;
  final DateTime selectedDate;

  /// Date-only dates that have a plan entry.
  final Set<DateTime> plannedDates;

  /// Date-only dates whose plan entry has already been marked worn.
  final Set<DateTime> wornDates;

  final ValueChanged<DateTime> onSelectDate;

  /// Called with `-1` (previous month) or `1` (next month).
  final ValueChanged<int> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final today = dateOnly(DateTime.now());
    final cells = monthGridDays(visibleMonth.year, visibleMonth.month);

    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: () => onChangeMonth(-1), icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                formatMonthYear(visibleMonth),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(onPressed: () => onChangeMonth(1), icon: const Icon(Icons.chevron_right)),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    weekdayAbbreviation(i),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        for (var weekStart = 0; weekStart < cells.length; weekStart += 7)
          Row(
            children: [
              for (final day in cells.sublist(weekStart, weekStart + 7))
                Expanded(
                  child: day == null
                      ? const SizedBox(height: 48)
                      : _DayCell(
                          day: day,
                          isToday: day == today,
                          isSelected: day == selectedDate,
                          isPlanned: plannedDates.contains(day),
                          isWorn: wornDates.contains(day),
                          onTap: () => onSelectDate(day),
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.isPlanned,
    required this.isWorn,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool isPlanned;
  final bool isWorn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = isSelected ? scheme.onPrimary : (isToday ? scheme.primary : scheme.onSurface);
    final dotColor = isSelected ? scheme.onPrimary : (isWorn ? scheme.primary : scheme.tertiary);

    return SizedBox(
      height: 48,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? scheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: (isToday && !isSelected) ? Border.all(color: scheme.primary, width: 1.5) : null,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(color: textColor, fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500),
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              height: 5,
              width: 5,
              child: isPlanned ? DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)) : null,
            ),
          ],
        ),
      ),
    );
  }
}
