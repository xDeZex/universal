class CalendarUtils {
  static int calculateDaysInMonth(DateTime month) {
    return DateTime(month.year, month.month + 1, 0).day;
  }

  static int calculateWeeksNeeded(DateTime month) {
    final daysInMonth = calculateDaysInMonth(month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    return ((daysInMonth + firstWeekday - 2) / 7).ceil();
  }

  static int calculateTotalCells(DateTime month) {
    return calculateWeeksNeeded(month) * 7;
  }

  static DateTime? calculateDateForCell(
    DateTime month,
    int cellIndex,
  ) {
    final daysInMonth = calculateDaysInMonth(month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday

    // Calculate the day number for this cell
    final dayNumber = cellIndex - (firstWeekday - 2); // Adjust for Monday start

    // Check if this cell should show a day from current month
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return null; // Empty cell
    }

    return DateTime(month.year, month.month, dayNumber);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}