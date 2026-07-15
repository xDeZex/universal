import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_controller.dart';

import 'active_workout_controller_test_helpers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ActiveWorkoutController.workout', () {
    test('resolves the Workout matching workoutId from the repository', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);

      expect(controller.workout?.id, 'workout-1');
    });

    test('is null once the Workout is no longer in the repository', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final repository = WorkoutRepository(
        initialWorkouts: [workout],
        initialExercises: const [],
      );
      final controller = ActiveWorkoutController(
        repository: repository,
        workoutId: 'workout-1',
      );

      repository.discardWorkout('workout-1');

      expect(controller.workout, isNull);
    });
  });

  group('ActiveWorkoutController.canAddNew / hasLoggedSets', () {
    test('canAddNew is true for an in-progress Workout', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);

      expect(controller.canAddNew(workout), isTrue);
    });

    test('canAddNew is false for a finished Workout', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        endTime: DateTime(2026, 1, 1, 1),
      );
      final controller = makeController(workout: workout);

      expect(controller.canAddNew(workout), isFalse);
    });

    test('hasLoggedSets is false when no Exercise Entry has a Set', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [
          ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1'),
        ],
      );
      final controller = makeController(workout: workout);

      expect(controller.hasLoggedSets(workout), isFalse);
    });

    test('hasLoggedSets is true once any Exercise Entry has a Set', () {
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [
          ExerciseEntry(
            id: 'entry-1',
            exerciseId: 'exercise-1',
            sets: [
              ExerciseSet(
                id: 'set-1',
                weight: 60,
                unit: WeightUnit.kg,
                reps: 8,
                loggedAt: DateTime(2026, 1, 1, 10),
              ),
            ],
          ),
        ],
      );
      final controller = makeController(workout: workout);

      expect(controller.hasLoggedSets(workout), isTrue);
    });
  });

  group('ActiveWorkoutController.addExerciseEntry', () {
    test(
      'a valid name adds an Exercise Entry, returns it, and selects it',
      () {
        final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
        final controller = makeController(workout: workout);

        final entry = controller.addExerciseEntry('Bench Press');

        expect(entry, isNotNull);
        expect(controller.workout!.exerciseEntries.single.id, entry!.id);
        expect(controller.selectedEntryId, entry.id);
      },
    );

    test(
      'a name matching an existing Exercise case-insensitively reuses it',
      () {
        final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
        final existing = Exercise(id: 'exercise-1', name: 'Bench Press');
        final controller = makeController(
          workout: workout,
          exercises: [existing],
        );

        final entry = controller.addExerciseEntry('bench press');

        expect(entry!.exerciseId, 'exercise-1');
      },
    );

    test(
      'a blank name is rejected: returns null, adds nothing, selects nothing',
      () {
        final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
        final controller = makeController(workout: workout);

        final entry = controller.addExerciseEntry('   ');

        expect(entry, isNull);
        expect(controller.workout!.exerciseEntries, isEmpty);
        expect(controller.selectedEntryId, isNull);
      },
    );

    test('notifies listeners only when an Entry is actually added', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.addExerciseEntry('   ');
      expect(notifications, 0);

      controller.addExerciseEntry('Bench Press');
      expect(notifications, 1);
    });
  });

  group('ActiveWorkoutController selection', () {
    test('selectEntry sets selectedEntryId and notifies listeners', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);
      var notified = false;
      controller.addListener(() => notified = true);

      controller.selectEntry('entry-1');

      expect(controller.selectedEntryId, 'entry-1');
      expect(notified, isTrue);
    });

    test(
      'deleteExerciseEntry clears the selection when the deleted Entry was '
      'selected',
      () {
        final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry],
        );
        final controller = makeController(workout: workout);
        controller.selectEntry('entry-1');

        controller.deleteExerciseEntry('entry-1');

        expect(controller.selectedEntryId, isNull);
        expect(controller.workout!.exerciseEntries, isEmpty);
      },
    );

    test(
      'deleteExerciseEntry leaves an unrelated selection unchanged',
      () {
        final entry1 = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
        final entry2 = ExerciseEntry(id: 'entry-2', exerciseId: 'exercise-2');
        final workout = Workout(
          id: 'workout-1',
          startTime: DateTime(2026, 1, 1),
          exerciseEntries: [entry1, entry2],
        );
        final controller = makeController(workout: workout);
        controller.selectEntry('entry-1');

        controller.deleteExerciseEntry('entry-2');

        expect(controller.selectedEntryId, 'entry-1');
      },
    );
  });
}
