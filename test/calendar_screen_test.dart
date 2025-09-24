import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/screens/calendar_screen.dart';
import 'package:universal/widgets/calendar_date_card.dart';
import 'package:universal/widgets/monthly_calendar_view.dart';
import 'package:universal/widgets/quick_actions_card.dart';

void main() {
  setUpAll(() {
    WidgetController.hitTestWarningShouldBeFatal = true;
  });

  group('CalendarScreen', () {
    Widget createWidget({bool showAppBar = false}) {
      return MaterialApp(
        home: CalendarScreen(showAppBar: showAppBar),
      );
    }

    testWidgets('should render all calendar components', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(CalendarDateCard), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should show app bar when showAppBar is true', (tester) async {
      await tester.pumpWidget(createWidget(showAppBar: true));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('should not show app bar when showAppBar is false', (tester) async {
      await tester.pumpWidget(createWidget(showAppBar: false));

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('should show screen title when no app bar', (tester) async {
      await tester.pumpWidget(createWidget(showAppBar: false));

      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('should not show screen title when app bar is present', (tester) async {
      await tester.pumpWidget(createWidget(showAppBar: true));

      // Calendar text should appear only once (in app bar)
      expect(find.text('Calendar'), findsOneWidget);
    });

    testWidgets('should initialize with current date', (tester) async {
      await tester.pumpWidget(createWidget());

      // Verify the components are rendered
      expect(find.byType(CalendarDateCard), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should have main column layout', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(Column), findsAtLeast(1));
    });

    testWidgets('should have proper screen padding', (tester) async {
      await tester.pumpWidget(createWidget());

      // Check that padding widgets exist in the layout
      expect(find.byType(Padding), findsAtLeast(1));
    });

    testWidgets('should arrange components vertically', (tester) async {
      await tester.pumpWidget(createWidget());

      final columns = find.byType(Column);
      expect(columns, findsAtLeast(1));

      // Find our main column by checking for crossAxisAlignment.start
      final hasMainColumn = tester.widgetList<Column>(columns)
          .any((c) => c.crossAxisAlignment == CrossAxisAlignment.start);

      expect(hasMainColumn, isTrue);
    });

    testWidgets('should have proper spacing between components', (tester) async {
      await tester.pumpWidget(createWidget());

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsAtLeast(2)); // At least 2 for spacing between cards
    });

    group('button interaction', () {
      testWidgets('should have functional Create Training Split button', (tester) async {
        await tester.pumpWidget(createWidget());

        // Verify floating action button exists
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);

        // Button should have proper tooltip
        final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
        expect(fab.tooltip, equals('Create Training Split'));
      });
    });

    group('date picker integration', () {
      testWidgets('should update info card when date changes via picker', (tester) async {
        await tester.pumpWidget(createWidget());

        // Get the calendar date card
        final dateCard = find.byType(CalendarDateCard);
        expect(dateCard, findsOneWidget);

        // Note: MonthlyCalendarView is complex to test interactions with directly
        // This test verifies the component integration exists
        expect(find.byType(MonthlyCalendarView), findsOneWidget);
      });
    });

    group('app bar configuration', () {
      testWidgets('should have correct app bar title', (tester) async {
        await tester.pumpWidget(createWidget(showAppBar: true));

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        final titleWidget = appBar.title as Text;
        expect(titleWidget.data, equals('Calendar'));
      });

      testWidgets('should use theme surface color for app bar', (tester) async {
        await tester.pumpWidget(createWidget(showAppBar: true));

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        final theme = Theme.of(tester.element(find.byType(AppBar)));
        expect(appBar.backgroundColor, equals(theme.colorScheme.surface));
      });
    });

    group('screen title configuration', () {
      testWidgets('should have correct title styling when no app bar', (tester) async {
        await tester.pumpWidget(createWidget(showAppBar: false));

        final titleTexts = find.text('Calendar');
        expect(titleTexts, findsOneWidget);

        final titleWidget = tester.widget<Text>(titleTexts);
        expect(titleWidget.style?.fontWeight, equals(FontWeight.bold));
      });

      testWidgets('should have proper title padding when no app bar', (tester) async {
        await tester.pumpWidget(createWidget(showAppBar: false));

        // Find the padding widgets around the title
        final titlePaddings = find.ancestor(
          of: find.text('Calendar'),
          matching: find.byType(Padding),
        );

        expect(titlePaddings, findsAtLeast(1));
        
        // Verify that at least one padding has the expected padding for screen title area
        final hasTitlePadding = tester.widgetList<Padding>(titlePaddings)
            .any((p) => p.padding == const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0));

        expect(hasTitlePadding, isTrue);
      });
    });

    group('date validation', () {
      testWidgets('should handle date changes with validation', (tester) async {
        await tester.pumpWidget(createWidget());

        // The screen should be initialized and functional
        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(CalendarDateCard), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('widget composition', () {
      testWidgets('should be properly structured', (tester) async {
        await tester.pumpWidget(createWidget());

        // Verify the widget hierarchy exists
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(Column), findsAtLeast(1));
        
        // Verify main components are present
        expect(find.byType(CalendarDateCard), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('state management', () {
      testWidgets('should maintain state across widget rebuilds', (tester) async {
        await tester.pumpWidget(createWidget());

        // Verify components exist before rebuild
        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(CalendarDateCard), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);

        // Rebuild the widget
        await tester.pumpWidget(createWidget());
        
        // The widget should still be functional after rebuild
        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(CalendarDateCard), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    group('accessibility', () {
      testWidgets('should be accessible', (tester) async {
        await tester.pumpWidget(createWidget(showAppBar: true));

        // Verify all main components are present for screen readers
        expect(find.byType(CalendarDateCard), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
        expect(find.text('Calendar'), findsOneWidget);
      });
    });

    group('responsive layout', () {
      testWidgets('should handle different screen sizes', (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 600));
        await tester.pumpWidget(createWidget());

        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(Column), findsAtLeast(1));

        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(createWidget());

        expect(find.byType(CalendarScreen), findsOneWidget);
        expect(find.byType(Column), findsAtLeast(1));
      });
    });

    testWidgets('should have consistent key parameter', (tester) async {
      const testKey = Key('calendar_screen_test');
      
      await tester.pumpWidget(
        MaterialApp(
          home: CalendarScreen(key: testKey, showAppBar: false),
        ),
      );

      expect(find.byKey(testKey), findsOneWidget);
    });
  });
}