import 'package:flutter/material.dart';
import 'monthly_calendar_view.dart';
import '../services/training_split_service.dart';

class CalendarDateCard extends StatelessWidget {
  const CalendarDateCard({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.onDayTap,
    this.trainingSplitService,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDayTap;
  final TrainingSplitService? trainingSplitService;

  @override
  Widget build(BuildContext context) {
    return MonthlyCalendarView(
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      onDayTap: onDayTap,
      trainingSplitService: trainingSplitService,
    );
  }
}