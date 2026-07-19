import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('ExerciseSet', () {
    test('creates with id, weight, unit, reps, and loggedAt', () {
      final loggedAt = DateTime(2026, 7, 10, 12, 0);
      final set = ExerciseSet(
        id: 'set-1',
        weight: 60,
        unit: WeightUnit.lbs,
        reps: 8,
        loggedAt: loggedAt,
      );

      expect(set.id, 'set-1');
      expect(set.weight, 60);
      expect(set.unit, WeightUnit.lbs);
      expect(set.reps, 8);
      expect(set.loggedAt, loggedAt);
    });

    test('copyWith returns a new Set with updated fields', () {
      final set = ExerciseSet(
        id: 'set-1',
        weight: 60,
        unit: WeightUnit.kg,
        reps: 8,
        loggedAt: DateTime(2026, 7, 10, 12, 0),
      );

      final updated = set.copyWith(weight: 65, unit: WeightUnit.lbs, reps: 6);

      expect(updated.id, 'set-1');
      expect(updated.weight, 65);
      expect(updated.unit, WeightUnit.lbs);
      expect(updated.reps, 6);
      expect(updated.loggedAt, set.loggedAt);
    });

    test('copyWith with no arguments returns an identical Set', () {
      final set = ExerciseSet(
        id: 'set-1',
        weight: 60,
        unit: WeightUnit.lbs,
        reps: 8,
        loggedAt: DateTime(2026, 7, 10, 12, 0),
      );

      final copy = set.copyWith();

      expect(copy.id, set.id);
      expect(copy.weight, set.weight);
      expect(copy.unit, set.unit);
      expect(copy.reps, set.reps);
      expect(copy.loggedAt, set.loggedAt);
    });

    test('toJson/fromJson round-trip preserves all fields', () {
      final set = ExerciseSet(
        id: 'set-1',
        weight: 60,
        unit: WeightUnit.lbs,
        reps: 8,
        loggedAt: DateTime(2026, 7, 10, 12, 0),
      );

      final restored = ExerciseSet.fromJson(set.toJson());

      expect(restored.id, 'set-1');
      expect(restored.weight, 60);
      expect(restored.unit, WeightUnit.lbs);
      expect(restored.reps, 8);
      expect(restored.loggedAt, set.loggedAt);
    });

    test('fromJson throws when id key is missing', () {
      final json = {
        'weight': 60,
        'unit': 'kg',
        'reps': 8,
        'loggedAt': DateTime(2026, 7, 10, 12, 0).toIso8601String(),
      };

      expect(() => ExerciseSet.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when weight key is missing', () {
      final json = {
        'id': 'set-1',
        'unit': 'kg',
        'reps': 8,
        'loggedAt': DateTime(2026, 7, 10, 12, 0).toIso8601String(),
      };

      expect(() => ExerciseSet.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when unit key is missing', () {
      final json = {
        'id': 'set-1',
        'weight': 60,
        'reps': 8,
        'loggedAt': DateTime(2026, 7, 10, 12, 0).toIso8601String(),
      };

      expect(() => ExerciseSet.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when reps key is missing', () {
      final json = {
        'id': 'set-1',
        'weight': 60,
        'unit': 'kg',
        'loggedAt': DateTime(2026, 7, 10, 12, 0).toIso8601String(),
      };

      expect(() => ExerciseSet.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when loggedAt key is missing', () {
      final json = {'id': 'set-1', 'weight': 60, 'unit': 'kg', 'reps': 8};

      expect(() => ExerciseSet.fromJson(json), throwsA(anything));
    });
  });
}
