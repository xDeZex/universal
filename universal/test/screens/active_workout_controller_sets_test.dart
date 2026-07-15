import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal/models/exercise.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/screens/active_workout_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ActiveWorkoutController makeController({
    required Workout workout,
    List<Exercise> exercises = const [],
  }) {
    final repository = WorkoutRepository(
      initialWorkouts: [workout],
      initialExercises: exercises,
    );
    return ActiveWorkoutController(
      repository: repository,
      workoutId: workout.id,
    );
  }

  group('ActiveWorkoutController unit stickiness', () {
    test('unitFor defaults to kg for an Entry with no remembered unit', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);

      expect(controller.unitFor('entry-1'), WeightUnit.kg);
    });

    test('setEntryUnit remembers the unit for that Entry and notifies', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setEntryUnit('entry-1', WeightUnit.lbs);

      expect(controller.unitFor('entry-1'), WeightUnit.lbs);
      expect(notified, isTrue);
    });

    test('addSet remembers the unit used for that Entry', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.addSet(
        entryId: 'entry-1',
        weight: 100,
        unit: WeightUnit.lbs,
        reps: 5,
      );

      expect(controller.unitFor('entry-1'), WeightUnit.lbs);
    });

    test('editSet remembers the unit used for that Entry', () {
      final entry = ExerciseEntry(
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
      );
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.editSet(
        entryId: 'entry-1',
        setId: 'set-1',
        weight: 65,
        unit: WeightUnit.lbs,
        reps: 6,
      );

      expect(controller.unitFor('entry-1'), WeightUnit.lbs);
    });
  });

  group('ActiveWorkoutController Set CRUD', () {
    test('addSet adds a Set to the Exercise Entry and persists the Workout', () {
      final entry = ExerciseEntry(id: 'entry-1', exerciseId: 'exercise-1');
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.addSet(
        entryId: 'entry-1',
        weight: 60,
        unit: WeightUnit.kg,
        reps: 8,
      );

      final sets = controller.workout!.exerciseEntries.single.sets;
      expect(sets.single.weight, 60);
      expect(sets.single.reps, 8);
    });

    test('editSet updates an existing Set', () {
      final entry = ExerciseEntry(
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
      );
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.editSet(
        entryId: 'entry-1',
        setId: 'set-1',
        weight: 65,
        unit: WeightUnit.kg,
        reps: 6,
      );

      final updated = controller.workout!.exerciseEntries.single.sets.single;
      expect(updated.weight, 65);
      expect(updated.reps, 6);
    });

    test('deleteSet removes a Set from its Exercise Entry', () {
      final entry = ExerciseEntry(
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
      );
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.deleteSet(entryId: 'entry-1', setId: 'set-1');

      expect(controller.workout!.exerciseEntries.single.sets, isEmpty);
    });
  });

  group('ActiveWorkoutController.finish / discard', () {
    test('finish is a no-op while the Workout has zero logged Sets', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);

      controller.finish();

      expect(controller.workout!.isInProgress, isTrue);
    });

    test('finish marks the Workout finished once it has a logged Set', () {
      final entry = ExerciseEntry(
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
      );
      final workout = Workout(
        id: 'workout-1',
        startTime: DateTime(2026, 1, 1),
        exerciseEntries: [entry],
      );
      final controller = makeController(workout: workout);

      controller.finish();

      expect(controller.workout!.isInProgress, isFalse);
    });

    test('discard removes the Workout from the repository', () {
      final workout = Workout(id: 'workout-1', startTime: DateTime(2026, 1, 1));
      final controller = makeController(workout: workout);

      controller.discard();

      expect(controller.workout, isNull);
    });
  });
}
