import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/calendar_event_indicators.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('CalendarEventIndicators', () {
    Widget createWidget(List<CalendarEvent> events) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 50,
            height: 50,
            child: CalendarEventIndicators(events: events),
          ),
        ),
      );
    }

    testWidgets('should show empty state when no events', (tester) async {
      await tester.pumpWidget(createWidget([]));

      expect(find.byType(CalendarEventIndicators), findsOneWidget);
      expect(find.text('+'), findsNothing);
    });

    testWidgets('should show events that fit in available space', (tester) async {
      final events = List.generate(5, (index) => CalendarEvent(
        id: 'event_$index',
        title: 'Event $index',
        date: DateTime.now(),
        trainingSplitId: 'split_$index',
        type: CalendarEventType.workout,
        isCompleted: false,
      ));

      await tester.pumpWidget(createWidget(events));

      // In a 50x50 container, should show first 2 events
      for (int i = 0; i < 2; i++) {
        expect(find.text('Event $i'), findsOneWidget);
      }

      // Should not show events that don't fit
      for (int i = 2; i < 5; i++) {
        expect(find.text('Event $i'), findsNothing);
      }

      // Should show overflow indicator
      expect(find.text('+3 more'), findsOneWidget);
    });

    testWidgets('should show overflow indicator when more events than fit', (tester) async {
      final events = List.generate(8, (index) => CalendarEvent(
        id: 'event_$index',
        title: 'Event $index',
        date: DateTime.now(),
        trainingSplitId: 'split_$index',
        type: CalendarEventType.workout,
        isCompleted: false,
      ));

      await tester.pumpWidget(createWidget(events));

      // Should show first 2 events (that fit in 50x50)
      for (int i = 0; i < 2; i++) {
        expect(find.text('Event $i'), findsOneWidget);
      }

      // Should not show events beyond 2
      for (int i = 2; i < 8; i++) {
        expect(find.text('Event $i'), findsNothing);
      }

      // Should show overflow indicator
      expect(find.text('+6 more'), findsOneWidget);
    });

    testWidgets('should handle many events without visual overflow', (tester) async {
      // Create 20 events to test extreme overflow
      final events = List.generate(20, (index) => CalendarEvent(
        id: 'event_$index',
        title: 'Very Long Event Title $index That Could Cause Overflow',
        date: DateTime.now(),
        trainingSplitId: 'split_$index',
        type: CalendarEventType.workout,
        isCompleted: false,
      ));

      await tester.pumpWidget(createWidget(events));

      // Should show first 2 events that fit in the constrained space
      for (int i = 0; i < 2; i++) {
        expect(find.textContaining('Very Long Event Title $i'), findsOneWidget);
      }

      // Should show overflow indicator with correct count
      expect(find.text('+18 more'), findsOneWidget);

      // Verify no visual overflow by checking that the widget doesn't cause render errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('should truncate long event titles', (tester) async {
      final events = [
        CalendarEvent(
          id: 'event_1',
          title: 'This is an extremely long event title that should be truncated to prevent overflow',
          date: DateTime.now(),
          trainingSplitId: 'split_1',
          type: CalendarEventType.workout,
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(createWidget(events));

      // Text should be present but truncated
      expect(find.byType(Text), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should show different event types with correct colors', (tester) async {
      final events = [
        CalendarEvent(
          id: 'workout',
          title: 'Workout',
          date: DateTime.now(),
          trainingSplitId: 'split_workout',
          type: CalendarEventType.workout,
          isCompleted: false,
        ),
        CalendarEvent(
          id: 'rest',
          title: 'Rest Day',
          date: DateTime.now(),
          trainingSplitId: 'split_rest',
          type: CalendarEventType.restDay,
          isCompleted: false,
        ),
        CalendarEvent(
          id: 'general',
          title: 'General',
          date: DateTime.now(),
          trainingSplitId: 'split_general',
          type: CalendarEventType.general,
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(createWidget(events));

      // Should show first 2 events in the limited space
      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Rest Day'), findsOneWidget);
      expect(find.text('General'), findsNothing); // Third event doesn't fit
      expect(find.text('+1 more'), findsOneWidget);
    });

    testWidgets('should handle completed vs incomplete events', (tester) async {
      final events = [
        CalendarEvent(
          id: 'completed',
          title: 'Completed Event',
          date: DateTime.now(),
          trainingSplitId: 'split_completed',
          type: CalendarEventType.workout,
          isCompleted: true,
        ),
        CalendarEvent(
          id: 'incomplete',
          title: 'Incomplete Event',
          date: DateTime.now(),
          trainingSplitId: 'split_incomplete',
          type: CalendarEventType.workout,
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(createWidget(events));

      expect(find.text('Completed Event'), findsOneWidget);
      expect(find.text('Incomplete Event'), findsOneWidget);
    });
  });
}