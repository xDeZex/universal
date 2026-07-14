import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/workout.dart';
import '../services/storage_service.dart';

/// Owns the in-memory Workout and Exercise lists, wrapping [StorageService]
/// for load/save, mirroring the [ChangeNotifier] shape of `UpdateService`.
class WorkoutRepository extends ChangeNotifier {
  WorkoutRepository({
    StorageService? storage,
    List<Workout>? initialWorkouts,
    List<Exercise>? initialExercises,
  })  : _storage = storage ?? StorageService(),
        _workouts = initialWorkouts,
        _exercises = initialExercises;

  final StorageService _storage;
  List<Workout>? _workouts;
  List<Exercise>? _exercises;

  List<Workout> get workouts => _workouts ?? [];
  List<Exercise> get exercises => _exercises ?? [];

  Future<void> load() async {
    if (_workouts != null) return;
    _workouts = await _storage.loadWorkouts();
    _exercises = await _storage.loadExercises();
    notifyListeners();
  }

  void startWorkout() {
    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );
    _workouts = [...workouts, workout];
    _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  void addExerciseEntry(String workoutId, String name) {
    final exercise = Exercise.resolve(name, exercises);
    if (exercise == null) return;

    final isNewExercise = !exercises.any((e) => e.id == exercise.id);
    final entry = ExerciseEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      exerciseId: exercise.id,
    );

    _replaceWorkout(
      workoutId,
      (workout) => workout.copyWith(
        exerciseEntries: [...workout.exerciseEntries, entry],
      ),
    );
    if (isNewExercise) {
      _exercises = [...exercises, exercise];
      _storage.saveExercises(exercises);
    }
    notifyListeners();
  }

  void addSet({
    required String workoutId,
    required String entryId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _replaceWorkout(
      workoutId,
      (workout) =>
          workout.addSet(entryId: entryId, weight: weight, unit: unit, reps: reps),
    );
    notifyListeners();
  }

  void editSet({
    required String workoutId,
    required String entryId,
    required String setId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _replaceWorkout(
      workoutId,
      (workout) => workout.editSet(
        entryId: entryId,
        setId: setId,
        weight: weight,
        unit: unit,
        reps: reps,
      ),
    );
    notifyListeners();
  }

  void deleteSet({
    required String workoutId,
    required String entryId,
    required String setId,
  }) {
    _replaceWorkout(
      workoutId,
      (workout) => workout.deleteSet(entryId: entryId, setId: setId),
    );
    notifyListeners();
  }

  void deleteExerciseEntry({required String workoutId, required String entryId}) {
    _replaceWorkout(
      workoutId,
      (workout) => workout.deleteExerciseEntry(entryId: entryId),
    );
    notifyListeners();
  }

  void finishWorkout(String workoutId) {
    final workout = workouts.firstWhere((w) => w.id == workoutId);
    final finished = workout.finish();
    if (finished == null) return;

    _replaceWorkout(workoutId, (_) => finished);
    notifyListeners();
  }

  void discardWorkout(String workoutId) {
    _workouts = workouts.where((w) => w.id != workoutId).toList();
    _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  void renameExercise(String exerciseId, String newName) {
    final exercise = exercises.firstWhere((e) => e.id == exerciseId);
    if (exercise.validateRename(newName, exercises) != null) return;

    _exercises = exercises
        .map((e) => e.id == exerciseId ? e.copyWith(name: newName.trim()) : e)
        .toList();
    _storage.saveExercises(exercises);
    notifyListeners();
  }

  void _replaceWorkout(String workoutId, Workout Function(Workout) update) {
    _workouts = workouts
        .map((w) => w.id == workoutId ? update(w) : w)
        .toList();
    _storage.saveWorkouts(workouts);
  }
}
