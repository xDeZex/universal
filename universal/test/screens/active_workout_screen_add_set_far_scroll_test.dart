import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';

import '../support/pump.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group(
    'ActiveWorkoutScreen Set logging scroll behavior when scrolled away',
    () {
      testWidgets(
        'adding a Set to an Exercise Entry that has scrolled far enough out '
        'of view to no longer be built still scrolls the new Set into view',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(tester.view.reset);

          final fillers = List.generate(
            20,
            (i) => ExerciseEntry(id: 'filler-$i', exerciseId: 'filler-ex-$i'),
          );
          final target = ExerciseEntry(
            id: 'target-entry',
            exerciseId: 'exercise-target',
            sets: [
              ExerciseSet(
                id: 'target-set-0',
                weight: 40,
                unit: WeightUnit.kg,
                reps: 5,
                loggedAt: DateTime(2026, 1, 1, 10, 0),
              ),
            ],
          );
          final workout = Workout(
            id: 'workout-1',
            startTime: DateTime(2026, 1, 1),
            exerciseEntries: [...fillers, target],
          );
          final exercises = [
            Exercise(id: 'exercise-target', name: 'Bench Press'),
            ...List.generate(
              20,
              (i) => Exercise(id: 'filler-ex-$i', name: 'Filler $i'),
            ),
          ];

          final repository = await pumpActiveWorkoutScreen(
            tester,
            workout: workout,
            exercises: exercises,
          );

          await tester.drag(find.byType(ListView), const Offset(0, -6000));
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(const ValueKey('entry-header-target-entry')),
          );
          await tester.pumpAndSettle();

          await tester.drag(find.byType(ListView), const Offset(0, 6000));
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

          final savedEntry = repository.workouts
              .firstWhere((w) => w.id == 'workout-1')
              .exerciseEntries
              .firstWhere((e) => e.id == 'target-entry');
          final newSetId = savedEntry.sets.last.id;

          final screenHeight =
              tester.view.physicalSize.height / tester.view.devicePixelRatio;
          final newSetRect = tester.getRect(
            find.byKey(ValueKey('set-$newSetId')),
          );

          expect(newSetRect.top, greaterThanOrEqualTo(0));
          expect(newSetRect.bottom, lessThanOrEqualTo(screenHeight));
        },
      );
    },
  );
}
