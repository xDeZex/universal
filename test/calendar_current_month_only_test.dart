import 'package:flutter_test/flutter_test.dart';
import 'package:universal/services/date_navigation_service.dart';

void main() {
  setUpAll(() {
    // WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('Calendar Current Month Only Display', () {
    late DateNavigationService service;

    setUp(() {
      // June 2024 - starts on Saturday (weekday 6), has 30 days
      service = DateNavigationService(initialDate: DateTime(2024, 6, 15));
    });

    tearDown(() {
      service.dispose();
    });

    test('should NOT show dates from previous month in calendar grid', () {
      // Check all cells to ensure no dates from previous month (May) are shown
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null) {
          expect(date.month, equals(6),
            reason: 'Cell $i should only contain June dates, but got ${date.month}/${date.day}');
        }
      }
    });

    test('should NOT show dates from next month in calendar grid', () {
      // Check all cells to ensure no dates from next month (July) are shown
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null) {
          expect(date.month, equals(6),
            reason: 'Cell $i should only contain June dates, but got ${date.month}/${date.day}');
        }
      }
    });

    test('should show all days of current month', () {
      final currentMonth = service.currentMonth.month;
      final daysInMonth = service.lastDayOfCurrentMonth.day;
      final foundDays = <int>[];

      // Collect all days found in the calendar
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null && date.month == currentMonth) {
          foundDays.add(date.day);
        }
      }

      // Check that we have all days from 1 to daysInMonth
      foundDays.sort();
      final expectedDays = List.generate(daysInMonth, (index) => index + 1);
      expect(foundDays, equals(expectedDays),
        reason: 'Should show all days of the current month');
    });

    test('should return null for cells before first day of month', () {
      // June 2024 starts on Saturday, so cells 0-5 should be null
      for (int i = 0; i < 6; i++) {
        final date = service.getDateForCell(i);
        expect(date, isNull,
          reason: 'Cell $i should be null as it comes before June 1st');
      }
    });

    test('should return valid date for first day of month', () {
      // June 2024 starts on Saturday, so cell 6 should be June 1st
      final date = service.getDateForCell(6);
      expect(date, isNotNull);
      expect(date!.month, equals(6));
      expect(date.day, equals(1));
    });

    test('should return valid date for last day of month', () {
      // Find June 30th in the calendar
      DateTime? lastDay;
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null && date.month == 6 && date.day == 30) {
          lastDay = date;
          break;
        }
      }

      expect(lastDay, isNotNull);
      expect(lastDay!.month, equals(6));
      expect(lastDay.day, equals(30));
    });

    test('should return null for cells after last day of month', () {
      // Find the cell index for June 30th
      int lastDayIndex = -1;
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null && date.month == 6 && date.day == 30) {
          lastDayIndex = i;
          break;
        }
      }

      expect(lastDayIndex, greaterThan(-1));

      // All cells after the last day should be null
      for (int i = lastDayIndex + 1; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        expect(date, isNull,
          reason: 'Cell $i should be null as it comes after June 30th');
      }
    });

    test('should have correct pattern of null and valid dates', () {
      final pattern = <String>[];

      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date == null) {
          pattern.add('null');
        } else {
          pattern.add('${date.day}');
        }
      }

      // June 2024: starts on Saturday (6 nulls), has 30 days, then nulls to fill 42 cells
      // Pattern should be: 6 nulls, then 1-30, then 6 nulls
      final expectedNullsAtStart = 6;
      final expectedDays = 30;

      expect(pattern.length, equals(42));

      // Check start nulls
      for (int i = 0; i < expectedNullsAtStart; i++) {
        expect(pattern[i], equals('null'),
          reason: 'Cell $i should be null at start');
      }

      // Check days 1-30
      for (int i = 0; i < expectedDays; i++) {
        final cellIndex = expectedNullsAtStart + i;
        expect(pattern[cellIndex], equals('${i + 1}'),
          reason: 'Cell $cellIndex should be day ${i + 1}');
      }

      // Check end nulls
      for (int i = expectedNullsAtStart + expectedDays; i < 42; i++) {
        expect(pattern[i], equals('null'),
          reason: 'Cell $i should be null at end');
      }
    });

    group('Different months', () {
      test('should handle February in leap year correctly', () {
        // February 2024 (leap year) - starts on Thursday, has 29 days
        final febService = DateNavigationService(initialDate: DateTime(2024, 2, 15));

        // Check that only February dates are shown
        for (int i = 0; i < febService.totalCalendarCells; i++) {
          final date = febService.getDateForCell(i);
          if (date != null) {
            expect(date.month, equals(2),
              reason: 'Should only show February dates');
            expect(date.day, greaterThanOrEqualTo(1));
            expect(date.day, lessThanOrEqualTo(29));
          }
        }

        febService.dispose();
      });

      test('should handle February in non-leap year correctly', () {
        // February 2023 (non-leap year) - starts on Wednesday, has 28 days
        final febService = DateNavigationService(initialDate: DateTime(2023, 2, 15));

        // Check that only February dates are shown
        for (int i = 0; i < febService.totalCalendarCells; i++) {
          final date = febService.getDateForCell(i);
          if (date != null) {
            expect(date.month, equals(2),
              reason: 'Should only show February dates');
            expect(date.day, greaterThanOrEqualTo(1));
            expect(date.day, lessThanOrEqualTo(28));
          }
        }

        febService.dispose();
      });

      test('should handle different month start days', () {
        // January 2024 starts on Monday
        final janService = DateNavigationService(initialDate: DateTime(2024, 1, 15));

        // Check that only January dates are shown
        for (int i = 0; i < janService.totalCalendarCells; i++) {
          final date = janService.getDateForCell(i);
          if (date != null) {
            expect(date.month, equals(1),
              reason: 'Should only show January dates');
          }
        }

        // First non-null cell should be January 1st
        DateTime? firstDate;
        for (int i = 0; i < janService.totalCalendarCells; i++) {
          final date = janService.getDateForCell(i);
          if (date != null) {
            firstDate = date;
            break;
          }
        }

        expect(firstDate, isNotNull);
        expect(firstDate!.month, equals(1));
        expect(firstDate.day, equals(1));

        janService.dispose();
      });
    });
  });
}