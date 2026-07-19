import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('ExerciseEntry', () {
    test('creates with id, exerciseId, and empty sets list', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1');

      expect(entry.id, 'entry-1');
      expect(entry.exerciseId, 'ex-1');
      expect(entry.sets, isEmpty);
    });

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
