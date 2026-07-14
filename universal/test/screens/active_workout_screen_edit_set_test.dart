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

  group('ActiveWorkoutScreen Set editing', () {
    testWidgets('tapping a logged Set opens an edit dialog pre-filled with its '
        'current weight, unit, and reps', (tester) async {
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

      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('edit-weight-stepper-set-1-value')),
            )
            .data,
        '60',
      );
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey('edit-reps-stepper-set-1-value')),
            )
            .data,
        '8',
      );
      final kgChip = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('edit-unit-kg-set-1')),
      );
      expect(kgChip.selected, isTrue);
    });

    testWidgets(
      'submitting new values from the edit dialog updates the Set and '
      'leaves loggedAt unchanged',
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

        await tester.tap(find.byKey(const ValueKey('edit-unit-lbs-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('edit-weight-stepper-set-1-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 2; i++) {
          await tester.tap(
            find.byKey(const ValueKey('edit-reps-stepper-set-1-decrement')),
          );
          await tester.pumpAndSettle();
        }
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
      'changing the unit while editing a Set also updates the remembered '
      'unit for that Exercise Entry',
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
        await tester.tap(find.byKey(const ValueKey('edit-unit-lbs-set-1')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('edit-submit-set-1')));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
        await tester.pumpAndSettle();

        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs')))
              .selected,
          isTrue,
        );
      },
    );
  });
}
