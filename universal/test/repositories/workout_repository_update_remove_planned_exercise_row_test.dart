import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';

import 'workout_repository_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.updatePlannedExerciseRow', () {
    test('on an active Routine, replaces the row at the given index in '
        'place, persists, and notifies listeners', () async {
      final existing = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
          ),
          PlannedExerciseRow(
            reps: FixedReps(10),
            weight: PlannedWeight(value: 50, unit: WeightUnit.kg),
          ),
        ],
      );
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [existing],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);
      const updatedRow = PlannedExerciseRow(
        reps: FixedReps(12),
        weight: PlannedWeight(value: 45, unit: WeightUnit.kg),
      );

      repository.updatePlannedExerciseRow('routine-1', 'pe-1', 0, updatedRow);

      final rows = repository.routines.single.plannedExercises.single.rows;
      expect((rows[0].reps as FixedReps).reps, 12);
      expect(rows[0].weight.value, 45);
      expect((rows[1].reps as FixedReps).reps, 10);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadRoutines();
      final storedRows = stored.single.plannedExercises.single.rows;
      expect((storedRows[0].reps as FixedReps).reps, 12);
    });

    test('on an archived Routine, leaves the row unchanged and persists '
        'nothing', () async {
      final existing = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
          ),
        ],
      );
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [existing],
        archivedAt: DateTime(2026, 1, 1),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);
      const updatedRow = PlannedExerciseRow(
        reps: FixedReps(12),
        weight: PlannedWeight(value: 45, unit: WeightUnit.kg),
      );

      repository.updatePlannedExerciseRow('routine-1', 'pe-1', 0, updatedRow);

      final rows = repository.routines.single.plannedExercises.single.rows;
      expect((rows[0].reps as FixedReps).reps, 8);
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });

    test(
      'with an out-of-range rowIndex, is a no-op and persists nothing',
      () async {
        final existing = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
            ),
          ],
        );
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: [existing],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );
        final wasNotified = trackNotifications(repository);
        const updatedRow = PlannedExerciseRow(
          reps: FixedReps(12),
          weight: PlannedWeight(value: 45, unit: WeightUnit.kg),
        );

        repository.updatePlannedExerciseRow('routine-1', 'pe-1', 5, updatedRow);

        final rows = repository.routines.single.plannedExercises.single.rows;
        expect((rows[0].reps as FixedReps).reps, 8);
        expect(wasNotified(), isFalse);
      },
    );
  });

  group('WorkoutRepository.removePlannedExerciseRow', () {
    test('on an active Routine, removes the row at the given index, '
        'persists, and notifies listeners', () async {
      final existing = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
          ),
          PlannedExerciseRow(
            reps: FixedReps(10),
            weight: PlannedWeight(value: 50, unit: WeightUnit.kg),
          ),
        ],
      );
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [existing],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.removePlannedExerciseRow('routine-1', 'pe-1', 0);

      final rows = repository.routines.single.plannedExercises.single.rows;
      expect(rows.length, 1);
      expect((rows[0].reps as FixedReps).reps, 10);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadRoutines();
      expect(stored.single.plannedExercises.single.rows.length, 1);
    });

    test('on an archived Routine, leaves the row list unchanged and '
        'persists nothing', () async {
      final existing = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'exercise-1',
        rows: const [
          PlannedExerciseRow(
            reps: FixedReps(8),
            weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
          ),
        ],
      );
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [existing],
        archivedAt: DateTime(2026, 1, 1),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.removePlannedExerciseRow('routine-1', 'pe-1', 0);

      final rows = repository.routines.single.plannedExercises.single.rows;
      expect(rows.length, 1);
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });

    test(
      'with an out-of-range rowIndex, is a no-op and persists nothing',
      () async {
        final existing = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: FixedReps(8),
              weight: PlannedWeight(value: 40, unit: WeightUnit.kg),
            ),
          ],
        );
        final routine = Routine(
          id: 'routine-1',
          name: 'Push Day',
          plannedExercises: [existing],
        );
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: [routine],
        );
        final wasNotified = trackNotifications(repository);

        repository.removePlannedExerciseRow('routine-1', 'pe-1', 5);

        final rows = repository.routines.single.plannedExercises.single.rows;
        expect(rows.length, 1);
        expect(wasNotified(), isFalse);
      },
    );
  });
}
