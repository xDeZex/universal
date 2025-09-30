import 'package:flutter/material.dart';
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
    return Column(
      children: [
        CalendarMonthHeader(
          currentMonth: _currentMonth,
          onPreviousMonth: _navigateToPreviousMonth,
          onNextMonth: _navigateToNextMonth,
        ),
        const SizedBox(height: 16),
        const CalendarWeekdayHeaders(),
        const SizedBox(height: 8),
        Expanded(
          child: _buildCalendarGrid(context),
        ),
      ],
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
    final totalCells = CalendarUtils.calculateTotalCells(_currentMonth);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.6,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) => _buildCalendarCell(context, index),
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
      onTap: widget.onDayTap != null ? () {
        widget.onDateChanged(date);
        widget.onDayTap!(date);
      } : () => widget.onDateChanged(date),
      onLongPress: null,
    );
  }
}