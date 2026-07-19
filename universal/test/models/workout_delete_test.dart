import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('Workout.deleteSet', () {
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
  });

  group('Workout.deleteExerciseEntry', () {
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
  });
}
