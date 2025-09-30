import 'package:flutter_test/flutter_test.dart';
import 'package:universal/services/date_navigation_service.dart';

void main() {
  group('Last Day Visibility Tests', () {
    test('should show last day of each month in 2024', () {
      // Test all 12 months of 2024
      final monthsWithDays = [
        {'month': 1, 'lastDay': 31}, // January
        {'month': 2, 'lastDay': 29}, // February (leap year)
        {'month': 3, 'lastDay': 31}, // March
        {'month': 4, 'lastDay': 30}, // April
        {'month': 5, 'lastDay': 31}, // May
        {'month': 6, 'lastDay': 30}, // June
        {'month': 7, 'lastDay': 31}, // July
        {'month': 8, 'lastDay': 31}, // August
        {'month': 9, 'lastDay': 30}, // September
        {'month': 10, 'lastDay': 31}, // October (DST issue month)
        {'month': 11, 'lastDay': 30}, // November
        {'month': 12, 'lastDay': 31}, // December
      ];

      for (final monthData in monthsWithDays) {
        final month = monthData['month'] as int;
        final expectedLastDay = monthData['lastDay'] as int;

        final service = DateNavigationService(initialDate: DateTime(2024, month, 15));

        // Get all visible dates for this month
        final visibleDates = <DateTime>[];
        for (int i = 0; i < service.totalCalendarCells; i++) {
          final date = service.getDateForCell(i);
          if (date != null && date.month == month) {
            visibleDates.add(date);
          }
        }

        // Check that the last day of the month is visible
        final lastDayFound = visibleDates.any((date) => date.day == expectedLastDay);

        expect(lastDayFound, isTrue,
          reason: 'Last day ($expectedLastDay) of month $month/2024 should be visible in calendar');

        // Also verify we have all days of the month
        final dayNumbers = visibleDates.map((date) => date.day).toSet();
        final expectedDays = List.generate(expectedLastDay, (index) => index + 1).toSet();

        expect(dayNumbers, equals(expectedDays),
          reason: 'All days of month $month/2024 should be visible (1-$expectedLastDay)');

        service.dispose();
      }
    });

    test('should show last day of February in leap and non-leap years', () {
      // Test leap year (2024)
      final leapYearService = DateNavigationService(initialDate: DateTime(2024, 2, 15));
      final leapYearDates = <DateTime>[];

      for (int i = 0; i < leapYearService.totalCalendarCells; i++) {
        final date = leapYearService.getDateForCell(i);
        if (date != null && date.month == 2) {
          leapYearDates.add(date);
        }
      }

      final leapYearLastDay = leapYearDates.map((d) => d.day).reduce((a, b) => a > b ? a : b);
      expect(leapYearLastDay, equals(29), reason: 'Leap year 2024 should have 29 days in February');

      // Test non-leap year (2023)
      final nonLeapYearService = DateNavigationService(initialDate: DateTime(2023, 2, 15));
      final nonLeapYearDates = <DateTime>[];

      for (int i = 0; i < nonLeapYearService.totalCalendarCells; i++) {
        final date = nonLeapYearService.getDateForCell(i);
        if (date != null && date.month == 2) {
          nonLeapYearDates.add(date);
        }
      }

      final nonLeapYearLastDay = nonLeapYearDates.map((d) => d.day).reduce((a, b) => a > b ? a : b);
      expect(nonLeapYearLastDay, equals(28), reason: 'Non-leap year 2023 should have 28 days in February');

      leapYearService.dispose();
      nonLeapYearService.dispose();
    });

    test('should show October 31, 2024 (DST transition month)', () {
      final service = DateNavigationService(initialDate: DateTime(2024, 10, 15));

      // Get all October dates
      final octoberDates = <DateTime>[];
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null && date.month == 10) {
          octoberDates.add(date);
        }
      }

      // Verify October 31st is present
      final oct31Found = octoberDates.any((date) => date.day == 31);
      expect(oct31Found, isTrue, reason: 'October 31, 2024 should be visible');

      // Verify we have all 31 days
      final dayNumbers = octoberDates.map((date) => date.day).toSet();
      final expectedDays = List.generate(31, (index) => index + 1).toSet();
      expect(dayNumbers, equals(expectedDays), reason: 'All 31 days of October should be visible');

      // Verify no duplicates
      expect(octoberDates.length, equals(31), reason: 'Should have exactly 31 unique October dates');

      service.dispose();
    });

    test('should show correct last day for months around DST transitions', () {
      // Test months around common DST transition periods
      final dstTestCases = [
        {'year': 2024, 'month': 3, 'lastDay': 31}, // March (spring DST)
        {'year': 2024, 'month': 10, 'lastDay': 31}, // October (fall DST)
        {'year': 2024, 'month': 11, 'lastDay': 30}, // November (after fall DST)
      ];

      for (final testCase in dstTestCases) {
        final year = testCase['year'] as int;
        final month = testCase['month'] as int;
        final expectedLastDay = testCase['lastDay'] as int;

        final service = DateNavigationService(initialDate: DateTime(year, month, 15));

        final monthDates = <DateTime>[];
        for (int i = 0; i < service.totalCalendarCells; i++) {
          final date = service.getDateForCell(i);
          if (date != null && date.month == month) {
            monthDates.add(date);
          }
        }

        final actualLastDay = monthDates.map((d) => d.day).reduce((a, b) => a > b ? a : b);
        expect(actualLastDay, equals(expectedLastDay),
          reason: 'Last day of $month/$year should be $expectedLastDay');

        service.dispose();
      }
    });

    test('should handle end-of-year transition correctly', () {
      // Test December 2024 to ensure December 31st is visible
      final service = DateNavigationService(initialDate: DateTime(2024, 12, 15));

      final decemberDates = <DateTime>[];
      for (int i = 0; i < service.totalCalendarCells; i++) {
        final date = service.getDateForCell(i);
        if (date != null && date.month == 12) {
          decemberDates.add(date);
        }
      }

      // Verify December 31st is present
      final dec31Found = decemberDates.any((date) => date.day == 31);
      expect(dec31Found, isTrue, reason: 'December 31, 2024 should be visible');

      // Verify we have all 31 days of December
      final dayNumbers = decemberDates.map((date) => date.day).toSet();
      final expectedDays = List.generate(31, (index) => index + 1).toSet();
      expect(dayNumbers, equals(expectedDays), reason: 'All 31 days of December should be visible');

      service.dispose();
    });

    test('should maintain consistency across different years', () {
      // Test the same month across different years to ensure consistency
      final years = [2023, 2024, 2025, 2026];

      for (final year in years) {
        final service = DateNavigationService(initialDate: DateTime(year, 10, 15));

        final octoberDates = <DateTime>[];
        for (int i = 0; i < service.totalCalendarCells; i++) {
          final date = service.getDateForCell(i);
          if (date != null && date.month == 10) {
            octoberDates.add(date);
          }
        }

        // October always has 31 days
        expect(octoberDates.length, equals(31),
          reason: 'October $year should have exactly 31 days');

        final oct31Found = octoberDates.any((date) => date.day == 31);
        expect(oct31Found, isTrue,
          reason: 'October 31, $year should be visible');

        service.dispose();
      }
    });
  });
}