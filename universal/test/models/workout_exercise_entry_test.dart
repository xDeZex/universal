import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('ExerciseEntry', () {
    test('creates with id, exerciseId, and empty sets list', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1');

      expect(entry.id, 'entry-1');
      expect(entry.exerciseId, 'ex-1');
      expect(entry.sets, isEmpty);
    });

    test('targets defaults to null', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1');

      expect(entry.targets, isNull);
    });

    test('copyWith supports overriding targets', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1');
      const targets = [
        PlannedExerciseRow(
          reps: FixedReps(10),
          weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
        ),
      ];

      final updated = entry.copyWith(targets: targets);

      expect(updated.targets, targets);
    });

    test('toJson/fromJson round-trips a non-null targets list', () {
      final entry = ExerciseEntry(
        id: 'entry-1',
        exerciseId: 'ex-1',
        targets: const [
          PlannedExerciseRow(
            reps: FixedReps(10),
            weight: PlannedWeight(value: 60, unit: WeightUnit.kg),
          ),
          PlannedExerciseRow(
            reps: RangeReps(min: 8, max: 12),
            weight: PlannedWeight(value: 40, unit: WeightUnit.lbs),
          ),
        ],
      );

      final restored = ExerciseEntry.fromJson(entry.toJson());

      expect(restored.targets, isNotNull);
      expect(restored.targets!.length, 2);
      expect(restored.targets![0].reps, isA<FixedReps>());
      expect((restored.targets![0].reps as FixedReps).reps, 10);
      expect(restored.targets![0].weight.value, 60);
      expect(restored.targets![0].weight.unit, WeightUnit.kg);
      expect(restored.targets![1].reps, isA<RangeReps>());
      expect((restored.targets![1].reps as RangeReps).min, 8);
      expect((restored.targets![1].reps as RangeReps).max, 12);
      expect(restored.targets![1].weight.value, 40);
      expect(restored.targets![1].weight.unit, WeightUnit.lbs);
    });

    test('toJson/fromJson round-trips a null targets as null', () {
      final entry = ExerciseEntry(
        id: 'entry-1',
        exerciseId: 'ex-1',
        targets: null,
      );

      final restored = ExerciseEntry.fromJson(entry.toJson());

      expect(restored.targets, isNull);
    });

    test(
      'fromJson on a map missing the targets key produces null rather than throwing',
      () {
        final json = {'id': 'entry-1', 'exerciseId': 'ex-1', 'sets': []};

        final restored = ExerciseEntry.fromJson(json);

        expect(restored.targets, isNull);
      },
    );

    test('copyWith returns a new ExerciseEntry with updated fields', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1');
      final set = ExerciseSet(
        id: 'set-1',
        weight: 60,
        unit: WeightUnit.kg,
        reps: 8,
        loggedAt: DateTime(2026, 7, 10, 12, 0),
      );

      final updated = entry.copyWith(sets: [set]);

      expect(updated.id, 'entry-1');
      expect(updated.exerciseId, 'ex-1');
      expect(updated.sets, [set]);
    });

    test('copyWith with no arguments returns an identical ExerciseEntry', () {
      final entry = ExerciseEntry(
        id: 'entry-1',
        exerciseId: 'ex-1',
        sets: [
          ExerciseSet(
            id: 'set-1',
            weight: 60,
            unit: WeightUnit.kg,
            reps: 8,
            loggedAt: DateTime(2026, 7, 10, 12, 0),
          ),
        ],
      );

      final copy = entry.copyWith();

      expect(copy.id, entry.id);
      expect(copy.exerciseId, entry.exerciseId);
      expect(copy.sets, entry.sets);
    });

    test(
      'toJson/fromJson round-trip preserves id, exerciseId, and nested sets',
      () {
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'ex-1',
          sets: [
            ExerciseSet(
              id: 'set-1',
              weight: 60,
              unit: WeightUnit.kg,
              reps: 8,
              loggedAt: DateTime(2026, 7, 10, 12, 0),
            ),
          ],
        );

        final restored = ExerciseEntry.fromJson(entry.toJson());

        expect(restored.id, 'entry-1');
        expect(restored.exerciseId, 'ex-1');
        expect(restored.sets.length, 1);
        expect(restored.sets[0].id, 'set-1');
        expect(restored.sets[0].weight, 60);
        expect(restored.sets[0].unit, WeightUnit.kg);
        expect(restored.sets[0].reps, 8);
        expect(restored.sets[0].loggedAt, entry.sets[0].loggedAt);
      },
    );

    test('fromJson throws when id key is missing', () {
      final json = {'exerciseId': 'ex-1', 'sets': []};

      expect(() => ExerciseEntry.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when exerciseId key is missing', () {
      final json = {'id': 'entry-1', 'sets': []};

      expect(() => ExerciseEntry.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when sets key is missing', () {
      final json = {'id': 'entry-1', 'exerciseId': 'ex-1'};

      expect(() => ExerciseEntry.fromJson(json), throwsA(anything));
    });
  });
}
