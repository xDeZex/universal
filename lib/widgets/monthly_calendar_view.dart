import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/training_split_service.dart';

class MonthlyCalendarView extends StatefulWidget {
  const MonthlyCalendarView({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.onDayTap,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<DateTime>? onDayTap;

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late DateTime _currentMonth;
  final TrainingSplitService _trainingSplitService = TrainingSplitService();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 16),
            _buildWeekdayHeaders(context),
            const SizedBox(height: 8),
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = _getMonthName(_currentMonth);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            '$monthName ${_currentMonth.year}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          onPressed: _nextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    final theme = Theme.of(context);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final daysInMonth = _getDaysInCurrentMonth();
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    
    // Calculate minimum weeks needed for this month
    final weeksNeeded = ((daysInMonth + firstWeekday - 2) / 7).ceil();
    final totalCells = weeksNeeded * 7;
    
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
        itemBuilder: (context, index) {
          return _buildCalendarDay(context, index, firstWeekday, daysInMonth);
        },
      ),
    );
  }

  Widget _buildCalendarDay(BuildContext context, int index, int firstWeekday, int daysInMonth) {
    // Calculate the day number for this cell
    final dayNumber = index - (firstWeekday - 2); // Adjust for Monday start
    
    // Check if this cell should show a day from current month
    if (dayNumber < 1 || dayNumber > daysInMonth) {
      return const SizedBox.shrink(); // Empty cell
    }
    
    final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
    final events = _trainingSplitService.getEventsForDate(date);
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isToday = _isSameDay(date, DateTime.now());
    
    return _buildDaySquare(context, date, events, isSelected, isToday);
  }

  Widget _buildDaySquare(BuildContext context, DateTime date, List<CalendarEvent> events, bool isSelected, bool isToday) {
    final theme = Theme.of(context);
    
    Color? backgroundColor;
    Color? borderColor;
    
    if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.primary;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.secondary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.secondary;
    }
    
    return GestureDetector(
      onTap: () => widget.onDateChanged(date),
      onLongPress: widget.onDayTap != null ? () => widget.onDayTap!(date) : null,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: borderColor != null ? Border.all(color: borderColor, width: 2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Day number
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '${date.day}',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? theme.colorScheme.primary
                      : isToday
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onSurface,
                ),
              ),
            ),
            
            // Activity indicators
            Expanded(
              child: _buildActivityIndicators(context, events),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityIndicators(BuildContext context, List<CalendarEvent> events) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final theme = Theme.of(context);
    
    // Show up to 3 events as small indicators
    final displayEvents = events.take(3).toList();
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayEvents.map((event) {
        final color = event.type == CalendarEventType.workout
            ? theme.colorScheme.primary
            : theme.colorScheme.secondary;
            
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
          height: 8,
          decoration: BoxDecoration(
            color: event.isCompleted ? color : color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  int _getDaysInCurrentMonth() {
    return DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  }

  String _getMonthName(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}