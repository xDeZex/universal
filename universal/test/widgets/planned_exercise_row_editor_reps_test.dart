import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'planned_exercise_row_editor_test_helpers.dart';

void main() {
  const defaultWeight = PlannedWeight(value: 0, unit: WeightUnit.kg);

  IconButton findButton(WidgetTester tester, String key) =>
      tester.widget<IconButton>(find.byKey(ValueKey(key)));

  group('PlannedExerciseRowEditor reps', () {
    testWidgets('renders a single reps stepper for FixedReps', (tester) async {
      await pumpEditor(
        tester,
        row: const PlannedExerciseRow(
          reps: FixedReps(8),
          weight: defaultWeight,
        ),
      );

      expect(find.byKey(const ValueKey('row-reps-value')), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.byKey(const ValueKey('row-reps-min-value')), findsNothing);
      expect(find.byKey(const ValueKey('row-reps-max-value')), findsNothing);
    });

    testWidgets(
      'renders two reps steppers joined by a range toggle for RangeReps',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: defaultWeight,
          ),
        );

        expect(
          find.byKey(const ValueKey('row-reps-min-value')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('row-reps-max-value')),
          findsOneWidget,
        );
        expect(find.text('8'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.byKey(const ValueKey('row-range-toggle')), findsOneWidget);
        expect(find.byKey(const ValueKey('row-reps-value')), findsNothing);
      },
    );

    testWidgets(
      'adjusting the fixed-reps stepper calls the update callback immediately',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: FixedReps(8),
            weight: defaultWeight,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('row-reps-increment')));
        await tester.pump();

        expect(find.text('9'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the range toggle on a fixed row converts it to a range',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: FixedReps(8),
            weight: defaultWeight,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('row-range-toggle')));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-reps-min-value')),
          findsOneWidget,
        );
        expect(find.text('8'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
      },
    );

    testWidgets(
      'tapping the range toggle on a ranged row converts it to fixed',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: defaultWeight,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('row-range-toggle')));
        await tester.pump();

        expect(find.byKey(const ValueKey('row-reps-value')), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.byKey(const ValueKey('row-reps-min-value')), findsNothing);
      },
    );

    testWidgets(
      "the max stepper's decrement is disabled when max == min + 1, and the "
      "min stepper's increment is disabled when min == max - 1",
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 9),
            weight: defaultWeight,
          ),
        );

        expect(findButton(tester, 'row-reps-max-decrement').onPressed, isNull);
        expect(findButton(tester, 'row-reps-min-increment').onPressed, isNull);
      },
    );

    testWidgets(
      'any reps stepper (fixed value, or either bound of a range) has its '
      'decrement disabled once its value is 1',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: FixedReps(1),
            weight: defaultWeight,
          ),
        );

        expect(findButton(tester, 'row-reps-decrement').onPressed, isNull);
      },
    );

    testWidgets(
      "the range min stepper's decrement is disabled once its value is 1",
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 1, max: 5),
            weight: defaultWeight,
          ),
        );

        expect(findButton(tester, 'row-reps-min-decrement').onPressed, isNull);
      },
    );

    testWidgets(
      'adjusting the range min stepper applies immediately, keeping max',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: defaultWeight,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('row-reps-min-increment')));
        await tester.pump();

        expect(find.text('9'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
      },
    );

    testWidgets(
      'adjusting the range max stepper applies immediately, keeping min',
      (tester) async {
        await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: defaultWeight,
          ),
        );

        await tester.tap(find.byKey(const ValueKey('row-reps-max-decrement')));
        await tester.pump();

        expect(find.text('8'), findsOneWidget);
        expect(find.text('11'), findsOneWidget);
      },
    );
  });
}
