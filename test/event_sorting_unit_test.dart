import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  group('Event Sorting Unit Tests', () {
    test('should sort events with all-day events first', () {
      final events = [
        CalendarEvent(
          id: '1',
          title: 'Timed Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        CalendarEvent(
          id: '2',
          title: 'All Day Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: true,
        ),
        CalendarEvent(
          id: '3',
          title: 'Early Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 8, minute: 0),
        ),
      ];

      // Apply the same sorting logic as in DayDetailScreen
      events.sort((a, b) {
        // All-day events first
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;

        // If both are all-day events, sort by title
        if (a.isAllDay && b.isAllDay) {
          return a.title.compareTo(b.title);
        }

        // For timed events, sort by start time
        final aTime = a.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final bTime = b.startTime ?? const TimeOfDay(hour: 0, minute: 0);

        // Convert to minutes for easy comparison
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;

        final timeComparison = aMinutes.compareTo(bMinutes);

        // If times are the same, sort by title
        return timeComparison != 0 ? timeComparison : a.title.compareTo(b.title);
      });

      // Expected order: All Day Event, Early Event (8:00), Timed Event (10:00)
      expect(events[0].title, equals('All Day Event'));
      expect(events[1].title, equals('Early Event'));
      expect(events[2].title, equals('Timed Event'));
    });

    test('should sort all-day events alphabetically', () {
      final events = [
        CalendarEvent(
          id: '1',
          title: 'Zebra Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: true,
        ),
        CalendarEvent(
          id: '2',
          title: 'Alpha Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: true,
        ),
        CalendarEvent(
          id: '3',
          title: 'Beta Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: true,
        ),
      ];

      // Apply sorting logic
      events.sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.isAllDay && b.isAllDay) {
          return a.title.compareTo(b.title);
        }
        final aTime = a.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final bTime = b.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        final timeComparison = aMinutes.compareTo(bMinutes);
        return timeComparison != 0 ? timeComparison : a.title.compareTo(b.title);
      });

      expect(events[0].title, equals('Alpha Event'));
      expect(events[1].title, equals('Beta Event'));
      expect(events[2].title, equals('Zebra Event'));
    });

    test('should sort timed events by start time', () {
      final events = [
        CalendarEvent(
          id: '1',
          title: 'Afternoon Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 14, minute: 30),
        ),
        CalendarEvent(
          id: '2',
          title: 'Morning Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        CalendarEvent(
          id: '3',
          title: 'Evening Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 18, minute: 15),
        ),
      ];

      // Apply sorting logic
      events.sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.isAllDay && b.isAllDay) {
          return a.title.compareTo(b.title);
        }
        final aTime = a.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final bTime = b.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        final timeComparison = aMinutes.compareTo(bMinutes);
        return timeComparison != 0 ? timeComparison : a.title.compareTo(b.title);
      });

      expect(events[0].title, equals('Morning Event'));
      expect(events[1].title, equals('Afternoon Event'));
      expect(events[2].title, equals('Evening Event'));
    });

    test('should sort events with same time alphabetically', () {
      final events = [
        CalendarEvent(
          id: '1',
          title: 'Zebra Meeting',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        CalendarEvent(
          id: '2',
          title: 'Alpha Meeting',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        CalendarEvent(
          id: '3',
          title: 'Beta Meeting',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 10, minute: 0),
        ),
      ];

      // Apply sorting logic
      events.sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.isAllDay && b.isAllDay) {
          return a.title.compareTo(b.title);
        }
        final aTime = a.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final bTime = b.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        final timeComparison = aMinutes.compareTo(bMinutes);
        return timeComparison != 0 ? timeComparison : a.title.compareTo(b.title);
      });

      expect(events[0].title, equals('Alpha Meeting'));
      expect(events[1].title, equals('Beta Meeting'));
      expect(events[2].title, equals('Zebra Meeting'));
    });

    test('should handle events without start time correctly', () {
      final events = [
        CalendarEvent(
          id: '1',
          title: 'Later Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          startTime: const TimeOfDay(hour: 12, minute: 0),
        ),
        CalendarEvent(
          id: '2',
          title: 'No Time Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: false,
          // No startTime specified
        ),
        CalendarEvent(
          id: '3',
          title: 'All Day Event',
          date: DateTime(2024, 6, 15),
          trainingSplitId: 'split-1',
          isAllDay: true,
        ),
      ];

      // Apply sorting logic
      events.sort((a, b) {
        if (a.isAllDay && !b.isAllDay) return -1;
        if (!a.isAllDay && b.isAllDay) return 1;
        if (a.isAllDay && b.isAllDay) {
          return a.title.compareTo(b.title);
        }
        final aTime = a.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final bTime = b.startTime ?? const TimeOfDay(hour: 0, minute: 0);
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        final timeComparison = aMinutes.compareTo(bMinutes);
        return timeComparison != 0 ? timeComparison : a.title.compareTo(b.title);
      });

      // Expected: All Day Event, No Time Event (00:00), Later Event (12:00)
      expect(events[0].title, equals('All Day Event'));
      expect(events[1].title, equals('No Time Event'));
      expect(events[2].title, equals('Later Event'));
    });
  });
}