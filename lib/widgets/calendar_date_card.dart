import 'package:flutter/material.dart';

class CalendarDateCard extends StatelessWidget {
  const CalendarDateCard({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  static const int _firstYear = 2020;
  static const int _lastYear = 2030;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime(_firstYear),
          lastDate: DateTime(_lastYear),
          onDateChanged: onDateChanged,
        ),
      ),
    );
  }
}