import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/workout.dart';

/// Reports that the raw data stored under [key] couldn't be parsed back
/// into its model, so it was treated as empty.
typedef CorruptDataReporter = void Function(
  String key,
  Object error,
  StackTrace stackTrace,
);

class StorageService {
  StorageService({CorruptDataReporter? onCorruptData})
      : _onCorruptData = onCorruptData ?? _logCorruptData;

  static const String _workoutsKey = 'workouts';
  static const String _exercisesKey = 'exercises';
  static const String _routinesKey = 'routines';

  final CorruptDataReporter _onCorruptData;

  static void _logCorruptData(String key, Object error, StackTrace stackTrace) {
    developer.log(
      'Discarding corrupted persisted data for key "$key"',
      name: 'StorageService',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  Future<List<T>> _loadList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);

      if (jsonString == null) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _onCorruptData(key, e, stackTrace);
      return [];
    }
  }

  Future<void> _saveList<T>(
    String key,
    List<T> items,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map(toJson).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  Future<List<Workout>> loadWorkouts() =>
      _loadList(_workoutsKey, Workout.fromJson);

  Future<void> saveWorkouts(List<Workout> workouts) =>
      _saveList(_workoutsKey, workouts, (w) => w.toJson());

  Future<List<Exercise>> loadExercises() =>
      _loadList(_exercisesKey, Exercise.fromJson);

  Future<void> saveExercises(List<Exercise> exercises) =>
      _saveList(_exercisesKey, exercises, (e) => e.toJson());

  Future<List<Routine>> loadRoutines() =>
      _loadList(_routinesKey, Routine.fromJson);

  Future<void> saveRoutines(List<Routine> routines) =>
      _saveList(_routinesKey, routines, (r) => r.toJson());
}
