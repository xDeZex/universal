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
    final displayEvents = events.take(3).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: displayEvents.map((event) {
        final color = _getEventColor(theme, event.type);

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