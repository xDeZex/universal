import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen Add row', () {
    testWidgets(
      'tapping "+ Add row" on a non-empty card copies the last row and '
      "opens the new row's editor",
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: RangeReps(min: 8, max: 12),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [planned],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-row-pe-1')),
        );
        await tester.pump();

        final rows = repository.routines.single.plannedExercises.single.rows;
        expect(rows, hasLength(2));
        expect((rows[1].reps as RangeReps).min, 8);
        expect((rows[1].reps as RangeReps).max, 12);
        expect(rows[1].weight.value, 60);
        expect(rows[1].weight.unit, WeightUnit.kg);

        expect(
          find.byKey(const ValueKey('row-pe-1-1-reps-min-value')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tapping "+ Add row" on an empty card defaults to fixed 1 rep / 0 kg '
      "and opens the new row's editor",
      (tester) async {
        final planned = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [planned],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-row-pe-1')),
        );
        await tester.pump();

        final rows = repository.routines.single.plannedExercises.single.rows;
        expect(rows, hasLength(1));
        expect((rows[0].reps as FixedReps).reps, 1);
        expect(rows[0].weight.value, 0);
        expect(rows[0].weight.unit, WeightUnit.kg);

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsOneWidget,
        );
      },
    );
  });
}
