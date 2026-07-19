import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
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
