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

  group('ActiveWorkoutScreen Set deletion', () {
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
  });
}
