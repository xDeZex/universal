import 'package:universal/models/exercise.dart';
import 'package:universal/models/routine.dart';
import 'package:universal/models/workout.dart';
import 'package:universal/repositories/workout_repository.dart';
import 'package:universal/services/storage_service.dart';

/// Attaches a listener to [repository] and returns a closure reporting
/// whether it has fired since this call.
bool Function() trackNotifications(WorkoutRepository repository) {
  var notified = false;
  repository.addListener(() => notified = true);
  return () => notified;
}

Future<T> _flushAndLoad<T>(Future<T> Function() loader) async {
  await Future<void>.delayed(Duration.zero);
  return loader();
}

/// Waits for the repository's fire-and-forget persistence to complete, then
/// reloads workouts from a fresh [StorageService].
Future<List<Workout>> flushAndLoadWorkouts() =>
    _flushAndLoad(StorageService().loadWorkouts);

/// Waits for the repository's fire-and-forget persistence to complete, then
/// reloads exercises from a fresh [StorageService].
Future<List<Exercise>> flushAndLoadExercises() =>
    _flushAndLoad(StorageService().loadExercises);

/// Waits for the repository's fire-and-forget persistence to complete, then
/// reloads routines from a fresh [StorageService].
Future<List<Routine>> flushAndLoadRoutines() =>
    _flushAndLoad(StorageService().loadRoutines);
