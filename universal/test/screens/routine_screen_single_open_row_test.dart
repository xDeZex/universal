import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'routine_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RoutineScreen Single open row editor', () {
    testWidgets('opening a different row collapses whichever editor was open, '
        'regardless of which card either row belongs to', (tester) async {
      final first = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        ],
      );
      final second = PlannedExercise(
        id: 'pe-2',
        exerciseId: 'exercise-2',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(5),
            weight: PlannedWeight(value: 100, unit: WeightUnit.kg),
          ),
        ],
      );
      await pumpRoutineScreen(
        tester,
        routines: [
          Routine(
            id: 'routine-1',
            name: 'Push Day',
            plannedExercises: [first, second],
          ),
        ],
        exercises: [
          Exercise(id: 'exercise-1', name: 'Bench Press'),
          Exercise(id: 'exercise-2', name: 'Squat'),
        ],
        routineId: 'routine-1',
      );

      await tester.tap(
        find.byKey(const ValueKey('planned-exercise-row-pe-1-0')),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('row-pe-1-0-reps-value')),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('planned-exercise-row-pe-2-0')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('planned-exercise-row-pe-2-0')),
      );
      await tester.pump();

      expect(find.byKey(const ValueKey('row-pe-1-0-reps-value')), findsNothing);
      expect(
        find.byKey(const ValueKey('row-pe-2-0-reps-value')),
        findsOneWidget,
      );
    });
  });
}
