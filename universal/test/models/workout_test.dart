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

  group('Workout', () {
    test('isInProgress is true when endTime is null', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
      );

      expect(workout.isInProgress, isTrue);
    });

    test('isInProgress is false when endTime is set', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        endTime: DateTime(2026, 7, 10, 11, 0),
      );

      expect(workout.isInProgress, isFalse);
    });

    test(
      'creates with id, startTime, no endTime, and empty exerciseEntries',
      () {
        final startTime = DateTime(2026, 7, 10, 10, 0);
        final workout = Workout(id: 'workout-1', startTime: startTime);

        expect(workout.id, 'workout-1');
        expect(workout.startTime, startTime);
        expect(workout.endTime, isNull);
        expect(workout.exerciseEntries, isEmpty);
      },
    );

    test('copyWith returns a new Workout with updated fields', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
      );
      final endTime = DateTime(2026, 7, 10, 11, 0);

      final updated = workout.copyWith(endTime: endTime);

      expect(updated.id, 'workout-1');
      expect(updated.startTime, workout.startTime);
      expect(updated.endTime, endTime);
    });

    test('copyWith with no arguments returns an identical Workout', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        endTime: DateTime(2026, 7, 10, 11, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      final copy = workout.copyWith();

      expect(copy.id, workout.id);
      expect(copy.startTime, workout.startTime);
      expect(copy.endTime, workout.endTime);
      expect(copy.exerciseEntries, workout.exerciseEntries);
    });

    test(
      'addSet appends a Set with loggedAt stamped at call time to the given entry',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [
            ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1'),
            ExerciseEntry(id: 'entry-2', exerciseId: 'ex-2'),
          ],
        );

        final before = DateTime.now();
        final updated = workout.addSet(
          entryId: 'entry-1',
          weight: 60,
          unit: WeightUnit.lbs,
          reps: 8,
        );
        final after = DateTime.now();

        final entry1 = updated.exerciseEntries.firstWhere(
          (e) => e.id == 'entry-1',
        );
        final entry2 = updated.exerciseEntries.firstWhere(
          (e) => e.id == 'entry-2',
        );

        expect(entry1.sets.length, 1);
        expect(entry1.sets[0].weight, 60);
        expect(entry1.sets[0].unit, WeightUnit.lbs);
        expect(entry1.sets[0].reps, 8);
        expect(
          entry1.sets[0].loggedAt.isAfter(before) ||
              entry1.sets[0].loggedAt.isAtSameMomentAs(before),
          isTrue,
        );
        expect(
          entry1.sets[0].loggedAt.isBefore(after) ||
              entry1.sets[0].loggedAt.isAtSameMomentAs(after),
          isTrue,
        );
        expect(entry2.sets, isEmpty);
      },
    );

    test('addSet throws when entryId matches no Exercise Entry', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.addSet(
          entryId: 'does-not-exist',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 8,
        ),
        throwsA(anything),
      );
    });

    test(
      'editSet updates weight, unit, and reps on the matching Set and leaves '
      'loggedAt unchanged',
      () {
        final loggedAt = DateTime(2026, 7, 10, 10, 15);
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [
            ExerciseEntry(
              id: 'entry-1',
              exerciseId: 'ex-1',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  weight: 60,
                  unit: WeightUnit.kg,
                  reps: 8,
                  loggedAt: loggedAt,
                ),
                ExerciseSet(
                  id: 'set-2',
                  weight: 20,
                  unit: WeightUnit.kg,
                  reps: 10,
                  loggedAt: loggedAt,
                ),
              ],
            ),
          ],
        );

        final updated = workout.editSet(
          entryId: 'entry-1',
          setId: 'set-1',
          weight: 65,
          unit: WeightUnit.lbs,
          reps: 6,
        );

        final entry = updated.exerciseEntries.first;
        expect(entry.sets[0].weight, 65);
        expect(entry.sets[0].unit, WeightUnit.lbs);
        expect(entry.sets[0].reps, 6);
        expect(entry.sets[0].loggedAt, loggedAt);
        expect(entry.sets[1].weight, 20);
      },
    );

    test('editSet throws when entryId matches no Exercise Entry', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.editSet(
          entryId: 'does-not-exist',
          setId: 'set-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 8,
        ),
        throwsA(anything),
      );
    });

    test('editSet throws when setId matches no Set within the Entry', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.editSet(
          entryId: 'entry-1',
          setId: 'does-not-exist',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 8,
        ),
        throwsA(anything),
      );
    });

    test(
      'deleteSet removes the matching Set from its Entry, leaving other Sets '
      'and other Entries untouched',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [
            ExerciseEntry(
              id: 'entry-1',
              exerciseId: 'ex-1',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  weight: 60,
                  unit: WeightUnit.kg,
                  reps: 8,
                  loggedAt: DateTime(2026, 7, 10, 10, 10),
                ),
                ExerciseSet(
                  id: 'set-2',
                  weight: 20,
                  unit: WeightUnit.kg,
                  reps: 10,
                  loggedAt: DateTime(2026, 7, 10, 10, 20),
                ),
              ],
            ),
            ExerciseEntry(id: 'entry-2', exerciseId: 'ex-2'),
          ],
        );

        final updated = workout.deleteSet(entryId: 'entry-1', setId: 'set-1');

        final entry1 = updated.exerciseEntries.firstWhere(
          (e) => e.id == 'entry-1',
        );
        expect(entry1.sets.length, 1);
        expect(entry1.sets[0].id, 'set-2');
        expect(
          updated.exerciseEntries.firstWhere((e) => e.id == 'entry-2').sets,
          isEmpty,
        );
      },
    );

    test('deleteSet leaves the Exercise Entry listed with zero Sets when '
        'deleting its only Set', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [
          ExerciseEntry(
            id: 'entry-1',
            exerciseId: 'ex-1',
            sets: [
              ExerciseSet(
                id: 'set-1',
                weight: 60,
                unit: WeightUnit.kg,
                reps: 8,
                loggedAt: DateTime(2026, 7, 10, 10, 10),
              ),
            ],
          ),
        ],
      );

      final updated = workout.deleteSet(entryId: 'entry-1', setId: 'set-1');

      expect(updated.exerciseEntries.length, 1);
      expect(updated.exerciseEntries[0].id, 'entry-1');
      expect(updated.exerciseEntries[0].sets, isEmpty);
    });

    test('deleteSet throws when entryId matches no Exercise Entry', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.deleteSet(entryId: 'does-not-exist', setId: 'set-1'),
        throwsA(anything),
      );
    });

    test('deleteSet throws when setId matches no Set within the Entry', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.deleteSet(entryId: 'entry-1', setId: 'does-not-exist'),
        throwsA(anything),
      );
    });

    test('deleteExerciseEntry removes the matching Entry and all its Sets, '
        'leaving other Entries untouched', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [
          ExerciseEntry(
            id: 'entry-1',
            exerciseId: 'ex-1',
            sets: [
              ExerciseSet(
                id: 'set-1',
                weight: 60,
                unit: WeightUnit.kg,
                reps: 8,
                loggedAt: DateTime(2026, 7, 10, 10, 10),
              ),
            ],
          ),
          ExerciseEntry(id: 'entry-2', exerciseId: 'ex-2'),
        ],
      );

      final updated = workout.deleteExerciseEntry(entryId: 'entry-1');

      expect(updated.exerciseEntries.length, 1);
      expect(updated.exerciseEntries[0].id, 'entry-2');
    });

    test(
      'deleteExerciseEntry throws when entryId matches no Exercise Entry',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
        );

        expect(
          () => workout.deleteExerciseEntry(entryId: 'does-not-exist'),
          throwsA(anything),
        );
      },
    );

    test(
      'finish sets endTime to the loggedAt of the most recently logged Set across all entries',
      () {
        final earliest = DateTime(2026, 7, 10, 10, 10);
        final latest = DateTime(2026, 7, 10, 10, 30);
        final middle = DateTime(2026, 7, 10, 10, 20);

        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [
            ExerciseEntry(
              id: 'entry-1',
              exerciseId: 'ex-1',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  weight: 60,
                  unit: WeightUnit.kg,
                  reps: 8,
                  loggedAt: earliest,
                ),
                ExerciseSet(
                  id: 'set-2',
                  weight: 65,
                  unit: WeightUnit.kg,
                  reps: 6,
                  loggedAt: latest,
                ),
              ],
            ),
            ExerciseEntry(
              id: 'entry-2',
              exerciseId: 'ex-2',
              sets: [
                ExerciseSet(
                  id: 'set-3',
                  weight: 20,
                  unit: WeightUnit.kg,
                  reps: 10,
                  loggedAt: middle,
                ),
              ],
            ),
          ],
        );

        final finished = workout.finish()!;

        expect(finished.endTime, latest);
        expect(finished.isInProgress, isFalse);
      },
    );

    test(
      'finish returns null and leaves the Workout unchanged when zero Sets are logged',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
        );

        final result = workout.finish();

        expect(result, isNull);
        expect(workout.endTime, isNull);
        expect(workout.isInProgress, isTrue);
      },
    );

    test(
      'toJson/fromJson round-trip preserves id, startTime, endTime, and nested entries/sets',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          endTime: DateTime(2026, 7, 10, 11, 0),
          exerciseEntries: [
            ExerciseEntry(
              id: 'entry-1',
              exerciseId: 'ex-1',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  weight: 60,
                  unit: WeightUnit.kg,
                  reps: 8,
                  loggedAt: DateTime(2026, 7, 10, 10, 30),
                ),
              ],
            ),
          ],
        );

        final restored = Workout.fromJson(workout.toJson());

        expect(restored.id, 'workout-1');
        expect(restored.startTime, workout.startTime);
        expect(restored.endTime, workout.endTime);
        expect(restored.exerciseEntries.length, 1);
        expect(restored.exerciseEntries[0].id, 'entry-1');
        expect(restored.exerciseEntries[0].exerciseId, 'ex-1');
        expect(restored.exerciseEntries[0].sets.length, 1);
        expect(restored.exerciseEntries[0].sets[0].id, 'set-1');
        expect(restored.exerciseEntries[0].sets[0].unit, WeightUnit.kg);
      },
    );

    test('fromJson throws when id key is missing', () {
      final json = {
        'startTime': DateTime(2026, 7, 10, 10, 0).toIso8601String(),
        'exerciseEntries': [],
      };

      expect(() => Workout.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when startTime key is missing', () {
      final json = {'id': 'workout-1', 'exerciseEntries': []};

      expect(() => Workout.fromJson(json), throwsA(anything));
    });

    test('fromJson throws when exerciseEntries key is missing', () {
      final json = {
        'id': 'workout-1',
        'startTime': DateTime(2026, 7, 10, 10, 0).toIso8601String(),
      };

      expect(() => Workout.fromJson(json), throwsA(anything));
    });
  });
}
