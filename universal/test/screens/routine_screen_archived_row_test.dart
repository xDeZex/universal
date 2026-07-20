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

  group('RoutineScreen Row editing while archived', () {
    testWidgets("an archived Routine's cards hide the Add row control", (
      tester,
    ) async {
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
            archivedAt: DateTime(2026, 1, 1),
            plannedExercises: [planned],
          ),
        ],
        exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        routineId: 'routine-1',
      );

      expect(
        find.byKey(const ValueKey('add-planned-exercise-row-pe-1')),
        findsNothing,
      );
    });

    testWidgets(
      "an archived Routine's rows are not tappable and show no delete icon",
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
              archivedAt: DateTime(2026, 1, 1),
              plannedExercises: [planned],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        expect(
          find.byKey(const ValueKey('delete-planned-exercise-row-pe-1-0')),
          findsNothing,
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
      'archiving a Routine while one of its row editors is open closes '
      'that editor',
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

        await tester.tap(
          find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
        );
        await tester.pump();
        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('routine-archive-toggle')));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'unarchiving a Routine does not resurface a row editor that was open '
      'before it was archived',
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

        await tester.tap(
          find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
        );
        await tester.pump();
        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const ValueKey('routine-archive-toggle')));
        await tester.pump();
        await tester.tap(find.byKey(const ValueKey('routine-archive-toggle')));
        await tester.pump();

        expect(
          find.byKey(const ValueKey('row-pe-1-0-reps-value')),
          findsNothing,
        );
      },
    );
  });
}
