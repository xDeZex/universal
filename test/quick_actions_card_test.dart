import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/quick_actions_card.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('QuickActionsCard', () {
    late int todayPressedCount;
    late int tomorrowPressedCount;

    setUp(() {
      todayPressedCount = 0;
      tomorrowPressedCount = 0;
    });

    Widget createWidget() {
      return MaterialApp(
        home: Scaffold(
          body: QuickActionsCard(
            onTodayPressed: () => todayPressedCount++,
            onTomorrowPressed: () => tomorrowPressedCount++,
          ),
        ),
      );
    }

    testWidgets('should render card with quick actions', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('should have two elevated buttons', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    testWidgets('should call onTodayPressed when Today button is tapped', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Today'));
      await tester.pump();

      expect(todayPressedCount, equals(1));
      expect(tomorrowPressedCount, equals(0));
    });

    testWidgets('should call onTomorrowPressed when Tomorrow button is tapped', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Tomorrow'));
      await tester.pump();

      expect(tomorrowPressedCount, equals(1));
      expect(todayPressedCount, equals(0));
    });

    testWidgets('should handle multiple button taps', (tester) async {
      await tester.pumpWidget(createWidget());

      // Tap Today button multiple times
      await tester.tap(find.text('Today'));
      await tester.pump();
      await tester.tap(find.text('Today'));
      await tester.pump();

      // Tap Tomorrow button once
      await tester.tap(find.text('Tomorrow'));
      await tester.pump();

      expect(todayPressedCount, equals(2));
      expect(tomorrowPressedCount, equals(1));
    });

    testWidgets('should have proper title styling', (tester) async {
      await tester.pumpWidget(createWidget());

      final titleText = tester.widget<Text>(
        find.text('Quick Actions'),
      );

      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should maintain proper card padding', (tester) async {
      await tester.pumpWidget(createWidget());

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
      await tester.pumpWidget(createWidget());

      final columns = find.descendant(
        of: find.byType(Card),
        matching: find.byType(Column),
      );
      
      expect(columns, findsAtLeastNWidgets(1));

      final columnWidget = tester.widget<Column>(columns.first);
      expect(columnWidget.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('should have proper spacing between elements', (tester) async {
      await tester.pumpWidget(createWidget());

      // Check that SizedBox widgets are present for spacing
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeast(1)); // At least 1 SizedBox for spacing
    });

    testWidgets('should arrange buttons in a row', (tester) async {
      await tester.pumpWidget(createWidget());

      final row = find.descendant(
        of: find.byType(Column),
        matching: find.byType(Row),
      );
      
      expect(row, findsOneWidget);

      // Both buttons should be in the row
      expect(
        find.descendant(
          of: row,
          matching: find.byType(ElevatedButton),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('should have expanded buttons for equal width', (tester) async {
      await tester.pumpWidget(createWidget());

      final expandedWidgets = find.byType(Expanded);
      expect(expandedWidgets, findsNWidgets(2));

      // Each expanded widget should contain an ElevatedButton
      for (final expandedFinder in [expandedWidgets.first, expandedWidgets.last]) {
        expect(
          find.descendant(
            of: expandedFinder,
            matching: find.byType(ElevatedButton),
          ),
          findsOneWidget,
        );
      }
    });

    testWidgets('should have consistent spacing between buttons', (tester) async {
      await tester.pumpWidget(createWidget());

      final row = find.descendant(
        of: find.byType(Column),
        matching: find.byType(Row),
      );

      final sizedBoxInRow = find.descendant(
        of: row,
        matching: find.byType(SizedBox),
      );
      
      expect(sizedBoxInRow, findsOneWidget);

      final spacingBox = tester.widget<SizedBox>(sizedBoxInRow);
      expect(spacingBox.width, equals(8.0));
    });

    testWidgets('should have consistent key parameter', (tester) async {
      const testKey = Key('quick_actions_card_test');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionsCard(
              key: testKey,
              onTodayPressed: () => todayPressedCount++,
              onTomorrowPressed: () => tomorrowPressedCount++,
            ),
          ),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });

    group('button behavior', () {
      testWidgets('should maintain button enabled state', (tester) async {
        await tester.pumpWidget(createWidget());

        final todayButton = find.widgetWithText(ElevatedButton, 'Today');
        final tomorrowButton = find.widgetWithText(ElevatedButton, 'Tomorrow');

        expect(todayButton, findsOneWidget);
        expect(tomorrowButton, findsOneWidget);

        // Buttons should be enabled (onPressed is not null)
        final todayButtonWidget = tester.widget<ElevatedButton>(todayButton);
        final tomorrowButtonWidget = tester.widget<ElevatedButton>(tomorrowButton);

        expect(todayButtonWidget.onPressed, isNotNull);
        expect(tomorrowButtonWidget.onPressed, isNotNull);
      });
    });

    group('accessibility', () {
      testWidgets('should have accessible button labels', (tester) async {
        await tester.pumpWidget(createWidget());

        // Verify button text is visible and accessible
        expect(find.text('Today'), findsOneWidget);
        expect(find.text('Tomorrow'), findsOneWidget);
      });
    });

    group('widget composition', () {
      testWidgets('should be properly structured', (tester) async {
        await tester.pumpWidget(createWidget());

        // Verify the widget hierarchy exists
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Column), findsAtLeast(1));
        expect(find.byType(Row), findsOneWidget);
        
        // Verify there are padding widgets inside the card
        final paddings = find.descendant(
          of: find.byType(Card),
          matching: find.byType(Padding),
        );
        expect(paddings, findsAtLeast(1));
      });
    });

    group('interaction testing', () {
      testWidgets('should handle rapid successive taps', (tester) async {
        await tester.pumpWidget(createWidget());

        // Rapid taps on Today button
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Today'));
          await tester.pump(const Duration(milliseconds: 10));
        }

        expect(todayPressedCount, equals(5));
      });

      testWidgets('should handle alternating button taps', (tester) async {
        await tester.pumpWidget(createWidget());

        await tester.tap(find.text('Today'));
        await tester.pump();
        await tester.tap(find.text('Tomorrow'));
        await tester.pump();
        await tester.tap(find.text('Today'));
        await tester.pump();

        expect(todayPressedCount, equals(2));
        expect(tomorrowPressedCount, equals(1));
      });
    });
  });
}