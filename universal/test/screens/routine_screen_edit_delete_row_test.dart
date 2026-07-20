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

  group('RoutineScreen Edit/delete row', () {
    testWidgets(
      'each row on an active Routine shows its reps/weight and an inline '
      'delete icon',
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
        await pumpRoutineScreen(
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

        expect(find.text('8–12 reps @ 60 kg'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('delete-planned-exercise-row-pe-1-0')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "adjusting an open row's reps stepper applies the change to the "
      'Planned Exercise immediately',
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
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
          find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
        );
        await tester.pump();

        await tester.tap(
          find.byKey(const ValueKey('row-pe-1-0-reps-increment')),
        );
        await tester.pump();

        final row =
            repository.routines.single.plannedExercises.single.rows.single;
        expect((row.reps as FixedReps).reps, 9);
      },
    );

    testWidgets(
      "tapping a row opens its editor; tapping it again collapses it",
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        await pumpRoutineScreen(
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

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsNothing,
        );

        await tester.tap(
          find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'tapping the delete icon on a row removes it immediately with no '
      'confirmation',
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
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
          find.byKey(const ValueKey('delete-planned-exercise-row-pe-1-0')),
        );
        await tester.pump();

        expect(
          repository.routines.single.plannedExercises.single.rows,
          isEmpty,
        );
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'deleting a row belonging to the Planned Exercise with a currently '
      'open editor closes that editor',
      (tester) async {
        final planned = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
            PlannedExerciseRow(
              reps: FixedReps(6),
              weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
            ),
          ],
        );
        await pumpRoutineScreen(
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
          find.byKey(const ValueKey('planned-exercise-row-pe-1-1')),
        );
        await tester.pump();
        expect(
          find.byKey(const ValueKey('row-pe-1-1-reps-value')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('delete-planned-exercise-row-pe-1-0')),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-pe-1-1-reps-value')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsNothing,
        );
      },
    );
  });
}
