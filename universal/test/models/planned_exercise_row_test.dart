import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('PlannedExerciseRow', () {
    test('a row with FixedReps and a weight round-trips through JSON', () {
      const row = PlannedExerciseRow(
        reps: FixedReps(10),
        weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      final restored = PlannedExerciseRow.fromJson(row.toJson());

      expect(restored.reps, isA<FixedReps>());
      expect((restored.reps as FixedReps).reps, 10);
      expect(restored.weight.value, 60);
      expect(restored.weight.unit, WeightUnit.kg);
    });

    test('a row with RangeReps and a weight round-trips through JSON', () {
      const row = PlannedExerciseRow(
        reps: RangeReps(min: 8, max: 12),
        weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      final restored = PlannedExerciseRow.fromJson(row.toJson());

      expect(restored.reps, isA<RangeReps>());
      final restoredReps = restored.reps as RangeReps;
      expect(restoredReps.min, 8);
      expect(restoredReps.max, 12);
      expect(restored.weight.value, 60);
      expect(restored.weight.unit, WeightUnit.kg);
    });

    test('fromJson migrates a null weight to 0 kg', () {
      final json = {'reps': const FixedReps(10).toJson(), 'weight': null};

      final restored = PlannedExerciseRow.fromJson(json);

      expect(restored.weight.value, 0);
      expect(restored.weight.unit, WeightUnit.kg);
    });

    test('fromJson migrates a missing weight key to 0 kg', () {
      final json = {'reps': const FixedReps(10).toJson()};

      final restored = PlannedExerciseRow.fromJson(json);

      expect(restored.weight.value, 0);
      expect(restored.weight.unit, WeightUnit.kg);
    });

    test('fromJson throws when reps key is missing', () {
      final json = {
        'weight': const PlannedWeight(value: 60, unit: WeightUnit.kg).toJson(),
      };

      expect(() => PlannedExerciseRow.fromJson(json), throwsA(anything));
    });

    test('copyWith returns a new row with updated fields', () {
      const row = PlannedExerciseRow(
        reps: FixedReps(10),
        weight: PlannedWeight(value: 0, unit: WeightUnit.kg),
      );

      final updated = row.copyWith(
        reps: const RangeReps(min: 8, max: 12),
        weight: const PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      expect(updated.reps, isA<RangeReps>());
      expect(updated.weight.value, 60);
      expect(updated.weight.unit, WeightUnit.kg);
    });

    test('copyWith with no arguments returns an identical row', () {
      const row = PlannedExerciseRow(
        reps: FixedReps(10),
        weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
      );

      final copy = row.copyWith();

      expect(copy.reps, row.reps);
      expect(copy.weight.value, row.weight.value);
      expect(copy.weight.unit, row.weight.unit);
    });
  });
}
