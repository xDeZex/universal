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

  group('ActiveWorkoutScreen Set logging scroll behavior', () {
    testWidgets(
      'adding a Set to an Exercise Entry whose existing Sets already fill '
      'the viewport scrolls the new Set into view',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);

        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: List.generate(
            20,
            (i) => ExerciseSet(
              id: 'entry-1-set-$i',
              weight: 40,
              unit: WeightUnit.kg,
              reps: 5,
              loggedAt: DateTime(2026, 1, 1, 10, i),
            ),
          ),
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

        await tester.tap(find.byKey(const ValueKey('entry-header-entry-1')));
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
            .firstWhere((e) => e.id == 'entry-1');
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
  });
}
