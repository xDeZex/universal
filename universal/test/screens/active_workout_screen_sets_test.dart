import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';

import 'active_workout_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen Set logging, editing, and deletion', () {

    testWidgets(
      'adding a Set via the bottom bar adds it to the selected Exercise '
      'Entry and persists the Workout',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 5; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets.length, 1);
        expect(saved.exerciseEntries[0].sets[0].weight, 5);
        expect(saved.exerciseEntries[0].sets[0].unit, WeightUnit.kg);
        expect(saved.exerciseEntries[0].sets[0].reps, 5);
      },
    );

    testWidgets(
      'selecting lbs before submitting a Set includes lbs on the created Set',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets[0].unit, WeightUnit.lbs);
        expect(saved.exerciseEntries[0].sets[0].weight, 5);
        expect(saved.exerciseEntries[0].sets[0].reps, 8);
      },
    );

    testWidgets(
      'the unit toggle stays on lbs for the next Set after logging one with '
      'lbs on the same Exercise Entry',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        // The unit chip should still read lbs without re-selecting it.
        expect(
          tester.widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs'))).selected,
          isTrue,
        );

        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 6; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets.length, 2);
        expect(saved.exerciseEntries[0].sets[1].unit, WeightUnit.lbs);
        expect(saved.exerciseEntries[0].sets[1].reps, 6);
      },
    );

    testWidgets(
      'a logged Set is displayed with its weight (incl. unit) and reps',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('unit-lbs')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        expect(find.text('5 lbs'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
      },
    );

    testWidgets(
      'a logged Set on a finished Workout additionally shows its logged time',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 50,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 1, 1, 18, 42),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 18, 0),
          endTime: DateTime(2026, 1, 1, 18, 42),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '50 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '8',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-time-set-1'))).data,
          '6:42 PM',
        );
      },
    );

    testWidgets(
      'tapping a logged Set opens an edit dialog pre-filled with its '
      'current weight, unit, and reps',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        final weightField = tester.widget<TextField>(
          find.byKey(const ValueKey('edit-weight-set-1')),
        );
        final repsField = tester.widget<TextField>(
          find.byKey(const ValueKey('edit-reps-set-1')),
        );
        final kgChip = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('edit-unit-kg-set-1')),
        );

        expect(weightField.controller!.text, '60');
        expect(repsField.controller!.text, '8');
        expect(kgChip.selected, isTrue);
      },
    );

    testWidgets(
      'submitting valid new values from the edit dialog updates the Set '
      'and leaves loggedAt unchanged',
      (tester) async {
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '65',
        );
        await tester.enterText(
          find.byKey(const ValueKey('edit-reps-set-1')),
          '6',
        );
        await tester.tap(find.byKey(const ValueKey('edit-unit-lbs-set-1')));
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        final updatedSet = saved.exerciseEntries[0].sets[0];
        expect(updatedSet.weight, 65);
        expect(updatedSet.unit, WeightUnit.lbs);
        expect(updatedSet.reps, 6);
        expect(updatedSet.loggedAt, loggedAt);
      },
    );

    testWidgets(
      'submitting a non-numeric weight from the edit dialog is rejected, '
      'leaving the Set unchanged',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        var notified = false;
        repository.addListener(() => notified = true);

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          'not-a-number',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(notified, isFalse);
        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsOneWidget);
      },
    );

    testWidgets(
      'submitting a non-positive-integer reps count from the edit dialog is '
      'rejected, leaving the Set unchanged',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        var notified = false;
        repository.addListener(() => notified = true);

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-reps-set-1')),
          '0',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        expect(notified, isFalse);
        expect(find.byKey(const ValueKey('edit-reps-set-1')), findsOneWidget);
      },
    );

    testWidgets(
      'submitting a zero or negative weight from the edit dialog is '
      'accepted, same as adding a Set',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '-10',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets[0].weight, -10);
      },
    );

    testWidgets(
      'tapping a logged Set belonging to a Locked Workout opens the same '
      'edit dialog and behaves identically to an in-progress Workout',
      (tester) async {
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsOneWidget);

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '70',
        );
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets[0].weight, 70);
        expect(saved.exerciseEntries[0].sets[0].loggedAt, loggedAt);
      },
    );

    testWidgets(
      'cancelling the edit dialog closes it without persisting or changing '
      'the Set',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        var notified = false;
        repository.addListener(() => notified = true);

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const ValueKey('edit-weight-set-1')),
          '999',
        );
        await tester.tap(find.byKey(const ValueKey('edit-cancel-set-1')));
        await tester.pumpAndSettle();

        expect(notified, isFalse);
        expect(find.byKey(const ValueKey('edit-weight-set-1')), findsNothing);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('set-reps-set-1'))).data,
          '8',
        );
      },
    );

    testWidgets(
      'the Set edit dialog has a Delete action that opens a confirmation '
      'dialog',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('confirm-delete-confirm')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('confirm-delete-cancel')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'confirming the delete-Set confirmation removes the Set from its '
      'Exercise Entry',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
            ExerciseSet(
              id: 'set-2',
              weight: 20,
              unit: WeightUnit.kg,
              reps: 10,
              loggedAt: DateTime(2026, 1, 1, 10, 10),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets.length, 1);
        expect(saved.exerciseEntries[0].sets[0].id, 'set-2');
      },
    );

    testWidgets(
      'cancelling the delete-Set confirmation leaves the Set unchanged',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );
        var notified = false;
        repository.addListener(() => notified = true);

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-cancel')));
        await tester.pumpAndSettle();

        expect(notified, isFalse);
      },
    );

    testWidgets(
      'deleting the only remaining Set under an Exercise Entry leaves that '
      'Entry listed with zero Sets, not removed',
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
              loggedAt: DateTime(2026, 1, 1, 10, 0),
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries.length, 1);
        expect(saved.exerciseEntries[0].id, 'entry-1');
        expect(saved.exerciseEntries[0].sets, isEmpty);
      },
    );

    testWidgets(
      'deleting a Set belonging to a Locked Workout succeeds identically '
      'to an in-progress Workout',
      (tester) async {
        final loggedAt = DateTime(2026, 1, 1, 10, 0);
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: loggedAt,
            ),
          ],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 9, 0),
          endTime: loggedAt,
          exerciseEntries: [entry],
        );

        final repository = await pumpActiveWorkoutScreen(
          tester,
          workout: workout,
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        );

        await tester.tap(find.byKey(const ValueKey('set-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-delete-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm-delete-confirm')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets, isEmpty);
      },
    );

    testWidgets(
      'tapping Add Set adds a Set to the selected Exercise Entry stamped '
      'with the current time',
      (tester) async {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        final before = DateTime.now();
        await tester.tap(find.byKey(const ValueKey('weight-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('reps-stepper-increment')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();
        final after = DateTime.now();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        final set = saved.exerciseEntries[0].sets.single;
        expect(set.weight, 2.5);
        expect(set.unit, WeightUnit.kg);
        expect(set.reps, 1);
        expect(
          set.loggedAt.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue,
        );
        expect(
          set.loggedAt.isBefore(after.add(const Duration(seconds: 1))),
          isTrue,
        );
      },
    );

  });
}
