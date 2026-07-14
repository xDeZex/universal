import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/services/storage_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository load', () {
    test(
      'with no seed data, load() reads Workouts and Exercises from '
      'StorageService and notifies listeners once both are available',
      () async {
        final storage = StorageService();
        await storage.saveWorkouts([
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ]);
        await storage.saveExercises([
          Exercise(id: 'exercise-1', name: 'Bench Press'),
        ]);

        final repository = WorkoutRepository();
        expect(repository.workouts, isEmpty);
        expect(repository.exercises, isEmpty);

        var notified = false;
        repository.addListener(() => notified = true);

        await repository.load();

        expect(notified, isTrue);
        expect(repository.workouts.map((w) => w.id), ['workout-1']);
        expect(repository.exercises.map((e) => e.name), ['Bench Press']);
      },
    );

    test(
      'seeded with initialWorkouts/initialExercises, load() is a no-op and '
      'never touches StorageService',
      () async {
        final storage = StorageService();
        await storage.saveWorkouts([
          Workout(id: 'stored-workout', startTime: DateTime(2026, 1, 1)),
        ]);

        final seededWorkout = Workout(
          id: 'seeded-workout',
          startTime: DateTime(2026, 1, 2),
        );
        final repository = WorkoutRepository(
          initialWorkouts: [seededWorkout],
          initialExercises: const [],
        );

        await repository.load();

        expect(repository.workouts.map((w) => w.id), ['seeded-workout']);
      },
    );

    test(
      'uses an injected StorageService instance instead of constructing its '
      'own',
      () async {
        final fakeStorage = StorageService();
        await fakeStorage.saveWorkouts([
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ]);

        final repository = WorkoutRepository(storage: fakeStorage);
        await repository.load();

        expect(repository.workouts.map((w) => w.id), ['workout-1']);
      },
    );
  });
}
