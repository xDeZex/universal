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

  group('ActiveWorkoutScreen Set logging timestamps', () {
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
        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
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
