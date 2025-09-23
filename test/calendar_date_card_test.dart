import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/calendar_date_card.dart';
import 'package:universal/widgets/monthly_calendar_view.dart';

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

    testWidgets('should render card with monthly calendar view', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      expect(find.byType(MonthlyCalendarView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display initial selected date', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final monthlyCalendar = tester.widget<MonthlyCalendarView>(
        find.byType(MonthlyCalendarView),
      );
      
      expect(monthlyCalendar.selectedDate, equals(testDate));
    });

    testWidgets('should display month name and year', (tester) async {
      await tester.pumpWidget(createWidget(testDate));
      
      // Should show the month name and year
      expect(find.text('June 2024'), findsOneWidget);
      
      // Should show weekday headers
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('Sun'), findsOneWidget);
    });

    testWidgets('should call onDateChanged when date is tapped', (tester) async {
      await tester.pumpWidget(createWidget(testDate));
      
      // Find a day number to tap (day 10 should be visible)
      final day10 = find.text('10');
      expect(day10, findsOneWidget);
      
      // Tap on day 10
      await tester.tap(day10);
      await tester.pump();
      
      // Should have called onDateChanged with June 10, 2024
      final expectedDate = DateTime(2024, 6, 10);
      expect(changedDates, contains(expectedDate));
    });

    testWidgets('should handle different initial dates', (tester) async {
      final dates = [
        DateTime(2024, 1, 1),
        DateTime(2024, 12, 31),
        DateTime(2025, 6, 15),
      ];

      for (final date in dates) {
        await tester.pumpWidget(createWidget(date));

        final monthlyCalendar = tester.widget<MonthlyCalendarView>(
          find.byType(MonthlyCalendarView),
        );
        
        expect(monthlyCalendar.selectedDate, equals(date));
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

    group('navigation', () {
      testWidgets('should have navigation buttons', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Should have previous and next month buttons
        expect(find.byIcon(Icons.chevron_left), findsOneWidget);
        expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      });

      testWidgets('should navigate to next month when next button is tapped', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Tap next month button
        await tester.tap(find.byIcon(Icons.chevron_right));
        await tester.pump();

        // Should show July 2024
        expect(find.text('July 2024'), findsOneWidget);
      });

      testWidgets('should navigate to previous month when previous button is tapped', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Tap previous month button
        await tester.tap(find.byIcon(Icons.chevron_left));
        await tester.pump();

        // Should show May 2024
        expect(find.text('May 2024'), findsOneWidget);
      });
    });

    group('widget composition', () {
      testWidgets('should be properly structured with card and monthly calendar', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Verify the widget hierarchy exists
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(MonthlyCalendarView), findsOneWidget);
        
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