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

  group('RoutineScreen add Planned Exercise', () {
    testWidgets(
      'submitting a name that case-insensitively matches an existing '
      'Exercise adds a Planned Exercise referencing that Exercise',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'bench press',
        );
        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-button')),
        );
        await tester.pump();

        expect(repository.exercises.length, 1);
        expect(
          repository.routines.single.plannedExercises.single.exerciseId,
          'exercise-1',
        );
      },
    );

    testWidgets(
      'submitting via the keyboard (onSubmitted) adds a Planned Exercise, '
      'same as tapping the add button',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'bench press',
        );
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        expect(
          repository.routines.single.plannedExercises.single.exerciseId,
          'exercise-1',
        );
      },
    );

    testWidgets(
      'submitting a name matching no existing Exercise creates a new '
      'Exercise and adds a Planned Exercise referencing it',
      (tester) async {
        final repository = await pumpRoutineScreen(
          tester,
          routines: [Routine(id: 'routine-1', name: 'Push Day')],
          routineId: 'routine-1',
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'Squat',
        );
        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-button')),
        );
        await tester.pump();

        final createdExercise = repository.exercises.single;
        expect(createdExercise.name, 'Squat');
        expect(
          repository.routines.single.plannedExercises.single.exerciseId,
          createdExercise.id,
        );
      },
    );

    testWidgets('submitting a blank or whitespace-only name adds nothing', (
      tester,
    ) async {
      final repository = await pumpRoutineScreen(
        tester,
        routines: [Routine(id: 'routine-1', name: 'Push Day')],
        routineId: 'routine-1',
      );

      await tester.enterText(
        find.byKey(const ValueKey('add-planned-exercise-field')),
        '   ',
      );
      await tester.tap(
        find.byKey(const ValueKey('add-planned-exercise-button')),
      );
      await tester.pump();

      expect(repository.routines.single.plannedExercises, isEmpty);
      expect(repository.exercises, isEmpty);
    });

    testWidgets(
      'a newly added Planned Exercise appears at the end of the list, '
      'matching repository order',
      (tester) async {
        final existing = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
        final repository = await pumpRoutineScreen(
          tester,
          routines: [
            Routine(
              id: 'routine-1',
              name: 'Push Day',
              plannedExercises: [existing],
            ),
          ],
          exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
          routineId: 'routine-1',
        );

        await tester.enterText(
          find.byKey(const ValueKey('add-planned-exercise-field')),
          'Squat',
        );
        await tester.tap(
          find.byKey(const ValueKey('add-planned-exercise-button')),
        );
        await tester.pump();

        final plannedExercises = repository.routines.single.plannedExercises;
        expect(plannedExercises, hasLength(2));
        expect(plannedExercises.first.id, 'pe-1');
        expect(plannedExercises.last.id, isNot('pe-1'));
      },
    );
  });
}
