import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/training_split_service.dart';
import '../utils/calendar_utils.dart';
import 'calendar_month_header.dart';
import 'calendar_weekday_headers.dart';
import 'calendar_day_cell.dart';

class MonthlyCalendarView extends StatefulWidget {
  const MonthlyCalendarView({
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
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late DateTime _currentMonth;
  late TrainingSplitService _trainingSplitService;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _trainingSplitService = widget.trainingSplitService ?? TrainingSplitService();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalendarMonthHeader(
              currentMonth: _currentMonth,
              onPreviousMonth: _navigateToPreviousMonth,
              onNextMonth: _navigateToNextMonth,
            ),
            const SizedBox(height: 16),
            const CalendarWeekdayHeaders(),
            const SizedBox(height: 8),
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  void _navigateToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _navigateToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final weeksNeeded = CalendarUtils.calculateWeeksNeeded(_currentMonth);
    final totalCells = CalendarUtils.calculateTotalCells(_currentMonth);

    return SizedBox(
      height: weeksNeeded * 60.0, // Fixed height per week
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) => _buildCalendarCell(context, index),
      ),
    );
  }

  Widget _buildCalendarCell(BuildContext context, int index) {
    final date = CalendarUtils.calculateDateForCell(_currentMonth, index);

    // Return empty cell if no date for this position
    if (date == null) {
      return const SizedBox.shrink();
    }

    final events = _trainingSplitService.getEventsForDate(date);
    final isSelected = CalendarUtils.isSameDay(date, widget.selectedDate);
    final isToday = CalendarUtils.isToday(date);

    return CalendarDayCell(
      date: date,
      events: events,
      isSelected: isSelected,
      isToday: isToday,
      onTap: () => widget.onDateChanged(date),
      onLongPress: widget.onDayTap != null ? () => widget.onDayTap!(date) : null,
    );
  }
}