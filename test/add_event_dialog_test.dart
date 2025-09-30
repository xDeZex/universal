import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/calendar_event.dart';
import 'package:universal/widgets/add_event_dialog.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('AddEventDialog', () {
    late DateTime testDate;
    late List<CalendarEvent> capturedEvents;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      capturedEvents = [];
    });

    void onEventCreated(CalendarEvent event) {
      capturedEvents.add(event);
    }

    Future<void> pumpDialog(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddEventDialog(
                selectedDate: testDate,
                onEventCreated: onEventCreated,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    group('Widget Structure', () {
      testWidgets('should render all form fields', (tester) async {
        await pumpDialog(tester);

        expect(find.text('Add Event for Jan 15, 2024'), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2)); // Title and Description
        expect(find.byType(DropdownButtonFormField<CalendarEventType>), findsOneWidget);
        expect(find.byType(CheckboxListTile), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Add Event'), findsOneWidget);
      });

      testWidgets('should show all-day checkbox checked by default', (tester) async {
        await pumpDialog(tester);

        final checkbox = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile));
        expect(checkbox.value, isTrue);
        expect(find.text('All day'), findsOneWidget);
      });

      testWidgets('should not show time section when all-day is checked', (tester) async {
        await pumpDialog(tester);

        expect(find.text('Start Time'), findsNothing);
        expect(find.text('Duration (Optional)'), findsNothing);
      });

      testWidgets('should show time section when all-day is unchecked', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('Duration (Optional)'), findsOneWidget);
        expect(find.text('Select time'), findsOneWidget);
        expect(find.text('No end time'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('should require event title', (tester) async {
        await pumpDialog(tester);

        // Try to submit without title
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(find.text('Please enter an event title'), findsOneWidget);
        expect(capturedEvents, isEmpty);
      });

      testWidgets('should accept valid form data', (tester) async {
        await pumpDialog(tester);

        // Fill in title
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.length, equals(1));
        expect(capturedEvents.first.title, equals('Test Event'));
        expect(capturedEvents.first.isAllDay, isTrue);
      });

      testWidgets('should trim whitespace from title', (tester) async {
        await pumpDialog(tester);

        // Fill in title with whitespace
        await tester.enterText(find.byType(TextFormField).first, '  Test Event  ');
        await tester.pumpAndSettle();

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.title, equals('Test Event'));
      });
    });

    group('Event Type Selection', () {
      testWidgets('should default to general event type', (tester) async {
        await pumpDialog(tester);

        // Check that 'General' text is displayed (indicating default selection)
        expect(find.text('General'), findsOneWidget);
      });

      testWidgets('should allow changing event type', (tester) async {
        await pumpDialog(tester);

        // Open dropdown
        await tester.tap(find.byType(DropdownButtonFormField<CalendarEventType>));
        await tester.pumpAndSettle();

        // Select workout type
        await tester.tap(find.text('Workout').last);
        await tester.pumpAndSettle();

        // Fill in title and submit
        await tester.enterText(find.byType(TextFormField).first, 'Workout Event');
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.type, equals(CalendarEventType.workout));
      });

      testWidgets('should show correct icons for event types', (tester) async {
        await pumpDialog(tester);

        // Open dropdown
        await tester.tap(find.byType(DropdownButtonFormField<CalendarEventType>));
        await tester.pumpAndSettle();

        // Check that icons are present
        expect(find.byIcon(Icons.fitness_center), findsOneWidget); // Workout
        expect(find.byIcon(Icons.hotel), findsOneWidget); // Rest Day
        expect(find.byIcon(Icons.event), findsAtLeastNWidgets(1)); // General
      });
    });

    group('All-day Toggle', () {
      testWidgets('should toggle all-day state', (tester) async {
        await pumpDialog(tester);

        final checkbox = find.byType(CheckboxListTile);

        // Initially checked (all-day)
        expect(tester.widget<CheckboxListTile>(checkbox).value, isTrue);

        // Uncheck
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(checkbox).value, isFalse);

        // Check again
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<CheckboxListTile>(checkbox).value, isTrue);
      });

      testWidgets('should hide time fields when switching to all-day', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day to show time fields
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Start Time'), findsOneWidget);

        // Check all-day again to hide time fields
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Start Time'), findsNothing);
      });
    });

    group('Time Selection', () {
      testWidgets('should show start time selector when not all-day', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Start Time'), findsOneWidget);
        expect(find.text('Select time'), findsOneWidget);
      });

      testWidgets('should show duration selector when not all-day', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(find.text('Duration (Optional)'), findsOneWidget);
        expect(find.text('No end time'), findsOneWidget);
      });

      testWidgets('should open duration dialog when duration field is tapped', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        // Tap duration field
        await tester.tap(find.text('No end time'));
        await tester.pumpAndSettle();

        expect(find.text('Select Duration'), findsOneWidget);
        expect(find.text('15m'), findsOneWidget);
        expect(find.text('30m'), findsOneWidget);
        expect(find.text('1h'), findsOneWidget);
      });

      testWidgets('should allow selecting duration from dialog', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        // Tap duration field
        await tester.tap(find.text('No end time'));
        await tester.pumpAndSettle();

        // Select 1 hour
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();

        expect(find.text('1h'), findsOneWidget);
        expect(find.text('No end time'), findsNothing);
      });

      testWidgets('should allow clearing duration', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        // Set duration first
        await tester.tap(find.text('No end time'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();

        expect(find.text('1h'), findsOneWidget);

        // Clear duration
        await tester.tap(find.text('1h'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('No end time'));
        await tester.pumpAndSettle();

        expect(find.text('No end time'), findsOneWidget);
      });
    });

    group('Description Field', () {
      testWidgets('should handle optional description', (tester) async {
        await pumpDialog(tester);

        // Fill in title only
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.description, isNull);
      });

      testWidgets('should include description when provided', (tester) async {
        await pumpDialog(tester);

        // Fill in title and description
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.enterText(find.byType(TextFormField).last, 'Test Description');

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.description, equals('Test Description'));
      });

      testWidgets('should trim whitespace from description', (tester) async {
        await pumpDialog(tester);

        // Fill in title and description with whitespace
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.enterText(find.byType(TextFormField).last, '  Test Description  ');

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.description, equals('Test Description'));
      });

      testWidgets('should treat empty description as null', (tester) async {
        await pumpDialog(tester);

        // Fill in title and empty description
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.enterText(find.byType(TextFormField).last, '   ');

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(capturedEvents.first.description, isNull);
      });
    });

    group('Event Creation', () {
      testWidgets('should create all-day event correctly', (tester) async {
        await pumpDialog(tester);

        // Fill form for all-day event
        await tester.enterText(find.byType(TextFormField).first, 'All Day Event');
        await tester.enterText(find.byType(TextFormField).last, 'All day description');

        // Submit form
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        final event = capturedEvents.first;
        expect(event.title, equals('All Day Event'));
        expect(event.description, equals('All day description'));
        expect(event.date, equals(testDate));
        expect(event.trainingSplitId, equals('user_created'));
        expect(event.type, equals(CalendarEventType.general));
        expect(event.isAllDay, isTrue);
        expect(event.startTime, isNull);
        expect(event.duration, isNull);
        expect(event.isCompleted, isFalse);
      });

      testWidgets('should create timed event without duration', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        // Fill form
        await tester.enterText(find.byType(TextFormField).first, 'Timed Event');

        // Submit form (without setting time - should still work)
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        final event = capturedEvents.first;
        expect(event.title, equals('Timed Event'));
        expect(event.isAllDay, isFalse);
        expect(event.startTime, isNull); // No time was actually selected
        expect(event.duration, isNull);
      });

      testWidgets('should generate event IDs with correct format', (tester) async {
        await pumpDialog(tester);

        // Create event
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        // ID should have correct format (event_ + timestamp)
        final eventId = capturedEvents.first.id;
        expect(eventId, startsWith('event_'));
        expect(eventId.length, greaterThan(6)); // 'event_' + timestamp
        expect(eventId.substring(6), matches(RegExp(r'^\d+$'))); // timestamp is numeric
      });
    });

    group('Dialog Navigation', () {
      testWidgets('should close dialog when Cancel is tapped', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => SingleChildScrollView(
                        child: AddEventDialog(
                          selectedDate: testDate,
                          onEventCreated: onEventCreated,
                        ),
                      ),
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(AddEventDialog), findsOneWidget);

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.byType(AddEventDialog), findsNothing);
        expect(capturedEvents, isEmpty);
      });

      testWidgets('should close dialog when event is created', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => SingleChildScrollView(
                        child: AddEventDialog(
                          selectedDate: testDate,
                          onEventCreated: onEventCreated,
                        ),
                      ),
                    ),
                    child: const Text('Open Dialog'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open dialog
        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.byType(AddEventDialog), findsOneWidget);

        // Fill and submit form
        await tester.enterText(find.byType(TextFormField).first, 'Test Event');
        await tester.tap(find.text('Add Event'));
        await tester.pumpAndSettle();

        expect(find.byType(AddEventDialog), findsNothing);
        expect(capturedEvents.length, equals(1));
      });
    });

    group('Date Formatting', () {
      testWidgets('should format different dates correctly', (tester) async {
        final testDates = [
          DateTime(2024, 1, 1),   // Jan 1, 2024
          DateTime(2024, 12, 31), // Dec 31, 2024
          DateTime(2023, 6, 15),  // Jun 15, 2023
        ];

        final expectedFormats = [
          'Jan 1, 2024',
          'Dec 31, 2024',
          'Jun 15, 2023',
        ];

        for (int i = 0; i < testDates.length; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: AddEventDialog(
                  selectedDate: testDates[i],
                  onEventCreated: onEventCreated,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Add Event for ${expectedFormats[i]}'), findsOneWidget);
        }
      });
    });

    group('Duration Formatting', () {
      testWidgets('should format various durations correctly', (tester) async {
        await pumpDialog(tester);

        // Uncheck all-day
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        // Open duration dialog
        await tester.tap(find.text('No end time'));
        await tester.pumpAndSettle();

        // Check that common durations are formatted correctly
        expect(find.text('15m'), findsOneWidget);
        expect(find.text('30m'), findsOneWidget);
        expect(find.text('45m'), findsOneWidget);
        expect(find.text('1h'), findsOneWidget);
        expect(find.text('1h 30m'), findsOneWidget);
        expect(find.text('2h'), findsOneWidget);
        expect(find.text('3h'), findsOneWidget);
        expect(find.text('4h'), findsOneWidget);
      });
    });
  });
}