import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/screens/day_detail_screen.dart';
import 'package:universal/services/training_split_service.dart';
import 'package:universal/models/calendar_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
    // Mock SharedPreferences for tests
    SharedPreferences.setMockInitialValues({});
  });

  group('Day Detail Event Ordering', () {
    late TrainingSplitService trainingSplitService;
    late DateTime testDate;

    setUp(() async {
      trainingSplitService = TrainingSplitService();
      await trainingSplitService.initialize();
      testDate = DateTime(2024, 6, 15);
    });

    tearDown(() {
      trainingSplitService.clearAllData();
    });

    Widget createWidget() {
      return MaterialApp(
        home: DayDetailScreen(
          selectedDate: testDate,
          trainingSplitService: trainingSplitService,
        ),
      );
    }

    testWidgets('should display all-day events before timed events', (tester) async {
      // Add test events
      final allDayEvent = CalendarEvent(
        id: 'all-day',
        title: 'All Day Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: true,
      );

      final timedEvent = CalendarEvent(
        id: 'timed',
        title: 'Timed Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 14, minute: 30),
      );

      trainingSplitService.addCalendarEvent(allDayEvent);
      trainingSplitService.addCalendarEvent(timedEvent);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check that both events are displayed
      expect(find.text('All Day Event'), findsOneWidget);
      expect(find.text('Timed Event'), findsOneWidget);
      expect(find.text('2 events'), findsOneWidget);

      // Get positions to verify order
      final allDayPosition = tester.getTopLeft(find.text('All Day Event')).dy;
      final timedEventPosition = tester.getTopLeft(find.text('Timed Event')).dy;

      // All-day event should appear before timed event
      expect(allDayPosition, lessThan(timedEventPosition));
    });

    testWidgets('should sort timed events by start time', (tester) async {
      // Add events in reverse chronological order
      final lateEvent = CalendarEvent(
        id: 'late',
        title: 'Late Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 18, minute: 0),
      );

      final earlyEvent = CalendarEvent(
        id: 'early',
        title: 'Early Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 8, minute: 0),
      );

      final middleEvent = CalendarEvent(
        id: 'middle',
        title: 'Middle Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 12, minute: 0),
      );

      // Add in random order
      trainingSplitService.addCalendarEvent(lateEvent);
      trainingSplitService.addCalendarEvent(earlyEvent);
      trainingSplitService.addCalendarEvent(middleEvent);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check that all events are displayed
      expect(find.text('Early Event'), findsOneWidget);
      expect(find.text('Middle Event'), findsOneWidget);
      expect(find.text('Late Event'), findsOneWidget);
      expect(find.text('3 events'), findsOneWidget);

      // Get positions to verify chronological order
      final earlyPosition = tester.getTopLeft(find.text('Early Event')).dy;
      final middlePosition = tester.getTopLeft(find.text('Middle Event')).dy;
      final latePosition = tester.getTopLeft(find.text('Late Event')).dy;

      // Events should be in chronological order
      expect(earlyPosition, lessThan(middlePosition));
      expect(middlePosition, lessThan(latePosition));
    });

    testWidgets('should sort events with same time alphabetically', (tester) async {
      final zebra = CalendarEvent(
        id: 'zebra',
        title: 'Zebra Meeting',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 10, minute: 0),
      );

      final alpha = CalendarEvent(
        id: 'alpha',
        title: 'Alpha Meeting',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 10, minute: 0),
      );

      // Add in reverse alphabetical order
      trainingSplitService.addCalendarEvent(zebra);
      trainingSplitService.addCalendarEvent(alpha);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check that both events are displayed
      expect(find.text('Alpha Meeting'), findsOneWidget);
      expect(find.text('Zebra Meeting'), findsOneWidget);
      expect(find.text('2 events'), findsOneWidget);

      // Get positions to verify alphabetical order
      final alphaPosition = tester.getTopLeft(find.text('Alpha Meeting')).dy;
      final zebraPosition = tester.getTopLeft(find.text('Zebra Meeting')).dy;

      // Alpha should come before Zebra
      expect(alphaPosition, lessThan(zebraPosition));
    });

    testWidgets('should display mixed events in correct order', (tester) async {
      // Create a mix of all-day and timed events
      final allDay = CalendarEvent(
        id: 'all-day',
        title: 'All Day Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: true,
      );

      final morning = CalendarEvent(
        id: 'morning',
        title: 'Morning Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 9, minute: 0),
      );

      final afternoon = CalendarEvent(
        id: 'afternoon',
        title: 'Afternoon Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 15, minute: 30),
      );

      // Add in random order
      trainingSplitService.addCalendarEvent(afternoon);
      trainingSplitService.addCalendarEvent(allDay);
      trainingSplitService.addCalendarEvent(morning);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check that all events are displayed
      expect(find.text('All Day Event'), findsOneWidget);
      expect(find.text('Morning Event'), findsOneWidget);
      expect(find.text('Afternoon Event'), findsOneWidget);
      expect(find.text('3 events'), findsOneWidget);

      // Get positions
      final allDayPosition = tester.getTopLeft(find.text('All Day Event')).dy;
      final morningPosition = tester.getTopLeft(find.text('Morning Event')).dy;
      final afternoonPosition = tester.getTopLeft(find.text('Afternoon Event')).dy;

      // Verify correct order: All Day, Morning (9:00), Afternoon (15:30)
      expect(allDayPosition, lessThan(morningPosition));
      expect(morningPosition, lessThan(afternoonPosition));
    });

    testWidgets('should handle empty state correctly', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No events scheduled'), findsOneWidget);
      expect(find.text('0 events'), findsOneWidget);
    });
  });
}