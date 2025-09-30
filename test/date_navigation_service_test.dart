import 'package:flutter_test/flutter_test.dart';
import 'package:universal/services/date_navigation_service.dart';

void main() {
  setUpAll(() {
    // WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('DateNavigationService', () {
    late DateNavigationService service;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 6, 15);
      service = DateNavigationService(initialDate: testDate);
    });

    tearDown(() {
      service.dispose();
    });

    test('should initialize with correct selected date', () {
      expect(service.selectedDate, equals(testDate));
      expect(service.currentMonth, equals(testDate));
    });

    test('should format current month year string correctly', () {
      expect(service.currentMonthYearString, equals('June 2024'));
    });

    test('should set selected date correctly', () {
      final newDate = DateTime(2024, 6, 20);
      service.setSelectedDate(newDate);
      expect(service.selectedDate, equals(newDate));
    });

    test('should navigate to previous month', () {
      service.navigateToPreviousMonth();
      expect(service.currentMonth.year, equals(2024));
      expect(service.currentMonth.month, equals(5));
      expect(service.currentMonthYearString, equals('May 2024'));
    });

    test('should navigate to next month', () {
      service.navigateToNextMonth();
      expect(service.currentMonth.year, equals(2024));
      expect(service.currentMonth.month, equals(7));
      expect(service.currentMonthYearString, equals('July 2024'));
    });

    test('should navigate to specific month', () {
      service.navigateToMonth(DateTime(2025, 12, 1));
      expect(service.currentMonth.year, equals(2025));
      expect(service.currentMonth.month, equals(12));
      expect(service.currentMonthYearString, equals('December 2025'));
    });

    test('should go to today correctly', () {
      final today = DateTime.now();
      service.goToToday();
      expect(service.selectedDate.year, equals(today.year));
      expect(service.selectedDate.month, equals(today.month));
      expect(service.selectedDate.day, equals(today.day));
    });

    test('should identify selected date correctly', () {
      expect(service.isSelectedDate(testDate), isTrue);
      expect(service.isSelectedDate(DateTime(2024, 6, 16)), isFalse);
    });

    test('should identify today correctly', () {
      final today = DateTime.now();
      expect(service.isToday(today), isTrue);
      expect(service.isToday(DateTime(2020, 1, 1)), isFalse);
    });

    test('should check same month correctly', () {
      expect(DateNavigationService.isSameMonth(
        DateTime(2024, 6, 1),
        DateTime(2024, 6, 30)
      ), isTrue);
      expect(DateNavigationService.isSameMonth(
        DateTime(2024, 6, 1),
        DateTime(2024, 7, 1)
      ), isFalse);
    });

    test('should check if date is in current month', () {
      expect(service.isInCurrentMonth(DateTime(2024, 6, 1)), isTrue);
      expect(service.isInCurrentMonth(DateTime(2024, 7, 1)), isFalse);
    });

    test('should get first and last day of current month', () {
      expect(service.firstDayOfCurrentMonth, equals(DateTime(2024, 6, 1)));
      expect(service.lastDayOfCurrentMonth, equals(DateTime(2024, 6, 30)));
    });

    test('should calculate calendar cells correctly', () {
      expect(service.totalCalendarCells, equals(42));
    });

    test('should get date for calendar cell', () {
      // June 2024 starts on Saturday (weekday 6)
      // So cell 0 should be null (it would be a previous month date)
      final cellDate = service.getDateForCell(0);
      expect(cellDate, isNull);

      // Cell 6 should be June 1st (first day of the month)
      final firstDayCell = service.getDateForCell(6);
      expect(firstDayCell, isNotNull);
      expect(firstDayCell!.month, equals(6));
      expect(firstDayCell.day, equals(1));
    });
  });
}