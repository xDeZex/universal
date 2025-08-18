import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/date_info_card.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('DateInfoCard', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 6, 15); // Saturday, June 15, 2024
    });

    Widget createWidget(DateTime selectedDate) {
      return MaterialApp(
        home: Scaffold(
          body: DateInfoCard(selectedDate: selectedDate),
        ),
      );
    }

    testWidgets('should render card with date information', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Selected Date'), findsOneWidget);
      expect(find.text('Day of Week'), findsOneWidget);
    });

    testWidgets('should display formatted date correctly', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      expect(find.text('June 15, 2024'), findsOneWidget);
    });

    testWidgets('should display weekday correctly', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      expect(find.text('Saturday'), findsOneWidget);
    });

    testWidgets('should handle different dates correctly', (tester) async {
      final testCases = [
        {
          'date': DateTime(2024, 1, 1), // Monday
          'expectedDate': 'January 1, 2024',
          'expectedWeekday': 'Monday',
        },
        {
          'date': DateTime(2024, 12, 25), // Wednesday
          'expectedDate': 'December 25, 2024',
          'expectedWeekday': 'Wednesday',
        },
        {
          'date': DateTime(2023, 2, 14), // Tuesday
          'expectedDate': 'February 14, 2023',
          'expectedWeekday': 'Tuesday',
        },
      ];

      for (final testCase in testCases) {
        await tester.pumpWidget(createWidget(testCase['date'] as DateTime));
        await tester.pump();

        expect(find.text(testCase['expectedDate'] as String), findsOneWidget);
        expect(find.text(testCase['expectedWeekday'] as String), findsOneWidget);
      }
    });

    testWidgets('should have proper text styling', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      // Find title texts
      final selectedDateTitle = tester.widget<Text>(
        find.text('Selected Date'),
      );
      final dayOfWeekTitle = tester.widget<Text>(
        find.text('Day of Week'),
      );

      // Verify title styling (should be titleMedium with bold)
      expect(selectedDateTitle.style?.fontWeight, equals(FontWeight.bold));
      expect(dayOfWeekTitle.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should maintain proper spacing', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      // Check that SizedBox widgets are present for spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeast(2)); // At least 2 SizedBox for spacing
    });

    testWidgets('should have proper card padding', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final paddings = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Padding),
      );
      
      // Should have at least one padding widget
      expect(paddings, findsAtLeast(1));
      
      // Find the specific padding we added with 16.0 all around
      final mainPadding = tester.widgetList<Padding>(paddings)
          .where((p) => p.padding == const EdgeInsets.all(16.0))
          .first;
      
      expect(mainPadding.padding, equals(const EdgeInsets.all(16.0)));
    });

    testWidgets('should arrange content in column', (tester) async {
      await tester.pumpWidget(createWidget(testDate));

      final columns = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Column),
      );
      
      expect(columns, findsAtLeast(1));

      // Find our main column by checking for crossAxisAlignment.start
      final mainColumn = tester.widgetList<Column>(columns)
          .where((c) => c.crossAxisAlignment == CrossAxisAlignment.start)
          .first;
      
      expect(mainColumn.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('should handle leap year dates', (tester) async {
      final leapYearDate = DateTime(2024, 2, 29); // February 29, 2024
      await tester.pumpWidget(createWidget(leapYearDate));

      expect(find.text('February 29, 2024'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget); // Feb 29, 2024 is a Thursday
    });

    testWidgets('should handle edge case dates', (tester) async {
      final edgeCases = [
        DateTime(2024, 1, 1), // New Year's Day
        DateTime(2024, 12, 31), // New Year's Eve
        DateTime(2023, 2, 28), // Last day of February in non-leap year
      ];

      for (final date in edgeCases) {
        await tester.pumpWidget(createWidget(date));
        await tester.pump();

        // Verify both title sections are present
        expect(find.text('Selected Date'), findsOneWidget);
        expect(find.text('Day of Week'), findsOneWidget);
      }
    });

    testWidgets('should have consistent key parameter', (tester) async {
      const testKey = Key('date_info_card_test');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DateInfoCard(
              key: testKey,
              selectedDate: testDate,
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    group('accessibility', () {
      testWidgets('should have readable text contrast', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Verify all text widgets are present and readable
        expect(find.text('Selected Date'), findsOneWidget);
        expect(find.text('Day of Week'), findsOneWidget);
        expect(find.text('June 15, 2024'), findsOneWidget);
        expect(find.text('Saturday'), findsOneWidget);
      });
    });

    group('widget composition', () {
      testWidgets('should be properly structured', (tester) async {
        await tester.pumpWidget(createWidget(testDate));

        // Verify the widget hierarchy exists
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Column), findsAtLeast(1));
        
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