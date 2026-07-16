import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('PlannedExercise', () {
    test('a PlannedExercise with nested rows round-trips through JSON', () {
      const exercise = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'ex-1',
        rows: [
          PlannedExerciseRow(reps: FixedReps(10), weight: null),
          PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
        ],
      );

      final restored = PlannedExercise.fromJson(exercise.toJson());

      expect(restored.id, 'pe-1');
      expect(restored.exerciseId, 'ex-1');
      expect(restored.rows.length, 2);
      expect(restored.rows[0].reps, isA<FixedReps>());
      expect(restored.rows[0].weight, isNull);
      expect(restored.rows[1].reps, isA<RangeReps>());
      expect(restored.rows[1].weight?.value, 60);
    });

    test('fromJson throws when id key is missing', () {
      final json = {'exerciseId': 'ex-1', 'rows': []};

      expect(() => PlannedExercise.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when exerciseId key is missing', () {
      final json = {'id': 'pe-1', 'rows': []};

      expect(() => PlannedExercise.fromJson(json), throwsA(anything));
    });

    test('a PlannedExercise with zero rows round-trips as a valid, non-error state', () {
      const exercise = PlannedExercise(id: 'pe-1', exerciseId: 'ex-1');

      final restored = PlannedExercise.fromJson(exercise.toJson());

      expect(restored.rows, isEmpty);
    });

    test('copyWith returns a new PlannedExercise with updated fields', () {
      const exercise = PlannedExercise(id: 'pe-1', exerciseId: 'ex-1');
      const row = PlannedExerciseRow(reps: FixedReps(10));

      final updated = exercise.copyWith(exerciseId: 'ex-2', rows: [row]);

      expect(updated.id, 'pe-1');
      expect(updated.exerciseId, 'ex-2');
      expect(updated.rows, [row]);
    });

    test('copyWith with no arguments returns an identical PlannedExercise', () {
      const row = PlannedExerciseRow(reps: FixedReps(10));
      const exercise = PlannedExercise(
        id: 'pe-1',
        exerciseId: 'ex-1',
        rows: [row],
      );

      final copy = exercise.copyWith();

      expect(copy.id, exercise.id);
      expect(copy.exerciseId, exercise.exerciseId);
      expect(copy.rows, exercise.rows);
    });
  });
}
