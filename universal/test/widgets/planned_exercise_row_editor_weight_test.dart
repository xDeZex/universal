import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'planned_exercise_row_editor_test_helpers.dart';

void main() {
  group('PlannedExerciseRowEditor weight', () {
    testWidgets('renders the shared weight stepper and unit toggle', (
      tester,
    ) async {
      await pumpEditor(
        tester,
        row: const PlannedExerciseRow(
          reps: FixedReps(8),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        ),
      );

      expect(
        find.byKey(const ValueKey('row-weight-stepper-value')),
        findsOneWidget,
      );
      expect(find.text('60'), findsOneWidget);
      expect(find.byKey(const ValueKey('row-unit-kg')), findsOneWidget);
      expect(find.byKey(const ValueKey('row-unit-lbs')), findsOneWidget);
    });

    testWidgets(
      'adjusting the weight stepper calls onChanged with the new value',
      (tester) async {
        final row = await pumpEditor(
          tester,
          row: const PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        );
        expect(row.weight.value, 60);

        await tester.tap(
          find.byKey(const ValueKey('row-weight-stepper-increment')),
        );
        await tester.pump();

        expect(find.text('62.5'), findsOneWidget);
      },
    );

    testWidgets('tapping the lbs segment calls onChanged with the new unit', (
      tester,
    ) async {
      await pumpEditor(
        tester,
        row: const PlannedExerciseRow(
          reps: FixedReps(8),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('row-unit-lbs')));
      await tester.pump();

      final segmentedButton = tester.widget<SegmentedButton<WeightUnit>>(
        find.ancestor(
          of: find.byKey(const ValueKey('row-unit-lbs')),
          matching: find.byType(SegmentedButton<WeightUnit>),
        ),
      );
      expect(segmentedButton.selected, {WeightUnit.lbs});
    });
  });
}
