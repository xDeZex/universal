import 'package:flutter_test/flutter_test.dart';
import 'package:universal/models/workout.dart';

void main() {
  group('Workout.routineId', () {
    test(
      'a Workout constructed with a routineId round-trips through JSON with '
      'that routineId intact',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
          routineId: 'routine-1',
        );

        final restored = Workout.fromJson(workout.toJson());

        expect(restored.routineId, 'routine-1');
      },
    );

    test(
      'a Workout constructed without a routineId has routineId == null and '
      'round-trips as null',
      () {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 7, 10, 10, 0),
        );

        expect(workout.routineId, isNull);

        final restored = Workout.fromJson(workout.toJson());

        expect(restored.routineId, isNull);
      },
    );

    test('copyWith has no parameter that can change routineId', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 7, 10, 10, 0),
        routineId: 'routine-1',
      );

      final copy = workout.copyWith(
        endTime: DateTime(2026, 7, 10, 11, 0),
        exerciseEntries: [ExerciseEntry(id: 'entry-1', exerciseId: 'ex-1')],
      );

      expect(copy.routineId, 'routine-1');
    });
  });
}
