import 'package:flutter/foundation.dart';
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

  group('RoutineScreen Planned Exercise editing while archived', () {
    testWidgets("an archived Routine's screen hides the add field", (
      tester,
    ) async {
      await pumpRoutineScreen(
        tester,
        routines: [
          Routine(
            id: 'routine-1',
            name: 'Push Day',
            archivedAt: DateTime(2026, 1, 1),
            plannedExercises: [
              PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1'),
            ],
          ),
        ],
        exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        routineId: 'routine-1',
      );

      expect(
        find.byKey(const ValueKey('add-planned-exercise-field')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('add-planned-exercise-button')),
        findsNothing,
      );
    });

    testWidgets("an archived Routine's cards hide the delete icon", (
      tester,
    ) async {
      await pumpRoutineScreen(
        tester,
        routines: [
          Routine(
            id: 'routine-1',
            name: 'Push Day',
            archivedAt: DateTime(2026, 1, 1),
            plannedExercises: [
              PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1'),
            ],
          ),
        ],
        exercises: [Exercise(id: 'exercise-1', name: 'Bench Press')],
        routineId: 'routine-1',
      );

      expect(
        find.byKey(const ValueKey('delete-planned-exercise-pe-1')),
        findsNothing,
      );
    });

    testWidgets(
      'long-press-dragging a card in an archived Routine has no reordering '
      'effect',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          final repository = await pumpRoutineScreen(
            tester,
            routines: [
              Routine(
                id: 'routine-1',
                name: 'Push Day',
                archivedAt: DateTime(2026, 1, 1),
                plannedExercises: [
                  PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1'),
                  PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2'),
                  PlannedExercise(id: 'pe-3', exerciseId: 'exercise-3'),
                ],
              ),
            ],
            exercises: [
              Exercise(id: 'exercise-1', name: 'Bench Press'),
              Exercise(id: 'exercise-2', name: 'Squat'),
              Exercise(id: 'exercise-3', name: 'Deadlift'),
            ],
            routineId: 'routine-1',
          );

          expect(find.byType(ReorderableListView), findsNothing);

          final cardHeight = tester
              .getSize(find.byKey(const ValueKey('pe-1')))
              .height;

          await dragCard(tester, const ValueKey('pe-1'), cardHeight * 3);

          final order = repository.routines.single.plannedExercises
              .map((pe) => pe.id)
              .toList();
          expect(order, ['pe-1', 'pe-2', 'pe-3']);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );
  });
}
