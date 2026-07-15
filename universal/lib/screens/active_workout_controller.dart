import 'package:flutter/foundation.dart';

import '../models/workout.dart';
import '../repositories/workout_repository.dart';

/// Non-rendering logic for [ActiveWorkoutScreen]: Set/Exercise Entry CRUD,
/// Exercise Entry selection, and per-Entry unit stickiness. The screen
/// renders this state and forwards taps into it.
class ActiveWorkoutController extends ChangeNotifier {
  ActiveWorkoutController({required this._repository, required this.workoutId});

  final WorkoutRepository _repository;
  final String workoutId;

  String? _selectedEntryId;
  String? get selectedEntryId => _selectedEntryId;

  final Map<String, WeightUnit> _entryUnits = {};

  Workout? get workout {
    for (final workout in _repository.workouts) {
      if (workout.id == workoutId) return workout;
    }
    return null;
  }

  bool canAddNew(Workout workout) => workout.isInProgress;

  bool hasLoggedSets(Workout workout) =>
      workout.exerciseEntries.any((entry) => entry.sets.isNotEmpty);

  WeightUnit unitFor(String entryId) => _entryUnits[entryId] ?? WeightUnit.kg;

  ExerciseEntry? addExerciseEntry(String name) {
    final entry = _repository.addExerciseEntry(workoutId, name);
    if (entry != null) {
      _selectedEntryId = entry.id;
      notifyListeners();
    }
    return entry;
  }

  void selectEntry(String entryId) {
    _selectedEntryId = entryId;
    notifyListeners();
  }

  void setEntryUnit(String entryId, WeightUnit unit) {
    _entryUnits[entryId] = unit;
    notifyListeners();
  }

  void addSet({
    required String entryId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _repository.addSet(
      workoutId: workoutId,
      entryId: entryId,
      weight: weight,
      unit: unit,
      reps: reps,
    );
    _entryUnits[entryId] = unit;
    notifyListeners();
  }

  void editSet({
    required String entryId,
    required String setId,
    required num weight,
    required WeightUnit unit,
    required int reps,
  }) {
    _repository.editSet(
      workoutId: workoutId,
      entryId: entryId,
      setId: setId,
      weight: weight,
      unit: unit,
      reps: reps,
    );
    _entryUnits[entryId] = unit;
    notifyListeners();
  }

  void deleteSet({required String entryId, required String setId}) {
    _repository.deleteSet(workoutId: workoutId, entryId: entryId, setId: setId);
  }

  void deleteExerciseEntry(String entryId) {
    _repository.deleteExerciseEntry(workoutId: workoutId, entryId: entryId);
    if (_selectedEntryId == entryId) {
      _selectedEntryId = null;
      notifyListeners();
    }
  }

  void finish() {
    final current = workout;
    if (current == null || !hasLoggedSets(current)) return;
    _repository.finishWorkout(workoutId);
  }

  void discard() {
    _repository.discardWorkout(workoutId);
  }
}
