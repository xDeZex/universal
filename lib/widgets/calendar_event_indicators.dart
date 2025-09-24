import 'package:flutter/material.dart';
import '../models/calendar_event.dart';

class CalendarEventIndicators extends StatelessWidget {
  const CalendarEventIndicators({
    super.key,
    required this.events,
  });

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final displayEvents = events.take(2).toList(); // Show max 2 events to fit in cell

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: displayEvents.map((event) {
        final color = _getEventColor(theme, event.type);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: event.isCompleted ? color : color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            event.title,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
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
}