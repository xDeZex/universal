import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/services/storage_service.dart';

import 'workout_repository_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.startWorkout with routineId', () {
    test(
      'accepts an optional routineId and sets it on the created Workout',
      () {
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
        );

        repository.startWorkout(routineId: 'routine-1');

        expect(repository.workouts.single.routineId, 'routine-1');
      },
    );

    test('omitting routineId defaults to null', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );

      repository.startWorkout();

      expect(repository.workouts.single.routineId, isNull);
    });
  });

  group('WorkoutRepository.load with Routines', () {
    test(
      'load() populates routines alongside workouts and exercises',
      () async {
        final storage = StorageService();
        await storage.saveRoutines([
          Routine(id: 'routine-1', name: 'Push Day'),
        ]);

        final repository = WorkoutRepository();
        expect(repository.routines, isEmpty);

        await repository.load();

        expect(repository.routines.map((r) => r.id), ['routine-1']);
      },
    );
  });

  group('WorkoutRepository.addRoutine', () {
    test('with a unique name, creates and returns a new active Routine with no '
        'Planned Exercises', () async {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: const [],
      );

      final routine = repository.addRoutine('Push Day')!;

      expect(routine.name, 'Push Day');
      expect(routine.plannedExercises, isEmpty);
      expect(routine.archivedAt, isNull);
      expect(repository.routines.single, routine);
    });

    test(
      'with a blank name, returns null and leaves the Routine list unchanged',
      () {
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: const [],
        );

        final result = repository.addRoutine('   ');

        expect(result, isNull);
        expect(repository.routines, isEmpty);
      },
    );

    test('with a name colliding case-insensitively with an existing Routine, '
        'returns null and creates no second Routine', () {
      final existing = Routine(id: 'routine-1', name: 'Push Day');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [existing],
      );

      final result = repository.addRoutine('push day');

      expect(result, isNull);
      expect(repository.routines.length, 1);
    });

    test(
      'a successful call persists the updated Routine list via StorageService '
      'and calls notifyListeners()',
      () async {
        final repository = WorkoutRepository(
          initialWorkouts: const [],
          initialExercises: const [],
          initialRoutines: const [],
        );
        final wasNotified = trackNotifications(repository);

        repository.addRoutine('Push Day');

        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadRoutines();
        expect(stored.map((r) => r.name), ['Push Day']);
      },
    );
  });
}
