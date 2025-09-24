import 'package:flutter/material.dart';

class CalendarWeekdayHeaders extends StatelessWidget {
  const CalendarWeekdayHeaders({super.key});

  static const List<String> _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: _weekdays.map((day) => Expanded(
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
}