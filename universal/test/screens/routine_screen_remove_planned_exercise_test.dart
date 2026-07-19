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

  group('RoutineScreen remove Planned Exercise', () {
    testWidgets(
      "tapping a card's delete icon removes that Planned Exercise and its "
      'rows immediately, with no confirmation dialog',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [
                PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1'),
                PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2'),
              ],
            ),
          ],
          exercises: [
            Exercise(id: 'exercise-1', name: 'Bench Press'),
            Exercise(id: 'exercise-2', name: 'Squat'),
          ],
          routineId: 'routine-1',
        );

        await tester.tap(
          find.byKey(const ValueKey('delete-planned-exercise-pe-1')),
        );
        await tester.pump();

        expect(find.byType(Dialog), findsNothing);
        final plannedExercises = repository.routines.single.plannedExercises;
        expect(plannedExercises, hasLength(1));
        expect(plannedExercises.single.id, 'pe-2');
      },
    );

    testWidgets(
      'deleting the only remaining Planned Exercise returns the screen to '
      'the empty state',
      (tester) async {
        await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [
                PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1'),
              ],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.tap(
          find.byKey(const ValueKey('delete-planned-exercise-pe-1')),
        );
        await tester.pump();

        expect(
          find.byKey(const ValueKey('routine-empty-state')),
          findsOneWidget,
        );
      },
    );
  });
}
