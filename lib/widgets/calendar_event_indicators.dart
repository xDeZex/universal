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
    final displayEvents = events.take(5).toList(); // Show more events with taller calendar
    final hasMoreEvents = events.length > 5;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many events can fit in the available space
        const eventHeight = 16.0; // Height per event (padding + text + margin)
        final maxEvents = ((constraints.maxHeight - 4) / eventHeight).floor().clamp(1, 5);
        final actualDisplayEvents = events.take(maxEvents).toList();
        final actualHasMoreEvents = events.length > maxEvents;

        return ClipRect(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...actualDisplayEvents.map((event) {
                final color = _getEventColor(theme, event.type);

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: event.isCompleted ? color : color.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    event.title,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              if (actualHasMoreEvents)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 0.5, horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '+${events.length - maxEvents} more',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
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