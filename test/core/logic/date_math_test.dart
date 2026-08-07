import 'package:flutter_closet/core/logic/date_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dateOnly', () {
    test('strips the time-of-day component', () {
      expect(dateOnly(DateTime(2026, 8, 7, 14, 30, 15)), DateTime(2026, 8, 7));
    });
  });

  group('addCalendarDays', () {
    test('adds days within a month', () {
      expect(addCalendarDays(DateTime(2026, 8, 7), 10), DateTime(2026, 8, 17));
    });

    test('subtracts days across a month boundary', () {
      // Aug 7 minus 7 days lands on Jul 31; 3 more days back is Jul 28.
      expect(addCalendarDays(DateTime(2026, 8, 7), -10), DateTime(2026, 7, 28));
    });

    test('crosses a year boundary', () {
      expect(addCalendarDays(DateTime(2026, 1, 1), -1), DateTime(2025, 12, 31));
      expect(addCalendarDays(DateTime(2025, 12, 31), 1), DateTime(2026, 1, 1));
    });
  });

  group('daysBetween', () {
    test('positive when "to" is later', () {
      expect(daysBetween(DateTime(2026, 8, 1), DateTime(2026, 8, 7)), 6);
    });

    test('negative when "to" is earlier', () {
      expect(daysBetween(DateTime(2026, 8, 7), DateTime(2026, 8, 1)), -6);
    });

    test('ignores time-of-day', () {
      expect(daysBetween(DateTime(2026, 8, 1, 23, 59), DateTime(2026, 8, 2, 0, 1)), 1);
    });
  });

  group('isSameDate', () {
    test('true for the same calendar date at different times', () {
      expect(isSameDate(DateTime(2026, 8, 7, 3, 0), DateTime(2026, 8, 7, 23, 59)), isTrue);
    });

    test('false for different calendar dates', () {
      expect(isSameDate(DateTime(2026, 8, 7), DateTime(2026, 8, 8)), isFalse);
    });
  });

  group('isSameMonth', () {
    test('true for the first and last day of the same month', () {
      expect(isSameMonth(DateTime(2026, 8, 1), DateTime(2026, 8, 31)), isTrue);
    });

    test('false across a month boundary', () {
      expect(isSameMonth(DateTime(2026, 8, 31), DateTime(2026, 9, 1)), isFalse);
    });
  });

  group('daysInMonth', () {
    test('31-day month', () => expect(daysInMonth(2026, 8), 31));
    test('30-day month', () => expect(daysInMonth(2026, 4), 30));
    test('December rolls over into next year correctly', () => expect(daysInMonth(2026, 12), 31));

    test('February in a non-leap year', () {
      // 2026 is not divisible by 4, so it is not a leap year.
      expect(daysInMonth(2026, 2), 28);
    });

    test('February in a leap year', () {
      // 2024 is divisible by 4 (and not a century exception), so it is leap.
      expect(daysInMonth(2024, 2), 29);
    });
  });
}
