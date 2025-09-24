import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import 'calendar_event_indicators.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.date,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
    this.onLongPress,
  });

  final DateTime date;
  final List<CalendarEvent> events;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellColors = _getCellColors(theme);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: cellColors.backgroundColor,
          border: cellColors.borderColor != null
              ? Border.all(color: cellColors.borderColor!, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDayNumber(theme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: CalendarEventIndicators(events: events),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayNumber(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 4.0, 0.0),
      child: Text(
        '${date.day}',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
          color: _getDayNumberColor(theme),
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getDayNumberColor(ThemeData theme) {
    if (isSelected) {
      return theme.colorScheme.primary;
    } else if (isToday) {
      return theme.colorScheme.secondary;
    } else {
      return theme.colorScheme.onSurface;
    }
  }

  _CellColors _getCellColors(ThemeData theme) {
    Color? backgroundColor;
    Color? borderColor;

    if (isSelected) {
      backgroundColor = theme.colorScheme.primary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.primary;
    } else if (isToday) {
      backgroundColor = theme.colorScheme.secondary.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.secondary;
    }

    return _CellColors(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }
}

class _CellColors {
  const _CellColors({
    this.backgroundColor,
    this.borderColor,
  });

  final Color? backgroundColor;
  final Color? borderColor;
}