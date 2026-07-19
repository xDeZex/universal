import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/services/storage_service.dart';

import 'workout_repository_test_helpers.dart';

/// Returns fixed, storage-independent data so tests can prove a
/// [WorkoutRepository] reads through *this* instance rather than a
/// `StorageService()` it silently constructed itself.
class _FakeStorageService extends StorageService {
  @override
  Future<List<Workout>> loadWorkouts() async => [
    Workout(id: 'fake-only-workout', startTime: DateTime(2026, 1, 1)),
  ];

  @override
  Future<List<Exercise>> loadExercises() async => [
    Exercise(id: 'fake-only-exercise', name: 'Fake Exercise'),
  ];
}

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

        final wasNotified = trackNotifications(repository);

        await repository.load();

        expect(wasNotified(), isTrue);
        expect(repository.workouts.map((w) => w.id), ['workout-1']);
        expect(repository.exercises.map((e) => e.name), ['Bench Press']);
      },
    );

    test('seeded with initialWorkouts/initialExercises, load() is a no-op and '
        'never touches StorageService', () async {
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
    });

    test('seeding only initialWorkouts (no initialExercises) still skips the '
        'StorageService load entirely, leaving exercises empty', () async {
      final storage = StorageService();
      await storage.saveExercises([
        Exercise(id: 'stored-exercise', name: 'Bench Press'),
      ]);

      final repository = WorkoutRepository(
        initialWorkouts: [
          Workout(id: 'seeded-workout', startTime: DateTime(2026, 1, 1)),
        ],
      );

      await repository.load();

      expect(repository.workouts.map((w) => w.id), ['seeded-workout']);
      expect(repository.exercises, isEmpty);
    });

    test('uses an injected StorageService instance instead of constructing its '
        'own', () async {
      // Nothing is saved to the real (mocked) SharedPreferences backing
      // store, so this can only pass if the repository reads through the
      // injected fake rather than a StorageService() it built itself.
      final repository = WorkoutRepository(storage: _FakeStorageService());
      await repository.load();

      expect(repository.workouts.map((w) => w.id), ['fake-only-workout']);
      expect(repository.exercises.map((e) => e.name), ['Fake Exercise']);
    });

    test('with no seed data and no prior storage, load() defaults to empty '
        'lists rather than throwing', () async {
      final repository = WorkoutRepository();

      await repository.load();

      expect(repository.workouts, isEmpty);
      expect(repository.exercises, isEmpty);
    });
  });

  group('WorkoutRepository.startWorkout', () {
    test('creates a new in-progress Workout, adds it to workouts, persists it, '
        'and notifies listeners', () async {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.startWorkout();

      expect(repository.workouts.length, 1);
      expect(repository.workouts[0].isInProgress, isTrue);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadWorkouts();
      expect(stored.length, 1);
      expect(stored[0].id, repository.workouts[0].id);
    });
  });

  group('WorkoutRepository.addExerciseEntry', () {
    test('resolving a new Exercise name creates the Exercise, appends the '
        'Entry, persists both lists, and notifies listeners', () async {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.addExerciseEntry('workout-1', 'Bench Press');

      expect(repository.exercises.map((e) => e.name), ['Bench Press']);
      final updated = repository.workouts.single;
      expect(
        updated.exerciseEntries.single.exerciseId,
        repository.exercises.single.id,
      );
      expect(wasNotified(), isTrue);

      expect((await flushAndLoadExercises()).length, 1);
      expect((await flushAndLoadWorkouts())[0].exerciseEntries.length, 1);
    });

    test('resolving an existing Exercise name (case-insensitive) reuses it '
        'instead of creating a duplicate', () async {
      final exercise = Exercise(id: 'exercise-1', name: 'Bench Press');
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: [exercise],
      );

      repository.addExerciseEntry('workout-1', 'bench press');

      expect(repository.exercises.length, 1);
      expect(
        repository.workouts.single.exerciseEntries.single.exerciseId,
        'exercise-1',
      );
    });

    test('is a no-op for a workoutId that matches no Workout, and does not '
        'orphan a newly-resolved Exercise', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.addExerciseEntry('missing-workout', 'Bench Press');

      expect(repository.exercises, isEmpty);
      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.addSet', () {
    test('delegates to Workout.addSet, replaces the Workout, persists it, and '
        'notifies listeners', () async {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.addSet(
        workoutId: 'workout-1',
        entryId: 'entry-1',
        weight: 60,
        unit: WeightUnit.kg,
        reps: 5,
      );

      final updated = repository.workouts.single;
      expect(updated.exerciseEntries.single.sets.single.weight, 60);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadWorkouts();
      expect(stored[0].exerciseEntries[0].sets.single.weight, 60);
    });

    test('is a no-op for a workoutId that matches no Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.addSet(
        workoutId: 'missing-workout',
        entryId: 'entry-1',
        weight: 60,
        unit: WeightUnit.kg,
        reps: 5,
      );

      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.editSet', () {
    test(
      'delegates to Workout.editSet, persists, and notifies listeners',
      () async {
        final set = ExerciseSet(
          id: 'set-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 5,
          loggedAt: DateTime(2026, 1, 1),
        );
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [set],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );
        final repository = WorkoutRepository(
          initialWorkouts: [workout],
          initialExercises: const [],
        );
        final wasNotified = trackNotifications(repository);

        repository.editSet(
          workoutId: 'workout-1',
          entryId: 'entry-1',
          setId: 'set-1',
          weight: 99,
          unit: WeightUnit.kg,
          reps: 3,
        );

        final updatedSet =
            repository.workouts.single.exerciseEntries.single.sets.single;
        expect(updatedSet.weight, 99);
        expect(updatedSet.reps, 3);
        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadWorkouts();
        expect(stored[0].exerciseEntries[0].sets[0].weight, 99);
      },
    );

    test('is a no-op for a workoutId that matches no Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.editSet(
        workoutId: 'missing-workout',
        entryId: 'entry-1',
        setId: 'set-1',
        weight: 99,
        unit: WeightUnit.kg,
        reps: 3,
      );

      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.deleteSet', () {
    test(
      'delegates to Workout.deleteSet, persists, and notifies listeners',
      () async {
        final set = ExerciseSet(
          id: 'set-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 5,
          loggedAt: DateTime(2026, 1, 1),
        );
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [set],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );
        final repository = WorkoutRepository(
          initialWorkouts: [workout],
          initialExercises: const [],
        );
        final wasNotified = trackNotifications(repository);

        repository.deleteSet(
          workoutId: 'workout-1',
          entryId: 'entry-1',
          setId: 'set-1',
        );

        expect(repository.workouts.single.exerciseEntries.single.sets, isEmpty);
        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadWorkouts();
        expect(stored[0].exerciseEntries[0].sets, isEmpty);
      },
    );

    test('is a no-op for a workoutId that matches no Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.deleteSet(
        workoutId: 'missing-workout',
        entryId: 'entry-1',
        setId: 'set-1',
      );

      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.deleteExerciseEntry', () {
    test('delegates to Workout.deleteExerciseEntry, persists, and notifies '
        'listeners', () async {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.deleteExerciseEntry(
        workoutId: 'workout-1',
        entryId: 'entry-1',
      );

      expect(repository.workouts.single.exerciseEntries, isEmpty);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadWorkouts();
      expect(stored[0].exerciseEntries, isEmpty);
    });

    test('is a no-op for a workoutId that matches no Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.deleteExerciseEntry(
        workoutId: 'missing-workout',
        entryId: 'entry-1',
      );

      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.finishWorkout', () {
    test(
      'delegates to Workout.finish(), persists, and notifies listeners',
      () async {
        final loggedAt = DateTime(2026, 1, 1, 10, 30);
        final set = ExerciseSet(
          id: 'set-1',
          weight: 60,
          unit: WeightUnit.kg,
          reps: 5,
          loggedAt: loggedAt,
        );
        final entry = ExerciseEntry(
          id: 'entry-1',
          exerciseId: 'exercise-1',
          sets: [set],
        );
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 10, 0),
          exerciseEntries: [entry],
        );
        final repository = WorkoutRepository(
          initialWorkouts: [workout],
          initialExercises: const [],
        );
        final wasNotified = trackNotifications(repository);

        repository.finishWorkout('workout-1');

        expect(repository.workouts.single.isInProgress, isFalse);
        expect(repository.workouts.single.endTime, loggedAt);
        expect(wasNotified(), isTrue);

        final stored = await flushAndLoadWorkouts();
        expect(stored[0].isInProgress, isFalse);
      },
    );

    test(
      'is a no-op when Workout.finish() returns null (no logged Sets)',
      () async {
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
        );
        final repository = WorkoutRepository(
          initialWorkouts: [workout],
          initialExercises: const [],
        );
        final wasNotified = trackNotifications(repository);

        repository.finishWorkout('workout-1');

        expect(repository.workouts.single.isInProgress, isTrue);
        expect(wasNotified(), isFalse);
      },
    );

    test('is a no-op for a workoutId that matches no Workout', () {
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.finishWorkout('missing-workout');

      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.discardWorkout', () {
    test('removes the Workout entirely from workouts, persists, and notifies '
        'listeners', () async {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.discardWorkout('workout-1');

      expect(repository.workouts, isEmpty);
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadWorkouts();
      expect(stored, isEmpty);
    });

    test('is a no-op for a workoutId that matches no Workout', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.discardWorkout('missing-workout');

      expect(repository.workouts.map((w) => w.id), ['workout-1']);
      expect(wasNotified(), isFalse);
    });

    test('is a no-op for a Workout that is already finished, leaving it '
        'unchanged (discard is unavailable on a finished Workout)', () {
      final finished = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1, 9, 0),
        endTime: DateTime(2026, 1, 1, 9, 30),
      );
      final repository = WorkoutRepository(
        initialWorkouts: [finished],
        initialExercises: const [],
      );
      final wasNotified = trackNotifications(repository);

      repository.discardWorkout('workout-1');

      expect(repository.workouts.map((w) => w.id), ['workout-1']);
      expect(repository.workouts.single.isInProgress, isFalse);
      expect(wasNotified(), isFalse);
    });
  });

  group('WorkoutRepository.renameExercise', () {
    test('delegates to Exercise.copyWith(name:), persists, and notifies '
        'listeners', () async {
      final exercise = Exercise(id: 'exercise-1', name: 'Bench Press');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: [exercise],
      );
      final wasNotified = trackNotifications(repository);

      repository.renameExercise('exercise-1', 'Incline Bench Press');

      expect(repository.exercises.single.name, 'Incline Bench Press');
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadExercises();
      expect(stored[0].name, 'Incline Bench Press');
    });

    test('rejects a blank new name, leaving the Exercise unchanged', () async {
      final exercise = Exercise(id: 'exercise-1', name: 'Bench Press');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: [exercise],
      );
      final wasNotified = trackNotifications(repository);

      repository.renameExercise('exercise-1', '   ');

      expect(repository.exercises.single.name, 'Bench Press');
      expect(wasNotified(), isFalse);
    });

    test('rejects a name colliding with another Exercise, leaving both '
        'unchanged', () async {
      final exercises = [
        Exercise(id: 'exercise-1', name: 'Bench Press'),
        Exercise(id: 'exercise-2', name: 'Squat'),
      ];
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: exercises,
      );
      final wasNotified = trackNotifications(repository);

      repository.renameExercise('exercise-2', 'bench press');

      expect(
        repository.exercises.firstWhere((e) => e.id == 'exercise-2').name,
        'Squat',
      );
      expect(wasNotified(), isFalse);
    });

    test('is a no-op for an exerciseId that matches no Exercise', () {
      final exercise = Exercise(id: 'exercise-1', name: 'Bench Press');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: [exercise],
      );
      final wasNotified = trackNotifications(repository);

      repository.renameExercise('missing-exercise', 'New Name');

      expect(repository.exercises.single.name, 'Bench Press');
      expect(wasNotified(), isFalse);
    });
  });
}
