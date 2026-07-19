import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/widgets/planned_exercise_card.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen reorder Planned Exercises', () {
    testWidgets(
      "long-press-dragging a card to a new position updates the Routine's "
      'Planned Exercise order and persists it across a rebuild',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          final repository = await pumpRoutineScreen(
            tester,
            routines: [
              Routine(
                id: 'routine-1',
                name: 'Push Day',
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

          final cardHeight = tester
              .getSize(find.byKey(const ValueKey('pe-1')))
              .height;

          await dragCard(tester, const ValueKey('pe-1'), cardHeight * 3);

          final order = repository.routines.single.plannedExercises
              .map((pe) => pe.id)
              .toList();
          expect(order.last, 'pe-1');
          expect(order, containsAll(['pe-1', 'pe-2', 'pe-3']));

          await tester.pump();
          final displayedOrder = tester
              .widgetList<PlannedExerciseCard>(find.byType(PlannedExerciseCard))
              .map((card) => card.plannedExercise.id)
              .toList();
          expect(displayedOrder, order);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets(
      'dropping a card back in its original position leaves the order '
      'unchanged',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        try {
          final repository = await pumpRoutineScreen(
            tester,
            routines: [
              Routine(
                id: 'routine-1',
                name: 'Push Day',
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

          final cardHeight = tester
              .getSize(find.byKey(const ValueKey('pe-1')))
              .height;
          final downDy = cardHeight * 1.5;

          await dragCard(tester, const ValueKey('pe-1'), downDy);

          final afterFirstDrop = repository.routines.single.plannedExercises
              .map((pe) => pe.id)
              .toList();
          expect(afterFirstDrop.first, isNot('pe-1'));

          await dragCard(tester, const ValueKey('pe-1'), -downDy);

          final order = repository.routines.single.plannedExercises
              .map((pe) => pe.id)
              .toList();
          expect(order, ['pe-1', 'pe-2', 'pe-3']);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      },
    );

    testWidgets('cards are keyed by Planned Exercise id, not list index', (
      tester,
    ) async {
      await pumpRoutineScreen(
        tester,
        routines: [
          Routine(
            id: 'routine-1',
            name: 'Push Day',
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

      for (final card in tester.widgetList<PlannedExerciseCard>(
        find.byType(PlannedExerciseCard),
      )) {
        expect(card.key, ValueKey(card.plannedExercise.id));
      }
    });
  });
}
