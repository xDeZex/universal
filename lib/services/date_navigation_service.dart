import 'package:flutter/foundation.dart';

/// Service for managing calendar navigation state
/// Handles current month navigation and selected date tracking
class DateNavigationService extends ChangeNotifier {
  DateTime _selectedDate;
  DateTime _currentMonth;

  DateNavigationService({DateTime? initialDate})
      : _selectedDate = initialDate ?? DateTime.now(),
        _currentMonth = initialDate ?? DateTime.now();

  /// Currently selected date
  DateTime get selectedDate => _selectedDate;

  /// Current month being displayed in the calendar
  DateTime get currentMonth => _currentMonth;

  /// Current month and year as formatted string
  String get currentMonthYearString {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_currentMonth.month - 1]} ${_currentMonth.year}';
  }

  /// Set the selected date
  void setSelectedDate(DateTime date) {
    if (_selectedDate != date) {
      _selectedDate = date;
      notifyListeners();
    }
  }

  /// Navigate to the previous month
  void navigateToPreviousMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    notifyListeners();
  }

  /// Navigate to the next month
  void navigateToNextMonth() {
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    notifyListeners();
  }

  /// Navigate to a specific month
  void navigateToMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  /// Go to today's date and month
  void goToToday() {
    final today = DateTime.now();
    _selectedDate = today;
    _currentMonth = today;
    notifyListeners();
  }

  /// Check if a date is the selected date
  bool isSelectedDate(DateTime date) {
    return _selectedDate.year == date.year &&
           _selectedDate.month == date.month &&
           _selectedDate.day == date.day;
  }

  /// Check if a date is today
  bool isToday(DateTime date) {
    final today = DateTime.now();
    return today.year == date.year &&
           today.month == date.month &&
           today.day == date.day;
  }

  /// Check if two dates are in the same month
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Check if a date is in the current month being displayed
  bool isInCurrentMonth(DateTime date) {
    return isSameMonth(_currentMonth, date);
  }

  /// Get the first day of the current month
  DateTime get firstDayOfCurrentMonth {
    return DateTime(_currentMonth.year, _currentMonth.month, 1);
  }

  /// Get the last day of the current month
  DateTime get lastDayOfCurrentMonth {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
  }

  /// Calculate total calendar cells needed (42 for 6 weeks)
  int get totalCalendarCells => 42;

  /// Get the date for a specific calendar cell index
  /// Returns null for cells that would show dates from previous or next month
  DateTime? getDateForCell(int cellIndex) {
    final firstDay = firstDayOfCurrentMonth;
    final lastDay = lastDayOfCurrentMonth;
    final firstWeekday = firstDay.weekday % 7; // 0 = Monday, 6 = Sunday

    // Use date arithmetic instead of duration arithmetic to avoid DST issues
    final startYear = firstDay.year;
    final startMonth = firstDay.month;
    final startDayOfMonth = firstDay.day - firstWeekday;

    // Calculate the actual date by adding days to the start day
    final cellDate = DateTime(startYear, startMonth, startDayOfMonth + cellIndex);

    // Only return dates that are in the current month
    if (cellDate.isBefore(firstDay) || cellDate.isAfter(lastDay)) {
      return null;
    }

    return cellDate;
  }
}