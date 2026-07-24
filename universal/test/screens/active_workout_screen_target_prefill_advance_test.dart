import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

import 'active_workout_screen_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutScreen add-Set bar target prefill after logging', () {
    testWidgets(
      'logging a Set on a still-selected Exercise Entry re-prefills the '
      'bar from the newly-current target rather than resetting to zero',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
            ),
            PlannedExerciseRow(
              reps: FixedReps(6),
              weight: PlannedWeight(value: 65, unit: WeightUnit.kg),
            ),
          ],
        );
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

        await tapAndSettle(tester, 'entry-header-entry-1');
        expect(weightStepperValue(tester), '60');
        expect(repsStepperValue(tester), '8');

        await tapAndSettle(tester, 'add-set');

        expect(weightStepperValue(tester), '65');
        expect(repsStepperValue(tester), '6');
      },
    );

    testWidgets(
      'a target authored in lbs prefills the unit toggle to lbs, not the '
      'entry\'s default kg',
      (tester) async {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          targets: const [
            PlannedExerciseRow(
              reps: FixedReps(5),
              weight: PlannedWeight(value: 135, unit: WeightUnit.lbs),
            ),
          ],
        );
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

        await tapAndSettle(tester, 'entry-header-entry-1');

        expect(isUnitSelected(tester, 'unit-lbs', WeightUnit.lbs), isTrue);
        expect(weightStepperValue(tester), '135');
      },
    );
  });
}
