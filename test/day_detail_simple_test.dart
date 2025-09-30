import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/screens/day_detail_screen.dart';
import 'package:universal/services/training_split_service.dart';
import 'package:universal/models/calendar_event.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('Day Detail Simple Test', () {
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

    testWidgets('should show empty state when no events', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('No events scheduled'), findsOneWidget);
      expect(find.text('0 events'), findsOneWidget);
    });

    testWidgets('should display events in correct order', (tester) async {
      // Add test events
      final allDayEvent = CalendarEvent(
        id: 'all-day',
        title: 'All Day Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: true,
      );

      final morningEvent = CalendarEvent(
        id: 'morning',
        title: 'Morning Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.workout,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 9, minute: 0),
      );

      final afternoonEvent = CalendarEvent(
        id: 'afternoon',
        title: 'Afternoon Event',
        date: testDate,
        trainingSplitId: 'split-1',
        type: CalendarEventType.general,
        isAllDay: false,
        startTime: const TimeOfDay(hour: 14, minute: 30),
      );

      trainingSplitService.addCalendarEvent(allDayEvent);
      trainingSplitService.addCalendarEvent(morningEvent);
      trainingSplitService.addCalendarEvent(afternoonEvent);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      // Check event count
      expect(find.text('3 events'), findsOneWidget);

      // Check that events are displayed
      expect(find.text('All Day Event'), findsOneWidget);
      expect(find.text('Morning Event'), findsOneWidget);
      expect(find.text('Afternoon Event'), findsOneWidget);

      // Get positions to verify order
      final allDayPosition = tester.getTopLeft(find.text('All Day Event')).dy;
      final morningPosition = tester.getTopLeft(find.text('Morning Event')).dy;
      final afternoonPosition = tester.getTopLeft(find.text('Afternoon Event')).dy;

      // All-day event should be first, then morning, then afternoon
      expect(allDayPosition, lessThan(morningPosition));
      expect(morningPosition, lessThan(afternoonPosition));
    });
  });
}