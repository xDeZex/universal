import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/repositories/workout_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.startWorkout with routineId', () {
    test('accepts an optional routineId and sets it on the created Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );

      repository.startWorkout(routineId: 'routine-1');

      expect(repository.workouts.single.routineId, 'routine-1');
    });

    test('omitting routineId defaults to null', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );

      repository.startWorkout();

      expect(repository.workouts.single.routineId, isNull);
    });
  });
}
