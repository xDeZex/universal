import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('loadWorkouts returns empty list when no data', () async {
      final workouts = await storageService.loadWorkouts();

      expect(workouts, isEmpty);
    });

    test('saveWorkouts and loadWorkouts round-trip works', () async {
      final workouts = [
        Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1, 8),
          endTime: DateTime(2026, 1, 1, 9),
          exerciseEntries: [
            ExerciseEntry(
              id: 'entry-1',
              exerciseId: 'exercise-1',
              sets: [
                ExerciseSet(
                  id: 'set-1',
                  weight: 60,
                  unit: WeightUnit.kg,
                  reps: 5,
                  loggedAt: DateTime(2026, 1, 1, 8, 30),
                ),
              ],
            ),
          ],
        ),
        Workout(id: 'workout-2', startTime: DateTime(2026, 1, 2, 8)),
      ];

      await storageService.saveWorkouts(workouts);
      final loaded = await storageService.loadWorkouts();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'workout-1');
      expect(loaded[0].endTime, DateTime(2026, 1, 1, 9));
      expect(loaded[0].exerciseEntries.length, 1);
      expect(loaded[0].exerciseEntries[0].sets.length, 1);
      expect(loaded[0].exerciseEntries[0].sets[0].weight, 60);
      expect(loaded[0].exerciseEntries[0].sets[0].unit, WeightUnit.kg);
      expect(loaded[1].id, 'workout-2');
      expect(loaded[1].exerciseEntries, isEmpty);
    });

    test('loadWorkouts handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({'workouts': 'not valid json'});
      storageService = StorageService();

      final workouts = await storageService.loadWorkouts();

      expect(workouts, isEmpty);
    });

    test('loadExercises returns empty list when no data', () async {
      final exercises = await storageService.loadExercises();

      expect(exercises, isEmpty);
    });

    test('saveExercises and loadExercises round-trip works', () async {
      final exercises = [
        Exercise(id: 'exercise-1', name: 'Bench Press'),
        Exercise(id: 'exercise-2', name: 'Squat'),
      ];

      await storageService.saveExercises(exercises);
      final loaded = await storageService.loadExercises();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'exercise-1');
      expect(loaded[0].name, 'Bench Press');
      expect(loaded[1].id, 'exercise-2');
      expect(loaded[1].name, 'Squat');
    });

    test('loadExercises handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({'exercises': 'not valid json'});
      storageService = StorageService();

      final exercises = await storageService.loadExercises();

      expect(exercises, isEmpty);
    });

    test(
      'saveExercises writes under a key separate from workouts',
      () async {
        final exercises = [Exercise(id: 'exercise-1', name: 'Bench Press')];
        final workouts = [
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ];

        await storageService.saveExercises(exercises);
        await storageService.saveWorkouts(workouts);

        final loadedExercises = await storageService.loadExercises();
        final loadedWorkouts = await storageService.loadWorkouts();

        expect(loadedExercises.length, 1);
        expect(loadedWorkouts.length, 1);
      },
    );

    test('loadRoutines returns empty list when no data', () async {
      final routines = await storageService.loadRoutines();

      expect(routines, isEmpty);
    });

    test('loadRoutines handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({'routines': 'not valid json'});
      storageService = StorageService();

      final routines = await storageService.loadRoutines();

      expect(routines, isEmpty);
    });

    test('saveRoutines and loadRoutines round-trip works', () async {
      final routines = [
        Routine(id: 'routine-1', name: 'Push Day'),
        Routine(id: 'routine-2', name: 'Pull Day'),
      ];

      await storageService.saveRoutines(routines);
      final loaded = await storageService.loadRoutines();

      expect(loaded.length, 2);
      expect(loaded[0].id, 'routine-1');
      expect(loaded[0].name, 'Push Day');
      expect(loaded[1].id, 'routine-2');
      expect(loaded[1].name, 'Pull Day');
    });

    test(
      'saveRoutines writes under a key separate from workouts and exercises',
      () async {
        final routines = [Routine(id: 'routine-1', name: 'Push Day')];
        final exercises = [Exercise(id: 'exercise-1', name: 'Bench Press')];
        final workouts = [
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ];

        await storageService.saveRoutines(routines);
        await storageService.saveExercises(exercises);
        await storageService.saveWorkouts(workouts);

        final loadedRoutines = await storageService.loadRoutines();
        final loadedExercises = await storageService.loadExercises();
        final loadedWorkouts = await storageService.loadWorkouts();

        expect(loadedRoutines.length, 1);
        expect(loadedExercises.length, 1);
        expect(loadedWorkouts.length, 1);
      },
    );
  });
}
