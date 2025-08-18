class DateFormatter {
  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  
  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static String formatDate(DateTime date) {
    try {
      if (date.month < 1 || date.month > 12) {
        return 'Invalid date';
      }
      return '${_months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  static String formatWeekday(DateTime date) {
    try {
      if (date.weekday < 1 || date.weekday > 7) {
        return 'Invalid weekday';
      }
      return _weekdays[date.weekday - 1];
    } catch (e) {
      return 'Invalid weekday';
    }
  }

  static bool isValidDate(DateTime date) {
    try {
      return date.month >= 1 && 
             date.month <= 12 && 
             date.day >= 1 && 
             date.day <= _getDaysInMonth(date.month, date.year);
    } catch (e) {
      return false;
    }
  }

  static int _getDaysInMonth(int month, int year) {
    switch (month) {
      case 2:
        return _isLeapYear(year) ? 29 : 28;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      default:
        return 31;
    }
  }

  static bool _isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }
}