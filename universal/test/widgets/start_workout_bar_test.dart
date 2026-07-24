import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/widgets/start_workout_bar.dart';

void main() {
  Future<void> pumpBar(
    WidgetTester tester, {
    bool hasInProgress = false,
    VoidCallback? onPressed,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartWorkoutBar(
            hasInProgress: hasInProgress,
            onPressed: onPressed ?? () {},
          ),
        ),
      ),
    );
  }

  group('StartWorkoutBar', () {
    testWidgets('reads "Start Workout" as a full-width FilledButton when no '
        'Workout is in progress', (tester) async {
      await pumpBar(tester, hasInProgress: false);

      expect(find.text('Start Workout'), findsOneWidget);
      expect(find.text('Continue Workout'), findsNothing);

      final buttonFinder = find.ancestor(
        of: find.text('Start Workout'),
        matching: find.byType(FilledButton),
      );
      expect(buttonFinder, findsOneWidget);

      final buttonWidth = tester.getSize(buttonFinder).width;
      final containerWidth = tester
          .getSize(find.byKey(const ValueKey('start-workout-bar')))
          .width;
      expect(buttonWidth, containerWidth - 32);
    });

    testWidgets('reads "Continue Workout" when a Workout is in progress', (
      tester,
    ) async {
      await pumpBar(tester, hasInProgress: true);

      expect(find.text('Continue Workout'), findsOneWidget);
      expect(find.text('Start Workout'), findsNothing);
    });

    testWidgets('tapping the button calls onPressed', (tester) async {
      var pressed = false;
      await pumpBar(tester, onPressed: () => pressed = true);

      await tester.tap(find.text('Start Workout'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });
}
