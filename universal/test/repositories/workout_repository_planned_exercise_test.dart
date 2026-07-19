import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/repositories/workout_repository.dart';

import 'workout_repository_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WorkoutRepository.addPlannedExercise', () {
    test('on an active Routine, resolves the name via Exercise.resolve, '
        'appends a new Planned Exercise referencing the resolved Exercise\'s '
        'id, persists, and notifies listeners', () async {
      final routine = Routine(id: 'routine-1', name: 'Push Day');
      final existingExercise = Exercise(id: 'exercise-1', name: 'Bench Press');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: [existingExercise],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      final planned = repository.addPlannedExercise('routine-1', 'bench press');

      expect(planned, isNotNull);
      expect(planned!.exerciseId, 'exercise-1');
      expect(
        repository.routines.single.plannedExercises.single.exerciseId,
        'exercise-1',
      );
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadRoutines();
      expect(stored.single.plannedExercises.single.exerciseId, 'exercise-1');
    });

    test('with a name matching no existing Exercise, creates a new Exercise, '
        'persists it, and references it from the new Planned Exercise', () async {
      final routine = Routine(id: 'routine-1', name: 'Push Day');
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );

      final planned = repository.addPlannedExercise('routine-1', 'Squat');

      expect(planned, isNotNull);
      final createdExercise = repository.exercises.single;
      expect(createdExercise.name, 'Squat');
      expect(planned!.exerciseId, createdExercise.id);

      final storedExercises = await flushAndLoadExercises();
      expect(storedExercises.single.name, 'Squat');
    });

    test('on an archived Routine, leaves the Routine list unchanged and '
        'persists nothing', () async {
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        archivedAt: DateTime(2026, 1, 1),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      final result = repository.addPlannedExercise('routine-1', 'Bench Press');

      expect(result, isNull);
      expect(repository.routines.single.plannedExercises, isEmpty);
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });
  });

  group('WorkoutRepository.removePlannedExercise', () {
    test('on an active Routine, removes the matching Planned Exercise, '
        'persists, and notifies listeners', () async {
      final keep = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final remove = PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [keep, remove],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.removePlannedExercise('routine-1', 'pe-2');

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-1'],
      );
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadRoutines();
      expect(stored.single.plannedExercises.map((pe) => pe.id), ['pe-1']);
    });

    test('with a plannedExerciseId that matches no Planned Exercise, is a '
        'no-op and persists nothing', () async {
      final planned = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [planned],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.removePlannedExercise('routine-1', 'missing-pe');

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-1'],
      );
      expect(wasNotified(), isFalse);
    });

    test('on an archived Routine, leaves the Routine list unchanged and '
        'persists nothing', () async {
      final planned = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [planned],
        archivedAt: DateTime(2026, 1, 1),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.removePlannedExercise('routine-1', 'pe-1');

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-1'],
      );
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });
  });

  group('WorkoutRepository.reorderPlannedExercises', () {
    test('on an active Routine, reorders the list, persists, and notifies '
        'listeners', () async {
      final first = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final second = PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2');
      final third = PlannedExercise(id: 'pe-3', exerciseId: 'exercise-3');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [first, second, third],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.reorderPlannedExercises('routine-1', 0, 2);

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-2', 'pe-3', 'pe-1'],
      );
      expect(wasNotified(), isTrue);

      final stored = await flushAndLoadRoutines();
      expect(
        stored.single.plannedExercises.map((pe) => pe.id),
        ['pe-2', 'pe-3', 'pe-1'],
      );
    });

    test('with an out-of-range oldIndex or newIndex, is a no-op and '
        'persists nothing', () async {
      final first = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final second = PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [first, second],
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.reorderPlannedExercises('routine-1', 0, 5);

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-1', 'pe-2'],
      );
      expect(wasNotified(), isFalse);
    });

    test('on an archived Routine, leaves the Routine list unchanged and '
        'persists nothing', () async {
      final first = PlannedExercise(id: 'pe-1', exerciseId: 'exercise-1');
      final second = PlannedExercise(id: 'pe-2', exerciseId: 'exercise-2');
      final routine = Routine(
        id: 'routine-1',
        name: 'Push Day',
        plannedExercises: [first, second],
        archivedAt: DateTime(2026, 1, 1),
      );
      final repository = WorkoutRepository(
        initialWorkouts: const [],
        initialExercises: const [],
        initialRoutines: [routine],
      );
      final wasNotified = trackNotifications(repository);

      repository.reorderPlannedExercises('routine-1', 0, 1);

      expect(
        repository.routines.single.plannedExercises.map((pe) => pe.id),
        ['pe-1', 'pe-2'],
      );
      expect(wasNotified(), isFalse);

      final stored = await flushAndLoadRoutines();
      expect(stored, isEmpty);
    });
  });
}
