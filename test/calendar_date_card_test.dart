import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/calendar_date_card.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('CalendarDateCard', () {
    late DateTime testDate;
    late List<DateTime> changedDates;

    setUp(() {
      testDate = DateTime(2024, 6, 15);
      changedDates = [];
    });

    Widget createWidget(DateTime selectedDate) {
      return MaterialApp(
        home: Scaffold(
          body: CalendarDateCard(
            selectedDate: selectedDate,
            onDateChanged: (date) => changedDates.add(date),
          ),
        ),
      );
    }

    testWidgets('should render card with calendar date picker', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });

    testWidgets('should display initial selected date', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final calendarPicker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      
      expect(calendarPicker.initialDate, equals(testDate));
    });

    testWidgets('should have correct date range constraints', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final calendarPicker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      
      expect(calendarPicker.firstDate, equals(DateTime(2020)));
      expect(calendarPicker.lastDate, equals(DateTime(2030)));
    });

    testWidgets('should call onDateChanged when date is selected', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      // Find and tap on a different date (this is tricky with CalendarDatePicker)
      // We'll verify the callback is properly wired
      final calendarPicker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      
      expect(calendarPicker.onDateChanged, isNotNull);
      
      // Simulate a date change by calling the callback directly
      final newDate = DateTime(2024, 6, 20);
      calendarPicker.onDateChanged(newDate);
      
      expect(changedDates, contains(newDate));
    });

    testWidgets('should handle different initial dates', (tester) async {
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
        DateTime(2025, 6, 15),
      ];

      for (final date in dates) {
        await tester.pumpWidget(createWidget(date));

        final calendarPicker = tester.widget<CalendarDatePicker>(
          find.byType(CalendarDatePicker),
        );
        
        expect(calendarPicker.initialDate, equals(date));
      }
    });

    testWidgets('should maintain proper padding', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final paddings = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      
      // Should have at least one padding widget with 16.0 all around
      expect(paddings, findsAtLeast(1));
      
      // Find the specific padding we added
      final mainPadding = tester.widgetList<Padding>(paddings)
          .where((p) => p.padding == const EdgeInsets.all(16.0))
          .first;
      
      expect(mainPadding.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('should have consistent key parameter', (tester) async {
      const testKey = Key('calendar_date_card_test');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarDateCard(
              key: testKey,
              selectedDate: testDate,
              onDateChanged: (date) => changedDates.add(date),
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    group('date constraints', () {
      testWidgets('should respect first date constraint', (tester) async {
        final validDate = DateTime(2025, 1, 1); // Use a valid date within range
        await tester.pumpWidget(createWidget(validDate));

        final calendarPicker = tester.widget<CalendarDatePicker>(
          find.byType(CalendarDatePicker),
        );
        
        expect(calendarPicker.firstDate, equals(DateTime(2020)));
      });

      testWidgets('should respect last date constraint', (tester) async {
        final validDate = DateTime(2029, 12, 31); // Use a valid date within range
        await tester.pumpWidget(createWidget(validDate));

        final calendarPicker = tester.widget<CalendarDatePicker>(
          find.byType(CalendarDatePicker),
        );
        
        expect(calendarPicker.lastDate, equals(DateTime(2030)));
      });
    });

    group('widget composition', () {
      testWidgets('should be properly structured with card and padding', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Verify the widget hierarchy exists
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(CalendarDatePicker), findsOneWidget);
        
        // Verify there are padding widgets inside the card
        final paddings = find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        );
        expect(paddings, findsAtLeast(1));
      });
    });
  });
}