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
}
