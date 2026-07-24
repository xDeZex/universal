import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/weight_unit.dart';
import 'package:universal/repositories/workout_repository.dart';

import 'workout_repository_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.startWorkout pre-filling from a Routine', () {
    test(
      'an active Routine with two Planned Exercises pre-fills matching ExerciseEntries',
      () {
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: const [
            PlannedExercise(
              id: 'pe-1',
              exerciseId: 'ex-1',
              rows: [
                PlannedExerciseRow(
                  reps: FixedReps(10),
                  weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
                ),
                PlannedExerciseRow(
                  reps: FixedReps(8),
                  weight: PlannedWeight(value: 65, unit: WeightUnit.kg),
                ),
              ],
            ),
            PlannedExercise(
              id: 'pe-2',
              exerciseId: 'ex-2',
              rows: [
                PlannedExerciseRow(
                  reps: RangeReps(min: 8, max: 12),
                  weight: PlannedWeight(value: 40, unit: WeightUnit.lbs),
                ),
              ],
            ),
          ],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );

        repository.startWorkout(routineId: 'routine-1');

        final entries = repository.workouts.single.exerciseEntries;
        expect(entries.length, 2);

        expect(entries[0].exerciseId, 'ex-1');
        expect(entries[0].sets, isEmpty);
        expect(entries[0].targets, isNotNull);
        expect(entries[0].targets!.length, 2);
        expect((entries[0].targets![0].reps as FixedReps).reps, 10);
        expect(entries[0].targets![0].weight.value, 60);
        expect((entries[0].targets![1].reps as FixedReps).reps, 8);
        expect(entries[0].targets![1].weight.value, 65);

        expect(entries[1].exerciseId, 'ex-2');
        expect(entries[1].sets, isEmpty);
        expect(entries[1].targets, isNotNull);
        expect(entries[1].targets!.length, 1);
        final rangeReps = entries[1].targets![0].reps as RangeReps;
        expect(rangeReps.min, 8);
        expect(rangeReps.max, 12);
        expect(entries[1].targets![0].weight.value, 40);
        expect(entries[1].targets![0].weight.unit, WeightUnit.lbs);
      },
    );

    test(
      'a routineId resolving to an archived Routine creates no Workout',
      () {
        final archived = Routine(
          id: 'routine-1',
          name: 'Push Day',
          archivedAt: DateTime(2026, 7, 1),
          plannedExercises: const [
            PlannedExercise(id: 'pe-1', exerciseId: 'ex-1'),
          ],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [archived],
        );

        repository.startWorkout(routineId: 'routine-1');

        expect(repository.workouts, isEmpty);
      },
    );

    test(
      'no routineId leaves exerciseEntries empty, unaffected by this change',
      () {
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: const [],
        );

        repository.startWorkout();

        expect(repository.workouts.single.exerciseEntries, isEmpty);
      },
    );

    test(
      'a Workout started from a Routine persists via StorageService and notifies listeners',
      () async {
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: const [
            PlannedExercise(id: 'pe-1', exerciseId: 'ex-1'),
          ],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );
        final wasNotified = trackNotifications(repository);

        repository.startWorkout(routineId: 'routine-1');

        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadWorkouts();
        expect(stored.single.routineId, 'routine-1');
        expect(stored.single.exerciseEntries.single.exerciseId, 'ex-1');
      },
    );

    test(
      'editing a Planned Exercise row after a Workout has started from it '
      "does not change that Workout's already-copied targets",
      () {
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: const [
            PlannedExercise(
              id: 'pe-1',
              exerciseId: 'ex-1',
              rows: [
                PlannedExerciseRow(
                  reps: FixedReps(10),
                  weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
                ),
              ],
            ),
          ],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );

        repository.startWorkout(routineId: 'routine-1');
        repository.updatePlannedExerciseRow(
          'routine-1',
          'pe-1',
          0,
          const PlannedExerciseRow(
            reps: FixedReps(20),
            weight: PlannedWeight(value: 100, unit: WeightUnit.kg),
          ),
        );

        final targets = repository.workouts.single.exerciseEntries.single
            .targets!;
        expect((targets[0].reps as FixedReps).reps, 10);
        expect(targets[0].weight.value, 60);
      },
    );

    test(
      'deleting a Planned Exercise row after a Workout has started from it '
      "does not change that Workout's already-copied targets",
      () {
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: const [
            PlannedExercise(
              id: 'pe-1',
              exerciseId: 'ex-1',
              rows: [
                PlannedExerciseRow(
                  reps: FixedReps(10),
                  weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
                ),
                PlannedExerciseRow(
                  reps: FixedReps(8),
                  weight: PlannedWeight(value: 65, unit: WeightUnit.kg),
                ),
              ],
            ),
          ],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );

        repository.startWorkout(routineId: 'routine-1');
        repository.removePlannedExerciseRow('routine-1', 'pe-1', 0);

        final targets = repository.workouts.single.exerciseEntries.single
            .targets!;
        expect(targets.length, 2);
        expect((targets[0].reps as FixedReps).reps, 10);
        expect(targets[0].weight.value, 60);
        expect((targets[1].reps as FixedReps).reps, 8);
        expect(targets[1].weight.value, 65);
      },
    );
  });
}
