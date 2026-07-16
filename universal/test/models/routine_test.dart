import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('RepsTarget', () {
    test('FixedReps round-trips through toJson/fromJson', () {
      const target = FixedReps(12);

      final restored = RepsTarget.fromJson(target.toJson());

      expect(restored, isA<FixedReps>());
      expect((restored as FixedReps).reps, 12);
    });

    test('RangeReps round-trips through toJson/fromJson', () {
      const target = RangeReps(min: 8, max: 12);

      final restored = RepsTarget.fromJson(target.toJson());

      expect(restored, isA<RangeReps>());
      restored as RangeReps;
      expect(restored.min, 8);
      expect(restored.max, 12);
    });

    test('fromJson throws on an unrecognized discriminator value', () {
      final json = {'type': 'unknown', 'reps': 12};

      expect(() => RepsTarget.fromJson(json), throwsA(anything));
    });
  });

  group('RangeReps.validate', () {
    test('returns no error for min < max', () {
      expect(RangeReps.validate(min: 8, max: 12), isNull);
    });

    test('returns an invalid-range error for min == max', () {
      expect(
        RangeReps.validate(min: 10, max: 10),
        RangeRepsError.invalidRange,
      );
    });

    test('returns an invalid-range error for min > max', () {
      expect(
        RangeReps.validate(min: 12, max: 8),
        RangeRepsError.invalidRange,
      );
    });
  });

  group('PlannedWeight', () {
    test('round-trips through toJson/fromJson', () {
      const weight = PlannedWeight(value: 60, unit: WeightUnit.lbs);

      final restored = PlannedWeight.fromJson(weight.toJson());

      expect(restored.value, 60);
      expect(restored.unit, WeightUnit.lbs);
    });

    test('fromJson throws when unit key is missing', () {
      final json = {'value': 60};

      expect(() => PlannedWeight.fromJson(json), throwsA(anything));
    });
  });

  group('PlannedExerciseRow', () {
    test('a row with FixedReps and weight: null round-trips through JSON', () {
      const row = PlannedExerciseRow(reps: FixedReps(10), weight: null);

      final restored = PlannedExerciseRow.fromJson(row.toJson());

      expect(restored.reps, isA<FixedReps>());
      expect((restored.reps as FixedReps).reps, 10);
      expect(restored.weight, isNull);
    });

    test('a row with RangeReps and a non-null weight round-trips through JSON', () {
      const row = PlannedExerciseRow(
        reps: RangeReps(min: 8, max: 12),
        weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      final restored = PlannedExerciseRow.fromJson(row.toJson());

      expect(restored.reps, isA<RangeReps>());
      final restoredReps = restored.reps as RangeReps;
      expect(restoredReps.min, 8);
      expect(restoredReps.max, 12);
      expect(restored.weight?.value, 60);
      expect(restored.weight?.unit, WeightUnit.kg);
    });

    test('fromJson throws when reps key is missing', () {
      final json = {'weight': null};

      expect(() => PlannedExerciseRow.fromJson(json), throwsA(anything));
    });

    test('copyWith returns a new row with updated fields', () {
      const row = PlannedExerciseRow(reps: FixedReps(10), weight: null);

      final updated = row.copyWith(
        reps: const RangeReps(min: 8, max: 12),
        weight: const PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      expect(updated.reps, isA<RangeReps>());
      expect(updated.weight?.value, 60);
      expect(updated.weight?.unit, WeightUnit.kg);
    });

    test('copyWith with no arguments returns an identical row', () {
      const row = PlannedExerciseRow(
        reps: FixedReps(10),
        weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      final copy = row.copyWith();

      expect(copy.reps, row.reps);
      expect(copy.weight?.value, row.weight?.value);
      expect(copy.weight?.unit, row.weight?.unit);
    });
  });

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
