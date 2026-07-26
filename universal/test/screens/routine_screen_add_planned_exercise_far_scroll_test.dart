import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group(
    'RoutineScreen add Planned Exercise scroll behavior with a long list',
    () {
      testWidgets(
        'adding a Planned Exercise to a routine long enough that cards '
        'beyond the cache extent are not yet built still scrolls the new '
        'card into view',
        (tester) async {
          tester.view.physicalSize = const Size(1080, 2400);
          tester.view.devicePixelRatio = 2.625;
          addTearDown(tester.view.reset);

          final existing = List.generate(
            20,
            (i) => PlannedExercise(id: 'pe-$i', exerciseId: 'exercise-$i'),
          );
          final exercises = List.generate(
            20,
            (i) => Exercise(id: 'exercise-$i', name: 'Exercise $i'),
          );

          final repository = await pumpRoutineScreen(
            tester,
            routines: [
              Routine(
                id: 'routine-1',
                name: 'Push Day',
                plannedExercises: existing,
              ),
            ],
            exercises: exercises,
            routineId: 'routine-1',
          );

          await tester.enterText(
            find.byKey(const ValueKey('add-planned-exercise-field')),
            'Squat',
          );
          await tester.tap(
            find.byKey(const ValueKey('add-planned-exercise-button')),
          );
          await tester.pumpAndSettle();

          final newPlannedExercise = repository.routines
              .firstWhere((r) => r.id == 'routine-1')
              .plannedExercises
              .last;

          final listRect = tester.getRect(find.byType(ReorderableListView));
          final newCardRect = tester.getRect(
            find.byKey(ValueKey(newPlannedExercise.id)),
          );

          expect(newCardRect.top, greaterThanOrEqualTo(listRect.top));
          expect(newCardRect.bottom, lessThanOrEqualTo(listRect.bottom));
        },
      );
    },
  );
}
