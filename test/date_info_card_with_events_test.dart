import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/date_info_card.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('DateInfoCard with Events', () {
    final testDate = DateTime(2024, 1, 15);
    
    Widget createWidget({List<CalendarEvent>? events}) {
      return MaterialApp(
        home: Scaffold(
          body: DateInfoCard(
            selectedDate: testDate,
            events: events ?? [],
          ),
        ),
      );
    }

    testWidgets('should show empty state when no events', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Training Events'), findsOneWidget);
      expect(find.text('No training events scheduled'), findsOneWidget);
    });

    testWidgets('should display workout events with fitness icons', (tester) async {
      final events = [
        CalendarEvent(
          id: 'event1',
          title: 'Push Day',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
        CalendarEvent(
          id: 'event2',
          title: 'Pull Day',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      expect(find.text('Training Events'), findsOneWidget);
      expect(find.text('Push Day'), findsOneWidget);
      expect(find.text('Pull Day'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsNWidgets(2));
      expect(find.text('No training events scheduled'), findsNothing);
    });

    testWidgets('should display rest day events with spa icons', (tester) async {
      final events = [
        CalendarEvent(
          id: 'rest1',
          title: 'Rest Day',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.restDay,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      expect(find.text('Training Events'), findsOneWidget);
      expect(find.text('Rest Day'), findsOneWidget);
      expect(find.byIcon(Icons.spa), findsOneWidget);
    });

    testWidgets('should show completed events with strikethrough and check icon', (tester) async {
      final events = [
        CalendarEvent(
          id: 'completed1',
          title: 'Completed Workout',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          isCompleted: true,
        ),
        CalendarEvent(
          id: 'pending1',
          title: 'Pending Workout',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          isCompleted: false,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      expect(find.text('Completed Workout'), findsOneWidget);
      expect(find.text('Pending Workout'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Only for completed
      expect(find.byIcon(Icons.fitness_center), findsNWidgets(2)); // Both have fitness icons
    });

    testWidgets('should display mixed event types correctly', (tester) async {
      final events = [
        CalendarEvent(
          id: 'workout1',
          title: 'Morning Workout',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
        CalendarEvent(
          id: 'rest1',
          title: 'Afternoon Rest',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.restDay,
        ),
        CalendarEvent(
          id: 'workout2',
          title: 'Evening Workout',
          date: testDate,
          trainingSplitId: 'split2',
          type: CalendarEventType.workout,
          isCompleted: true,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      expect(find.text('Morning Workout'), findsOneWidget);
      expect(find.text('Afternoon Rest'), findsOneWidget);
      expect(find.text('Evening Workout'), findsOneWidget);
      
      expect(find.byIcon(Icons.fitness_center), findsNWidgets(2));
      expect(find.byIcon(Icons.spa), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should handle Swedish characters in event titles', (tester) async {
      final events = [
        CalendarEvent(
          id: 'swedish1',
          title: 'Överkropp Träning',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      expect(find.text('Överkropp Träning'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('should maintain proper text styling for completed events', (tester) async {
      final events = [
        CalendarEvent(
          id: 'completed1',
          title: 'Completed Task',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
          isCompleted: true,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      final textWidget = tester.widget<Text>(find.text('Completed Task'));
      expect(textWidget.style?.decoration, equals(TextDecoration.lineThrough));
    });

    testWidgets('should arrange events vertically', (tester) async {
      final events = [
        CalendarEvent(
          id: 'event1',
          title: 'First Event',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
        CalendarEvent(
          id: 'event2',
          title: 'Second Event',
          date: testDate,
          trainingSplitId: 'split1',
          type: CalendarEventType.workout,
        ),
      ];

      await tester.pumpWidget(createWidget(events: events));

      final eventItems = find.byType(Padding);
      expect(eventItems, findsWidgets);
      
      // Both events should be present
      expect(find.text('First Event'), findsOneWidget);
      expect(find.text('Second Event'), findsOneWidget);
    });

    group('Widget Structure', () {
      testWidgets('should maintain card structure with events', (tester) async {
        final events = [
          CalendarEvent(
            id: 'event1',
            title: 'Test Event',
            date: testDate,
            trainingSplitId: 'split1',
            type: CalendarEventType.workout,
          ),
        ];

        await tester.pumpWidget(createWidget(events: events));

        expect(find.byType(Card), findsOneWidget);
        expect(find.text('Selected Date'), findsOneWidget);
        expect(find.text('Day of Week'), findsOneWidget);
        expect(find.text('Training Events'), findsOneWidget);
      });

      testWidgets('should have proper spacing between sections', (tester) async {
        await tester.pumpWidget(createWidget());

        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('should have accessible text for events', (tester) async {
        final events = [
          CalendarEvent(
            id: 'accessible1',
            title: 'Accessible Event',
            date: testDate,
            trainingSplitId: 'split1',
            type: CalendarEventType.workout,
          ),
        ];

        await tester.pumpWidget(createWidget(events: events));

        expect(find.text('Accessible Event'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      });
    });
  });
}