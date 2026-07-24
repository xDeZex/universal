import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'active_workout_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen add-Set bar target auto-prefill', () {
    testWidgets(
      'selecting an Exercise Entry with an unfilled target auto-prefills '
      'the weight and reps steppers from that target',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tapAndSettle(tester, 'entry-header-entry-1');

        expect(weightStepperValue(tester), '60');
        expect(repsStepperValue(tester), '8');
      },
    );

    testWidgets(
      'selecting an Exercise Entry whose targets are all already fulfilled '
      'resets the weight and reps steppers to zero',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 9, 0),
            ),
          ],
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tapAndSettle(tester, 'entry-header-entry-1');

        expect(tester.takeException(), isNull);
        expect(weightStepperValue(tester), '0');
        expect(repsStepperValue(tester), '0');
      },
    );

    testWidgets(
      'a ranged target prefills the reps stepper with its minimum, not its '
      'maximum',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: RangeReps(min: 5, max: 10),
              weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tapAndSettle(tester, 'entry-header-entry-1');

        expect(weightStepperValue(tester), '40');
        expect(repsStepperValue(tester), '5');
      },
    );

    testWidgets(
      'logging a Set from a prefilled target appends via the normal addSet '
      'path, using the submitted values rather than the target\'s',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tapAndSettle(tester, 'entry-header-entry-1');
        expect(weightStepperValue(tester), '60');
        expect(repsStepperValue(tester), '8');

        await tapAndSettle(tester, 'weight-stepper-increment');
        await tapAndSettle(tester, 'weight-stepper-increment');
        await tapAndSettle(tester, 'reps-stepper-increment');
        await tapAndSettle(tester, 'reps-stepper-increment');
        expect(weightStepperValue(tester), '65');
        expect(repsStepperValue(tester), '10');

        await tapAndSettle(tester, 'add-set');

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        final loggedSet = saved.exerciseEntries.single.sets.single;
        expect(loggedSet.weight, 65);
        expect(loggedSet.reps, 10);

        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
      },
    );

    testWidgets(
      'a target row has no tap affordance: tapping it neither opens the '
      'edit-Set dialog nor is wrapped in an InkWell/GestureDetector',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        final targetRow = find.byKey(const ValueKey('target-0-entry-1'));
        expect(
          find.descendant(of: targetRow, matching: find.byType(InkWell)),
          findsNothing,
        );
        expect(
          find.descendant(
            of: targetRow,
            matching: find.byType(GestureDetector),
          ),
          findsNothing,
        );

        await tester.tap(targetRow);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'deleting the Set that fulfilled a target makes that target row '
      'dashed again and re-prefills the add-Set bar from it',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 9, 0),
            ),
          ],
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tapAndSettle(tester, 'entry-header-entry-1');
        expect(find.byKey(const ValueKey('target-0-entry-1')), findsNothing);
        expect(weightStepperValue(tester), '0');
        expect(repsStepperValue(tester), '0');

        await tapAndSettle(tester, 'set-set-1');
        await tapAndSettle(tester, 'edit-delete-set-1');
        await tapAndSettle(tester, 'confirm-delete-confirm');

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.single.sets, isEmpty);

        expect(find.byKey(const ValueKey('target-0-entry-1')), findsOneWidget);
        expect(weightStepperValue(tester), '60');
        expect(repsStepperValue(tester), '8');
      },
    );
  });
}
