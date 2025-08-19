import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../utils/date_formatter.dart';

class DateInfoCard extends StatelessWidget {
  const DateInfoCard({
    super.key,
    required this.selectedDate,
    this.events = const [],
  });

  final DateTime selectedDate;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection(
              title: 'Selected Date',
              content: DateFormatter.formatDate(selectedDate),
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              title: 'Day of Week',
              content: DateFormatter.formatWeekday(selectedDate),
              theme: theme,
            ),
            const SizedBox(height: 16),
            _buildEventsSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildEventsSection(ThemeData theme) {
    if (events.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Training Events',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No training events scheduled',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Events',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...events.map((event) => _buildEventItem(event, theme)),
      ],
    );
  }

  Widget _buildEventItem(CalendarEvent event, ThemeData theme) {
    final isRestDay = event.type == CalendarEventType.restDay;
    final iconColor = isRestDay ? theme.colorScheme.secondary : theme.colorScheme.primary;
    final icon = isRestDay ? Icons.spa : Icons.fitness_center;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              event.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration: event.isCompleted ? TextDecoration.lineThrough : null,
                color: event.isCompleted 
                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                    : null,
              ),
            ),
          ),
          if (event.isCompleted)
            Icon(
              Icons.check_circle,
              size: 16,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }
}