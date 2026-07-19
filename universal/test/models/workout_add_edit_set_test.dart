import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('Workout.addSet', () {
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

    test('addSet throws when reps is not > 0', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(
        () => workout.addSet(
          entryId: 'entry-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 0,
        ),
        throwsA(anything),
      );
    });
  });

  group('Workout.editSet', () {
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

    test('editSet throws when reps is not > 0', () {
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
            ],
          ),
        ],
      );

      expect(
        () => workout.editSet(
          entryId: 'entry-1',
          setId: 'set-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: -1,
        ),
        throwsA(anything),
      );
    });
  });
}
