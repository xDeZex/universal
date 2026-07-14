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

  group('ActiveWorkoutScreen Set edit dialog actions', () {
    testWidgets('the edit dialog\'s Save action is disabled once reps has been '
        'stepped down to zero', (tester) async {
      final entry = ExerciseEntry(
        id: 'entry-1',
        exerciseId: 'exercise-1',
        sets: [
          ExerciseSet(
            id: 'set-1',
            weight: 60,
            unit: WeightUnit.kg,
            reps: 1,
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
      await tester.tap(
        find.byKey(const ValueKey('edit-reps-stepper-set-1-decrement')),
      );
      await tester.pumpAndSettle();

      final saveButton = tester.widget<TextButton>(
        find.byKey(const ValueKey('edit-submit-set-1')),
      );
      expect(saveButton.onPressed, isNull);
    });

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

        expect(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-value')),
          findsOneWidget,
        );

        await tester.tap(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-increment')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets[0].weight, 62.5);
        expect(saved.exerciseEntries[0].sets[0].loggedAt, loggedAt);
      },
    );

    testWidgets(
      'selecting kg in the edit dialog while a Set is in lbs switches its '
      'unit back to kg',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.lbs,
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
        await tester.tap(find.byKey(const ValueKey('edit-unit-kg-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        final saved = repository.workouts.firstWhere(
          (w) => w.id == 'workout-1',
        );
        expect(saved.exerciseEntries[0].sets[0].unit, WeightUnit.kg);
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

        await tester.tap(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-increment')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-cancel-set-1')));
        await tester.pumpAndSettle();

        expect(notified, isFalse);
        expect(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-value')),
          findsNothing,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-weight-set-1')))
              .data,
          '60 kg',
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-reps-set-1')))
              .data,
          '8',
        );
      },
    );
  });
}
