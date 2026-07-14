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

  group('ActiveWorkoutScreen Set logging', () {
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

        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 5; i++) {
          await tester.tap(
            find.byKey(const ValueKey('reps-stepper-increment')),
          );
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
        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(
            find.byKey(const ValueKey('reps-stepper-increment')),
          );
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
        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(
            find.byKey(const ValueKey('reps-stepper-increment')),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byKey(const ValueKey('add-set')));
        await tester.pumpAndSettle();

        // The unit chip should still read lbs without re-selecting it.
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(const ValueKey('unit-lbs')))
              .selected,
          isTrue,
        );

        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 6; i++) {
          await tester.tap(
            find.byKey(const ValueKey('reps-stepper-increment')),
          );
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
        await tester.tap(
          find.byKey(const ValueKey('weight-stepper-increment')),
        );
        await tester.pumpAndSettle();
        for (var i = 0; i < 8; i++) {
          await tester.tap(
            find.byKey(const ValueKey('reps-stepper-increment')),
          );
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
          tester
              .widget<Text>(find.byKey(const ValueKey('set-reps-set-1')))
              .data,
          '8',
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('set-time-set-1')))
              .data,
          '6:42 PM',
        );
      },
    );
  });
}
