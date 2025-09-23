import 'package:flutter/material.dart';
import 'monthly_calendar_view.dart';

class CalendarDateCard extends StatelessWidget {
  const CalendarDateCard({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return MonthlyCalendarView(
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
    );
  }
}