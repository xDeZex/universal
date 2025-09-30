import 'package:flutter/material.dart';
import '../services/training_split_service.dart';
import '../services/date_navigation_service.dart';
import '../services/calendar_event_service.dart';
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
    this.calendarEventService,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDayTap;
  final TrainingSplitService? trainingSplitService;
  final CalendarEventService? calendarEventService;

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late DateNavigationService _dateNavigationService;
  late TrainingSplitService _trainingSplitService;
  CalendarEventService? _calendarEventService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    _dateNavigationService = DateNavigationService(initialDate: widget.selectedDate);
    _trainingSplitService = widget.trainingSplitService ?? TrainingSplitService();
    _calendarEventService = widget.calendarEventService;

    // Listen to navigation changes to trigger rebuilds
    _dateNavigationService.addListener(_onNavigationChanged);

    // Listen to calendar event changes if service is provided
    _calendarEventService?.addListener(_onEventChanged);
  }

  @override
  void dispose() {
    _dateNavigationService.removeListener(_onNavigationChanged);
    _calendarEventService?.removeListener(_onEventChanged);
    _dateNavigationService.dispose();
    super.dispose();
  }

  void _onNavigationChanged() {
    setState(() {
      // Trigger rebuild when navigation state changes
    });
  }

  void _onEventChanged() {
    setState(() {
      // Trigger rebuild when events change
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarMonthHeader(
          currentMonth: _dateNavigationService.currentMonth,
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
    _dateNavigationService.navigateToPreviousMonth();
  }

  void _navigateToNextMonth() {
    _dateNavigationService.navigateToNextMonth();
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final totalCells = _dateNavigationService.totalCalendarCells;

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
    final date = _dateNavigationService.getDateForCell(index);

    // Return empty cell if no date for this position
    if (date == null) {
      return const SizedBox.shrink();
    }

    // Use CalendarEventService if available, otherwise fall back to TrainingSplitService
    final events = _calendarEventService?.getEventsForDate(date) ??
                  _trainingSplitService.getEventsForDate(date);
    final isSelected = _dateNavigationService.isSelectedDate(date);
    final isToday = _dateNavigationService.isToday(date);

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