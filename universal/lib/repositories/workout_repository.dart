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
  }) : _storage = storage ?? StorageService(),
       _workouts = initialWorkouts,
       _exercises = initialExercises;

  final StorageService _storage;
  List<Workout>? _workouts;
  List<Exercise>? _exercises;

  List<Workout> get workouts => _workouts ?? [];
  List<Exercise> get exercises => _exercises ?? [];
  bool get isLoaded => _workouts != null;

  Future<void> load() async {
    if (_workouts != null) return;
    _workouts = await _storage.loadWorkouts();
    _exercises = await _storage.loadExercises();
    notifyListeners();
  }

  void startWorkout({String? routineId}) {
    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      routineId: routineId,
    );
    _workouts = [...workouts, workout];
    _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  ExerciseEntry? addExerciseEntry(String workoutId, String name) {
    if (!workouts.any((w) => w.id == workoutId)) return null;

    final exercise = Exercise.resolve(name, exercises);
    if (exercise == null) return null;

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
    return entry;
  }

  void addSet({
    required String workoutId,
    required String entryId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _mutateWorkout(
      workoutId,
      (workout) =>
          workout.addSet(entryId: entryId, weight: weight, unit: unit, reps: reps),
    );
  }

  void editSet({
    required String workoutId,
    required String entryId,
    required String setId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _mutateWorkout(
      workoutId,
      (workout) => workout.editSet(
        entryId: entryId,
        setId: setId,
        weight: weight,
        unit: unit,
        reps: reps,
      ),
    );
  }

  void deleteSet({
    required String workoutId,
    required String entryId,
    required String setId,
  }) {
    _mutateWorkout(
      workoutId,
      (workout) => workout.deleteSet(entryId: entryId, setId: setId),
    );
  }

  void deleteExerciseEntry({
    required String workoutId,
    required String entryId,
  }) {
    _mutateWorkout(
      workoutId,
      (workout) => workout.deleteExerciseEntry(entryId: entryId),
    );
  }

  void finishWorkout(String workoutId) {
    final index = workouts.indexWhere((w) => w.id == workoutId);
    if (index == -1) return;

    final finished = workouts[index].finish();
    if (finished == null) return;

    _replaceWorkout(workoutId, (_) => finished);
    notifyListeners();
  }

  void discardWorkout(String workoutId) {
    if (!workouts.any((w) => w.id == workoutId && w.isInProgress)) return;

    _workouts = workouts.where((w) => w.id != workoutId).toList();
    _storage.saveWorkouts(workouts);
    notifyListeners();
  }

  void renameExercise(String exerciseId, String newName) {
    final index = exercises.indexWhere((e) => e.id == exerciseId);
    if (index == -1) return;
    if (exercises[index].validateRename(newName, exercises) != null) return;

    _exercises = exercises
        .map((e) => e.id == exerciseId ? e.copyWith(name: newName.trim()) : e)
        .toList();
    _storage.saveExercises(exercises);
    notifyListeners();
  }

  /// Replaces the Workout matching [workoutId] via [_replaceWorkout] and
  /// notifies listeners only if a match was found.
  void _mutateWorkout(String workoutId, Workout Function(Workout) update) {
    if (_replaceWorkout(workoutId, update)) notifyListeners();
  }

  /// Replaces the Workout matching [workoutId], persisting and returning
  /// `true` only if a match was found — a no-op otherwise, so callers don't
  /// persist or notify for an id that doesn't exist.
  bool _replaceWorkout(String workoutId, Workout Function(Workout) update) {
    if (!workouts.any((w) => w.id == workoutId)) return false;

    _workouts = workouts.map((w) => w.id == workoutId ? update(w) : w).toList();
    _storage.saveWorkouts(workouts);
    return true;
  }
}
