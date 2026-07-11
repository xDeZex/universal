import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/checklist.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storageService = StorageService();
    });

    test('loadChecklists returns empty list when no data', () async {
      final checklists = await storageService.loadChecklists();

      expect(checklists, isEmpty);
    });

    test('saveChecklists and loadChecklists round-trip works', () async {
      final checklists = [
        Checklist(
          name: 'Groceries',
          items: [
            ChecklistItem(name: 'Milk'),
            ChecklistItem(name: 'Bread', isChecked: true),
          ],
        ),
        Checklist(name: 'Todo'),
      ];

      await storageService.saveChecklists(checklists);
      final loaded = await storageService.loadChecklists();

      expect(loaded.length, 2);
      expect(loaded[0].name, 'Groceries');
      expect(loaded[0].items.length, 2);
      expect(loaded[0].items[0].name, 'Milk');
      expect(loaded[0].items[0].isChecked, false);
      expect(loaded[0].items[1].name, 'Bread');
      expect(loaded[0].items[1].isChecked, true);
      expect(loaded[1].name, 'Todo');
      expect(loaded[1].items, isEmpty);
    });

    test('saveChecklists overwrites existing data', () async {
      final initial = [Checklist(name: 'First')];
      await storageService.saveChecklists(initial);

      final replacement = [Checklist(name: 'Second')];
      await storageService.saveChecklists(replacement);

      final loaded = await storageService.loadChecklists();

      expect(loaded.length, 1);
      expect(loaded[0].name, 'Second');
    });

    test('saveChecklists with empty list clears data', () async {
      final checklists = [Checklist(name: 'Test')];
      await storageService.saveChecklists(checklists);

      await storageService.saveChecklists([]);

      final loaded = await storageService.loadChecklists();
      expect(loaded, isEmpty);
    });

    test('loadChecklists handles corrupted JSON gracefully', () async {
      SharedPreferences.setMockInitialValues({'checklists': 'not valid json'});
      storageService = StorageService();

      final checklists = await storageService.loadChecklists();

      expect(checklists, isEmpty);
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

    test('saveWorkouts writes under a key separate from checklists', () async {
      final workouts = [
        Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
      ];
      final checklists = [Checklist(name: 'Groceries')];

      await storageService.saveWorkouts(workouts);
      await storageService.saveChecklists(checklists);

      final loadedWorkouts = await storageService.loadWorkouts();
      final loadedChecklists = await storageService.loadChecklists();

      expect(loadedWorkouts.length, 1);
      expect(loadedChecklists.length, 1);
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
      'saveExercises writes under a key separate from workouts and checklists',
      () async {
        final exercises = [Exercise(id: 'exercise-1', name: 'Bench Press')];
        final workouts = [
          Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1)),
        ];
        final checklists = [Checklist(name: 'Groceries')];

        await storageService.saveExercises(exercises);
        await storageService.saveWorkouts(workouts);
        await storageService.saveChecklists(checklists);

        final loadedExercises = await storageService.loadExercises();
        final loadedWorkouts = await storageService.loadWorkouts();
        final loadedChecklists = await storageService.loadChecklists();

        expect(loadedExercises.length, 1);
        expect(loadedWorkouts.length, 1);
        expect(loadedChecklists.length, 1);
      },
    );
  });
}
