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

  group('WorkoutRepository.addPlannedExerciseRow', () {
    test(
      'on an active Routine with existing rows, appends a row copying '
      'the last row\'s reps and weight, persists, and notifies listeners',
      () async {
        final existing = PlannedExercise(
          id: 'pe-1',
          exerciseId: 'exercise-1',
          rows: const [
            PlannedExerciseRow(
              reps: RangeReps(min: 8, max: 12),
              weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
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

        final added = repository.addPlannedExerciseRow('routine-1', 'pe-1');

        expect(added, isNotNull);
        final rows = repository.routines.single.plannedExercises.single.rows;
        expect(rows.length, 2);
        expect(rows[1].reps, isA<RangeReps>());
        expect((rows[1].reps as RangeReps).min, 8);
        expect((rows[1].reps as RangeReps).max, 12);
        expect(rows[1].weight.value, 60);
        expect(rows[1].weight.unit, WeightUnit.kg);
        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadRoutines();
        expect(stored.single.plannedExercises.single.rows.length, 2);
      },
    );

    test('on an active Routine with no rows yet, appends a row defaulting '
        'to fixed 1 rep and 0 kg', () async {
      final existing = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
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

      final added = repository.addPlannedExerciseRow('routine-1', 'pe-1');

      expect(added, isNotNull);
      final rows = repository.routines.single.plannedExercises.single.rows;
      expect(rows.length, 1);
      expect(rows[0].reps, isA<FixedReps>());
      expect((rows[0].reps as FixedReps).reps, 1);
      expect(rows[0].weight.value, 0);
      expect(rows[0].weight.unit, WeightUnit.kg);
    });

    test('on an archived Routine, leaves the row list unchanged and '
        'persists nothing', () async {
      final existing = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
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

      final added = repository.addPlannedExerciseRow('routine-1', 'pe-1');

      expect(added, isNull);
      expect(repository.routines.single.plannedExercises.single.rows, isEmpty);
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });
  });
}
