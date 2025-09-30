import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../services/training_split_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/add_event_dialog.dart';

class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({
    super.key,
    required this.selectedDate,
    required this.trainingSplitService,
  });

  final DateTime selectedDate;
  final TrainingSplitService trainingSplitService;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() {
      _events = widget.trainingSplitService.getEventsForDate(widget.selectedDate);
    });
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        selectedDate: widget.selectedDate,
        onEventCreated: (event) {
          widget.trainingSplitService.addCalendarEvent(event);
          _loadEvents();
        },
      ),
    );
  }

  void _toggleEventCompletion(CalendarEvent event) {
    setState(() {
      widget.trainingSplitService.toggleEventCompletion(event.id);
      _loadEvents();
    });
  }

  void _deleteEvent(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.trainingSplitService.deleteEvent(event.id);
              _loadEvents();
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = widget.selectedDate.year == now.year &&
                   widget.selectedDate.month == now.month &&
                   widget.selectedDate.day == now.day;

    return Scaffold(
      appBar: AppBar(
        title: Text('${DateFormatter.formatWeekday(widget.selectedDate)}, ${DateFormatter.formatDate(widget.selectedDate)}'),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEventDialog,
            tooltip: 'Add Event',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(theme, isToday),
          const SizedBox(height: 16),
          Expanded(
            child: _events.isEmpty ? _buildEmptyState(theme) : _buildEventsList(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateHeader(ThemeData theme, bool isToday) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${widget.selectedDate.day}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDate(widget.selectedDate),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormatter.formatWeekday(widget.selectedDate),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isToday) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            '${_events.length} event${_events.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add an event',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(theme, event);
      },
    );
  }

  Widget _buildEventCard(ThemeData theme, CalendarEvent event) {
    final eventColor = _getEventColor(theme, event.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleEventCompletion(event),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: event.isCompleted
                      ? eventColor.withValues(alpha: 0.5)
                      : eventColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: event.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: event.isCompleted
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getEventIcon(event.type),
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEventTypeLabel(event.type),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.timeDisplayString,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      event.isCompleted
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: event.isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _toggleEventCompletion(event),
                    tooltip: event.isCompleted ? 'Mark incomplete' : 'Mark complete',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: () => _deleteEvent(event),
                    tooltip: 'Delete event',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEventColor(ThemeData theme, CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return theme.colorScheme.primary;
      case CalendarEventType.restDay:
        return theme.colorScheme.secondary;
      case CalendarEventType.general:
        return theme.colorScheme.tertiary;
    }
  }

  IconData _getEventIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return Icons.fitness_center;
      case CalendarEventType.restDay:
        return Icons.hotel;
      case CalendarEventType.general:
        return Icons.event;
    }
  }

  String _getEventTypeLabel(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.workout:
        return 'Workout';
      case CalendarEventType.restDay:
        return 'Rest Day';
      case CalendarEventType.general:
        return 'General';
    }
  }
}